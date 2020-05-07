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
DROP TABLE IF EXISTS WWS_Schedules CASCADE;
DROP TABLE IF EXISTS MWS CASCADE;
DROP TABLE IF EXISTS FullTimers CASCADE;
DROP TABLE IF EXISTS PartTimers CASCADE;
DROP TABLE IF EXISTS Salaries CASCADE;
DROP TABLE IF EXISTS RestaurantStaffs CASCADE;
DROP TABLE IF EXISTS FDSManagers CASCADE;
DROP TABLE IF EXISTS Promotions CASCADE;
DROP TABLE IF EXISTS FDSPromotions CASCADE;
DROP TABLE IF EXISTS RestaurantPromotions CASCADE;
DROP TABLE IF EXISTS Orderlogs CASCADE;
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
	customerId			INTEGER,
	lastLoginDate	 	TIMESTAMP NOT NULL,
	totalExpenditure 	DECIMAL DEFAULT 0,
	orderCount		 	INTEGER DEFAULT 0,
	rewardPoints     	INTEGER DEFAULT 0,

	PRIMARY KEY (customerId),
	FOREIGN KEY (customerId) REFERENCES Users(userId) ON DELETE CASCADE
	);

CREATE TABLE RecentLocations (
	customerId			INTEGER,
	location 			INTEGER NOT NULL, /*postal code*/
	lastUsingTime		TIMESTAMP NOT NULL,

	PRIMARY KEY (customerId, location),
	UNIQUE (customerId, lastUsingTime),
	FOREIGN KEY (customerId) REFERENCES Customers(customerId) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE CreditCards (
    cardNo INTEGER,
    customerId INTEGER NOT NULL,
    bank VARCHAR(20) NOT NULL,
    PRIMARY KEY (cardNo),
    FOREIGN KEY (customerId) REFERENCES Customers (customerId) ON DELETE CASCADE
);

CREATE TABLE Restaurants (
    restaurantId SERIAL,
    name VARCHAR(30) NOT NULL,
    minOrderCost INTEGER DEFAULT 0,
    PRIMARY KEY (restaurantId),
    CHECK (minOrderCost > 0)
);

CREATE TABLE Foods (
    foodId SERIAL,
    name VARCHAR(30) NOT NULL,
    restaurantId INTEGER NOT NULL,
    dailyLimit INTEGER DEFAULT 0,
    quantity INTEGER DEFAULT 0,
    price DECIMAL DEFAULT 0,
    isSold BOOLEAN DEFAULT 't',
    PRIMARY KEY (foodId),
    FOREIGN KEY (restaurantId) REFERENCES Restaurants (restaurantId) ON DELETE CASCADE,
    UNIQUE (name, restaurantId),
    UNIQUE (foodId, restaurantId)
);

CREATE TABLE FoodCategories (
    fcid                INTEGER,
	foodId				INTEGER,
	category			VARCHAR(20) NOT NULL,

	PRIMARY KEY (fcid, foodId),
	FOREIGN KEY (foodId) REFERENCES Foods(foodId) ON DELETE CASCADE
);

CREATE TABLE Carts (
	cartId				INTEGER,
	quantity			INTEGER DEFAULT 1 CHECK (quantity > 0),
	foodId				INTEGER NOT NULL,
	restaurantId		INTEGER NOT NULL,

	PRIMARY KEY (cartId, foodId),
	FOREIGN KEY (cartId) REFERENCES Customers(customerId) ON DELETE CASCADE,
	FOREIGN KEY (foodId) REFERENCES Foods (foodId) ON DELETE CASCADE
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
	baseSalary			DECIMAL NOT NULL CHECK (baseSalary > 0),

	UNIQUE (riderId, startDate),
	PRIMARY KEY (workId),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE,
	CHECK (endDate >= startDate)
);

CREATE TABLE WWS_Schedules (
	workId				INTEGER,
	weekday				VARCHAR(10),
	startTime			SMALLINT CHECK (startTime >= 10 AND startTime < 22),
	endTime				SMALLINT CHECK (endTime > 10 AND endTime <= 2),

	PRIMARY KEY (workId, weekday, startTime),
	FOREIGN KEY (workId) REFERENCES WWS (workId) ON DELETE CASCADE,
	CHECK (endTime > startTime)
);

CREATE TABLE MWS (
	workId				SERIAL,
	riderId				INTEGER NOT NULL,
	startDate			DATE NOT NULL,
	endDate				DATE,
	isUsed				BOOLEAN NOT NULL DEFAULT 't',
	baseSalary			DECIMAL NOT NULL CHECK (baseSalary > 0),
	workDays			INTEGER NOT NULL CHECK (workDays >= 1 and workDays <= 7), /*use 1-7 to represents 7 options of work days*/
	shifts				INTEGER[5] CHECK (1 <= ALL(shifts) and 4 >= ALL(shifts)), /*use 1-4 to represents 4 shifts*/

	UNIQUE (riderId, startDate),
	PRIMARY KEY (workId),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE,
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
    FOREIGN KEY (riderId) REFERENCES DeliveryRiders (riderId) ON DELETE CASCADE,
    FOREIGN KEY (workId) REFERENCES WWS (workId)
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
	promoId 			SERIAL,
	type				INTEGER NOT NULL CHECK (type = 1 or type = 2), /*use integer(1, 2) to represent type*/
	value				INTEGER, /*what does this mean?*/
	startDate			DATE,
	endDate				DATE,
	condition			TEXT, /*how to use this condition?*/
	description			TEXT, /*how to use this description?*/

	PRIMARY KEY (promoId)
);

CREATE TABLE RestaurantPromotions(
	promoId				INTEGER,
	restaurantId		INTEGER,

	PRIMARY KEY (promoId),
	FOREIGN KEY (promoId) REFERENCES Promotions(promoId),
	FOREIGN KEY (restaurantId) REFERENCES Restaurants(restaurantId) ON DELETE SET NULL
);

CREATE TABLE FDSPromotions (
	promoId				INTEGER,
	managerId 			INTEGER,

	PRIMARY KEY (promoId),
	FOREIGN KEY (promoId) REFERENCES Promotions(promoId),
	FOREIGN KEY (managerId) REFERENCES FDSManagers(managerId) ON DELETE SET NULL
);

CREATE TABLE Orderlogs (
	orderId				SERIAL,
	customerId			INTEGER,
	riderId				INTEGER,
	restaurantId		INTEGER,
	orderDate			DATE NOT NULL,
	orderTime			TIME[5], /*five types of time*/
	paymentMethod		INTEGER NOT NULL CHECK (paymentMethod = 1 or paymentMethod = 2),
	cardNo				BIGINT,
	foodFee 			DECIMAL NOT NULL,
	deliveryFee			DECIMAL NOT NULL,
	deliveryLocation	INTEGER NOT NULL,
	promoId				INTEGER,
	ratings 			INTEGER,

	PRIMARY KEY (orderId),
	FOREIGN KEY (customerId) REFERENCES Customers(customerId) ON DELETE SET NULL,
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE SET NULL,
	FOREIGN KEY (restaurantId) REFERENCES Restaurants(restaurantId) ON DELETE SET NULL,
	FOREIGN KEY (promoId) REFERENCES Promotions(promoId),
	CHECK (paymentMethod = 1 AND cardNo IS NOT NULL)

);

CREATE TABLE Orders (
	orderId				INTEGER,
	foodId				INTEGER,
	quantity			INTEGER NOT NULL CHECK (quantity > 0),
	uni_price			DECIMAL NOT NULL,

	PRIMARY KEY (orderId, foodId),
	FOREIGN KEY (orderId) REFERENCES Orderlogs (orderId),
	FOREIGN KEY (foodId) REFERENCES Foods (foodId)
);

CREATE TABLE Reviews (
    orderId integer,
    reviewDate date NOT NULL,
    rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
    /*use points 1-5 to represent rating*/
    feedback text NOT NULL DEFAULT '-NIL-',
    PRIMARY KEY (orderId)
);
