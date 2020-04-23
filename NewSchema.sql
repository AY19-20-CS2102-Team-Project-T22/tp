DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS CreditCards CASCADE;
DROP TABLE IF EXISTS Carts CASCADE;
DROP TABLE IF EXISTS DeliveryRiders CASCADE;
DROP TABLE IF EXISTS FullTimers CASCADE;
DROP TABLE IF EXISTS PartTimers CASCADE;
DROP TABLE IF EXISTS Salaries CASCADE;
DROP TABLE IF EXISTS RestaurantStaffs CASCADE;
DROP TABLE IF EXISTS FDSManagers CASCADE;
DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS Foods CASCADE;
DROP TABLE IF EXISTS FoodCategories CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Promotions CASCADE;
DROP TABLE IF EXISTS FDSPromotions CASCADE;
DROP TABLE IF EXISTS RestaurantPromotions CASCADE;
DROP TABLE IF EXISTS WWS CASCADE;
DROP TABLE IF EXISTS MWS CASCADE;
DROP TABLE IF EXISTS Reviews CASCADE;


CREATE TABLE Users (
	userId 			 	SERIAL,
	userName		 	VARCHAR(30) NOT NULL,
	userPassword     	VARCHAR(30) NOT NULL,
	lastName         	VARCHAR(20) NOT NULL,
	firstName       	VARCHAR(20) NOT NULL,
	phoneNumber     	INTEGER NOT NULL,
	registrationDate	TIMESTAMP NOT NULL,
	emailAddress    	VARCHAR NOT NULL,
	active          	BOOLEAN NOT NULL

	PRIMARY KEY (userId),
	UNIQUE (phoneNumber),
	UNIQUE (emailAddress),
	CHECK (phoneNumber >= 10000000 and phoneNumber <= 99999999)
);


CREATE TABLE Customers (
	customerId			INTEGER,
	lastLoginDate	 	TIMESTAMP NOT NULL,
	totalExpenditure 	DECIMAL DEFAULT 0,
	orderCount		 	INTEGER DEFAULT 0,
	rewardPoints     	INTEGER DEFAULT 0,
	recentLocations	 	INTEGER(100)[], /*how to update? how to represent? (postal code)*/ 

	PRIMARY KEY (customerId)，
	FOREIGN KEY (customerId) REFERENCES Users(userId) ON DELETE CASCADE
);


CREATE TABLE CreditCards (
	cardNo				INTEGER,
	customerId			INTEGER,
	bank				VARCHAR(20) NOT NULL,

	PRIMARY KEY (cardNo),
	FOREIGN KEY (customerId) REFERENCES Customers(customerId) ON DELETE CASCADE
);


CREATE TABLE Carts (
	cartId				INTEGER,
	quantity			INTEGER DEFAULT 1,
	foodId				INTEGER NOT NULL,
	restaurantId		INTEGER NOT NULL,

	PRIMARY KEY (carId, foodId),
	FOREIGN KEY (carId) REFERENCES Customers(customerId) ON DELETE CASCADE,
	FOREIGN KEY (restaurantId, foodId) REFERENCES Sells(restaurantId, foodId) MATCH FULL ON DELETE CASCADE,
	/*Order in only one restaurant*/
	CHECK()
	/*if quantity becomes 0?*/

);


CREATE TABLE DeliveryRiders (
	riderId				INTEGER,
	type				INTEGER NOT NULL, /*use integer(1, 2) to represent type*/

	PRIMARY KEY (riderId),
	FOREIGN KEY (riderId) REFERENCES Users(userId) ON DELETE CASCADE
);

/* how to add base salary to daily salary?*/
CREATE TABLE FullTimers (
	riderId				INTEGER,
	baseSalary			DECIMAL NOT NULL, /*month*/
	MWS

	PRIMARY KEY (riderId),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE
);


CREATE TABLE PartTimers (
	riderId				INTEGER,
	baseSalary			DECIMAL NOT NULL, /*daily*/
	WWS

	PRIMARY KEY (riderId),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE
);


/*salary will be calculated at the end of every month (no matter type of riders)*/
CREATE TABLE Salaries (
	riderId				INTEGER,
	day					DATE,
	amount				DECIMAL DEFAULT 0,

	PRIMARY KEY (riderId, day),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE
);


