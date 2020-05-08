
/*Helper function that returns total monthly salary for a rider given a month and year */
DROP FUNCTION IF EXISTS totalMthSalary;
CREATE OR REPLACE FUNCTION totalMthSalary (rId INTEGER, mth INTEGER, yr INTEGER) RETURNS DECIMAL
AS $$
    DECLARE
        deliveryFee DECIMAL := 0;
        baseSal DECIMAL := 0;

    BEGIN
        SELECT COALESCE(SUM(O.deliveryfee),0) INTO deliveryFee
        FROM Orderlogs O
        WHERE O.riderid = rId
        AND (SELECT EXTRACT(MONTH FROM O.orderDate)) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.orderDate)) = yr
        ;
        
        SELECT COALESCE(W.baseSalary, 0) INTO baseSal
        FROM WWS W
        WHERE W.riderid = rId
        AND (SELECT EXTRACT(MONTH FROM W.startdate)) = mth
        AND (SELECT EXTRACT(YEAR FROM W.startdate)) = yr
        ;

        IF baseSal = 0 THEN
            SELECT SUM(M.basesalary) INTO baseSal
            FROM MWS M
            WHERE M.riderid = rId
            AND (SELECT EXTRACT(MONTH FROM M.startdate)) = mth
            AND (SELECT EXTRACT(YEAR FROM M.startdate)) = yr
            ;
        
        END IF;

        IF baseSal IS NULL THEN
            baseSal := 0;
        END IF;

        IF deliveryFee IS NULL THEN
            deliveryFee := 0;
        END IF;

        RAISE NOTICE 'DELIVERYFEE IS % || BASESAL IS % ', deliveryFee, baseSal;
        RETURN deliveryfee + baseSal;
    END;

$$ LANGUAGE plpgsql;

/*Helper function that returns the total number of new customers, total orders, total cost per given month and year*/
CREATE OR REPLACE FUNCTION totalMthlyFdsStatistics (mth INTEGER, yr INTEGER)
RETURNS TABLE (
    cust_count INTEGER,
    order_count INTEGER,
    total_cost REAL
) 
AS $$
    BEGIN

        SELECT COALESCE(COUNT(DISTINCT U.userid), 0) INTO cust_count
        FROM Users U
        WHERE U.type = 1
        AND (SELECT EXTRACT(MONTH FROM U.registrationdate)) = mth
        AND (SELECT EXTRACT(YEAR FROM U.registrationdate)) = yr
        ;

        SELECT COALESCE(COUNT(DISTINCT O.orderid),0), COALESCE(SUM(O.foodfee + O.deliveryfee),0) INTO order_count, total_cost
        FROM Orderlogs O
        WHERE (SELECT EXTRACT(MONTH FROM O.orderDate)) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.orderDate)) = yr
        ;
        RETURN QUERY SELECT cust_count, order_count, total_cost;
    END;

$$ LANGUAGE plpgsql;

/*Helper function that returns the number of orders placed and total cost of orders per given customer,mth,year*/
CREATE OR REPLACE FUNCTION mthlyCustomerStatistics (cId INTEGER, mth INTEGER, yr INTEGER)
RETURNS TABLE (
    order_count BIGINT,
    total_cost REAL
)
AS $$
    BEGIN
        RETURN QUERY SELECT COALESCE(COUNT(DISTINCT O.orderId),0), CAST(COALESCE(SUM(O.foodfee + O.deliveryfee),0) AS REAL)
        FROM Orderlogs O
        WHERE O.customerid = cId
        AND (SELECT EXTRACT(MONTH FROM O.orderDate)) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.orderDate)) = yr
        ;
    END;

$$ LANGUAGE plpgsql;


