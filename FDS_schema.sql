DROP TABLE IF EXISTS
	Users,
	Customers,
	Riders,
	Staff,
	FDSManagers,
	Restaurants,
	Foods,
	FoodCategories,
	DeliveryCost,
	CreditCards,
	DeliveryAreas,
	Menu,
	Orders,
	OrdersLog
CASCADE;


/* Set Timezone to UTC+8 */
SET timezone=+8;
-- SET timezone='Asia/Singapore'; -- Alternative


/* COMMON HELPER FUNCTIONS */

/*
 * Given date (yyyy-mm-dd),
 * return new date where dd is the last day of the month mm.
 */
CREATE OR REPLACE FUNCTION last_day(DATE)
RETURNS DATE AS
'
	SELECT (date_trunc(''MONTH'', $1) + INTERVAL ''1 MONTH - 1 day'')::DATE;
'
LANGUAGE 'sql' IMMUTABLE STRICT;


/* PARENT TABLES */

CREATE TABLE Users (
	uid 			 	SERIAL,
	username		 	VARCHAR(20) NOT NULL,
	password	     	VARCHAR(20) NOT NULL,
	first_name         	VARCHAR(20) NOT NULL,
	last_name       	VARCHAR(20) NOT NULL,
	email		    	VARCHAR(40),
	contact_no   	 		INTEGER,
	registration_date	TIMESTAMPTZ NOT NULL,
	is_active          	BOOLEAN NOT NULL DEFAULT true,
  last_login			TIMESTAMPTZ NOT NULL,

	PRIMARY KEY (uid),
  UNIQUE (username),
	UNIQUE (contact_no),
	UNIQUE (email),
	CHECK (contact_no >= 10000000 AND contact_no <= 99999999)
);

CREATE TABLE Restaurants (
	rid					SERIAL,
	rname				VARCHAR(60) NOT NULL,
	address				VARCHAR(80) NOT NULL,
	min_order_cost		NUMERIC NOT NULL,
  
	PRIMARY KEY(rid),
	CHECK (min_order_cost > 0.0)
);

CREATE TABLE FoodCategories (
	fcid				SERIAL,
	fcname				VARCHAR(20) NOT NULL,

	PRIMARY KEY (fcid),
  UNIQUE (fcname)
);

CREATE TABLE DeliveryCost (
	region				VARCHAR(10),
	cost				NUMERIC NOT NULL,

	PRIMARY KEY (region)
);


/* CHILD TABLES */

CREATE TABLE Customers (
	points				NUMERIC NOT NULL DEFAULT 0.0,
	total_spending		NUMERIC NOT NULL DEFAULT 0.0,
	total_orders		INTEGER NOT NULL DEFAULT 0,
  last_order_date		TIMESTAMPTZ,

	PRIMARY KEY (uid),
  UNIQUE (username),
	UNIQUE (contact_no),
	UNIQUE (email),
  	CHECK(last_order_date > registration_date),
  	CHECK(last_login >= registration_date)
) INHERITS (Users);

CREATE OR REPLACE FUNCTION check_customers()
	RETURNS TRIGGER AS
    '
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
	FOR EACH ROW EXECUTE PROCEDURE check_customers();

CREATE TABLE CreditCards (
	uid					INTEGER NOT NULL,
	card_no				BIGINT NOT NULL,
	cvv_no				VARCHAR(4) NOT NULL,
	name_on_card		VARCHAR(60) NOT NULL,
	card_type			VARCHAR(30) NOT NULL,
	expiry_date			DATE NOT NULL,

	PRIMARY KEY (uid, card_no),
  UNIQUE (card_no),
	FOREIGN KEY (uid) REFERENCES Customers(uid) ON DELETE CASCADE
);

CREATE TABLE Riders (
	total_deliveries	INTEGER NOT NULL DEFAULT 0,

	PRIMARY KEY (uid),
  UNIQUE (username),
	UNIQUE (contact_no),
	UNIQUE (email),
	CHECK (total_deliveries >= 0)
) INHERITS (Users);

CREATE OR REPLACE FUNCTION check_riders()
	RETURNS TRIGGER AS
    '
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
	FOR EACH ROW EXECUTE PROCEDURE check_riders();

CREATE TABLE MWS (

);

/*
 * dayOfWeek: range [1, 7] => Mon to Sun
 */
