/*ensure one customer can only choose food in one retaurant*/
CREATE OR REPLACE FUNCTION check_restaurant () RETURNS TRIGGER AS $$
DECLARE
	restaurant		INTEGER;
BEGIN
	SELECT C.restaurantId INTO restaurant
		FROM Carts C
		WHERE NEW.cartId = C.cartId AND NEW.restaurantId <> C.restaurantId;
	IF restaurant IS NOT NULL THEN
		RAISE exception 'Food are from different restaurants';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_restaurant_trigger ON Carts CASCADE;
CREATE TRIGGER check_restaurant_trigger
	BEFORE INSERT
	ON Carts
	FOR EACH ROW
	EXECUTE FUNCTION check_restaurant();

/*ensure every slot does not exceed 4 hours*/
CREATE OR REPLACE FUNCTION check_work_slot() RETURNS TRIGGER AS $$
BEGIN
	IF NEW.endTime > NEW.startTime THEN
		RAISE exception 'Working slot on % from %:00 to %:00 exceeds 4 hours', NEW.weekday, NEW.startTime, NEW.endTime;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_work_slot_trigger ON WWS_Schedules CASCADE;
CREATE TRIGGER check_work_slot_trigger
	BEFORE UPDATE OF startTime, endTime OR INSERT
	ON WWS_Schedules
	FOR EACH ROW
	EXECUTE FUNCTION check_work_slot();

/*ensure total working hour >= 10 and <= 48*/
CREATE OR REPLACE FUNCTION check_total_work_hour () RETURNS TRIGGER AS $$
DECLARE
	total_work_hour		INTEGER;
BEGIN
	SELECT sum (endTime - startTime) INTO total_work_hour
	FROM WWS_Schedules W
	WHERE NEW.workId = W.workId;

	IF total_work_hour < 10 THEN
		RAISE exception 'Total working hour within one week is less than 10 hours';
	ELSIF total_work_hour > 48 THEN
		RAISE exception 'Total working hour within one week is larger than 48 hours';
	ELSE
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_total_work_hour_trigger ON WWS_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER check_total_work_hour_trigger
	AFTER UPDATE OF workId, startTime, endTime OR INSERT
	ON WWS_Schedules
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE FUNCTION check_total_work_hour();

/*ensure there is a break between two slots*/
CREATE OR REPLACE FUNCTION check_break() RETURNS TRIGGER AS $$
DECLARE
	slot_start	WWS_Schedules%ROWTYPE;
	slot_end	WWS_Schedules%ROWTYPE;
BEGIN
	SELECT * INTO slot_start
	FROM WWS_Schedules W, WWS_Schedules W2
	WHERE NEW.workId = W.workId AND NEW.workId = W2.workId
	AND NEW.weekday = W.weekday AND NEW.weekday = W2.weekday
	AND NEW.startTime = W.startTime AND NEW.startTime >= W2.endTime;

	SELECT * INTO slot_end
	FROM WWS_Schedules W, WWS_Schedules W2
	WHERE NEW.workId = W.workId AND NEW.workId = W2.workId
	AND NEW.weekday = W.weekday AND NEW.weekday = W2.weekday
	AND NEW.endTime = W.endTime AND NEW.endTime <= W2.startTime;

	IF slot_start IS NOT NULL THEN
		RAISE exception 'There is no break between two slots %:00-%:00 and %:00-%:00 on %', 
		slot_start.startTime, slot_start.endTime, NEW.startTime, NEW.endTime, NEW.weekday;
	END IF;

	IF slot_end IS NOT NULL THEN
		RAISE exception 'There is no break between two slots %:00-%:00 and %:00-%:00 on %',
		NEW.startTime, NEW.endTime, slot_end.startTime, slot_end.endTime, NEW.weekday;
	END IF;

END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_break_trigger ON WWS_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER check_break_trigger
	AFTER UPDATE OF weekday, startTime, endTime OR INSERT
	ON WWS_Schedules
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE FUNCTION check_break();

/*ensure that food in cart has enough availability*/
CREATE OR REPLACE FUNCTION check_food_availability () RETURNS TRIGGER AS $$
DECLARE
	availability 		INTEGER;
BEGIN
	SELECT quantity INTO availability
	FROM Foods
	WHERE NEW.foodId = Foods.foodId;

	IF availability < NEW.quantity THEN
		RAISE exception 'There are only % available', availability;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_food_availability_trigger ON Carts CASCADE;
CREATE TRIGGER check_food_availability_trigger
	BEFORE UPDATE OF foodId, quantity OR INSERT
	ON Carts
	FOR EACH ROW
	EXECUTE FUNCTION check_food_availability ();

