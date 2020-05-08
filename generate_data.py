#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 jiangyc <0599jiangyc@gmail.com>
#
# Distributed under terms of the MIT license.

import random
import csv
import string

"""
insert into Users (userId, type, userName, userPassword, lastName, firstName, phoneNumber, registrationDate, email, active) values
insert into RecentLocations (customerId, location, lastUsingTime) values
insert into CreditCards (cardNo, customerId, bank) values
insert into Restaurants (restaurantId, name, minOrderCost) values
insert into Foods (foodId, name, restaurantId, dailyLimit, quantity, price, isSold) values
insert into FoodCategories (foodId, category) values
insert into Carts (cartId, quantity, foodId, restaurantId) values
insert into DeliveryRiders (riderId, type) values
insert into WWS (workId, riderId, startDate, endDate, isUsed, workDays, baseSalary) values
insert into MWS (workId, riderId, startDate, endDate, isUsed, baseSalary, workDays, shifts) values
insert into WWS_Schedules (workId, weekday, startTime, endTime) values
insert into FullTimers (riderId, workId) values
insert into PartTimers (riderId, workId) values
insert into RestaurantStaffs (staffId, restaurantId) values
insert into FDSmanagers (managerId) values
insert into Promotions (promoId, type, value, startDate, endDate, condition, description) values
insert into RestaurantPromotions (promoId, restaurantId) values
insert into FDSPromotions (promoId, managerId) values
insert into Orders (orderId, customerId, riderId, restaurantId, orderTime, paymentMethod, cardNo, foodFee, deliveryFee, deliveryLocation, promoId) values
insert into Reviews (orderId, reviewDate, rating, feedback) values
"""

f=open("data.sql", "aw")


parttimers = [13,20,25,26,31,36,39,42,53,67,71,87,90,91,97,107,109,111,113,114,119,120,121,123,124,126,131,133,134,135,136,137,138,141,144,145,146,149,150,152,155,157,158,160,161,163,166,167,169,172,173,174,175,177,178,179,180,182,184,186,187,189,190,193,194,197,199,200]
fulltimers = [3,5,9,17,35,44,47,69,79,95,101,102,103,104,105,106,108,110,112,115,116,117,118,122,125,127,128,129,130,132,139,140,142,143,147,148,151,153,154,156,159,162,164,165,168,170,171,176,181,183,185,188,191,192,195,196,198]
def ran_letters(digit):
    ran_str = ''.join(random.sample(string.ascii_letters, digit))
    return ran_str

def ran_num(digit):
    ran_str = ''.join(random.sample(string.digits, digit))
    return ran_str

def ran_str(digit):
    ran_str = ''.join(random.sample(string.ascii_letters + string.digits, digit))
    return ran_str

for i in range(50):
    s = "INSERT INTO Foods VALUES ({}, '{}', {}, {}, {}, {}, DEFAULT);\n".format(i, ran_letters(7), i, ran_num(3), ran_num(3), ran_num(3))
    f.write(s)

for i in range(50):
    s = "insert into Restaurants values ({}, '{}', {});\n".format(i, ran_letters(7), ran_num(4))
    f.write(s)


for i in range(50):
    s = "insert into FoodCategories values ({}, {}, '{}');\n".format(i, 49-i, str(i)+ran_letters(5))
    f.write(s)

#insert into WWS (workId, riderId, startDate, endDate, baseSalary) values (1, 17, '5/8/2020', null, 115.36);

for i in range(400):
    s = "insert into WWS (workId, riderId, startDate, endDate, baseSalary) values ({}, {}, NOW()::date, null, {});\n ".format(i, random.choice(parttimers), float(random.randrange(10000,20000)/100))
    f.write(s)

for i in range(200):
    s = "insert into WWS (workId, riderId, startDate, endDate, baseSalary) values ({}, {}, (NOW() + (random() * interval '2 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'))::date, null, {});\n ".format(i, random.choice(parttimers), float(random.randrange(10000,20000)/100))
    f.write(s)

for i in range(400):
    s = "SELECT * FROM new_mws({}, NOW()::date, {},{} , ARRAY[{},{},{},{},{}]);\n ".format(str(random.choice(fulltimers)), float(random.randrange(70000,90000)/100), random.randrange(1,5), random.randrange(1,4),random.randrange(1,4),random.randrange(1,4),random.randrange(1,4),random.randrange(1,4))
    f.write(s)

for i in range(200):
    s = "SELECT * FROM new_mws({}, (NOW() + (random() * interval '2 years') + (random() * interval '23 hours') + (random() * interval '59 minutes') + (random() * interval '59 seconds'))::date, {},{} , ARRAY[{},{},{},{},{}]);\n ".format(str(random.choice(fulltimers)), float(random.randrange(70000,90000)/100), random.randrange(1,5), random.randrange(1,4),random.randrange(1,4),random.randrange(1,4),random.randrange(1,4),random.randrange(1,4))
    f.write(s)

f.close()
##SELECT * FROM new_mws(56, 20, '2020-06-02 00:00:00', '700.28',3 , ARRAY[3,2,4,1,2]);