DROP TABLE IF EXISTS Users, Customers, Riders, Staff, FDSManagers, Restaurants, Foods, FoodCategories, DeliveryCost, CreditCards, DeliveryAreas, Menu, Orders, OrdersLog, WWS, MWS, RecentLocations CASCADE;


/* Set Timezone to UTC+8 */
SET timezone = + 8;

-- SET timezone='Asia/Singapore'; -- Alternative
/* COMMON HELPER FUNCTIONS */
/*
 * Given date (yyyy-mm-dd),
 * return new date where dd is the last day of the month mm.
 */
CREATE OR REPLACE FUNCTION last_day (date)
  RETURNS date
  AS '
  SELECT
    (date_trunc(''MONTH'', $1) + interval ''1 MONTH - 1 day'')::date;

'
LANGUAGE 'sql'
IMMUTABLE STRICT;


/* PARENT TABLES */
CREATE TABLE Users (
  uid serial,
  username varchar(20) NOT NULL,
  PASSWORD VARCHAR(20) NOT NULL,
  first_name varchar(20) NOT NULL,
  last_name varchar(20) NOT NULL,
  email varchar(40),
  contact_no integer,
  registration_date timestamptz NOT NULL,
  is_active boolean NOT NULL DEFAULT TRUE,
  last_login timestamptz NOT NULL,
  PRIMARY KEY (uid),
  UNIQUE (username),
  UNIQUE (contact_no),
  UNIQUE (email),
  CHECK (contact_no >= 10000000 AND contact_no <= 99999999)
);

CREATE TABLE Restaurants (
  rid serial,
  rname varchar(60) NOT NULL,
  address varchar(80) NOT NULL,
  min_order_cost numeric NOT NULL,
  PRIMARY KEY (rid),
  CHECK (min_order_cost > 0.0)
);

CREATE TABLE FoodCategories (
  fcid serial,
  fcname varchar(20) NOT NULL,
  PRIMARY KEY (fcid),
  UNIQUE (fcname)
);

CREATE TABLE DeliveryCost (
  region varchar(10),
  COST NUMERIC NOT NULL,
  PRIMARY KEY (region)
);


/* CHILD TABLES */
CREATE TABLE Customers (
  points numeric NOT NULL DEFAULT 0.0,
  total_spending numeric NOT NULL DEFAULT 0.0,
  total_orders integer NOT NULL DEFAULT 0,
  last_order_date timestamptz,
  PRIMARY KEY (uid),
  UNIQUE (username),
  UNIQUE (contact_no),
  UNIQUE (email),
  CHECK (last_order_date > registration_date),
  CHECK (last_login >= registration_date)
)
INHERITS (
  Users
);



CREATE OR REPLACE FUNCTION check_customers ()
  RETURNS TRIGGER
  AS '
BEGIN
  IF NEW.last_login IS NULL THEN
    NEW.last_login := NEW.registration_date;
  END IF;
  RETURN NEW;
END;
'
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_customers_trigger ON Customers;
CREATE TRIGGER check_customers_trigger
  BEFORE INSERT ON Customers
  FOR EACH ROW
  EXECUTE PROCEDURE check_customers ();