/*ensures each customer only has 5 location records*/
CREATE OR REPLACE FUNCTION check_customer_locations () RETURNS TRIGGER AS $$
DECLARE
	location_count INTEGER;
BEGIN
	SELECT COUNT(*) INTO location_count
	FROM RecentLocations R
	WHERE R.customerId = NEW.customerId;

	IF location_count > 5 THEN
		DELETE FROM RecentLocations R
		WHERE R.lastUsingTime <= ALL (
		SELECT R1.lastUsingTime
		FROM RecentLocations R1
		WHERE R1.customerId = NEW.customerId
		);
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_customer_locations ON RecentLocations;
CREATE CONSTRAINT TRIGGER check_customer_locations
	AFTER INSERT ON RecentLocations
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW 
	EXECUTE FUNCTION check_customer_locations ();


/*ensure every hour interval has at least 5 riders*/
/*CREATE OR REPLACE FUNCTION check_num_of_riders RETURNS TRIGGER AS $$
DECLARE
	weekday			WWS_Schedules.weekday%TYPE;
BEGIN
	
END;
$$ LANGUAGE plpgsql;	

DROP TRIGGER IF EXISTS check_num_of_riders_trigger_part ON WWS_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER check_num_of_riders_trigger_part
	AFTER UPDATE OF weekday, startTime, endTime OR DELETE
	ON WWS_Schedules
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE FUNCTION check_num_of_riders();

DROP TRIGGER IF EXISTS check_num_of_riders_trigger_full ON MWS CASCADE;
CREATE CONSTRAINT TRIGGER check_num_of_riders_trigger_full
	AFTER UPDATE OF workDays, shifts OR DELETE
	ON MWS
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE FUNCTION check_num_of_riders();
*/


/* checks whether there are atleast 5 riders for every hour on the current day*/
DROP FUNCTION IF EXISTS check_num_of_riders();
CREATE OR REPLACE FUNCTION check_num_of_riders()
RETURNS TRIGGER
AS $$
  DECLARE
      todays_date date;
      valid integer := 0;
      riderCount INTEGER;
  BEGIN
    SELECT NOW()::TIMESTAMP::DATE INTO todays_date;

  FOR checkTime IN 10..22 LOOP
    SELECT COUNT(DISTINCT WS.workId) INTO riderCount
    FROM  WWS_Schedules WS
    WHERE (SELECT W.date::timestamp::date FROM WWS W WHERE W.workid = WS.workid) = todays_date
    AND checkTime >= WS.startTime
    AND checkTime <= WS.endTime
    ;
    IF riderCount < 5 THEN
      RAISE EXCEPTION 'DAY: % | TIME : % HAS NOT ENOUGH RIDERS', todays_date, checkTime;
    END IF;
  END LOOP;
  END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_num_of_riders ON WWS_Schedules;
CREATE CONSTRAINT TRIGGER check_num_of_riders
	AFTER INSERT OR DELETE OR UPDATE ON WWS_Schedules DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE FUNCTION check_num_of_riders();

/*Adds reward points to customers upon order*/
CREATE OR REPLACE FUNCTION customer_add_points()
RETURNS TRIGGER
AS $$
	DECLARE
		curr_points INTEGER := 0;
		total_points INTEGER;
	BEGIN
		SELECT C.rewardPoints INTO curr_points
		FROM Customers C
		WHERE C.customerId = NEW.customerId
		;
		total_points := curr_points + FLOOR(NEW.foodFee);

		UPDATE Customers SET rewardPoints = total_points WHERE customerId = NEW.customerId;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS customers_add_points ON Orders;
CREATE TRIGGER customer_add_points
	AFTER INSERT OR UPDATE ON Orders
	FOR EACH ROW
	EXECUTE FUNCTION customer_add_points();

/* Checks whether order meets restaurants min */
CREATE OR REPLACE FUNCTION check_min_fee()
RETURNS TRIGGER
AS $$
	DECLARE
		restaurant_min INTEGER := 0;
	BEGIN
		SELECT R.minOrderCost INTO restaurant_min
		FROM Restaurants R
		WHERE R.restaurantId = NEW.restaurantId
		;

		IF NEW.foodFee < restaurant_min THEN
			RAISE EXCEPTION 'ORDER AMOUNT % DOES NOT MEET RESTAURANTS MIN ORDER OF %', NEW.foodFee, restaurant_min;
		ELSE
			RETURN NEW;
		END IF;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_min_fee ON Orders;
CREATE TRIGGER check_min_fee
	BEFORE INSERT OR UPDATE ON Orders 
	FOR EACH ROW
	EXECUTE FUNCTION check_min_fee();

