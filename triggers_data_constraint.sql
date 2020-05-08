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

	IF availability = 0 THEN
		UPDATE Foods SET issold = FALSE WHERE foodid = NEW.foodId ;
		RAISE exception 'Food item % is currently sold out', NEW.foodId;
	ELSIF availability < NEW.quantity THEN
		RAISE exception 'There are only % available for foodId %', availability, NEW.foodId;
	ELSE
		UPDATE Foods SET quantity = availability - NEW.quantity WHERE foodId = NEW.foodId;
		RAISE NOTICE 'Updated Food ID % qty from % to %', NEW.foodId, availability, availability - NEW.quantity;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_food_availability_trigger ON Orders CASCADE;
CREATE TRIGGER check_food_availability_trigger
	BEFORE UPDATE OF foodId, quantity OR INSERT
	ON Orders
	FOR EACH ROW
	EXECUTE FUNCTION check_food_availability ();

CREATE OR REPLACE FUNCTION check_food_restaurant_validity () 
RETURNS TRIGGER 
AS $$
	DECLARE
		valid BOOLEAN;
		rId INTEGER;
	BEGIN
		SELECT OL.restaurantid INTO rId
		FROM Orderlogs OL
		WHERE OL.orderId = NEW.orderId
		;

		RAISE NOTICE 'ORDER ID IS %, RESTAURANT ID IS %', NEW.orderId, rId;

		SELECT TRUE INTO VALID
		FROM Foods F
		WHERE F.foodId = NEW.foodId
		AND F.restaurantId = rId
		;



		/*WITH restFoodPair AS (
			SELECT DISTINCT R.restaurantId, O.foodId 
			FROM Orders O JOIN Orderlogs R 
			ON R.orderid = NEW.orderid
		)
		SELECT TRUE INTO valid
		FROM restFoodPair R
		WHERE EXISTS ( SELECT 1
			FROM Foods F
			WHERE F.foodid = NEW.foodid
			AND F.restaurantid = R.restaurantId
		);*/

		RAISE NOTICE 'IS RESTAURANT FOOD PAIR VALID? %', VALID; 

		IF VALID IS NULL THEN
			RAISE EXCEPTION 'INVALID FOOD RESTAURANT PAIR';
		ELSIF VALID THEN
			RETURN NEW;
		END IF;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_food_restaurant_validity ON Orders CASCADE;
CREATE TRIGGER check_food_restaurant_validity
	BEFORE UPDATE OF foodId, quantity OR INSERT
	ON Orders
	FOR EACH ROW
	EXECUTE FUNCTION check_food_restaurant_validity ();




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

CREATE OR REPLACE FUNCTION check_customer_locations_exists ()
RETURNS TRIGGER 
AS $$
	DECLARE
		locationExists BOOLEAN := FALSE;
	BEGIN
		SELECT TRUE INTO locationExists
		FROM RecentLocations R
		WHERE R.location = NEW.location
		AND R.customerid = NEW.customerid
		;

		IF locationExists THEN
			UPDATE RecentLocations SET lastUsingTime = NEW.lastUsingTime WHERE location = NEW.location and customerid = NEW.customerid;
			RETURN NULL;
		ELSE 
			RETURN NEW;
		END IF;
	END;

$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_customer_locations_exists ON RecentLocations;
CREATE TRIGGER check_customer_locations_exists
	BEFORE INSERT ON RecentLocations
	FOR EACH ROW 
	EXECUTE FUNCTION check_customer_locations_exists();

