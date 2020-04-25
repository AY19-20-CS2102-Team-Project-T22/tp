DROP TABLE IF EXISTS
	Users,
	Customers,
	Riders,
	Staff,
	FDSManagers
CASCADE;

-- Set Timezone to UTC+8
SET timezone=+8;
-- SET timezone='Asia/Singapore'; -- Alternative

CREATE TABLE Users (
	uid 			 	SERIAL,
	username		 	VARCHAR(30) NOT NULL,
	password	     	VARCHAR(30) NOT NULL,
	first_name         	VARCHAR(20) NOT NULL,
	last_name       	VARCHAR(20) NOT NULL,
	email		    	VARCHAR,
	phone_no   	 		INTEGER NOT NULL,
	registration_date	TIMESTAMPTZ NOT NULL,
	is_active          	BOOLEAN NOT NULL DEFAULT true,

	PRIMARY KEY (uid),
	UNIQUE (phone_no),
	UNIQUE (email),
	CHECK (phone_no >= 10000000 and phone_no <= 99999999)
);

CREATE TABLE Restaurants (
	rid					SERIAL,
	rname				VARCHAR(60) NOT NULL,
	address				VARCHAR(80) NOT NULL,
	min_order_cost		NUMERIC,
  
	primary key(rid)
);

/*
TODO:
Create triggers to copy value of registration_date
to last_login as DEFAULT value.

Current (temporary) implementation expects the above to
be done before performing INSERT operation on DB.
*/

CREATE TABLE Customers (
	points				NUMERIC NOT NULL DEFAULT 0.00,
	total_spending		NUMERIC NOT NULL DEFAULT 0.00,
	total_orders		INTEGER NOT NULL DEFAULT 0,
	last_login			TIMESTAMPTZ NOT NULL,

	primary key(uid)
) INHERITS (Users);

CREATE TABLE Riders (
	total_deliveries	INTEGER NOT NULL DEFAULT 0,
	last_login			TIMESTAMPTZ NOT NULL,

	primary key(uid)
) INHERITS (Users);

CREATE TABLE Staff (
	rid					SERIAL REFERENCES Restaurants(rid) ON DELETE CASCADE,
	last_login			TIMESTAMPTZ NOT NULL,

	primary key(uid)
) INHERITS (Users);

CREATE TABLE FDSManagers (
	last_login			TIMESTAMPTZ NOT NULL,

	primary key(uid)
) INHERITS (Users);