CREATE TABLE wws (
  uid integer,
  dayOfWeek integer not null,
  start_1 timetz not null,
  end_1	timetz not null,
  start_2 timetz,
  end_2 timetz,
  start_3 timetz,
  end_3	timetz,
  start_4 timetz,
  end_4 timetz,
  start_5 timetz,
  end_5	timetz,
  start_6 timetz,
  end_6 timetz,
  
  primary key (uid, dayOfWeek),
  
  -- minimum of 1 work hours for each interval
  check (start_1 < end_1 AND end_1::time - start_1::time >=  interval '1h'),
  check (start_2 < end_2 AND end_2::time - start_2::time >=  interval '1h'),
  check (start_3 < end_3 AND end_3::time - start_3::time >=  interval '1h'),
  check (start_4 < end_4 AND end_4::time - start_4::time >=  interval '1h'),
  check (start_5 < end_5 AND end_5::time - start_5::time >=  interval '1h'),
  check (start_6 < end_6 AND end_6::time - start_6::time >=  interval '1h'),
  
  -- Break time between work intervals must be >= 1 hour
  check (
    start_2::time - end_1::time >= interval '1h' 
    AND start_3::time - end_2::time >= interval '1h' 
    AND start_4::time - end_3::time >= interval '1h' 
    AND start_5::time - end_4::time >= interval '1h' 
    AND start_6::time - end_5::time >= interval '1h'
    ),
  
  -- if start time is defined, end time must also be defined
  check (start_2 IS NOT NULL AND end_2 IS NOT NULL OR start_2 IS NULL AND end_2 IS NULL),
  check (start_3 IS NOT NULL AND end_3 IS NOT NULL OR start_3 IS NULL AND end_3 IS NULL),
  check (start_4 IS NOT NULL AND end_4 IS NOT NULL OR start_4 IS NULL AND end_4 IS NULL),
  check (start_5 IS NOT NULL AND end_5 IS NOT NULL OR start_5 IS NULL AND end_5 IS NULL),
  check (start_6 IS NOT NULL AND end_6 IS NOT NULL OR start_6 IS NULL AND end_6 IS NULL),
  
  -- cannot define interval x if interval x - 1 is not defined
  check (start_3 IS NULL OR start_3 IS NOT NULL AND start_2 IS NOT NULL),
  check (start_4 IS NULL OR start_4 IS NOT NULL AND start_3 IS NOT NULL),
  check (start_5 IS NULL OR start_5 IS NOT NULL AND start_4 IS NOT NULL),
  check (start_6 IS NULL OR start_6 IS NOT NULL AND start_5 IS NOT NULL),
  
  -- work hours must be between 10am to 10pm
  check (start_1 >= time '10:00' AND end_1 <= time '22:00'),
  check (start_2 >= time '10:00' AND end_2 <= time '22:00'),
  check (start_3 >= time '10:00' AND end_3 <= time '22:00'),
  check (start_4 >= time '10:00' AND end_4 <= time '22:00'),
  check (start_5 >= time '10:00' AND end_5 <= time '22:00'),
  check (start_6 >= time '10:00' AND end_6 <= time '22:00'),
  
  -- work hours must be on the hour (e.g. 11:00 am - allowed BUT 11:30 am - not allowed)
  check (
    extract(m from start_1) = 0 AND extract(s from start_1) = 0
    AND extract(m from end_1) = 0 AND extract(s from end_1) = 0
  ),
  check (
    extract(m from start_2) = 0 AND extract(s from start_2) = 0
    AND extract(m from end_2) = 0 AND extract(s from end_2) = 0
  ),
  check (
    extract(m from start_3) = 0 AND extract(s from start_3) = 0
    AND extract(m from end_3) = 0 AND extract(s from end_3) = 0
  ),
  check (
    extract(m from start_4) = 0 AND extract(s from start_4) = 0
    AND extract(m from end_4) = 0 AND extract(s from end_4) = 0
  ),
  check (
    extract(m from start_5) = 0 AND extract(s from start_5) = 0
    AND extract(m from end_5) = 0 AND extract(s from end_5) = 0
  ),
  check (
    extract(m from start_6) = 0 AND extract(s from start_6) = 0
    AND extract(m from end_6) = 0 AND extract(s from end_6) = 0
  )
);

CREATE TABLE Staff (
	rid					INTEGER REFERENCES Restaurants(rid) ON DELETE CASCADE,

	PRIMARY KEY (uid),
  UNIQUE (username),
	UNIQUE (contact_no),
	UNIQUE (email)
) INHERITS (Users);

CREATE OR REPLACE FUNCTION check_staff()
	RETURNS TRIGGER AS
    '
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
	FOR EACH ROW EXECUTE PROCEDURE check_staff();

CREATE TABLE FDSManagers (
	PRIMARY KEY (uid),
  UNIQUE (username),
	UNIQUE (contact_no),
	UNIQUE (email)
) INHERITS (Users);

CREATE OR REPLACE FUNCTION check_fdsmanager()
	RETURNS TRIGGER AS
    '
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
	FOR EACH ROW EXECUTE PROCEDURE check_fdsmanager();