/* checks whether there are atleast 5 riders for every hour on the current day*/
DROP FUNCTION IF EXISTS check_num_of_riders() CASCADE;
CREATE OR REPLACE FUNCTION check_num_of_riders()
RETURNS TRIGGER
AS $$
  DECLARE
      todays_date date;
      valid integer := 0;
      riderCount INTEGER;
	  dayList varchar[7] := ARRAY['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY'];
  BEGIN
    SELECT NOW()::DATE INTO todays_date;

	FOR dow IN 1..7 LOOP  
		FOR checkTime IN 10..22 LOOP
			WITH active_ws AS( 
				SELECT W.workId, W.riderId
				FROM WWS W
				WHERE W.startDate <= todays_date
				AND (W.endDate >= todays_date OR W.endDate IS NULL)
			)
			SELECT COUNT(DISTINCT A.riderId) INTO riderCount
			FROM active_ws A JOIN WWS_Schedules WS
			ON A.workid = WS.workid
			WHERE WS.weekday = TRIM(to_char(NOW(), 'DAY'))
			AND WS.startTime <= checkTime
			AND WS.endTime > checkTime
			;
			IF riderCount < 5 THEN
				RAISE NOTICE 'DAY: % | TIME : % HAS NOT ENOUGH RIDERS', todays_date, checkTime;
			END IF;

		END LOOP;
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

		UPDATE Customers SET rewardPoints = total_points, orderCount = orderCount + 1, totalexpenditure = totalexpenditure + NEW.foodFee  WHERE customerId = NEW.customerId;
		RETURN NEW;
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
		AND WS.weekday = NEW.weekday
		AND ((NEW.startTime > WS.startTime AND NEW.startTime <= WS.endTime)
		OR (NEW.endTime >= WS.startTime AND NEW.endTime < WS.endTime))
		;

		IF invalidSchedule THEN
			RAISE EXCEPTION 'SCHEDULE OVERLAP DETECTED | DAY: % : %-%', NEW.weekday, NEW.startTime, NEW.endTime;
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
		AND (NEW.startDate < NOW()::DATE OR NEW.startDate < W.endDate)
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


/*Adds an end date to the last entry in WWS*/
CREATE OR REPLACE FUNCTION valid_mws_addition()
RETURNS TRIGGER
AS $$
	DECLARE
		pId INTEGER;
		sDate DATE;
	BEGIN
		SELECT M.riderId, M.startDate INTO pId, sDate
		FROM MWS M
		WHERE m.startDate <> NEW.startDate
		AND M.riderId = NEW.riderId
		AND M.endDate IS NULL
		;

		IF pid IS NOT NULL THEN
			UPDATE MWS SET endDate = NEW.startDate - 1 WHERE riderId = pId AND startDate = sDate;
			
		END IF;

		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS valid_mws_addition ON WWS;
CREATE TRIGGER valid_wws_addition
	AFTER INSERT ON MWS
	FOR EACH ROW
	EXECUTE FUNCTION valid_mws_addition();


/* Ensures that when adding to WWS, adding schedule to FUTURE(no schedule yet) not PAST */
CREATE OR REPLACE FUNCTION check_mws_future_1()
RETURNS TRIGGER
AS $$
	DECLARE
		invalidSchedule BOOLEAN := FALSE;
	BEGIN
		SELECT TRUE INTO invalidSchedule
		FROM MWS M
		WHERE M.startDate <> NEW.startDate
		AND M.riderId = NEW.riderId
		AND (NEW.startDate < NOW()::DATE OR NEW.startDate < M.endDate)
		;

		IF invalidSchedule THEN
			RAISE EXCEPTION 'StartDate invalid due to an already existing schedule';
		ELSE
			RETURN NEW;
		END IF;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_mws_future_1 ON MWS;
CREATE TRIGGER check_mws_future_1
	BEFORE INSERT OR UPDATE OF startDate ON MWS
	FOR EACH ROW
	EXECUTE FUNCTION check_mws_future_1();