CREATE TABLE RecentLocations
(
  customerId integer,
  location INTEGER NOT NULL,
  /*postal code*/
  lastUsingTime timestamp NOT NULL,
  PRIMARY KEY (customerId, lastUsingTime),
  FOREIGN KEY (customerId) REFERENCES Users (uid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE OR REPLACE FUNCTION check_customer_locations ()
  RETURNS TRIGGER
  AS $$
    DECLARE
      location_count INTEGER;
    BEGIN
      SELECT COUNT(*) INTO location_count
      FROM RecentLocations R
      WHERE R.customerId = NEW.customerId
      ;
      IF location_count > 5 THEN
        DELETE FROM RecentLocations R
        WHERE R.lastUsingTime <= ALL (
          SELECT R1.lastUsingTime
          FROM RecentLocations R1
          WHERE R1.customerId = NEW.customerId
        )
        ;
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

CREATE TABLE CreditCards (
  uid integer NOT NULL,
  card_no bigint NOT NULL,
  cvv_no varchar(4) NOT NULL,
  name_on_card varchar(60) NOT NULL,
  card_type varchar(30) NOT NULL,
  expiry_date date NOT NULL,
  PRIMARY KEY (uid, card_no),
  UNIQUE (card_no),
  FOREIGN KEY (uid) REFERENCES Customers (uid) ON DELETE CASCADE
);

CREATE TABLE Riders (
  total_deliveries integer NOT NULL DEFAULT 0,
  PRIMARY KEY (uid),
  UNIQUE (username),
  UNIQUE (contact_no),
  UNIQUE (email),
  CHECK (total_deliveries >= 0)
)
INHERITS (
  Users
);

CREATE OR REPLACE FUNCTION check_riders ()
  RETURNS TRIGGER
  AS '
BEGIN
  IF NEW.last_login IS NULL THEN
    NEW.last_login := NEW.registration_date;
  END IF;
  RETURN NEW;
END;
'
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_riders_trigger ON Riders;

CREATE TRIGGER check_riders_trigger
  BEFORE INSERT ON Riders
  FOR EACH ROW
  EXECUTE PROCEDURE check_riders ();

CREATE TABLE MWS ();


/*
-- Query to get total hours

WITH daily_total_hours AS (
 SELECT uid, workdate, SUM((end_1::time - start_1::time) +
 (CASE WHEN start_2 IS NOT NULL THEN end_2::time - start_2::time ELSE interval '0' END) +
 (CASE WHEN start_3 IS NOT NULL THEN end_3::time - start_3::time ELSE interval '0' END) +
 (CASE WHEN start_4 IS NOT NULL THEN end_4::time - start_4::time ELSE interval '0' END) +
 (CASE WHEN start_5 IS NOT NULL THEN end_5::time - start_5::time ELSE interval '0' END) +
 (CASE WHEN start_6 IS NOT NULL THEN end_6::time - start_6::time ELSE interval '0' END)
 ) as total_hrs
 FROM wws
 GROUP BY uid, workdate
 ORDER BY workdate
)

-- To get daily total hours for every riders
SELECT * FROM daily_total_hours;

-- To get weekly total hours for every riders
SELECT uid, 
(SELECT (CASE EXTRACT(dow FROM workdate)
 WHEN 1 THEN workdate
 WHEN 2 THEN workdate - interval '1d'
 WHEN 3 THEN workdate - interval '2d'     
 WHEN 4 THEN workdate - interval '3d'
 WHEN 5 THEN workdate - interval '4d'
 WHEN 6 THEN workdate - interval '5d'
 WHEN 0 THEN workdate - interval '6d'
 ELSE null
 END
)) as start_date_of_week,
SUM(total_hrs)
FROM daily_total_hours
GROUP BY uid, start_date_of_week
ORDER BY start_date_of_week
;
 */

 /*
CREATE TABLE WWS (
  uid integer REFERENCES Riders (uid),
  workDate date NOT NULL,
  start_1 timetz,
  end_1 timetz,
  start_2 timetz,
  end_2 timetz,
  start_3 timetz,
  end_3 timetz,
  start_4 timetz,
  end_4 timetz,
  start_5 timetz,
  end_5 timetz,
  start_6 timetz,
  end_6 timetz,
  PRIMARY KEY (uid, workDate),
  -- minimum of 1 work hours and maximum 4 work hours for each interval
  CHECK (start_1 < end_1 AND end_1::time - start_1::time >= interval '1h' AND end_1::time - start_1::time <= interval '4h'),
  CHECK (start_2 < end_2 AND end_2::time - start_2::time >= interval '1h' AND end_2::time - start_2::time <= interval '4h'),
  CHECK (start_3 < end_3 AND end_3::time - start_3::time >= interval '1h' AND end_3::time - start_3::time <= interval '4h'),
  CHECK (start_4 < end_4 AND end_4::time - start_4::time >= interval '1h' AND end_4::time - start_4::time <= interval '4h'),
  CHECK (start_5 < end_5 AND end_5::time - start_5::time >= interval '1h' AND end_5::time - start_5::time <= interval '4h'),
  CHECK (start_6 < end_6 AND end_6::time - start_6::time >= interval '1h' AND end_6::time - start_6::time <= interval '4h'),
  -- Break time between work intervals must be >= 1 hour
  CHECK (start_2::time - end_1::time >= interval '1h' AND start_3::time - end_2::time >= interval '1h' AND start_4::time - end_3::time >= interval '1h' AND start_5::time - end_4::time >= interval '1h' AND start_6::time - end_5::time >= interval '1h'),
  -- if start time is defined, end time must also be defined
  CHECK (start_1 IS NOT NULL AND end_1 IS NOT NULL OR start_1 IS NULL AND end_1 IS NULL),
  CHECK (start_2 IS NOT NULL AND end_2 IS NOT NULL OR start_2 IS NULL AND end_2 IS NULL),
  CHECK (start_3 IS NOT NULL AND end_3 IS NOT NULL OR start_3 IS NULL AND end_3 IS NULL),
  CHECK (start_4 IS NOT NULL AND end_4 IS NOT NULL OR start_4 IS NULL AND end_4 IS NULL),
  CHECK (start_5 IS NOT NULL AND end_5 IS NOT NULL OR start_5 IS NULL AND end_5 IS NULL),
  CHECK (start_6 IS NOT NULL AND end_6 IS NOT NULL OR start_6 IS NULL AND end_6 IS NULL),
  -- cannot define interval x if interval x - 1 is not defined
  CHECK (start_2 IS NULL OR start_2 IS NOT NULL AND start_1 IS NOT NULL),
  CHECK (start_3 IS NULL OR start_3 IS NOT NULL AND start_2 IS NOT NULL),
  CHECK (start_4 IS NULL OR start_4 IS NOT NULL AND start_3 IS NOT NULL),
  CHECK (start_5 IS NULL OR start_5 IS NOT NULL AND start_4 IS NOT NULL),
  CHECK (start_6 IS NULL OR start_6 IS NOT NULL AND start_5 IS NOT NULL),
  -- work hours must be between 10am to 10pm
  CHECK (start_1 >= time '10:00' AND end_1 <= time '22:00'),
  CHECK (start_2 >= time '10:00' AND end_2 <= time '22:00'),
  CHECK (start_3 >= time '10:00' AND end_3 <= time '22:00'),
  CHECK (start_4 >= time '10:00' AND end_4 <= time '22:00'),
  CHECK (start_5 >= time '10:00' AND end_5 <= time '22:00'),
  CHECK (start_6 >= time '10:00' AND end_6 <= time '22:00'),
  -- work hours must be on the hour (e.g. 11:00 am - allowed BUT 11:30 am - not allowed)
  CHECK (extract(m FROM start_1) = 0 AND extract(s FROM start_1) = 0 AND extract(m FROM end_1) = 0 AND extract(s FROM end_1) = 0),
  CHECK (extract(m FROM start_2) = 0 AND extract(s FROM start_2) = 0 AND extract(m FROM end_2) = 0 AND extract(s FROM end_2) = 0),
  CHECK (extract(m FROM start_3) = 0 AND extract(s FROM start_3) = 0 AND extract(m FROM end_3) = 0 AND extract(s FROM end_3) = 0),
  CHECK (extract(m FROM start_4) = 0 AND extract(s FROM start_4) = 0 AND extract(m FROM end_4) = 0 AND extract(s FROM end_4) = 0),
  CHECK (extract(m FROM start_5) = 0 AND extract(s FROM start_5) = 0 AND extract(m FROM end_5) = 0 AND extract(s FROM end_5) = 0),
  CHECK (extract(m FROM start_6) = 0 AND extract(s FROM start_6) = 0 AND extract(m FROM end_6) = 0 AND extract(s FROM end_6) = 0)
);

*/


CREATE TABLE WWS
(
  workId serial,
  riderId integer NOT NULL,
  startDate date NOT NULL,
  endDate date,
  isUsed boolean NOT NULL DEFAULT 't',
  baseSalary DECIMAL NOT NULL CHECK (baseSalary > 0),
  UNIQUE (riderId, startDate),
  PRIMARY KEY (workId),
  FOREIGN KEY (riderId) REFERENCES Riders (uid) ON DELETE CASCADE,
  CHECK (endDate >= startDate)
);

CREATE TABLE WWS_Schedules
(
  workId integer,
  weekday varchar(10),
  startTime smallint CHECK (startTime >= 0 AND startTime < 24),
  endTime smallint CHECK (endTime > 0 AND endTime <= 24),
  PRIMARY KEY (workId, weekday, startTime),
  FOREIGN KEY (workId) REFERENCES WWS (workId) ON DELETE CASCADE,
  CHECK (endTime > startTime)
);

CREATE TABLE MWS
(
  workId serial,
  riderId integer NOT NULL,
  startDate date NOT NULL,
  endDate date,
  isUsed boolean NOT NULL DEFAULT 't',
  baseSalary DECIMAL NOT NULL CHECK (baseSalary > 0),
  workDays integer NOT NULL CHECK (workDays >= 1 AND workDays <= 7),
  /*use 1-7 to represents 7 options of work days*/
  shifts integer[5] CHECK(1 <= ALL(shifts) AND 4 >= ALL(shifts)),
    /*use 1-4 to represents 4 shifts*/
  UNIQUE(riderId, startDate),
  PRIMARY KEY (workId),
  FOREIGN KEY (riderId) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE,
  CHECK (endDate >= startDate)
);

CREATE TABLE Staff (
  rid integer REFERENCES Restaurants (rid) ON DELETE CASCADE,
  PRIMARY KEY (uid),
  UNIQUE (username),
  UNIQUE (contact_no),
  UNIQUE (email)
)
INHERITS (
  Users
);

CREATE OR REPLACE FUNCTION check_staff ()
  RETURNS TRIGGER
  AS '
BEGIN
  IF NEW.last_login IS NULL THEN
    NEW.last_login := NEW.registration_date;
  END IF;
  RETURN NEW;
END;
'
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_staff_trigger ON Staff;

CREATE TRIGGER check_staff_trigger
  BEFORE INSERT ON Staff
  FOR EACH ROW
  EXECUTE PROCEDURE check_staff ();

CREATE TABLE FDSManagers (
  PRIMARY KEY (uid),
  UNIQUE (username),
  UNIQUE (contact_no),
  UNIQUE (email)
)
INHERITS (
  Users
);

CREATE OR REPLACE FUNCTION check_fdsmanager ()
  RETURNS TRIGGER
  AS '
BEGIN
  IF NEW.last_login IS NULL THEN
    NEW.last_login := NEW.registration_date;
  END IF;
  RETURN NEW;
END;
'
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_fdsmanager_trigger ON FDSManagers;

CREATE TRIGGER check_fdsmanager_trigger
  BEFORE INSERT ON FDSManagers
  FOR EACH ROW
  EXECUTE PROCEDURE check_fdsmanager ();

CREATE TABLE Foods (
  fid serial,
  fname varchar(100) NOT NULL,
  category integer NOT NULL REFERENCES FoodCategories (fcid) ON DELETE RESTRICT,
  PRIMARY KEY (fid)
);

CREATE TABLE DeliveryAreas (
  region varchar(20) REFERENCES DeliveryCost (region) ON DELETE CASCADE,
  postal_sector varchar(2),
  PRIMARY KEY (region, postal_sector)
);

CREATE TABLE Menu (
  fid integer REFERENCES Foods (fid) ON DELETE CASCADE,
  rid integer REFERENCES Restaurants (rid) ON DELETE CASCADE,
  daily_limit integer,
  unit_price numeric NOT NULL,
  is_available boolean,
  PRIMARY KEY (fid, rid),
  CHECK (unit_price > 0.0),
  CHECK (daily_limit >= 0)
);

CREATE OR REPLACE FUNCTION check_menu ()
  RETURNS TRIGGER
  AS '
BEGIN
  IF NEW.daily_limit IS NULL OR NEW.daily_limit > 0 THEN
    NEW.is_available := TRUE;
  ELSE
    NEW.is_available := FALSE;
  END IF;
  RETURN NEW;
END;
'
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_menu_trigger ON Menu;

CREATE TRIGGER check_menu_trigger
  BEFORE INSERT OR UPDATE ON Menu
  FOR EACH ROW
  EXECUTE PROCEDURE check_menu ();

CREATE TABLE Orders (
  uid integer NOT NULL,
  rid integer NOT NULL,
  fid integer NOT NULL,
  unit_price numeric NOT NULL,
  qty integer NOT NULL,
  delivery_cost numeric NOT NULL,
  order_timestamp timestamptz NOT NULL,
  address varchar(50) NOT NULL,
  postal_code varchar(6) NOT NULL,
  payment_method integer NOT NULL,
  card_no bigint REFERENCES CreditCards (card_no),
  PRIMARY KEY (uid, rid, fid, order_timestamp),
  CHECK (payment_method = 0 AND card_no IS NULL OR payment_method <> 0 AND card_no IS NOT NULL)
);

CREATE TABLE OrdersLog (
  oid serial,
  order_timestamp timestamptz NOT NULL,
  order_cost numeric NOT NULL,
  delivery_cost numeric NOT NULL,
  payment_method integer NOT NULL,
  rider_id integer,
  address varchar(50) NOT NULL,
  postal_code varchar(6) NOT NULL,
  depart_for_r timestamptz,
  arrived_at_r timestamptz,
  depart_for_c timestamptz,
  arrived_at_c timestamptz,
  PRIMARY KEY (oid, order_timestamp)
);

CREATE TABLE Carts
(
  cartId integer,
  quantity integer DEFAULT 1,
  foodId integer NOT NULL,
  restaurantId integer NOT NULL,
  PRIMARY KEY (cartId, foodId),
  FOREIGN KEY (cartId) REFERENCES Customers (customerId) ON DELETE CASCADE,
  FOREIGN KEY (foodId, restaurantId) REFERENCES Foods (foodId, restaurantId) ON DELETE CASCADE ON UPDATE CASCADE
  /*Order in only one restaurant, handled by logic*/
);






/* 
 * TODO:
 * Replace hard-coded values with sub queries
 * to determine the available delivery rider
 * depending on some criterias.
 */
CREATE OR REPLACE FUNCTION log_orders ()
  RETURNS TRIGGER
  AS '
BEGIN
  INSERT INTO OrdersLog (order_timestamp, order_cost, delivery_cost, payment_method, rider_id, address, postal_code) ( WITH temp_table AS (
      SELECT
        n.order_timestamp,
        SUM(n.unit_price * n.qty) AS order_cost,
        n.delivery_cost,
        n.payment_method,
        5 AS rider_id,
        n.address,
        n.postal_code
      FROM
        new_table n
      GROUP BY
        n.order_timestamp,
        n.delivery_cost,
        n.payment_method,
        n.address,
        n.postal_code
)
      SELECT
        order_timestamp,
        SUM(order_cost),
        delivery_cost,
        payment_method,
        rider_id,
        address,
        postal_code
      FROM
        temp_table
      GROUP BY
        order_timestamp,
        delivery_cost,
        payment_method,
        rider_id,
        address,
        postal_code);
  RETURN NULL;
END;
'
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS log_orders_trigger ON Orders;

CREATE TRIGGER log_orders_trigger
  AFTER INSERT ON Orders REFERENCING NEW TABLE AS new_table
  FOR EACH STATEMENT
  EXECUTE PROCEDURE log_orders ();

------------------
-- FDS MANAGERS --
------------------

INSERT INTO FDSManagers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'hbogie0', '2oV0Wpo', 'Halie', 'Bogie', 'hbogie0@earthlink.net', '60690938', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO FDSManagers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'ldufray1', '2NGPg0', 'Lamond', 'Du Fray', 'ldufray1@salon.com', '83119402', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO FDSManagers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'ehaslum2', 'seJd78', 'Emlyn', 'Haslum', 'ehaslum2@cafepress.com', '92332086', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO FDSManagers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'yderle3', 'UM6fWyBlyETB', 'Yvon', 'Derle', 'yderle3@sakura.ne.jp', '92658500', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

---------------
-- CUSTOMERS --
---------------

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'sharcus0', 'tvhf0ivDdR', 'Stoddard', 'Harcus', 'sharcus0@mapy.cz', '85096217', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'croskam1', 'Y6DfS70MFaBE', 'Chelsy', 'Roskam', 'croskam1@gravatar.com', '92045140', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'sherries2', '7GaoU0ti6', 'Stanislas', 'Herries', 'sherries2@fc2.com', '67219834', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'jwatford3', 'uRl9GF41', 'Jehu', 'Watford', 'jwatford3@t-online.de', '82426087', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'dhinz4', 'D7F0jGVku', 'Douglass', 'Hinz', 'dhinz4@comcast.net', '86339432', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'yfitzsimons5', 'CUTcjxQyf3q', 'Yuma', 'Fitzsimons', 'yfitzsimons5@seattletimes.com', '89227882', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'btuffey6', '0LUU5Z', 'Boothe', 'Tuffey', 'btuffey6@webs.com', '98016785', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'jgutherson7', '2VyWCGLJ', 'Jill', 'Gutherson', 'jgutherson7@intel.com', '61728893', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'bcumberpatch8', '2oBvpL', 'Berni', 'Cumberpatch', 'bcumberpatch8@xing.com', '85931687', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'dtumilson9', 'tPBhI3kD', 'Danice', 'Tumilson', 'dtumilson9@flavors.me', '83071317', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'dfehelya', 'iMqvYNAUs', 'Darrelle', 'Fehely', 'dfehelya@cdbaby.com', '61345771', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'jingarfillb', 'xuYsjg7qcypq', 'Jordain', 'Ingarfill', 'jingarfillb@wp.com', '97422443', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'dtabbittc', '94ADplNeA7yj', 'Daisy', 'Tabbitt', 'dtabbittc@boston.com', '89363689', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'dethertond', 'a0mUyzele8', 'Derk', 'Etherton', 'dethertond@ebay.com', '98076906', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'emartinete', 'DHBnfJcmcXW', 'Ellwood', 'Martinet', 'emartinete@washingtonpost.com', '94920581', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'dstannionf', 'll6VgwlzP', 'Dianna', 'Stannion', 'dstannionf@dmoz.org', '94067798', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'odukeg', 'dIWgbGa', 'Orella', 'Duke', 'odukeg@hao123.com', '87425358', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'rpiscullih', '4ysxouzDkR7F', 'Roxane', 'Pisculli', 'rpiscullih@bing.com', '97045119', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'lklemensiewiczi', 'p45KOIibZJ', 'Leora', 'Klemensiewicz', 'lklemensiewiczi@time.com', '98563852', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

INSERT INTO Customers (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date)
  VALUES (DEFAULT, 'slavrickj', 'JVkrs1J0', 'Shep', 'Lavrick', 'slavrickj@bigcartel.com', '80881582', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));

------------------
-- CREDIT CARDS --
------------------

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (7, '3537771022455820', '0510', 'BRINEY SHADDICK', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (5, '3586676110384289', '7947', 'CAMMY CLEOBURY', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (15, '5550105555083336', '4273', 'JACQUELYN SEARSON', 'mastercard', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (19, '5602219917933134', '226', 'MAURISE MAPLETHORPE', 'bankcard', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (6, '4903986281048462', '7799', 'DEVA CHURCHLEY', 'switch', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (24, '201567223433561', '3178', 'MONROE HUZZEY', 'diners-club-enroute', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (12, '5151506736918816', '992', 'TANITANSY PILSBURY', 'mastercard', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (20, '5108751437906207', '3826', 'BAYARD KILBOURNE', 'mastercard', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (21, '3562138540625391', '4832', 'DORIS RIDETT', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (14, '5572998797411099', '761', 'CECIL SODA', 'diners-club-us-ca', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (9, '50380142212451111', '6389', 'LETICIA KEPPIE', 'maestro', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (10, '5100170636401811', '078', 'JUNIE TOURS', 'mastercard', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (7, '3569446152172518', '385', 'GYPSY NORTHGRAVES', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (6, '3537814557273000', '9573', 'DARLA SZABO', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (11, '3533047214118375', '243', 'DOROLISA KAUSCHER', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (7, '5602229221249663', '2416', 'HUEY COURTOIS', 'china-unionpay', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (16, '3557395920471377', '6002', 'BARBEY FARGUHAR', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (10, '4026346520590539', '4662', 'THOMAS CROIX', 'visa-electron', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (18, '6771091682123417284', '6320', 'MAYBELLE FERRAR', 'laser', last_day ((now()::date + (random() * interval '5 years'))::date));

INSERT INTO CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date)
  VALUES (5, '3579522824652612', '731', 'LOYDIE FIGGER', 'jcb', last_day ((now()::date + (random() * interval '5 years'))::date));

-----------------
-- RESTAURANTS --
-----------------

INSERT INTO Restaurants (rid, rname, address, min_order_cost)
  VALUES (DEFAULT, 'Gerhold-Schneider', '37190 Packers Trail', 3.5);

INSERT INTO Restaurants (rid, rname, address, min_order_cost)
  VALUES (DEFAULT, 'Jenkins Group', '54 Moulton Point', 1);

INSERT INTO Restaurants (rid, rname, address, min_order_cost)
  VALUES (DEFAULT, 'Schiller and Sons', '7 Ridgeview Crossing', 3);

INSERT INTO Restaurants (rid, rname, address, min_order_cost)
  VALUES (DEFAULT, 'Vandervort, Smitham and Mohr', '791 Maple Wood Pass', 0.5);

---------------------
-- DELIVERY RIDERS --
---------------------

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'mjoplin0', '99mRUK9SIy', 'Marylinda', 'Joplin', 'mjoplin0@zdnet.com', '91156281', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 15);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'nstiven1', 'bYarJszgIWrW', 'Nolana', 'Stiven', 'nstiven1@live.com', '89047851', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 12);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'mstrete2', 'Gm9FEPo', 'Merl', 'Strete', 'mstrete2@sbwire.com', '96559892', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 29);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'ymacgibbon3', 'CEpdTkWI', 'Yetty', 'MacGibbon', 'ymacgibbon3@nhs.uk', '95690961', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'jantonias4', '6hgaM9p082', 'Jillene', 'Antonias', 'jantonias4@flavors.me', '97666473', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 17);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'bblancowe5', 'H8bHy0pWD3c', 'Brena', 'Blancowe', 'bblancowe5@microsoft.com', '94277769', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 15);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'hgeely6', 'MqjEJ6k1xHA', 'Herbert', 'Geely', 'hgeely6@yahoo.com', '91023570', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 14);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'kfairholme7', 'ShDCocYU656', 'Kip', 'Fairholme', 'kfairholme7@theguardian.com', '95716269', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 27);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'lheathcote8', 'SanzKbe1', 'Lillis', 'Heathcote', 'lheathcote8@abc.net.au', '81534822', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 17);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'lcheccucci9', 'e32mCzi5je', 'Leo', 'Checcucci', 'lcheccucci9@guardian.co.uk', '65568625', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 8);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'awehnerra', 'dbCvYC', 'Amity', 'Wehnerr', 'awehnerra@nature.com', '90190740', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 29);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'mcomptonb', 'Tq8QfSOPk', 'Meghann', 'Compton', 'mcomptonb@wired.com', '91859184', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 5);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'lcoweuppec', 'mj4fYK', 'Lorianna', 'Coweuppe', 'lcoweuppec@nyu.edu', '93321355', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 0);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'wvaggesd', '5W0Ipa2UNz', 'Willard', 'Vagges', 'wvaggesd@home.pl', '96079876', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 6);

INSERT INTO Riders (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, total_deliveries)
  VALUES (DEFAULT, 'mkhomine', 'm1qZuIz', 'Marj', 'Khomin', 'mkhomine@archive.org', '90933430', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 28);

----------------------
-- RESTAURANT STAFF --
----------------------

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'houldred0', 'gTM5xoAbeSzW', 'Haleigh', 'Ouldred', 'houldred0@cam.ac.uk', '68947594', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'mcicchinelli1', '0i0dDlCZBLr', 'Mair', 'Cicchinelli', 'mcicchinelli1@who.int', '88093576', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'ndensham2', 'xE2MCl', 'Nari', 'Densham', 'ndensham2@paginegialle.it', '60298707', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'brearie3', 'l1Ow6xW90qt2', 'Britney', 'Rearie', 'brearie3@cdc.gov', '94760768', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'psleicht4', 'sWTTF5WpVF', 'Pierce', 'Sleicht', 'psleicht4@about.me', '92323199', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'abickerton5', 'vM7dGd2cy', 'Avery', 'Bickerton', 'abickerton5@nationalgeographic.com', '99872952', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'awoolvin6', 'EEuTKO', 'Anders', 'Woolvin', 'awoolvin6@scientificamerican.com', '81701678', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'abeebis7', '39QK9nU', 'Ashley', 'Beebis', 'abeebis7@example.com', '87001729', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'sdunbar8', 'sLpSEmO', 'Sophey', 'Dunbar', 'sdunbar8@ed.gov', '95242436', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'mbergstrand9', 'x8RJrOx', 'Martynne', 'Bergstrand', 'mbergstrand9@goo.gl', '93867998', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'gnewarka', 'oBPDL2qC', 'Gunner', 'Newark', 'gnewarka@engadget.com', '88559639', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'aricholdb', 'tb7Pszk', 'Axe', 'Richold', 'aricholdb@yelp.com', '94113032', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'dwhitecrossc', 'hHZJIN7Mgyy', 'Devy', 'Whitecross', 'dwhitecrossc@buzzfeed.com', '99538203', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'dshelsherd', 'e9HmoC8OsG5', 'Dickie', 'Shelsher', 'dshelsherd@noaa.gov', '83353318', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'gdibartolomeoe', '6Jj8rX67uBa', 'Gordan', 'Di Bartolomeo', 'gdibartolomeoe@sciencedaily.com', '87402027', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'gbourgaizef', 'sDda48FaV', 'Gisela', 'Bourgaize', 'gbourgaizef@artisteer.com', '97190367', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'mpeeryg', 'OAgzfTttyp', 'Mellie', 'Peery', 'mpeeryg@ameblo.jp', '99688846', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'swillsmoreh', 'Ol1NaO7kSUy', 'Sherwin', 'Willsmore', 'swillsmoreh@miitbeian.gov.cn', '63404845', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'chandsi', 'rKfDAb', 'Christiano', 'Hands', 'chandsi@bbb.org', '88662559', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'mgreedj', 'MtonZexv', 'Marsha', 'Greed', 'mgreedj@about.com', '97527856', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'glittleyk', '3V30Sk1OM4', 'Gina', 'Littley', 'glittleyk@google.com', '99142009', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'ahammettl', 'KZUx9t', 'Amanda', 'Hammett', 'ahammettl@redcross.org', '92931818', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'bccominim', '4XpBAIMM', 'Burl', 'Ccomini', 'bccominim@google.ca', '90831603', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'cflewinn', 'P6Hy6yy', 'Cosetta', 'Flewin', 'cflewinn@exblog.jp', '68999898', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);

INSERT INTO Staff (uid, username, PASSWORD, first_name, last_name, email, contact_no, registration_date, rid)
  VALUES (DEFAULT, 'fdreyeo', 'lxmm7X', 'Faustina', 'Dreye', 'fdreyeo@scribd.com', '92802951', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);

---------------------
-- FOOD CATEGORIES --
---------------------

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Local');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Western');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Vegetarian');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Chinese');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Malay');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Indian');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Japanese');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Desserts');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Drinks');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Breakfast');

