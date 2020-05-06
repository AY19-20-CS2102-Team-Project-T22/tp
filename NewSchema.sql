DROP TABLE IF EXISTS Users CASCADE;

DROP TABLE IF EXISTS Customers CASCADE;

DROP TABLE IF EXISTS RecentLocations CASCADE;

DROP TABLE IF EXISTS CreditCards CASCADE;

DROP TABLE IF EXISTS Restaurants CASCADE;

DROP TABLE IF EXISTS Foods CASCADE;

DROP TABLE IF EXISTS FoodCategories CASCADE;

DROP TABLE IF EXISTS Carts CASCADE;

DROP TABLE IF EXISTS DeliveryRiders CASCADE;

DROP TABLE IF EXISTS WWS CASCADE;

DROP TABLE IF EXISTS WWS_SCHEDULES CASCADE;

DROP TABLE IF EXISTS MWS CASCADE;

DROP TABLE IF EXISTS FullTimers CASCADE;

DROP TABLE IF EXISTS PartTimers CASCADE;

DROP TABLE IF EXISTS Salaries CASCADE;

DROP TABLE IF EXISTS RestaurantStaffs CASCADE;

DROP TABLE IF EXISTS FDSManagers CASCADE;

DROP TABLE IF EXISTS Promotions CASCADE;

DROP TABLE IF EXISTS FDSPromotions CASCADE;

DROP TABLE IF EXISTS RestaurantPromotions CASCADE;

DROP TABLE IF EXISTS Orders CASCADE;

DROP TABLE IF EXISTS Reviews CASCADE;


/*SET TIMEZONE = +8;*/
CREATE TABLE Users (
	userId				SERIAL,
	type 				INTEGER NOT NULL CHECK (type >= 1 and type <= 4),
	userName		 	VARCHAR(30) NOT NULL,
	userPassword     	VARCHAR(30) NOT NULL,
	lastName         	VARCHAR(20) NOT NULL,
	firstName       	VARCHAR(20) NOT NULL,
	phoneNumber     	INTEGER NOT NULL,
	registrationDate	TIMESTAMP NOT NULL,
	email				VARCHAR NOT NULL,
	active          	BOOLEAN NOT NULL,

	PRIMARY KEY (userId),
	UNIQUE (phoneNumber),
	UNIQUE (email),
	UNIQUE (userName),
	CHECK (phoneNumber >= 10000000 and phoneNumber <= 99999999)
);

CREATE TABLE Customers (
    customerId integer,
    lastLoginDate timestamp NOT NULL,
    totalExpenditure DECIMAL DEFAULT 0,
    orderCount integer DEFAULT 0,
    rewardPoints integer DEFAULT 0,
    PRIMARY KEY (customerId),
    FOREIGN KEY (customerId) REFERENCES Users (userId) ON DELETE CASCADE
);