/*checks whether a order can be created*/
CREATE OR REPLACE FUNCTION check_order_validity()
RETURNS TRIGGER
AS $$
	DECLARE
		validCc BOOLEAN := FALSE;
		promoType INTEGER;
		validPromoRest BOOLEAN;
	BEGIN
		RAISE NOTICE 'PAYMENT METHOD IS %', NEW.paymentMethod;
		IF NEW.paymentMethod > 2 THEN
			RAISE EXCEPTION 'INVALID PAYMENT METHOD';
		ELSIF NEW.paymentMethod < 1 THEN
			RAISE EXCEPTION 'INVALID PAYMENT METHOD';
		END IF;

		IF NEW.paymentMethod = 1 THEN
			IF NEW.cardNo IS NULL THEN
				RAISE EXCEPTION 'Credit card field cannot be empty, chosen payment method: Credit card';
			END IF;
			SELECT TRUE INTO validCc
			FROM CreditCards C
			WHERE C.customerId = NEW.customerId
			AND C.cardNo = NEW.cardNo
			;
			IF validCc IS NULL THEN 
				RAISE EXCEPTION 'Invalid Credit card no % for customer %', NEW.cardNo, NEW.customerId;
			ELSIF validCc = FALSE THEN 
				RAISE EXCEPTION 'Invalid Credit card no % for customer %', NEW.cardNo, NEW.customerId;
			END IF;
		END IF;

		IF NEW.promoId IS NOT NULL THEN
			SELECT P.type INTO promoType
			FROM Promotions P
			WHERE P.promoId = NEW.promoId
			AND (P.endDate >= NOW()::DATE OR P.endDate IS NULL)
			;

			IF promoType = 1 THEN
				SELECT TRUE into validPromoRest
				FROM RestaurantPromotions RP
				WHERE RP.promoId = NEW.promoId
				AND RP.restaurantId = NEW.restaurantId
				;

				IF validPromoRest IS NULL THEN
					RAISE EXCEPTION 'The promo id % does not apply for restaurant %', NEW.promoId, NEW.restaurantId;
				ELSIF validPromoRest = FALSE THEN
					RAISE EXCEPTION 'The promo id % does not apply for restaurant %', NEW.promoId, NEW.restaurantId;
				END IF;

			ELSIF promoType IS NULL THEN
				RAISE EXCEPTION 'Promo % is invalid', NEW.promoId;
			END IF;

		END IF;

		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_order_validity ON Orderlogs;
CREATE TRIGGER check_order_validity
	BEFORE INSERT OR UPDATE OF promoId, paymentMethod, cardNo ON OrderLogs
	FOR EACH ROW
	EXECUTE FUNCTION check_order_validity();



/*
CREATE OR REPLACE FUNCTION create_mws()
RETURNS TRIGGER
AS $$
	DECLARE
		wwsId INTEGER;
		iterateDate VARCHAR(10);
		iterateTimeStart1 SMALLINT;
		iterateTimeStart2 SMALLINT;
		iterateTimeEnd1 SMALLINT;
		iterateTimeEnd2 SMALLINT;

	BEGIN
		INSERT INTO WWS(riderId,startDate,baseSalary) VALUES (NEW.riderId, NEW.startDate, 0);

		SELECT W.workId INTO wwsId
		FROM WWS W
		WHERE W.riderId = NEW.riderId
		AND W.startDate = NEW.startDate
		; 

		FOR n IN 1..5 LOOP
			SELECT MSD.workDays[n] INTO iterateDate
			FROM MWS_Schedules_Days MSD
			WHERE MSD.workWeekId = NEW.workWeekId
			;

			SELECT MWT.startTime[1], MWT.startTime[2], MWT.endTime[1], MWT.endTime[2]
			INTO iterateTimeStart1, iterateTimeStart2, iterateTimeEnd1, iterateTimeEnd2
			FROM MWS_Schedules_Times MWT
			WHERE MWT.shiftId = NEW.shifts[n]
			;

			INSERT INTO WWS_Schedules(workId,weekday,startTime,endTime) VALUES (wwsId, iterateDate, iterateTimeStart1, iterateTimeEnd1);
			INSERT INTO WWS_Schedules(workId,weekday,startTime,endTime) VALUES (wwsId, iterateDate, iterateTimeStart2, iterateTimeEnd2);

		END LOOP;

		NEW.workId = wwsId;
		RETURN NEW;

	END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS create_mws ON MWS;
CREATE TRIGGER CREATE_MWS
	AFTER INSERT ON MWS
	FOR EACH ROW
	EXECUTE FUNCTION CREATE_MWS();

*/