INSERT INTO FoodCategories (fcid, fcname)
  VALUES (DEFAULT, 'Fast food');

-----------
-- FOODS --
-----------

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Loratadine and Pseudoephedrine', 2);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Midodrine Hydrochloride', 2);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'ISAKNOX X202 WHITENING SECRET ESSENCE', 2);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Nyloxin', 6);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'NEOMYCIN SULFATE', 4);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'LBEL Couleur Luxe Rouge Amplifier XP amplifying SPF 15', 7);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Good Sense Heartburn Relief', 10);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Gabapentin', 8);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Gattex', 10);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'TopCare', 4);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Pinchot Juniper', 3);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'ALPRAZOLAM', 7);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'OxyContin', 9);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'FLOVENT', 11);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Fluconazole', 1);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Acetic Acid', 1);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'SkinMedica Daily Physical Defense SPF 30 Sunscreen', 2);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Degree', 2);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'pain relief', 9);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Betamethasone Valerate', 7);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Medicated Pain Relief', 11);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'FSK-5', 3);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Hand Wash', 10);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Tranexamic Acid', 6);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Josie Maran Argan Daily Moisturizer SPF47', 1);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Good Neighbor Pharmacy Pain Relief', 5);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'FLUVIRIN', 7);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'PHENTERMINE HYDROCHLORIDE', 5);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Naproxen', 4);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Anti-Bacterial Moisturizing Hand', 9);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Leader Sore Throat', 1);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Naloxone Hydrochloride', 7);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Drowz Away', 5);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Hydroxyzine Pamoate', 5);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Simvastatin', 11);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Isosorbide Mononitrate', 3);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Anticavity', 5);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Colirio Ocusan', 2);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'Fentanyl Citrate', 11);

