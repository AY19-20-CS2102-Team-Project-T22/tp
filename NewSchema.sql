DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS RecentLocations CASCADE;
DROP TABLE IF EXISTS CreditCards CASCADE;
DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS Foods CASCADE;
DROP TABLE IF EXISTS FoodCategories CASCADE;
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
DROP TABLE IF EXISTS MWS_Schedules_Times CASCADE;
DROP TABLE IF EXISTS MWS_Schedules_Days CASCADE;



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
    cardNo				BIGINT,
    customerId 			INTEGER NOT NULL,
    bank				VARCHAR(30) NOT NULL,
	expiryDate			TIMESTAMP NOT NULL,
    
    PRIMARY KEY (cardNo),
    FOREIGN KEY (customerId) REFERENCES Customers (customerId) ON DELETE CASCADE
);

CREATE TABLE Restaurants (
    restaurantId		SERIAL,
    name 				VARCHAR(50) NOT NULL,
    minOrderCost 		INTEGER DEFAULT 0,
    
    PRIMARY KEY (restaurantId),
    CHECK (minOrderCost > 0)
);

CREATE TABLE Foods (
    foodId 				SERIAL,
    name 				VARCHAR(40) NOT NULL,
    restaurantId 		INTEGER NOT NULL,
    dailyLimit 			INTEGER DEFAULT 0,
    quantity 			INTEGER DEFAULT 0,
    price 				DECIMAL DEFAULT 0,
    isSold 				BOOLEAN DEFAULT 't',
    
    PRIMARY KEY (foodId),
    FOREIGN KEY (restaurantId) REFERENCES Restaurants (restaurantId) ON DELETE CASCADE,
    UNIQUE (name, restaurantId),
    UNIQUE (foodId, restaurantId)
);

CREATE TABLE FoodCategories (
    fcid				INTEGER,
	foodId				INTEGER,
	category			VARCHAR(30) NOT NULL,

	PRIMARY KEY (fcid, foodId),
	UNIQUE (category, foodId),
	FOREIGN KEY (foodId) REFERENCES Foods(foodId) ON DELETE CASCADE
);

CREATE TABLE DeliveryRiders (
    riderId 			INTEGER,
    type 				INTEGER NOT NULL CHECK (TYPE = 1 OR TYPE = 2),
    
    PRIMARY KEY (riderId),
    FOREIGN KEY (riderId) REFERENCES Users (userId) ON DELETE CASCADE
);

CREATE TABLE WWS (
	workId				SERIAL,
	riderId				INTEGER NOT NULL,
	startDate			DATE NOT NULL,
	endDate				DATE DEFAULT NULL, 
	baseSalary			DECIMAL NOT NULL CHECK (baseSalary >= 0),

	UNIQUE (riderId, startDate),
	PRIMARY KEY (workId),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE,
	CHECK (endDate > startDate AND (endDate - startDate) % 7 = 0)
);

CREATE TABLE WWS_Schedules (
	workId				INTEGER,
	weekday				VARCHAR(10),
	startTime			SMALLINT CHECK (startTime >= 10 AND startTime < 22),
	endTime				SMALLINT CHECK (endTime > 10 AND endTime <= 22),

	PRIMARY KEY (workId, weekday, startTime),
	FOREIGN KEY (workId) REFERENCES WWS (workId) ON DELETE CASCADE,
	CHECK (endTime > startTime AND endTime - startTime <= 4)
);

CREATE TABLE MWS_Schedules_times (
	shiftId				INTEGER CHECK(1 <= shiftId and 4>= shiftId),
	startTime			SMALLINT[2] CHECK (10 <= ALL(startTime) AND 22 > ALL(startTime)),
	endTime				SMALLINT[2] CHECK (10 < ALL(endTime) AND 22>= ALL(endTime)),

	PRIMARY KEY(shiftId)
);

CREATE TABLE MWS_Schedules_days (
	workWeekId	INTEGER CHECK( workWeekId >= 1 AND workWeekId <= 7),
	workDays VARCHAR(10)[5] NOT NULL,

	PRIMARY KEY(workWeekId)

);