CREATE TABLE RecentLocations (
    customerId integer,
    location INTEGER NOT NULL,
    /*postal code*/
    lastUsingTime timestamp NOT NULL,
    PRIMARY KEY (customerId, lastUsingTime),
    FOREIGN KEY (customerId) REFERENCES Users (userId) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CreditCards (
    cardNo integer,
    customerId integer NOT NULL,
    bank varchar(20) NOT NULL,
    PRIMARY KEY (cardNo),
    FOREIGN KEY (customerId) REFERENCES Customers (customerId) ON DELETE CASCADE
);

CREATE TABLE Restaurants (
    restaurantId serial,
    name varchar(30) NOT NULL,
    minOrderCost integer DEFAULT 0,
    PRIMARY KEY (restaurantId),
    CHECK (minOrderCost > 0)
);

CREATE TABLE Foods (
    foodId serial,
    name varchar(30) NOT NULL,
    restaurantId integer NOT NULL,
    dailyLimit integer DEFAULT 0,
    quantity integer DEFAULT 0,
    price DECIMAL DEFAULT 0,
    isSold boolean DEFAULT 't',
    PRIMARY KEY (foodId),
    FOREIGN KEY (restaurantId) REFERENCES Restaurants (restaurantId) ON DELETE CASCADE,
    UNIQUE (name, restaurantId),
    UNIQUE (foodId, restaurantId)
);

CREATE TABLE FoodCategories (
    foodId integer,
    category varchar(20),
    PRIMARY KEY (foodId, category),
    FOREIGN KEY (foodId) REFERENCES Foods (foodId) ON DELETE CASCADE
);

CREATE TABLE Carts (
	cartId				INTEGER,
	quantity			INTEGER DEFAULT 1,
	foodId				INTEGER NOT NULL,
	restaurantId		INTEGER NOT NULL,

	PRIMARY KEY (cartId, foodId),
	FOREIGN KEY (cartId) REFERENCES Customers(customerId) ON DELETE CASCADE,
	FOREIGN KEY (foodId, restaurantId) REFERENCES Foods (foodId, restaurantId) ON DELETE CASCADE ON UPDATE CASCADE
	/*Order in only one restaurant*/

);

CREATE TABLE DeliveryRiders (
    riderId integer,
    type INTEGER NOT NULL CHECK (TYPE = 1 OR TYPE = 2),
    PRIMARY KEY (riderId),
    FOREIGN KEY (riderId) REFERENCES Users (userId) ON DELETE CASCADE
);

CREATE TABLE WWS (
	workId				SERIAL,
	riderId				INTEGER NOT NULL,
	startDate			DATE NOT NULL,
	endDate				DATE,
	isUsed				BOOLEAN NOT NULL DEFAULT 't',
	workDays			INTEGER NOT NULL CHECK (workDays >= 1 and workDays <= 7), /*use 1-7 to represents 7 options of work days*/
	baseSalary			DECIMAL NOT NULL CHECK (baseSalary > 0),

	UNIQUE (riderId, startDate),
	PRIMARY KEY (workId),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE,
	CHECK (endDate >= startDate)
);

CREATE TABLE WWS_Schedules (
    workId integer,
    weekday varchar(10),
    startTime smallint CHECK (startTime >= 0 AND startTime < 24),
    endTime smallint CHECK (endTime > 0 AND endTime <= 24),
    PRIMARY KEY (workId, weekday, startTime),
    FOREIGN KEY (workId) REFERENCES WWS (workId) ON DELETE CASCADE,
    CHECK (endTime > startTime)
);

CREATE TABLE MWS (
    workId serial,
    riderId integer NOT NULL,
    startDate date NOT NULL,
    endDate date,
    isUsed boolean NOT NULL DEFAULT 't',
    baseSalary DECIMAL NOT NULL CHECK (baseSalary > 0),
    workDays integer NOT NULL CHECK (workDays >= 1 AND workDays <= 7),
    /*use 1-7 to represents 7 options of work days*/
    shifts integer[5] CHECK (1 <= ALL (shifts) AND 4 >= ALL (shifts)),
    /*use 1-4 to represents 4 shifts*/
    UNIQUE (riderId, startDate),
    PRIMARY KEY (workId),
    FOREIGN KEY (riderId) REFERENCES DeliveryRiders (riderId) ON DELETE CASCADE,
    CHECK (endDate >= startDate)
);


/* how to add base salary to daily salary?*/
CREATE TABLE FullTimers (
    riderId integer,
    workId integer NOT NULL,
    PRIMARY KEY (riderId),
    FOREIGN KEY (riderId) REFERENCES DeliveryRiders (riderId) ON DELETE CASCADE,
    FOREIGN KEY (workId) REFERENCES MWS (workId)
);

CREATE TABLE PartTimers (
    riderId integer,
    workId integer NOT NULL,
    PRIMARY KEY (riderId),
    FOREIGN KEY (riderId) REFERENCES DeliveryRiders (riderId) ON DELETE CASCADE
);


/*salary will be calculated at the end of every month (no matter type of riders)*/
/*CREATE TABLE Salaries (
riderId				INTEGER,
day					DATE,
amount				DECIMAL DEFAULT 0,

PRIMARY KEY (riderId, day),
FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE
);
 */
CREATE TABLE RestaurantStaffs (
    staffId integer,
    restaurantId integer NOT NULL,
    PRIMARY KEY (staffId),
    FOREIGN KEY (staffId) REFERENCES Users (userId) ON DELETE CASCADE,
    FOREIGN KEY (restaurantId) REFERENCES Restaurants (restaurantId) ON DELETE CASCADE
);

CREATE TABLE FDSManagers (
    managerId integer,
    PRIMARY KEY (managerId),
    FOREIGN KEY (managerId) REFERENCES Users (userId) ON DELETE CASCADE
);


/*cannot delete any record*/
CREATE TABLE Promotions (
    promoId serial,
    type INTEGER NOT NULL CHECK (TYPE = 1 OR TYPE = 2),
    /*use integer(1, 2) to represent type*/
    value integer,
    /*what does this mean?*/
    startDate date,
    endDate date,
    condition text,
    /*how to use this condition?*/
    description text,
    /*how to use this description?*/
    PRIMARY KEY (promoId)
);

CREATE TABLE RestaurantPromotions (
    promoId integer,
    restaurantId integer,
    PRIMARY KEY (promoId),
    FOREIGN KEY (promoId) REFERENCES Promotions (promoId),
    FOREIGN KEY (restaurantId) REFERENCES Restaurants (restaurantId) ON DELETE SET NULL
);

CREATE TABLE FDSPromotions (
    promoId integer,
    managerId integer,
    PRIMARY KEY (promoId),
    FOREIGN KEY (promoId) REFERENCES Promotions (promoId),
    FOREIGN KEY (managerId) REFERENCES FDSManagers (managerId) ON DELETE SET NULL
);

CREATE TABLE Orders (
    orderId serial,
    customerId integer,
    riderId integer,
    restaurantId integer,
    orderTime timestamp[5],
    /*five types of time*/
    paymentMethod integer NOT NULL CHECK (paymentMethod = 1 OR paymentMethod = 2),
    cardNo bigint,
    foodFee DECIMAL NOT NULL,
    deliveryFee DECIMAL NOT NULL,
    deliveryLocation integer NOT NULL,
    promoId integer,
    PRIMARY KEY (orderId),
    FOREIGN KEY (customerId) REFERENCES Customers (customerId) ON DELETE SET NULL,
    FOREIGN KEY (riderId) REFERENCES DeliveryRiders (riderId) ON DELETE SET NULL,
    FOREIGN KEY (restaurantId) REFERENCES Restaurants (restaurantId) ON DELETE SET NULL,
    FOREIGN KEY (promoId) REFERENCES Promotions (promoId),
    CHECK (paymentMethod = 1 AND cardNo IS NOT NULL)
);

CREATE TABLE Reviews (
    orderId integer,
    reviewDate date NOT NULL,
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    /*use points 1-5 to represent rating*/
    feedback text NOT NULL DEFAULT '-NIL-',
    PRIMARY KEY (orderId)
);