INSERT INTO Foods (fid, fname, category)
  VALUES (DEFAULT, 'LBEL Couleur luxe rouge irresistible maximum hydration SPF 17', 5);

----------
-- MENU --
----------

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (31, 1, 188, 14.2);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (40, 3, 254, 10.3);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (7, 1, 138, 7.8);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (18, 4, 181, 14.3);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (28, 2, 158, 5.4);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (5, 3, 98, 11.1);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (17, 4, 223, 5.6);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (17, 3, 97, 1.9);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (15, 2, 71, 1.0);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (35, 3, 153, 4.9);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (5, 1, 175, 3.3);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (19, 1, 147, 3.6);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (23, 3, 11, 7.2);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (6, 1, 177, 1.4);

INSERT INTO Menu (fid, rid, daily_limit, unit_price)
  VALUES (2, 4, 102, 5.5);

----------------------------------
-- DELIVERY COST (REGION-BASED) --
----------------------------------

INSERT INTO DeliveryCost
  VALUES ('central', 2.00);

INSERT INTO DeliveryCost
  VALUES ('north', 2.40);

INSERT INTO DeliveryCost
  VALUES ('northeast', 2.20);

INSERT INTO DeliveryCost
  VALUES ('east', 2.50);

INSERT INTO DeliveryCost
  VALUES ('west', 2.20);