CREATE TABLE Foods (
	fid					SERIAL,
	fname 				VARCHAR(100) NOT NULL,
	category			INTEGER NOT NULL REFERENCES FoodCategories(fcid) ON DELETE RESTRICT,

	PRIMARY KEY (fid)
);

CREATE TABLE DeliveryAreas (
	region				VARCHAR(20) REFERENCES DeliveryCost(region) ON DELETE CASCADE,
	postal_sector		VARCHAR(2),

	PRIMARY KEY (region, postal_sector)
);

CREATE TABLE Menu (
	fid					INTEGER REFERENCES Foods(fid) ON DELETE CASCADE,
	rid					INTEGER REFERENCES Restaurants(rid) ON DELETE CASCADE,
	daily_limit 		INTEGER,
	unit_price 			NUMERIC NOT NULL,
    is_available		BOOLEAN,

	PRIMARY KEY (fid, rid),
	CHECK (unit_price > 0.0),
	CHECK (daily_limit >= 0)
);

CREATE OR REPLACE FUNCTION check_menu()
	RETURNS TRIGGER AS
    '
	BEGIN
		IF NEW.daily_limit IS NULL OR NEW.daily_limit > 0 THEN
			NEW.is_available := true;
        ELSE
        	NEW.is_available := false;
		END IF;
		RETURN NEW;
	END;
    '
LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS check_menu_trigger ON Menu;
CREATE TRIGGER check_menu_trigger
	BEFORE INSERT OR UPDATE ON Menu
	FOR EACH ROW EXECUTE PROCEDURE check_menu();

CREATE TABLE Orders (
	uid					INTEGER NOT NULL,
	rid					INTEGER NOT NULL,
	fid					INTEGER NOT NULL,
	unit_price			NUMERIC NOT NULL,
	qty					INTEGER NOT NULL,
	delivery_cost		NUMERIC NOT NULL,
	order_timestamp		TIMESTAMPTZ NOT NULL,
	address				VARCHAR(50) NOT NULL,
	postal_code			VARCHAR(6) NOT NULL,
  payment_method  INTEGER NOT NULL,
  card_no         BIGINT REFERENCES CreditCards(card_no),

	PRIMARY KEY (uid, rid, fid, order_timestamp),
  CHECK (payment_method = 0 AND card_no IS NULL
         OR payment_method <> 0 AND card_no IS NOT NULL)
);

CREATE TABLE OrdersLog (
	oid					SERIAL,
	order_timestamp		TIMESTAMPTZ NOT NULL,
	order_cost			NUMERIC NOT NULL,
	delivery_cost		NUMERIC NOT NULL,
  payment_method  INTEGER NOT NULL,
	rider_id			INTEGER,
	address				VARCHAR(50) NOT NULL,
	postal_code			VARCHAR(6) NOT NULL,
	depart_for_r		TIMESTAMPTZ,
	arrived_at_r		TIMESTAMPTZ,
	depart_for_c		TIMESTAMPTZ,
	arrived_at_c		TIMESTAMPTZ,

	PRIMARY KEY (oid, order_timestamp)
);

/* 
 * TODO:
 * Replace hard-coded values with sub queries
 * to determine the available delivery rider
 * depending on some criterias.
 */
CREATE OR REPLACE FUNCTION log_orders()
	RETURNS TRIGGER AS
	'
	BEGIN
		INSERT INTO OrdersLog(order_timestamp, order_cost, delivery_cost, payment_method, rider_id, address, postal_code) 
			(WITH temp_table as (
        SELECT
          n.order_timestamp,
          SUM(n.unit_price * n.qty) as order_cost,
          n.delivery_cost,
          n.payment_method,
          5 as rider_id,
          n.address,
          n.postal_code
        FROM new_table n
        GROUP BY n.order_timestamp, n.delivery_cost, n.payment_method, n.address, n.postal_code
      )
      SELECT
        order_timestamp,
        SUM(order_cost),
        delivery_cost,
        payment_method,
        rider_id,
        address,
        postal_code
      FROM temp_table
      GROUP BY order_timestamp, delivery_cost, payment_method, rider_id, address, postal_code)
      ;

      RETURN NULL;
	END;
	'
LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS log_orders_trigger ON Orders;
CREATE TRIGGER log_orders_trigger
	AFTER INSERT ON Orders
	REFERENCING NEW TABLE AS new_table
	FOR EACH STATEMENT EXECUTE PROCEDURE log_orders();