/*Helper function that returns the total number of ordeers, hours, salary, average delivery time,
 *number of ratings and average ratings given a rider and month */
 CREATE OR REPLACE FUNCTION mthlyRiderStatistics (rId INTEGER, mth INTEGER, yr INTEGER)
 RETURNS TABLE (
     order_count BIGINT,
     total_hours BIGINT,
     total_salary REAL,
     average_del_time REAL,
     rating_count BIGINT,
     average_rating REAL
 )
 AS $$
    BEGIN
        SELECT COALESCE(COUNT(DISTINCT O.orderId),0), COALESCE(AVG((EXTRACT(epoch FROM (O.ordertime[5] - O.ordertime[4]))/60::REAL)),0) INTO order_count, average_del_time
        FROM Orderlogs O
        WHERE O.riderid = rId
        AND (SELECT EXTRACT(MONTH FROM O.orderDate)) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.orderDate)) = yr
        ;

        SELECT totalMthSalary(rId, mth, yr) INTO total_salary;

        SELECT COALESCE(COUNT(O.ratings),0), COALESCE(AVG(O.ratings), 0) INTO rating_count, average_rating
        FROM Orderlogs O
        WHERE O.riderid = rId
        AND O.ratings <> 0
        AND (SELECT EXTRACT(MONTH FROM O.orderDate)) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.orderDate)) = yr
        ;

        WITH WWSMerged AS (
            SELECT W.riderid, WS.starttime, WS.endtime, W.startdate
            FROM WWS W JOIN WWS_Schedules WS ON W.workid = WS.workid
        )
        SELECT COALESCE(SUM(WM.endtime - WM.starttime),0) INTO total_hours
        FROM WWSMerged WM
        WHERE WM.riderid = rId
        AND (SELECT EXTRACT(MONTH FROM WM.startdate)) = mth 
        AND (SELECT EXTRACT(YEAR FROM WM.startdate)) = yr
        ;

        RETURN QUERY SELECT order_count, total_hours, total_salary, average_del_time, rating_count, average_rating;
    END;
 $$ LANGUAGE plpgsql;

 /*Helper function that retrieves the promotion duration and average num of orders given a promo*/
 CREATE OR REPLACE FUNCTION getPromoStatistics (pId INTEGER)
 RETURNS TABLE (
     total_duration INTEGER,
     average_orders REAL
 )
AS $$
    BEGIN
        SELECT SUM((EXTRACT(DAY FROM P.endDate)) - (EXTRACT(DAY FROM P.startDate))) INTO total_duration
        FROM Promotions P
        WHERE P.promoId = pId
        ;
        
        IF total_duration <= 0 THEN
            total_duration := 1;
        END IF;

        RAISE NOTICE 'total_duration : %', total_duration;

        SELECT COALESCE((COUNT(DISTINCT O.orderId) / total_duration),0) INTO average_orders
        FROM Orderlogs O
        WHERE O.promoId = pId
        ;

        IF average_orders = NULL THEN
            average_orders := 0;
        END IF;

        RAISE NOTICE 'average_orders : %', average_orders;

        RETURN QUERY SELECT total_duration, average_orders;
    END;
$$ LANGUAGE plpgsql;



/* Helper Function that returns the total number of orders placed at each hour for a specific location*/
CREATE OR REPLACE FUNCTION getLocationStatisticsByHr(lId INTEGER, hr INTEGER) RETURNS INTEGER
AS $$
    DECLARE
        total_orders INTEGER := 0;
    BEGIN
        SELECT COALESCE(SUM(DISTINCT O.orderId),0) INTO total_orders
        FROM Orderlogs O
        WHERE O.deliveryLocation = lId
        AND (SELECT EXTRACT(HOUR FROM O.ordertime[1])) = hr
        ;
        RETURN total_orders;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION getLocationStatistics(lId INTEGER)
RETURNS SETOF INTEGER
AS $BODY$
    BEGIN
        FOR hrIterator IN 10..22 LOOP
            RETURN QUERY SELECT * FROM getLocationStatisticsByHr(lId, hrIterator);
        END LOOP;
        RETURN;
    END;
$BODY$ LANGUAGE plpgsql STABLE STRICT;

CREATE OR REPLACE FUNCTION create_mws_schedule(wId INTEGER)
RETURNS VOID
AS $$
	DECLARE
        rId INTEGER;
        sDate DATE;
		iterateDate VARCHAR(10);
		iterateTimeStart1 SMALLINT;
		iterateTimeStart2 SMALLINT;
		iterateTimeEnd1 SMALLINT;
		iterateTimeEnd2 SMALLINT;

	BEGIN
		SELECT W.riderId, W.startDate INTO rId, sDate
        FROM WWS W
        WHERE W.workId = wId
        ;
        
        FOR n IN 1..5 LOOP

			SELECT MSD.workDays[n] INTO iterateDate
			FROM MWS_Schedules_Days MSD
			WHERE MSD.workWeekId = (SELECT M.workweekid FROM MWS M WHERE M.riderId = rId AND M.startDate = sDate)
			;

			

			SELECT MWT.startTime[1], MWT.startTime[2], MWT.endTime[1], MWT.endTime[2]
			INTO iterateTimeStart1, iterateTimeStart2, iterateTimeEnd1, iterateTimeEnd2
			FROM MWS_Schedules_Times MWT
			WHERE MWT.shiftId = (SELECT M.shifts[n] FROM MWS M WHERE M.riderId = rId AND M.startDate = sDate)
			;

			RAISE NOTICE 'WID: % || DAY: % || SHIFT %-%', wId, iterateDate,iterateTimeStart1,iterateTimeEnd1;
			RAISE NOTICE 'WID: % || DAY: % || SHIFT %-%', wId, iterateDate,iterateTimeStart2,iterateTimeEnd2;

			INSERT INTO WWS_Schedules(workId,weekday,startTime,endTime) VALUES (wId, iterateDate, iterateTimeStart1, iterateTimeEnd1);
			INSERT INTO WWS_Schedules(workId,weekday,startTime,endTime) VALUES (wId, iterateDate, iterateTimeStart2, iterateTimeEnd2);

		END LOOP;
	END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION new_mws(rId INTEGER, sDate DATE, bSal DECIMAL, wwId INTEGER, shifts INTEGER[5])