--------------------
-- DELIVERY AREAS --
--------------------
-- District 1

INSERT INTO DeliveryAreas
  VALUES ('central', '01');

INSERT INTO DeliveryAreas
  VALUES ('central', '02');

INSERT INTO DeliveryAreas
  VALUES ('central', '03');

INSERT INTO DeliveryAreas
  VALUES ('central', '04');

INSERT INTO DeliveryAreas
  VALUES ('central', '05');

INSERT INTO DeliveryAreas
  VALUES ('central', '06');

-- District 2
INSERT INTO DeliveryAreas
  VALUES ('central', '07');

INSERT INTO DeliveryAreas
  VALUES ('central', '08');

-- District 3
INSERT INTO DeliveryAreas
  VALUES ('central', '14');

INSERT INTO DeliveryAreas
  VALUES ('central', '15');

INSERT INTO DeliveryAreas
  VALUES ('central', '16');

-- District 4
INSERT INTO DeliveryAreas
  VALUES ('central', '09');

INSERT INTO DeliveryAreas
  VALUES ('central', '10');

-- District 5
INSERT INTO DeliveryAreas
  VALUES ('west', '11');

INSERT INTO DeliveryAreas
  VALUES ('west', '12');

INSERT INTO DeliveryAreas
  VALUES ('west', '13');