---------------
-- CUSTOMERS --
---------------
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (1, 'rreinhard0', 'QP8a0R', 'Risa', 'Reinhard', 'rreinhard0@amazon.de', '81516087', '2009-02-24 22:06:04', '2009-02-24 22:06:04');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (2, 'aburroughes1', '5ZOpKQFCFHDI', 'Avivah', 'Burroughes', 'aburroughes1@microsoft.com', '93085090', '2003-12-24 15:58:35', '2003-12-24 15:58:35');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (3, 'tborland2', 'MFdsD4j', 'Tory', 'Borland', 'tborland2@google.co.uk', '94873663', '2009-02-24 03:02:58', '2009-02-24 03:02:58');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (4, 'fsavoury3', 'eqZgQt', 'Felicdad', 'Savoury', 'fsavoury3@usda.gov', '83075300', '2009-03-24 06:49:34', '2009-03-24 06:49:34');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (5, 'amackstead4', 'RuuoNn9', 'Andros', 'Mackstead', 'amackstead4@barnesandnoble.com', '99960851', '2011-03-24 20:50:05', '2011-03-24 20:50:05');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (6, 'mgilliam5', 'Peiwxg0gY', 'Maressa', 'Gilliam', 'mgilliam5@smugmug.com', '93125930', '2006-02-24 13:43:36', '2006-02-24 13:43:36');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (7, 'dsalmon6', 'N8N4B7ZJnxTV', 'Dario', 'Salmon', 'dsalmon6@ox.ac.uk', '94362720', '2017-12-24 13:45:00', '2017-12-24 13:45:00');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (8, 'thudspith7', 'uPn9ox0dPt', 'Tiebout', 'Hudspith', 'thudspith7@twitpic.com', '61389628', '2018-09-24 10:00:46', '2018-09-24 10:00:46');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (9, 'vlackemann8', 'a3n8M5', 'Vonny', 'Lackemann', 'vlackemann8@digg.com', '62221632', '2009-07-25 00:00:26', '2009-07-25 00:00:26');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (10, 'gsiely9', 'wSyXwEO', 'Guntar', 'Siely', 'gsiely9@princeton.edu', '96724440', '2015-06-24 14:07:25', '2015-06-24 14:07:25');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (11, 'fmacdaida', '4oDmheQkHB', 'Fara', 'MacDaid', 'fmacdaida@omniture.com', '68120626', '2007-09-24 08:37:16', '2007-09-24 08:37:16');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (12, 'saxelbeeb', 'z8xoMh', 'Starlene', 'Axelbee', 'saxelbeeb@disqus.com', '93115882', '2011-11-25 01:03:25', '2011-11-25 01:03:25');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (13, 'afranzettoinic', 'B3TXHRbXWqz', 'Aindrea', 'Franzettoini', 'afranzettoinic@dailymotion.com', '98850324', '2017-02-24 10:45:36', '2017-02-24 10:45:36');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (14, 'adeardend', '8BwRqZdp', 'Addie', 'Dearden', 'adeardend@devhub.com', '90000182', '2013-09-24 13:58:14', '2013-09-24 13:58:14');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (15, 'aarnowicze', 'aFglaqtdv', 'Aretha', 'Arnowicz', 'aarnowicze@acquirethisname.com', '96707843', '2011-03-24 14:21:40', '2011-03-24 14:21:40');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (16, 'privenzonf', 'WVS9jXY', 'Prescott', 'Rivenzon', 'privenzonf@yellowbook.com', '90382653', '2009-01-25 01:29:09', '2009-01-25 01:29:09');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (17, 'aventrisg', 'oAonxa', 'Arline', 'Ventris', 'aventrisg@usgs.gov', '94629414', '2009-11-24 13:13:54', '2009-11-24 13:13:54');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (18, 'zgroomebridgeh', '3U9fvX', 'Zebedee', 'Groomebridge', 'zgroomebridgeh@nature.com', '80346565', '2004-02-24 05:21:46', '2004-02-24 05:21:46');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (19, 'bcabrali', 'EhWlXkp68owA', 'Basilio', 'Cabral', 'bcabrali@fc2.com', '97049382', '2013-04-24 13:58:07', '2013-04-24 13:58:07');
insert into Customers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (20, 'kspyerj', 'OXp9km', 'Kasper', 'Spyer', 'kspyerj@360.cn', '94109129', '2017-10-24 13:47:22', '2017-10-24 13:47:22');





-----------------
-- RESTAURANTS --
-----------------
insert into Restaurants (rid, rname, address, min_order_cost) values (1, 'Reilly LLC', '4944 Rigney Terrace', 1);
insert into Restaurants (rid, rname, address, min_order_cost) values (2, 'Pfeffer, Schamberger and Schroeder', '59 Corscot Circle', 2.5);
insert into Restaurants (rid, rname, address, min_order_cost) values (3, 'Walter, Goldner and Nolan', '1 Cordelia Terrace', 2.5);
insert into Restaurants (rid, rname, address, min_order_cost) values (4, 'Buckridge-Boehm', '3049 Mitchell Road', 0.5);