CREATE TABLE RestaurantStaffs (
	staffId				INTEGER,
	restaurantId		INTEGER NOT NULL,

	PRIMARY KEY (staffId),
	FOREIGN KEY (staffId) REFERENCES Users(userId) ON DELETE CASCADE,
	FOREIGN KEY (restaurantId) REFERENCES Restaurants(restaurantId) ON DELETE CASCADE
);


CREATE TABLE FDSManagers (
	managerId				INTEGER,

	PRIMARY KEY (managerId),
	FOREIGN KEY (managerId) REFERENCES Users(userId) ON DELETE CASCADE
);

CREATE TABLE Restaurants (
	restaurantId		SERIAL,
	name 				VARCHAR(30) NOT NULL,
	minOrderCost		INTEGER DEFAULT 0,

	PRIMARY KEY (restaurantId)
);


CREATE TABLE Foods (
	foodId				SERIAL,
	name 				VARCHAR(30) NOT NULL,
	restaurantId		INTEGER NOT NULL,
	dailyLimit			INTEGER DEFAULT 0,
	quantity			INTEGER DEFAULT 0,
	price				DECIMAL DEFAULT 0,

	PRIMARY KEY (foodId), 
	FOREIGN KEY (restaurantId) REFERENCES Restaurants(restaurantId) ON DELETE CASCADE,
	UNIQUE (name, restaurantId)
);

CREATE TABLE FoodCategories (
	foodId				INTEGER,
	category			VARCHAR(20),

	PRIMARY KEY (foodId, category),
	FOREIGN KEY (foodId) REFERENCES Foods(foodId) ON DELETE CASCADE
)

/*cannot delete any record*/
CREATE TABLE Promotions (
	promoId 			SERIAL,
	type				INTEGER, /*use integer(1, 2) to represent type*/
	value				INTEGER, /*what does this mean?*/
	startDate			DATE,
	endDate				DATE,
	condition			TEXT, /*how to use this condition?*/
	description			TEXT, /*how to use this description?*/

	PRIMARY KEY (promoId)
)

CREATE TABLE RestaurantPromotions(
	promoId				INTEGER,
	restaurantId		INTEGER,

	PRIMARY KEY (promoId),
	FOREIGN KEY (promoId) REFERENCES Promotions(promoId),
	FOREIGN KEY (restaurantId) REFERENCES Restaurants(restaurantId) ON DELETE SET NULL
)

CREATE TABLE FDSPromotions (
	promoId				INTEGER,
	managerId 			INTEGER,

	PRIMARY KEY (promoId),
	FOREIGN KEY (promoId) REFERENCES Promotions(promoId),
	FOREIGN KEY (managerId) REFERENCES FDSManagers(managerId) ON DELETE SET NULL
)

CREATE TABLE Orders (
	orderId				SERIAL,
	customerId			INTEGER,
	riderId				INTEGER,
	orderTime			TIMESTAMP NOT NULL,
	paymentMethod		INTEGER NOT NULL, /*use integer to represent type (should it be cash or card/ should it be credit card number?)*/
	foodAmount 			DECIMAL NOT NULL,
	deliveryFee			DECIMAL NOT NULL,
	deliveryLocation	INTEGER NOT NULL,

	PRIMARY KEY (orderId),
	FOREIGN KEY (customerId) REFERENCES Customers(customerId) ON DELETE SET NULL
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE SET NULL

)

CREATE TABLE Reviews (
	orderId				INTEGER,
	reviewDate			DATE NOT NULL,
	rating				INTEGER NOT NULL, /*use points to represent rating*/
	feedback			TEXT NOT NULL DEFAULT '-NIL-', 

	PRIMARY KEY (orderId)
)

/*how to make sure every hour interval has at least 5 riders?*/
/*how to represent work days and shifts?*/
CREATE TABLE WWS (
	riderId				INTEGER,
	startDate			DATE NOT NULL,

	PRIMARY KEY (),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE

)

CREATE TABLE MWS (
	riderId				INTEGER,
	startDate			DATE NOT NULL,
	workDays			INTEGER NOT NULL, /*use 1-7 to represents 7 options of work days*/
	shifts				INTEGER[5][2], /*use 1-4 to represents 4 shifts*/

	PRIMARY KEY (),
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE CASCADE

)