RETURNS VOID
AS $$
    DECLARE
        wId INTEGER;
    BEGIN
        INSERT INTO WWS(riderId, startDate, baseSalary) VALUES (rId, sDate, 0);
        INSERT INTO MWS(riderId, startDate, baseSalary, workweekid, shifts) VALUES (rId, sDate, bSal, wwId, shifts);
        
        SELECT workId INTO wId
        FROM WWS 
        WHERE riderId = rId 
        AND startDate = sDate
        ;
        
        PERFORM create_mws_schedule(wId);
    END;
$$ LANGUAGE plpgsql;


/*Transaction to create a successful order*/
CREATE OR REPLACE FUNCTION create_new_order_success ( cId INTEGER, rId INTEGER, 
													  restId INTEGER, pay INTEGER, cardNo BIGINT, foodFee INTEGER, 
													  delFee INTEGER, delLoc INTEGER, promoId INTEGER, orderArr int[])
RETURNS VOID
AS $$
    DECLARE
        availableRider INTEGER;
        currTime TIME := NOW()::time;
        ord INTEGER[];
        fId INTEGER;
        qty INTEGER;
    BEGIN

        INSERT INTO Orderlogs(customerId, riderId, restaurantId, orderDate, orderTime, paymentMethod, cardNo, foodFee, deliveryFee, deliveryLocation, promoId)
        VALUES (cId, rId, restId, NOW()::date , ARRAY[currTime,null,null,null,null], pay, cardNo, foodFee, delFee, delLoc, promoId);

        FOREACH ord SLICE 1 IN ARRAY orderArr 
        LOOP
            INSERT INTO Orders(foodId, quantity) VALUES (ord[1], ord[2]);
        END LOOP;
        
        RAISE NOTICE 'Succesfully created new order';
    END;
$$ LANGUAGE plpgsql;

/*Helper Function to retrieve top 5 favourite food items for a given restaurant, mth,yr*/
/*
CREATE OR REPLACE FUNCTION getTop5(rId INTEGER, mth INTEGER, yr INTEGER) 
RETURNS TABLE (
    fId INTEGER,
    fName VARCHAR(30)
)
AS $BODY$
    BEGIN
        SELECT O.ordersid, F.foodName INTO fId, fName
        FROM Orders O NATURAL JOIN Foods F
        ;

    END;
$BODY$ LANGUAGE plpgsql;
*/

/*CREATE OR REPLACE FUNCTION totalMthWorkingHour (rid INTEGER, mth INTEGER, yr INTEGER) RETURNS INTEGER
AS $$
DECLARE

BEGIN
    WITH WWS_HOUR (startdate)
    SELECT startdate, COALESCE(NOW()::DATE, endDate), 
    CASE weekday
    WHEN 'monday' THEN 1
    WHEN 'tuesday'THEN 2
    WHEN 'wednesday' THEN 3
    WHEN 'thursday' THEN 4
    WHEN 'friday' THEN 5
    WHEN 'saturday' THEN 6
    ELSE 7
    END,
    COALESCE(0, SUM(endTime - startTime))
    FROM WWS W NATURAL JOIN WWS_Schedules S
    WHERE W.riderid = rid
    AND (startDate, COALESCE(current_date, endDate)) OVERLAPS
        (mth_start, mth_end)
    GROUP BY startDate, endDate, weekday;*/
    
    /*WITH MWS_HOUR ()
    SELECT startDate, endDate, workweekid, 8
    FROM MWS M
    WHERE M.riderid = rid
    AND (startDate, COALESCE(current_date, endDate)) OVERLAPS
        (mth_start, mth_end)*/

    /*WITH ALL_DAYS (daytime) AS (
    SELECT * FROM GENERATE_SERIES(mth_start::DATE, mth_end, '1 DAY'));

    SELECT *
    FROM WWS_HOUR H JOIN ALL_DAYS A 
    ON startDate <= daytime::DATE
    AND endDate >= daytime::DATE
    AND EXTRACT(isdow FROM daytime::DATE) = H.weekday;*/