-- District 6
INSERT INTO DeliveryAreas
  VALUES ('central', '17');

-- District 7
INSERT INTO DeliveryAreas
  VALUES ('central', '18');

INSERT INTO DeliveryAreas
  VALUES ('central', '19');

-- District 8
INSERT INTO DeliveryAreas
  VALUES ('central', '20');

INSERT INTO DeliveryAreas
  VALUES ('central', '21');

-- District 9
INSERT INTO DeliveryAreas
  VALUES ('central', '22');

INSERT INTO DeliveryAreas
  VALUES ('central', '23');

-- District 10
INSERT INTO DeliveryAreas
  VALUES ('central', '24');

INSERT INTO DeliveryAreas
  VALUES ('central', '25');

INSERT INTO DeliveryAreas
  VALUES ('central', '26');

INSERT INTO DeliveryAreas
  VALUES ('central', '27');

-- District 11
INSERT INTO DeliveryAreas
  VALUES ('central', '28');

INSERT INTO DeliveryAreas
  VALUES ('central', '29');

INSERT INTO DeliveryAreas
  VALUES ('central', '30');

-- District 12
INSERT INTO DeliveryAreas
  VALUES ('central', '31');

INSERT INTO DeliveryAreas
  VALUES ('central', '32');

INSERT INTO DeliveryAreas
  VALUES ('central', '33');

