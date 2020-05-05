const router = require('express').Router()
const db = require('../db')

// For each month, the total number of new customers, the total number of orders, and the total cost of all orders.

//total number of nem customers
//  xxx/managers/new_customers?y=2020&m=1
router.route('/num_of_customers').get((req, res) => {
    let start_time_str = req.query.year + "-" + req.query.month + "-01 00:00:00+8";          // "yyyy-mm-01 00:00:00"
    let end_time_str = '';
    switch(req.query.month){
        case '01':
        case '03':
        case '05':
        case '07':
        case '08':
        case '10':
        case '12':
            end_time_str = req.query.year + "-" + req.query.month +"-31 23:59:59+8";
            break;
        case '04':
        case '06':
        case '09':
        case '11':
            console.log("yes");
            end_time_str = req.query.year + "-" + req.query.month+ "-30 23:59:59+8";
            break;
        case '02':
            end_time_str = req.query.year + "-" + req.query.month + "-28 23:59:59+8";    //FIXME: ignore leap year here
            break;
        default:
            console.log(req.query.month);
            console.log("error");
            break;
    }
    const query = 'select count(uid) from customers where registration_date>=$1 AND registration_date<=$2';
    const values = [start_time_str, end_time_str];
    
    // db.connect()
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        } else {
          res.status(200).json(result.rows)
        }
        // db.end()
      })
})

//total number of order
router.route('/num_of_orders').get((req, res) => {
    if(!req.query.year&&!req.query.month){
        const query = 'select count(oid) from OrdersLog';
        const values = [];
        
        // db.connect()
        db.query(query, values, (error, result) => {
            if (error) {
            console.log(error)
            res.status(400).json('Error: ' + error)
            } else {
            res.status(200).json(result.rows)
            }
            // db.end()
        })
    }
    else{       // params: year, month
        let start_time_str = req.query.year + "-" + req.query.month + "-01 00:00:00+8";          // "yyyy-mm-01 00:00:00"
        let end_time_str = '';
        switch(req.query.month){
            case '01':
            case '03':
            case '05':
            case '07':
            case '08':
            case '10':
            case '12':
                end_time_str = req.query.year + "-" + req.query.month +"-31 23:59:59+8";
                break;
            case '04':
            case '06':
            case '09':
            case '11':
                console.log("yes");
                end_time_str = req.query.year + "-" + req.query.month+ "-30 23:59:59+8";
                break;
            case '02':
                end_time_str = req.query.year + "-" + req.query.month + "-28 23:59:59+8";    //FIXME: ignore leap year here
                break;
            default:
                console.log(req.query.month);
                console.log("error");
                break;
        }
        const query = 'select count(oid) from OrdersLog where order_timestamp>=$1 AND order_timestamp<=$2';
        const values = [start_time_str, end_time_str];
        
        // db.connect()
        db.query(query, values, (error, result) => {
            if (error) {
            console.log(error)
            res.status(400).json('Error: ' + error)
            } else {
            res.status(200).json(result.rows)
            }
            // db.end()
        })
    }
})

//total cost of all orders
router.route('/cost_of_orders').get((req, res) => {
    const query = 'select SUM(order_cost) from OrdersLog';
    const values = [];
    
    // db.connect()
    db.query(query, values, (error, result) => {
        if (error) {
        console.log(error)
        res.status(400).json('Error: ' + error)
        } else {
        res.status(200).json(result.rows)
        }
        // db.end()
    })
})

module.exports = router;