------------------
-- FDS MANAGERS --
------------------
insert into FDSManagers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'hbogie0', '2oV0Wpo', 'Halie', 'Bogie', 'hbogie0@earthlink.net', '60690938', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into FDSManagers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'ldufray1', '2NGPg0', 'Lamond', 'Du Fray', 'ldufray1@salon.com', '83119402', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into FDSManagers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'ehaslum2', 'seJd78', 'Emlyn', 'Haslum', 'ehaslum2@cafepress.com', '92332086', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into FDSManagers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'yderle3', 'UM6fWyBlyETB', 'Yvon', 'Derle', 'yderle3@sakura.ne.jp', '92658500', NOW() - (interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));




---------------
-- CUSTOMERS --
---------------
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'sharcus0', 'tvhf0ivDdR', 'Stoddard', 'Harcus', 'sharcus0@mapy.cz', '85096217', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'croskam1', 'Y6DfS70MFaBE', 'Chelsy', 'Roskam', 'croskam1@gravatar.com', '92045140', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'sherries2', '7GaoU0ti6', 'Stanislas', 'Herries', 'sherries2@fc2.com', '67219834', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'jwatford3', 'uRl9GF41', 'Jehu', 'Watford', 'jwatford3@t-online.de', '82426087', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'dhinz4', 'D7F0jGVku', 'Douglass', 'Hinz', 'dhinz4@comcast.net', '86339432', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'yfitzsimons5', 'CUTcjxQyf3q', 'Yuma', 'Fitzsimons', 'yfitzsimons5@seattletimes.com', '89227882', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'btuffey6', '0LUU5Z', 'Boothe', 'Tuffey', 'btuffey6@webs.com', '98016785', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'jgutherson7', '2VyWCGLJ', 'Jill', 'Gutherson', 'jgutherson7@intel.com', '61728893', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'bcumberpatch8', '2oBvpL', 'Berni', 'Cumberpatch', 'bcumberpatch8@xing.com', '85931687', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'dtumilson9', 'tPBhI3kD', 'Danice', 'Tumilson', 'dtumilson9@flavors.me', '83071317', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'dfehelya', 'iMqvYNAUs', 'Darrelle', 'Fehely', 'dfehelya@cdbaby.com', '61345771', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'jingarfillb', 'xuYsjg7qcypq', 'Jordain', 'Ingarfill', 'jingarfillb@wp.com', '97422443', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'dtabbittc', '94ADplNeA7yj', 'Daisy', 'Tabbitt', 'dtabbittc@boston.com', '89363689', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'dethertond', 'a0mUyzele8', 'Derk', 'Etherton', 'dethertond@ebay.com', '98076906', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'emartinete', 'DHBnfJcmcXW', 'Ellwood', 'Martinet', 'emartinete@washingtonpost.com', '94920581', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'dstannionf', 'll6VgwlzP', 'Dianna', 'Stannion', 'dstannionf@dmoz.org', '94067798', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'odukeg', 'dIWgbGa', 'Orella', 'Duke', 'odukeg@hao123.com', '87425358', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'rpiscullih', '4ysxouzDkR7F', 'Roxane', 'Pisculli', 'rpiscullih@bing.com', '97045119', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'lklemensiewiczi', 'p45KOIibZJ', 'Leora', 'Klemensiewicz', 'lklemensiewiczi@time.com', '98563852', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));
insert into Customers (uid, username, password, first_name, last_name, email, contact_no, registration_date) values (DEFAULT, 'slavrickj', 'JVkrs1J0', 'Shep', 'Lavrick', 'slavrickj@bigcartel.com', '80881582', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'));




------------------
-- CREDIT CARDS --
------------------
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (7, '3537771022455820', '0510', 'BRINEY SHADDICK', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (5, '3586676110384289', '7947', 'CAMMY CLEOBURY', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (15, '5550105555083336', '4273', 'JACQUELYN SEARSON', 'mastercard', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (19, '5602219917933134', '226', 'MAURISE MAPLETHORPE', 'bankcard', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (6, '4903986281048462', '7799', 'DEVA CHURCHLEY', 'switch', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (24, '201567223433561', '3178', 'MONROE HUZZEY', 'diners-club-enroute', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (12, '5151506736918816', '992', 'TANITANSY PILSBURY', 'mastercard', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (20, '5108751437906207', '3826', 'BAYARD KILBOURNE', 'mastercard', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (21, '3562138540625391', '4832', 'DORIS RIDETT', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (14, '5572998797411099', '761', 'CECIL SODA', 'diners-club-us-ca', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (9, '50380142212451111', '6389', 'LETICIA KEPPIE', 'maestro', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (10, '5100170636401811', '078', 'JUNIE TOURS', 'mastercard', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (7, '3569446152172518', '385', 'GYPSY NORTHGRAVES', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (6, '3537814557273000', '9573', 'DARLA SZABO', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (11, '3533047214118375', '243', 'DOROLISA KAUSCHER', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (7, '5602229221249663', '2416', 'HUEY COURTOIS', 'china-unionpay', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (16, '3557395920471377', '6002', 'BARBEY FARGUHAR', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (10, '4026346520590539', '4662', 'THOMAS CROIX', 'visa-electron', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (18, '6771091682123417284', '6320', 'MAYBELLE FERRAR', 'laser', last_day((now()::date + (random() * interval '5 years'))::date));
insert into CreditCards (uid, card_no, cvv_no, name_on_card, card_type, expiry_date) values (5, '3579522824652612', '731', 'LOYDIE FIGGER', 'jcb', last_day((now()::date + (random() * interval '5 years'))::date));




-----------------
-- RESTAURANTS --
-----------------
insert into Restaurants (rid, rname, address, min_order_cost) values (DEFAULT, 'Gerhold-Schneider', '37190 Packers Trail', 3.5);
insert into Restaurants (rid, rname, address, min_order_cost) values (DEFAULT, 'Jenkins Group', '54 Moulton Point', 1);
insert into Restaurants (rid, rname, address, min_order_cost) values (DEFAULT, 'Schiller and Sons', '7 Ridgeview Crossing', 3);
insert into Restaurants (rid, rname, address, min_order_cost) values (DEFAULT, 'Vandervort, Smitham and Mohr', '791 Maple Wood Pass', 0.5);




---------------------
-- DELIVERY RIDERS --
---------------------
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'mjoplin0', '99mRUK9SIy', 'Marylinda', 'Joplin', 'mjoplin0@zdnet.com', '91156281', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 15);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'nstiven1', 'bYarJszgIWrW', 'Nolana', 'Stiven', 'nstiven1@live.com', '89047851', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 12);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'mstrete2', 'Gm9FEPo', 'Merl', 'Strete', 'mstrete2@sbwire.com', '96559892', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 29);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'ymacgibbon3', 'CEpdTkWI', 'Yetty', 'MacGibbon', 'ymacgibbon3@nhs.uk', '95690961', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'jantonias4', '6hgaM9p082', 'Jillene', 'Antonias', 'jantonias4@flavors.me', '97666473', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 17);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'bblancowe5', 'H8bHy0pWD3c', 'Brena', 'Blancowe', 'bblancowe5@microsoft.com', '94277769', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 15);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'hgeely6', 'MqjEJ6k1xHA', 'Herbert', 'Geely', 'hgeely6@yahoo.com', '91023570', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 14);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'kfairholme7', 'ShDCocYU656', 'Kip', 'Fairholme', 'kfairholme7@theguardian.com', '95716269', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 27);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'lheathcote8', 'SanzKbe1', 'Lillis', 'Heathcote', 'lheathcote8@abc.net.au', '81534822', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 17);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'lcheccucci9', 'e32mCzi5je', 'Leo', 'Checcucci', 'lcheccucci9@guardian.co.uk', '65568625', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 8);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'awehnerra', 'dbCvYC', 'Amity', 'Wehnerr', 'awehnerra@nature.com', '90190740', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 29);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'mcomptonb', 'Tq8QfSOPk', 'Meghann', 'Compton', 'mcomptonb@wired.com', '91859184', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 5);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'lcoweuppec', 'mj4fYK', 'Lorianna', 'Coweuppe', 'lcoweuppec@nyu.edu', '93321355', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 0);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'wvaggesd', '5W0Ipa2UNz', 'Willard', 'Vagges', 'wvaggesd@home.pl', '96079876', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 6);
insert into Riders (uid, username, password, first_name, last_name, email, contact_no, registration_date, total_deliveries) values (DEFAULT, 'mkhomine', 'm1qZuIz', 'Marj', 'Khomin', 'mkhomine@archive.org', '90933430', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 28);




----------------------
-- RESTAURANT STAFF --
----------------------
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'houldred0', 'gTM5xoAbeSzW', 'Haleigh', 'Ouldred', 'houldred0@cam.ac.uk', '68947594', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'mcicchinelli1', '0i0dDlCZBLr', 'Mair', 'Cicchinelli', 'mcicchinelli1@who.int', '88093576', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'ndensham2', 'xE2MCl', 'Nari', 'Densham', 'ndensham2@paginegialle.it', '60298707', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'brearie3', 'l1Ow6xW90qt2', 'Britney', 'Rearie', 'brearie3@cdc.gov', '94760768', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'psleicht4', 'sWTTF5WpVF', 'Pierce', 'Sleicht', 'psleicht4@about.me', '92323199', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'abickerton5', 'vM7dGd2cy', 'Avery', 'Bickerton', 'abickerton5@nationalgeographic.com', '99872952', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'awoolvin6', 'EEuTKO', 'Anders', 'Woolvin', 'awoolvin6@scientificamerican.com', '81701678', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'abeebis7', '39QK9nU', 'Ashley', 'Beebis', 'abeebis7@example.com', '87001729', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'sdunbar8', 'sLpSEmO', 'Sophey', 'Dunbar', 'sdunbar8@ed.gov', '95242436', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'mbergstrand9', 'x8RJrOx', 'Martynne', 'Bergstrand', 'mbergstrand9@goo.gl', '93867998', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'gnewarka', 'oBPDL2qC', 'Gunner', 'Newark', 'gnewarka@engadget.com', '88559639', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'aricholdb', 'tb7Pszk', 'Axe', 'Richold', 'aricholdb@yelp.com', '94113032', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'dwhitecrossc', 'hHZJIN7Mgyy', 'Devy', 'Whitecross', 'dwhitecrossc@buzzfeed.com', '99538203', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'dshelsherd', 'e9HmoC8OsG5', 'Dickie', 'Shelsher', 'dshelsherd@noaa.gov', '83353318', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'gdibartolomeoe', '6Jj8rX67uBa', 'Gordan', 'Di Bartolomeo', 'gdibartolomeoe@sciencedaily.com', '87402027', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'gbourgaizef', 'sDda48FaV', 'Gisela', 'Bourgaize', 'gbourgaizef@artisteer.com', '97190367', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 3);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'mpeeryg', 'OAgzfTttyp', 'Mellie', 'Peery', 'mpeeryg@ameblo.jp', '99688846', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'swillsmoreh', 'Ol1NaO7kSUy', 'Sherwin', 'Willsmore', 'swillsmoreh@miitbeian.gov.cn', '63404845', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'chandsi', 'rKfDAb', 'Christiano', 'Hands', 'chandsi@bbb.org', '88662559', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'mgreedj', 'MtonZexv', 'Marsha', 'Greed', 'mgreedj@about.com', '97527856', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'glittleyk', '3V30Sk1OM4', 'Gina', 'Littley', 'glittleyk@google.com', '99142009', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 1);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'ahammettl', 'KZUx9t', 'Amanda', 'Hammett', 'ahammettl@redcross.org', '92931818', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'bccominim', '4XpBAIMM', 'Burl', 'Ccomini', 'bccominim@google.ca', '90831603', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'cflewinn', 'P6Hy6yy', 'Cosetta', 'Flewin', 'cflewinn@exblog.jp', '68999898', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 2);
insert into Staff (uid, username, password, first_name, last_name, email, contact_no, registration_date, rid) values (DEFAULT, 'fdreyeo', 'lxmm7X', 'Faustina', 'Dreye', 'fdreyeo@scribd.com', '92802951', NOW() - (random() * interval '5 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'), 4);




---------------------
-- FOOD CATEGORIES --
---------------------
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Local');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Western');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Vegetarian');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Chinese');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Malay');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Indian');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Japanese');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Desserts');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Drinks');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Breakfast');
insert into FoodCategories (fcid, fcname) values (DEFAULT, 'Fast food');




