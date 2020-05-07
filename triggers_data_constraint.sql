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
	IF NEW.endTime - NEW.startTime > 4 THEN
		RAISE exception 'Working slot on % from %:00 to %:00 exceeds 4 hours', NEW.weekday, NEW.startTime, NEW.endTime;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_work_slot_trigger ON WWS_Schedules CASCADE;
CREATE TRIGGER check_work_slot_trigger
	BEFORE UPDATE OF startTime, endTime OR INSERT ON WWS_Schedules
	FOR EACH ROW
	EXECUTE FUNCTION check_work_slot();

/*ensure total working hour > 48*/
CREATE OR REPLACE FUNCTION check_total_work_hour_upper () RETURNS TRIGGER AS $$
DECLARE
	total_work_hour		INTEGER;
BEGIN
	SELECT sum (endTime - startTime) INTO total_work_hour
	FROM WWS_Schedules W
	WHERE NEW.workId = W.workId;

	IF total_work_hour > 48 THEN
		RAISE exception 'Total working hour within one week is larger than 48 hours';
	ELSE
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_total_work_hour_trigger_upper ON WWS_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER check_total_work_hour_trigger_upper
	AFTER UPDATE OF workId, startTime, endTime OR INSERT
	ON WWS_Schedules
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE FUNCTION check_total_work_hour_upper();

/*ensures that working hour < 10*/
CREATE OR REPLACE FUNCTION check_total_work_hour_lower () RETURNS TRIGGER AS $$
DECLARE
	total_work_hour		INTEGER;
BEGIN
	SELECT sum (endTime - startTime) INTO total_work_hour
	FROM WWS_Schedules W
	WHERE NEW.workId = W.workId;

	IF total_work_hour < 48 THEN
		RAISE exception 'Total working hour within one week is less than 10 hours';
	ELSE
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_total_work_hour_trigger_lower ON WWS_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER check_total_work_hour_trigger_lower
	AFTER UPDATE OF workId, startTime, endTime OR DELETE
	ON WWS_Schedules
	DEFERRABLE INITIALLY DEFERRED
	FOR EACH ROW
	EXECUTE FUNCTION check_total_work_hour_lower();

/*ensure there is a break between two slots*/
/*CREATE OR REPLACE FUNCTION check_break() RETURNS TRIGGER AS $$
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

	RETURN NEW;

END;
$$ LANGUAGE plpgsql;*/

CREATE OR REPLACE FUNCTION check_break() RETURNS TRIGGER AS $$
DECLARE
	invalidSchedule BOOLEAN := false;
BEGIN
	SELECT TRUE INTO invalidSchedule
	FROM WWS_Schedules WS
	WHERE WS.workId = NEW.workId
	AND WS.startTime <> NEW.startTime
	AND WS.endTime <> NEW.endTime
	AND WS.weekday = NEW.weekday
	AND ((WS.startTime = WS.endTime)
	OR (WS.endTime = NEW.startTime))
	;

	IF invalidSchedule THEN
		RAISE EXCEPTION 'There is no break between existing slots';
	ELSE
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_break_trigger ON WWS_Schedules CASCADE;
CREATE TRIGGER check_break_trigger
	BEFORE UPDATE OF weekday, startTime, endTime OR INSERT ON WWS_Schedules
	FOR EACH ROW
	EXECUTE FUNCTION check_break();

/*ensure that food in cart has enough availability, if 0 set availability to false*/
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

	IF availability = 0 THEN
		UPDATE Foods SET issold = FALSE WHERE foodid = NEW.foodId;
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
	AFTER DELETE ON WWS_Schedules DEFERRABLE INITIALLY DEFERRED
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

DROP TRIGGER IF EXISTS customers_add_points ON Orderlogs;
CREATE TRIGGER customer_add_points
	AFTER INSERT OR UPDATE ON Orderlogs
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

DROP TRIGGER IF EXISTS check_min_fee ON Orderlogs;
CREATE TRIGGER check_min_fee
	BEFORE INSERT OR UPDATE ON Orderlogs 
	FOR EACH ROW
	EXECUTE FUNCTION check_min_fee();

/* Ensues that there are no overlapping schedules upon insertion/update of WWS_Schedules*/
CREATE OR REPLACE FUNCTION check_schedule_overlap()
RETURNS TRIGGER
AS $$
	DECLARE
		invalidSchedule BOOLEAN := FALSE;
	BEGIN
		SELECT TRUE INTO invalidSchedule
		FROM WWS_Schedules WS
		WHERE WS.workId = NEW.workId
		AND (WS.weekday = NEW.weekday AND NEW.startTime >= WS.startTime AND NEW.startTime < WS.endTime)
		OR (WS.weekday = NEW.weekday AND NEW.endTime > WS.startTime AND NEW.endTime <= WS.endTime)
		;

		IF invalidSchedule THEN
			RAISE EXCEPTION 'SCHEDULE OVERLAP DETECTED';
		ELSE
			RETURN NEW;
		END IF;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_schedule_overlap ON WWS_Schedules;
CREATE TRIGGER check_schedule_overlap
	BEFORE INSERT ON WWS_Schedules
	FOR EACH ROW
	EXECUTE FUNCTION check_schedule_overlap();


/* Ensures that when adding to WWS, adding schedule to FUTURE(no schedule yet) not PAST */
CREATE OR REPLACE FUNCTION check_wws_future_1()
RETURNS TRIGGER
AS $$
	DECLARE
		invalidSchedule BOOLEAN := FALSE;
	BEGIN
		SELECT TRUE INTO invalidSchedule
		FROM WWS W
		WHERE W.workId <> NEW.workId
		AND W.riderId = NEW.riderId
		AND (NEW.startDate < NOW() OR NEW.startDate < W.endDate)
		;

		IF invalidSchedule THEN
			RAISE EXCEPTION 'StartDate invalid due to an already existing schedule';
		ELSE
			RETURN NEW;
		END IF;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_wws_future_1 ON WWS;
CREATE TRIGGER check_wws_future_1
	BEFORE INSERT OR UPDATE OF startDate ON WWS
	FOR EACH ROW
	EXECUTE FUNCTION check_wws_future_1();

/*Adds an end date to the last entry in WWS*/
CREATE OR REPLACE FUNCTION valid_wws_addition()
RETURNS TRIGGER
AS $$
	DECLARE
		pId INTEGER;
	BEGIN
		SELECT W.workId INTO pId
		FROM WWS W
		WHERE W.workId <> NEW.workId
		AND W.riderId = NEW.riderId
		AND W.endDate IS NULL
		;

		IF pid IS NOT NULL THEN
			UPDATE WWS SET endDate = NEW.startDate - 1 WHERE workId = pId;
			
		END IF;

		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS valid_wws_addition ON WWS;
CREATE TRIGGER valid_wws_addition
	AFTER INSERT ON WWS
	FOR EACH ROW
	EXECUTE FUNCTION valid_wws_addition();