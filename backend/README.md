

| api | url | GET or POST | params | return value |
| ---| -------- | -------- | -------- |--|
| to get account basic information | http://localhost:5000/account_info | GET | uid   | username, password, first_name, last_name, email, contact_no  | |
| to modify account basic information | http://localhost:5000/account_info/modify | POST | uid, type, username, password, firstName, lastName, email, contactNo | boolean |
| to get user's credit card information|http://localhost:5000/account_info/credit_card| GET | uid | card_no, cvv_no, card_type, name_on_card, expiry_date |
| to add new credit card | http://localhost:5000/account_info_credit_card/add | POST | uid, card_no, cvv_no, card_type, name_on_card, expiry_date | boolean |
| to get the order history of customers | http://localhost:5000/customers/orderHistory | GET | uid | rid, fid, unit_price, qty, delivery_cost, order_timestamp, address, postal_code(need further join to get more detailed information) |
| to get order history of riders | http://localhost:5000/riders/orderHistory |GET | rider_id(must), (order_timestamp, address, postal_code, depart_for_r, arrived_at_r, depart_for_c)(optional) | oid, order_timestamp, order_cost, delivery_cost, address, postal_code, depart_for_r, arrived_at_r, depart_for_c |