-- District 13
INSERT INTO DeliveryAreas
  VALUES ('central', '34');

INSERT INTO DeliveryAreas
  VALUES ('central', '35');

INSERT INTO DeliveryAreas
  VALUES ('central', '36');

INSERT INTO DeliveryAreas
  VALUES ('central', '37');

-- District 14
INSERT INTO DeliveryAreas
  VALUES ('central', '38');

INSERT INTO DeliveryAreas
  VALUES ('central', '39');

INSERT INTO DeliveryAreas
  VALUES ('central', '40');

INSERT INTO DeliveryAreas
  VALUES ('central', '41');

-- District 15
INSERT INTO DeliveryAreas
  VALUES ('east', '42');

INSERT INTO DeliveryAreas
  VALUES ('east', '43');

INSERT INTO DeliveryAreas
  VALUES ('east', '44');

INSERT INTO DeliveryAreas
  VALUES ('east', '45');

-- District 16
INSERT INTO DeliveryAreas
  VALUES ('east', '46');

INSERT INTO DeliveryAreas
  VALUES ('east', '47');

INSERT INTO DeliveryAreas
  VALUES ('east', '48');

-- District 17
INSERT INTO DeliveryAreas
  VALUES ('east', '49');

INSERT INTO DeliveryAreas
  VALUES ('east', '50');

