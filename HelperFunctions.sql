
/*Helper function that returns total monthly salary for a rider given a month and year */
CREATE OR REPLACE FUNCTION totalMthSalary (rId INTEGER, mth INTEGER, yr INTEGER) RETURNS REAL 
AS $$
    DECLARE
        deliveryFee REAL := 0;
        baseSal REAL := 0;

    BEGIN
        SELECT SUM(O.deliveryfee) INTO deliveryFee
        FROM Orders O
        WHERE O.riderid = rId
        AND (SELECT EXTRACT(MONTH FROM O.ordertime[1])) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.ordertime[1])) = yr
        ;
        
        SELECT COALESCE(M.baseSalary, 0) INTO baseSal
        FROM MWS M
        WHERE M.riderid = rId
        AND (SELECT EXTRACT(MONTH FROM M.startdate)) = mth
        AND (SELECT EXTRACT(YEAR FROM M.startdate)) = yr
        ;

        IF baseSal = 0 THEN
            SELECT SUM(W.basesalary) INTO baseSal
            FROM WWS W
            WHERE W.riderid = rId
            AND (SELECT EXTRACT(MONTH FROM W.startdate)) = mth
            AND (SELECT EXTRACT(YEAR FROM W.startdate)) = yr
            ;
        
        END IF;
        RETURN (deliveryFee + baseSal);
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

        SELECT COALESCE(COUNT(DISTINCT O.orderid),0), COALESCE(SUM(O.foodfee + O.deliveryfee),0) INTO cust_count, total_cost
        FROM Orders O
        WHERE (SELECT EXTRACT(MONTH FROM O.ordertime[1])) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.ordertime[1])) = yr
        ;

    END;

$$ LANGUAGE plpgsql;

/*Helper function that returns the number of orders placed and total cost of orders per given customer,mth,year*/
CREATE OR REPLACE FUNCTION mthlyCustomerStatistics (cId INTEGER, mth INTEGER, yr INTEGER)
RETURNS TABLE (
    order_count INTEGER,
    total_cost REAL
)
AS $$
    BEGIN
        SELECT COALESCE(COUNT(DISTINCT O.orderId),0), COALESCE(SUM(O.foodfee + O.deliveryfee),0) INTO order_count, total_cost
        FROM Orders O
        WHERE O.customerid = cId
        AND (SELECT EXTRACT(MONTH FROM O.ordertime[1])) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.ordertime[1])) = yr
        ;
    END;

$$ LANGUAGE plpgsql;


/*Helper function that returns the total number of ordeers, hours, salary, average delivery time,
 *number of ratings and average ratings given a rider and month */
 CREATE OR REPLACE FUNCTION mthlyRiderStatistics (rId INTEGER, mth INTEGER, yr INTEGER)
 RETURNS TABLE (
     order_count INTEGER,
     total_hours INTEGER,
     total_salary REAL,
     average_del_time REAL,
     rating_count INTEGER,
     average_rating REAL
 )
 AS $$
    BEGIN
        SELECT COALESCE(COUNT(DISTINCT O.orderId),0), COALESCE(AVG(O.ordertime[5] - O.ordertime[4]),0) INTO order_count, average_del_time
        FROM Orders O
        WHERE O.riderid = rId
        AND (SELECT EXTRACT(MONTH FROM O.ordertime[1])) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.ordertime[1])) = yr
        ;

        SELECT totalMthSalary(rId, mth, year) INTO total_salary;

        SELECT COALESCE(COUNT(O.ratings),0), COALESCE(AVG(O.ratings), 0) INTO rating_count, average_rating
        FROM Orders O
        WHERE O.riderid = rId
        AND O.ratings <> 0
        AND (SELECT EXTRACT(MONTH FROM O.ordertime[1])) = mth 
        AND (SELECT EXTRACT(YEAR FROM O.ordertime[1])) = yr
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
    END;
 $$ LANGUAGE plpgsql;

 /*Helper function that retrieves the promotion duration and average num of orders given a promo*/
 CREATE OR REPLACE FUNCTION getRestaurantStatistics (pId INTEGER)
 RETURNS TABLE (
     total_duration INTEGER,
     average_orders REAL
 )
AS $$
    BEGIN
        SELECT SUM((SELECT EXTRACT(DAY FROM P.endDate)) - (SELECT EXTRACT(DAY FROM P.startDate))) INTO total_duration
        FROM Promotions P
        WHERE P.promoId = pId
        ;
        
        IF total_duration <= 0 THEN
            total_duration := 1;
        END IF;

        SELECT (COUNT(DISTINCT O.orderId) / total_duration) INTO average_orders
        FROM Orders O
        WHERE O.promoId = pId
        ;
    END;
$$ LANGUAGE plpgsql;



/* Helper Function that returns the total number of orders placed at each hour for a specific location*/
CREATE OR REPLACE FUNCTION getLocationStatisticsByHr(lId INTEGER, hr INTEGER) RETURNS INTEGER
AS $$
    DECLARE
        total_orders INTEGER := 0;
    BEGIN
        SELECT COALESCE(SUM(DISTINCT O.orderId),0) INTO total_orders
        FROM Orders O
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


/*Helper Function to retrieve top 5 favourite food items for a given restaurant, mth,yr*/
CREATE OR REPLACE FUNCTION getTop5(rId INTEGER, mth INTEGER, yr INTEGER) 
RETURNS TABLE (
    fId INTEGER,
    fName VARCHAR(30)
)
AS $BODY$
    BEGIN
        SELECT O.ordersid, F.foodName INTO fId, fName
        FROM Orders O JOIN Foods F

    END;
$BODY$ LANGUAGE plpgsql;