-----------
-- FOODS --
-----------
insert into Foods (fid, fname, category) values (DEFAULT, 'Loratadine and Pseudoephedrine', 2);
insert into Foods (fid, fname, category) values (DEFAULT, 'Midodrine Hydrochloride', 2);
insert into Foods (fid, fname, category) values (DEFAULT, 'ISAKNOX X202 WHITENING SECRET ESSENCE', 2);
insert into Foods (fid, fname, category) values (DEFAULT, 'Nyloxin', 6);
insert into Foods (fid, fname, category) values (DEFAULT, 'NEOMYCIN SULFATE', 4);
insert into Foods (fid, fname, category) values (DEFAULT, 'LBEL Couleur Luxe Rouge Amplifier XP amplifying SPF 15', 7);
insert into Foods (fid, fname, category) values (DEFAULT, 'Good Sense Heartburn Relief', 10);
insert into Foods (fid, fname, category) values (DEFAULT, 'Gabapentin', 8);
insert into Foods (fid, fname, category) values (DEFAULT, 'Gattex', 10);
insert into Foods (fid, fname, category) values (DEFAULT, 'TopCare', 4);
insert into Foods (fid, fname, category) values (DEFAULT, 'Pinchot Juniper', 3);
insert into Foods (fid, fname, category) values (DEFAULT, 'ALPRAZOLAM', 7);
insert into Foods (fid, fname, category) values (DEFAULT, 'OxyContin', 9);
insert into Foods (fid, fname, category) values (DEFAULT, 'FLOVENT', 11);
insert into Foods (fid, fname, category) values (DEFAULT, 'Fluconazole', 1);
insert into Foods (fid, fname, category) values (DEFAULT, 'Acetic Acid', 1);
insert into Foods (fid, fname, category) values (DEFAULT, 'SkinMedica Daily Physical Defense SPF 30 Sunscreen', 2);
insert into Foods (fid, fname, category) values (DEFAULT, 'Degree', 2);
insert into Foods (fid, fname, category) values (DEFAULT, 'pain relief', 9);
insert into Foods (fid, fname, category) values (DEFAULT, 'Betamethasone Valerate', 7);
insert into Foods (fid, fname, category) values (DEFAULT, 'Medicated Pain Relief', 11);
insert into Foods (fid, fname, category) values (DEFAULT, 'FSK-5', 3);
insert into Foods (fid, fname, category) values (DEFAULT, 'Hand Wash', 10);
insert into Foods (fid, fname, category) values (DEFAULT, 'Tranexamic Acid', 6);
insert into Foods (fid, fname, category) values (DEFAULT, 'Josie Maran Argan Daily Moisturizer SPF47', 1);
insert into Foods (fid, fname, category) values (DEFAULT, 'Good Neighbor Pharmacy Pain Relief', 5);
insert into Foods (fid, fname, category) values (DEFAULT, 'FLUVIRIN', 7);
insert into Foods (fid, fname, category) values (DEFAULT, 'PHENTERMINE HYDROCHLORIDE', 5);
insert into Foods (fid, fname, category) values (DEFAULT, 'Naproxen', 4);
insert into Foods (fid, fname, category) values (DEFAULT, 'Anti-Bacterial Moisturizing Hand', 9);
insert into Foods (fid, fname, category) values (DEFAULT, 'Leader Sore Throat', 1);
insert into Foods (fid, fname, category) values (DEFAULT, 'Naloxone Hydrochloride', 7);
insert into Foods (fid, fname, category) values (DEFAULT, 'Drowz Away', 5);
insert into Foods (fid, fname, category) values (DEFAULT, 'Hydroxyzine Pamoate', 5);
insert into Foods (fid, fname, category) values (DEFAULT, 'Simvastatin', 11);
insert into Foods (fid, fname, category) values (DEFAULT, 'Isosorbide Mononitrate', 3);
insert into Foods (fid, fname, category) values (DEFAULT, 'Anticavity', 5);
insert into Foods (fid, fname, category) values (DEFAULT, 'Colirio Ocusan', 2);
insert into Foods (fid, fname, category) values (DEFAULT, 'Fentanyl Citrate', 11);
insert into Foods (fid, fname, category) values (DEFAULT, 'LBEL Couleur luxe rouge irresistible maximum hydration SPF 17', 5);