CREATE TABLE MWS (
	riderId				INTEGER NOT NULL,
	startDate 			DATE NOT NULL,
	endDate 			DATE DEFAULT NULL,
	baseSalary 			DECIMAL NOT NULL CHECK (baseSalary >= 0) ,
	workWeekId			SMALLINT CHECK (workWeekId >= 1 AND workWeekId <= 7),
	shifts				INTEGER[5] CHECK (1 <= ALL(shifts) and 4 >= ALL(shifts)), /*use 1-4 to represents 4 shifts*/

	PRIMARY KEY (riderId, startDate),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE,
	FOREIGN KEY (workWeekId) REFERENCES MWS_Schedules_Days(workWeekId),
	CHECK (endDate > startDate AND (endDate - startDate) % 28 = 0)

);

/* how to add base salary to daily salary?*/
CREATE TABLE FullTimers (
    riderId				INTEGER,
    
    PRIMARY KEY (riderId),
    FOREIGN KEY (riderId) REFERENCES DeliveryRiders (riderId) ON DELETE CASCADE
);

CREATE TABLE PartTimers (
    riderId 			INTEGER,
    
    PRIMARY KEY (riderId),
    FOREIGN KEY (riderId) REFERENCES DeliveryRiders (riderId) ON DELETE CASCADE
);

CREATE TABLE RestaurantStaffs (
    staffId 			INTEGER,
    restaurantId 		INTEGER NOT NULL,
    
    PRIMARY KEY (staffId),
    FOREIGN KEY (staffId) REFERENCES Users (userId) ON DELETE CASCADE,
    FOREIGN KEY (restaurantId) REFERENCES Restaurants (restaurantId) ON DELETE CASCADE
);

CREATE TABLE FDSManagers (
    managerId 			INTEGER,
    
    PRIMARY KEY (managerId),
    FOREIGN KEY (managerId) REFERENCES Users (userId) ON DELETE CASCADE
);


/*cannot delete any record*/
CREATE TABLE Promotions (
	promoId 			SERIAL,
	type				INTEGER NOT NULL CHECK (type = 1 or type = 2), /*use integer(1, 2) to represent type*/
	discountValue		NUMERIC, /*what does this mean?*/
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
	orderTime			TIME[5] CHECK (orderTime[1] IS NOT NULL), /*order placed, time rider depart, arrive at restaurant, departs from rest, delivered*/
	paymentMethod		INTEGER NOT NULL CHECK (paymentMethod = 1 OR paymentMethod = 2),
	cardNo				BIGINT,
	foodFee 			DECIMAL NOT NULL,
	deliveryFee			DECIMAL NOT NULL,
	deliveryLocation	INTEGER NOT NULL,
	promoId				INTEGER,

	PRIMARY KEY (orderId),
	FOREIGN KEY (customerId) REFERENCES Customers(customerId) ON DELETE SET NULL,
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE SET NULL,
	FOREIGN KEY (restaurantId) REFERENCES Restaurants(restaurantId) ON DELETE SET NULL,
	FOREIGN KEY (promoId) REFERENCES Promotions(promoId),
	CHECK (orderTime[1] < orderTime[2] AND orderTime[2] < orderTime[3] AND orderTime[3] < orderTime[4] AND orderTime[4] < orderTime[5])

);

CREATE TABLE Orders (
	orderId				INTEGER,
	foodId				INTEGER,
	quantity			INTEGER NOT NULL CHECK (quantity > 0),

	PRIMARY KEY (orderId, foodId),
	FOREIGN KEY (orderId) REFERENCES Orderlogs (orderId),
	FOREIGN KEY (foodId) REFERENCES Foods (foodId)
);

CREATE TABLE Reviews (
    orderId 			INTEGER,
    reviewDate 			DATE NOT NULL,
    rating 				INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    /*use points 1-5 to represent rating*/
    feedback 			TEXT NOT NULL DEFAULT '-NIL-',
    
    PRIMARY KEY (orderId)
);