---------------------
-- DELIVERY RIDERS --
---------------------
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (1, 'eliverock0', 'txidYo8ogvq', 'Elenore', 'Liverock', 'eliverock0@goo.ne.jp', '90522187', '2010-04-25 00:54:24', 13, '2010-04-25 00:54:24');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (2, 'lmcgiveen1', 'WkUKYqo', 'Lexy', 'McGiveen', 'lmcgiveen1@wsj.com', '94797038', '2014-07-25 00:40:57', 2, '2014-07-25 00:40:57');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (3, 'mwitter2', 'nuKC0yNW33', 'Manya', 'Witter', 'mwitter2@epa.gov', '85955704', '2019-09-24 09:11:18', 8, '2019-09-24 09:11:18');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (4, 'rtunnacliffe3', 'BQYEPOaIWoy2', 'Raeann', 'Tunnacliffe', 'rtunnacliffe3@tuttocitta.it', '92639660', '2016-02-24 18:18:21', 1, '2016-02-24 18:18:21');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (5, 'rjudkin4', 'P7BG3Gwc0p2', 'Raquela', 'Judkin', 'rjudkin4@nhs.uk', '66218708', '2005-12-24 10:27:07', 10, '2005-12-24 10:27:07');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (6, 'zhune5', 'V0IxaifFTD', 'Zared', 'Hune', 'zhune5@cmu.edu', '83130236', '2014-10-24 21:46:33', 19, '2014-10-24 21:46:33');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (7, 'mchittock6', 'eNAaz5', 'Merrielle', 'Chittock', 'mchittock6@go.com', '95852514', '2017-01-25 04:29:22', 22, '2017-01-25 04:29:22');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (8, 'mgaule7', 'JH3wuPyBb', 'Marje', 'Gaule', 'mgaule7@list-manage.com', '96012261', '2017-08-24 06:06:31', 19, '2017-08-24 06:06:31');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (9, 'kbellenie8', 'EwapTtHVgO5w', 'Keen', 'Bellenie', 'kbellenie8@irs.gov', '89953405', '2006-02-25 01:32:53', 26, '2006-02-25 01:32:53');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (10, 'ilothean9', 'sY7vtCBYWr', 'Irvin', 'Lothean', 'ilothean9@g.co', '82581176', '2014-04-25 04:47:23', 11, '2014-04-25 04:47:23');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (11, 'ngallimorea', 'VmkHP2Px', 'Nedda', 'Gallimore', 'ngallimorea@booking.com', '97750360', '2010-10-24 20:38:23', 21, '2010-10-24 20:38:23');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (12, 'cjammetb', 'pj8Asw', 'Catina', 'Jammet', 'cjammetb@printfriendly.com', '65919876', '2010-03-24 05:58:26', 5, '2010-03-24 05:58:26');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (13, 'atretwellc', 'exDBmnZFJ0C5', 'Averell', 'Tretwell', 'atretwellc@china.com.cn', '95199908', '2011-08-24 13:27:15', 22, '2011-08-24 13:27:15');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (14, 'mhuntard', 'm5HNR5x', 'Micheil', 'Huntar', 'mhuntard@nba.com', '92266885', '2007-09-25 04:53:46', 8, '2007-09-25 04:53:46');
insert into Riders (uid, username, password, first_name, last_name, email, phone_no, registration_date, total_deliveries, last_login) values (15, 'asinkingse', 'A2PT0xfSQQJ', 'Asa', 'Sinkings', 'asinkingse@jimdo.com', '80631891', '2015-08-24 17:09:07', 6, '2015-08-24 17:09:07');




