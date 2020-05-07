const router = require('express').Router()
const db = require('../db')

router.route('/type').get((req, res) => {
  let query = 'select * from DeliveryRiders where riderId=$1';
  let values = [req.query.riderId];
  db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }else{
          res.status(200).json(result.rows);
        }
    });
})

router.route('/totalNumOrders').get((req, res) => {
    let query = 'select count(orderId) from OrderLogs where riderId=$1';
    let values = [req.query.riderId];
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }else{
          res.status(200).json(result.rows);
        }
    });
})

//Queries database for order history
router.route('/totalSalary').get((req, res) => {
    let salary = 0;
    //get total salary
    query = 'select SUM(deliveryFee) from OrderLogs where riderId=$1';
    values = [req.query.riderId];
    db.query(query, values, (error, result) => {
        if (error) {
          console.log(error)
          res.status(400).json('Error: ' + error)
        }else{
          salary += parseInt(result.rows[0].sum);
          query = 'select SUM(baseSalary) from WWS where riderId=$1';
          values = [req.query.riderId];
          db.query(query, values, (error, result) => {
              if (error) {
                console.log(error)
                res.status(400).json('Error: ' + error)
              }else{
                if(result.rows[0].sum!=null){
                  salary += parseInt(result.rows[0].sum);
                }
                query = 'select SUM(baseSalary) from MWS where riderId=$1';
                values = [req.query.riderId];
                db.query(query, values, (error, result) => {
                    if (error) {
                      console.log(error)
                      res.status(400).json('Error: ' + error)
                    }else{
                      if(result.rows[0].sum!=null){
                        salary += parseInt(result.rows[0].sum);
                      }
                      res.status(200).json(salary);
                    }
                });
              }
          });
        }
    });
})

router.route('/monthOrder').get((req, res) => {
  const query = 
  `
  SELECT COUNT(*)
  FROM OrderLogs O
  WHERE O.riderId = $1
  AND date_part('year', O.orderDate) = $2
  AND date_part('month', O.orderDate) = $3
  `;
  const values = [req.query.riderId, req.query.year, req.query.month];
  db.query(query, values, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    }else{
      res.status(200).json(result.rows)
    }
  });
})

/*
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
*/
//Queries database for past schedule

//Queries database for past salaries


module.exports = router;