INSERT INTO DeliveryAreas
  VALUES ('east', '81');

-- District 18
INSERT INTO DeliveryAreas
  VALUES ('east', '51');

INSERT INTO DeliveryAreas
  VALUES ('east', '52');

-- District 19
INSERT INTO DeliveryAreas
  VALUES ('northeast', '53');

INSERT INTO DeliveryAreas
  VALUES ('northeast', '54');

INSERT INTO DeliveryAreas
  VALUES ('northeast', '55');

INSERT INTO DeliveryAreas
  VALUES ('northeast', '82');

-- District 20
INSERT INTO DeliveryAreas
  VALUES ('northeast', '56');

INSERT INTO DeliveryAreas
  VALUES ('northeast', '57');

-- District 21
INSERT INTO DeliveryAreas
  VALUES ('central', '58');

INSERT INTO DeliveryAreas
  VALUES ('central', '59');

-- District 22
INSERT INTO DeliveryAreas
  VALUES ('west', '60');

INSERT INTO DeliveryAreas
  VALUES ('west', '61');

INSERT INTO DeliveryAreas
  VALUES ('west', '62');

INSERT INTO DeliveryAreas
  VALUES ('west', '63');

INSERT INTO DeliveryAreas
  VALUES ('west', '64');

-- District 23
INSERT INTO DeliveryAreas
  VALUES ('west', '65');

INSERT INTO DeliveryAreas
  VALUES ('west', '66');

INSERT INTO DeliveryAreas
  VALUES ('west', '67');

INSERT INTO DeliveryAreas
  VALUES ('west', '68');

-- District 24
INSERT INTO DeliveryAreas
  VALUES ('north', '69');

INSERT INTO DeliveryAreas
  VALUES ('north', '70');

INSERT INTO DeliveryAreas
  VALUES ('north', '71');

-- District 25
INSERT INTO DeliveryAreas
  VALUES ('north', '72');

INSERT INTO DeliveryAreas
  VALUES ('north', '73');

-- District 26
INSERT INTO DeliveryAreas
  VALUES ('central', '77');

INSERT INTO DeliveryAreas
  VALUES ('central', '78');

-- District 27
INSERT INTO DeliveryAreas
  VALUES ('north', '75');

INSERT INTO DeliveryAreas
  VALUES ('north', '76');

-- District 28
INSERT INTO DeliveryAreas
  VALUES ('northeast', '79');

INSERT INTO DeliveryAreas
  VALUES ('northeast', '80');

----------------------------
-- WEEKLY WORK SCHEDULES --
----------------------------
/*
INSERT INTO wws
  VALUES (28, now()::date - interval '4d', '10:00 am', '12:00 pm', '2:00 pm', '5:00 pm');

INSERT INTO wws
  VALUES (28, now()::date - interval '3d', '12:00 pm', '3:00 pm');

INSERT INTO wws
  VALUES (28, now()::date, '10:00 am', '11:00 am', '12:00 pm', '1:00 pm', '2:00 pm', '3:00 pm', '4:00 pm', '5:00 pm', '6:00 pm', '7:00 pm', '8:00 pm', '9:00 pm');

INSERT INTO wws
  VALUES (28, now()::date + interval '1d', '10:00 am', '1:00 pm', '3:00 pm', '5:00 pm');

INSERT INTO wws
  VALUES (35, now()::date - interval '9d', '11:00 am', '12:00 pm', '3:00 pm', '6:00 pm');

INSERT INTO wws
  VALUES (35, now()::date - interval '7d', '11:00 am', '12:00 pm', '3:00 pm', '6:00 pm');
  
  */