----------
-- MENU --
----------
insert into Menu (fid, rid, daily_limit, unit_price) values (31, 1, 188, 14.2);
insert into Menu (fid, rid, daily_limit, unit_price) values (40, 3, 254, 10.3);
insert into Menu (fid, rid, daily_limit, unit_price) values (7, 1, 138, 7.8);
insert into Menu (fid, rid, daily_limit, unit_price) values (18, 4, 181, 14.3);
insert into Menu (fid, rid, daily_limit, unit_price) values (28, 2, 158, 5.4);
insert into Menu (fid, rid, daily_limit, unit_price) values (5, 3, 98, 11.1);
insert into Menu (fid, rid, daily_limit, unit_price) values (17, 4, 223, 5.6);
insert into Menu (fid, rid, daily_limit, unit_price) values (17, 3, 97, 1.9);
insert into Menu (fid, rid, daily_limit, unit_price) values (15, 2, 71, 1.0);
insert into Menu (fid, rid, daily_limit, unit_price) values (35, 3, 153, 4.9);
insert into Menu (fid, rid, daily_limit, unit_price) values (5, 1, 175, 3.3);
insert into Menu (fid, rid, daily_limit, unit_price) values (19, 1, 147, 3.6);
insert into Menu (fid, rid, daily_limit, unit_price) values (23, 3, 11, 7.2);
insert into Menu (fid, rid, daily_limit, unit_price) values (6, 1, 177, 1.4);
insert into Menu (fid, rid, daily_limit, unit_price) values (2, 4, 102, 5.5);




