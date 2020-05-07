#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 jiangyc <0599jiangyc@gmail.com>
#
# Distributed under terms of the MIT license.

import random

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

f.close()