----------------------
-- RESTAURANT STAFF --
----------------------
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (1, 'mbake0', 'dxSoWAwaYO', 'Madelena', 'Bake', 'mbake0@vk.com', '66204366', '2004-01-24 20:06:00', 3, '2004-01-24 20:06:00');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (2, 'smccullock1', 'qsI8Hc2yVrC', 'Silvano', 'McCullock', 'smccullock1@i2i.jp', '82526712', '2005-02-25 02:21:33', 2, '2005-02-25 02:21:33');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (3, 'ecronkshaw2', 'DehNYOwZV', 'Erminia', 'Cronkshaw', 'ecronkshaw2@webeden.co.uk', '82933793', '2017-09-24 04:52:37', 4, '2017-09-24 04:52:37');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (4, 'hhaibel3', 'eNUwfLC2K', 'Homere', 'Haibel', 'hhaibel3@skyrock.com', '92345284', '2006-03-25 04:10:09', 1, '2006-03-25 04:10:09');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (5, 'swhiskin4', '5IXxIvN6U', 'Sarge', 'Whiskin', 'swhiskin4@squarespace.com', '81791407', '2004-04-25 03:19:07', 3, '2004-04-25 03:19:07');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (6, 'jsmithers5', 'S6KomTK', 'Judye', 'Smithers', 'jsmithers5@europa.eu', '90320927', '2005-03-24 14:35:04', 3, '2005-03-24 14:35:04');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (7, 'cbertram6', '1RMR359exF', 'Cordie', 'Bertram', 'cbertram6@booking.com', '61407535', '2010-11-24 09:36:28', 1, '2010-11-24 09:36:28');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (8, 'ebirtwisle7', 'A9kmfCs9', 'Ernesta', 'Birtwisle', 'ebirtwisle7@reuters.com', '83154019', '2015-11-24 11:45:26', 2, '2015-11-24 11:45:26');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (9, 'gwhate8', 'TeA1FguY', 'Gaynor', 'Whate', 'gwhate8@aboutads.info', '68242775', '2014-12-24 19:35:52', 1, '2014-12-24 19:35:52');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (10, 'bwingham9', 'pwjeVVzahbG', 'Benita', 'Wingham', 'bwingham9@creativecommons.org', '90830057', '2008-07-24 13:53:35', 4, '2008-07-24 13:53:35');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (11, 'csustona', '77S5t6vZ0Nie', 'Chandler', 'Suston', 'csustona@imgur.com', '68811272', '2012-04-24 14:55:34', 2, '2012-04-24 14:55:34');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (12, 'aclampb', '9pm8z96', 'Archy', 'Clamp', 'aclampb@noaa.gov', '91466573', '2013-03-25 01:41:34', 1, '2013-03-25 01:41:34');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (13, 'jmcfetrichc', 'RM1RGQB9Zk', 'Jenelle', 'McFetrich', 'jmcfetrichc@bbc.co.uk', '92133628', '2006-05-24 05:33:20', 4, '2006-05-24 05:33:20');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (14, 'ygrigoired', 'FT9FnPhRL9L', 'Yvette', 'Grigoire', 'ygrigoired@fda.gov', '99236416', '2017-11-24 07:40:53', 3, '2017-11-24 07:40:53');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (15, 'blongeae', 'BxybL5', 'Barthel', 'Longea', 'blongeae@ifeng.com', '93785892', '2011-05-24 12:58:51', 4, '2011-05-24 12:58:51');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (16, 'ayearsleyf', 'RhymjB3jnYp', 'Abran', 'Yearsley', 'ayearsleyf@ed.gov', '96964318', '2011-07-24 08:24:19', 1, '2011-07-24 08:24:19');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (17, 'jshafierg', 'QWqfXc', 'Jeanine', 'Shafier', 'jshafierg@yellowpages.com', '65802032', '2012-07-24 22:09:04', 3, '2012-07-24 22:09:04');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (18, 'chogbenh', 'a8xlvn', 'Cari', 'Hogben', 'chogbenh@google.pl', '96523876', '2013-02-24 06:26:57', 4, '2013-02-24 06:26:57');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (19, 'hbackshilli', 'dlqYrkpmYjz', 'Hillary', 'Backshill', 'hbackshilli@tuttocitta.it', '93030173', '2012-02-24 23:31:49', 3, '2012-02-24 23:31:49');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (20, 'wmaccaffertyj', 'FO5704gj', 'Wrennie', 'MacCafferty', 'wmaccaffertyj@wunderground.com', '60722233', '2016-04-24 08:26:18', 4, '2016-04-24 08:26:18');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (21, 'abarrimk', 'WdMnFU', 'Arabelle', 'Barrim', 'abarrimk@mit.edu', '67028797', '2015-06-25 01:11:29', 2, '2015-06-25 01:11:29');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (22, 'psalvagel', 'O0w3iE', 'Prudi', 'Salvage', 'psalvagel@chicagotribune.com', '89189491', '2008-12-24 12:37:13', 3, '2008-12-24 12:37:13');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (23, 'acavellm', 'QEgjQgT', 'Anette', 'Cavell', 'acavellm@is.gd', '93250059', '2017-06-24 09:09:35', 3, '2017-06-24 09:09:35');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (24, 'vbrimilcomben', 'FMJ9I64EdmR1', 'Violet', 'Brimilcombe', 'vbrimilcomben@nasa.gov', '86777972', '2010-04-24 23:27:39', 1, '2010-04-24 23:27:39');
insert into Staff (uid, username, password, first_name, last_name, email, phone_no, registration_date, rid, last_login) values (25, 'vsineo', 'i6cbczDi', 'Vanda', 'Sine', 'vsineo@ibm.com', '64285442', '2008-03-24 07:47:31', 2, '2008-03-24 07:47:31');




------------------
-- FDS MANAGERS --
------------------
insert into FDSManagers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (1, 'asennett0', 'eLLCYCdB0', 'Antonius', 'Sennett', 'asennett0@wikimedia.org', '93015394', '2004-06-24 19:13:32', '2004-06-24 19:13:32');
insert into FDSManagers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (2, 'syuryshev1', 'r18lSOz98t', 'Shelli', 'Yuryshev', 'syuryshev1@spotify.com', '66229547', '2018-09-24 14:21:30', '2018-09-24 14:21:30');
insert into FDSManagers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (3, 'areeveley2', 'dEMJ1LDUUst0', 'Aurelia', 'Reeveley', 'areeveley2@webs.com', '66952137', '2004-01-24 08:10:38', '2004-01-24 08:10:38');
insert into FDSManagers (uid, username, password, first_name, last_name, email, phone_no, registration_date, last_login) values (4, 'ahowardgater3', 'pr72dWUHury', 'Ange', 'Howard - Gater', 'ahowardgater3@yahoo.co.jp', '93423753', '2015-03-24 15:05:28', '2015-03-24 15:05:28');