----------------------------------
-- DELIVERY COST (REGION-BASED) --
----------------------------------
insert into DeliveryCost values ('central', 2.00);
insert into DeliveryCost values ('north', 2.40);
insert into DeliveryCost values ('northeast', 2.20);
insert into DeliveryCost values ('east', 2.50);
insert into DeliveryCost values ('west', 2.20);




--------------------
-- DELIVERY AREAS --
--------------------
-- District 1
insert into DeliveryAreas values ('central', '01');
insert into DeliveryAreas values ('central', '02');
insert into DeliveryAreas values ('central', '03');
insert into DeliveryAreas values ('central', '04');
insert into DeliveryAreas values ('central', '05');
insert into DeliveryAreas values ('central', '06');

-- District 2
insert into DeliveryAreas values ('central', '07');
insert into DeliveryAreas values ('central', '08');

-- District 3
insert into DeliveryAreas values ('central', '14');
insert into DeliveryAreas values ('central', '15');
insert into DeliveryAreas values ('central', '16');

-- District 4
insert into DeliveryAreas values ('central', '09');
insert into DeliveryAreas values ('central', '10');

-- District 5
insert into DeliveryAreas values ('west', '11');
insert into DeliveryAreas values ('west', '12');
insert into DeliveryAreas values ('west', '13');

