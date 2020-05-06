const router = require('express').Router()
const db = require('../db')


//Queries database for order history
router.route('/rider_info').get((req, res) => {
    let return_value = {
        'type':0,
        'num_of_orders':0,
        'total_salary':0
    };

    //get type
    let query = 'select * from DeliveryRiders where riderId=$1';
    let values = [req.query.riderId];
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }
    });
    return_value.type = result.rows[0].type;

    //get number of orders
    query = 'select count(orderId) from Orders where riderId=$1';
    values = [req.query.riderId];
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }
    });
    return_value.num_of_orders = result.rows[0].count;

    //get total salary
    query = 'select SUM(deliveryFee) from Orders where riderId=$1';
    values = [req.query.riderId];
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }
    });
    const deliver_salary = result.rows[0].sum;
    query = 'select SUM(baseSalary) from WWS where riderId=$1';
    values = [req.query.riderId];
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }
    });
    const WWSbaseSalary = result.rows[0].sum;
    query = 'select SUM(baseSalary) from MWS where riderId=$1';
    values = [req.query.riderId];
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }
    });
    const MWSbaseSalary = result.rows[0].sum;
    const total_salary = deliver_salary + WWSbaseSalary + MWSbaseSalary;
    return_value.total_salary = total_salary;
    res.status(200).json(return_value);

})



//1. total number of orders  2.total working hours 3. total salary 4. average deliver time 5. num of ratings 6. average rating
router.route('/num_of_orders').get((req, res) => {
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
            end_time_str = req.query.year + "-" + req.query.month+ "-30 23:59:59+8";
            break;
        case '02':
            end_time_str = req.query.year + "-" + req.query.month + "-28 23:59:59+8";    //FIXME: ignore leap year here
            break;
        default:
            break;
    }

    const query = 'select count(orderId) from Orders where riderId=$1 AND OrderTime[0]>=$2 AND OrderTime[0]<=$3';
    const values = [req.query.rider_id, start_time_str, end_time_str];     //rider_id is necessary

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

//1. total number of orders  2.total working hours 3. total salary 4. average deliver time 5. num of ratings 6. average rating
router.route('/working_hours').get((req, res) => {
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
            end_time_str = req.query.year + "-" + req.query.month+ "-30 23:59:59+8";
            break;
        case '02':
            end_time_str = req.query.year + "-" + req.query.month + "-28 23:59:59+8";    //FIXME: ignore leap year here
            break;
        default:
            break;
    }

    const query = 'select count(orderId) from Orders where riderId=$1 AND OrderTime[0]>=$2 AND OrderTime[0]<=$3';
    const values = [req.query.rider_id, start_time_str, end_time_str];     //rider_id is necessary

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

//Queries database for past schedule

//Queries database for past salaries


module.exports = router;