-- District 6
insert into DeliveryAreas values ('central', '17');

-- District 7
insert into DeliveryAreas values ('central', '18');
insert into DeliveryAreas values ('central', '19');

-- District 8
insert into DeliveryAreas values ('central', '20');
insert into DeliveryAreas values ('central', '21');

-- District 9
insert into DeliveryAreas values ('central', '22');
insert into DeliveryAreas values ('central', '23');

-- District 10
insert into DeliveryAreas values ('central', '24');
insert into DeliveryAreas values ('central', '25');
insert into DeliveryAreas values ('central', '26');
insert into DeliveryAreas values ('central', '27');

-- District 11
insert into DeliveryAreas values ('central', '28');
insert into DeliveryAreas values ('central', '29');
insert into DeliveryAreas values ('central', '30');

-- District 12
insert into DeliveryAreas values ('central', '31');
insert into DeliveryAreas values ('central', '32');
insert into DeliveryAreas values ('central', '33');

-- District 13
insert into DeliveryAreas values ('central', '34');
insert into DeliveryAreas values ('central', '35');
insert into DeliveryAreas values ('central', '36');
insert into DeliveryAreas values ('central', '37');

-- District 14
insert into DeliveryAreas values ('central', '38');
insert into DeliveryAreas values ('central', '39');
insert into DeliveryAreas values ('central', '40');
insert into DeliveryAreas values ('central', '41');

-- District 15
insert into DeliveryAreas values ('east', '42');
insert into DeliveryAreas values ('east', '43');
insert into DeliveryAreas values ('east', '44');
insert into DeliveryAreas values ('east', '45');

-- District 16
insert into DeliveryAreas values ('east', '46');
insert into DeliveryAreas values ('east', '47');
insert into DeliveryAreas values ('east', '48');

-- District 17
insert into DeliveryAreas values ('east', '49');
insert into DeliveryAreas values ('east', '50');
insert into DeliveryAreas values ('east', '81');

-- District 18
insert into DeliveryAreas values ('east', '51');
insert into DeliveryAreas values ('east', '52');

-- District 19
insert into DeliveryAreas values ('northeast', '53');
insert into DeliveryAreas values ('northeast', '54');
insert into DeliveryAreas values ('northeast', '55');
insert into DeliveryAreas values ('northeast', '82');

-- District 20
insert into DeliveryAreas values ('northeast', '56');
insert into DeliveryAreas values ('northeast', '57');

-- District 21
insert into DeliveryAreas values ('central', '58');
insert into DeliveryAreas values ('central', '59');

-- District 22
insert into DeliveryAreas values ('west', '60');
insert into DeliveryAreas values ('west', '61');
insert into DeliveryAreas values ('west', '62');
insert into DeliveryAreas values ('west', '63');
insert into DeliveryAreas values ('west', '64');

-- District 23
insert into DeliveryAreas values ('west', '65');
insert into DeliveryAreas values ('west', '66');
insert into DeliveryAreas values ('west', '67');
insert into DeliveryAreas values ('west', '68');

-- District 24
insert into DeliveryAreas values ('north', '69');
insert into DeliveryAreas values ('north', '70');
insert into DeliveryAreas values ('north', '71');

-- District 25
insert into DeliveryAreas values ('north', '72');
insert into DeliveryAreas values ('north', '73');

-- District 26
insert into DeliveryAreas values ('central', '77');
insert into DeliveryAreas values ('central', '78');

-- District 27
insert into DeliveryAreas values ('north', '75');
insert into DeliveryAreas values ('north', '76');

-- District 28
insert into DeliveryAreas values ('northeast', '79');
insert into DeliveryAreas values ('northeast', '80');




------------
-- ORDERS --
------------
/* 
Orders table columns:
uid | rid | fid | unit_price | qty | delivery_cost | order_timestamp | address | postal_code
primary key: (uid, rid, fid, order_timestamp)
*/


