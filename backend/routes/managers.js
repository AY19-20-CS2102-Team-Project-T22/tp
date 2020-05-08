const router = require('express').Router()
const db = require('../db')

/* promotion part
    promotions => view promotions
    promotions/add => add promotion
    promotions/delete => delete promotion
    promotions/modify => modity promotion
*/

router.route('/promotions/get_promoId').get((req, res) => {
  const get_pid = 'select promoId as pid from promotions where type=$1 AND discountvalue=$2 AND startDate=$3 AND endDate=$4 AND condition=$5 AND description=$6';
  const get_pid_values = [req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description];
  db.query(get_pid, get_pid_values, (error, result) => {
    if (error) {
      console.log(error);
      res.status(400).json('Error: ' + error);
    }
    else {
      res.status(200).json(result.rows);
    }
  });
})

router.route('/promotions').get((req, res) => {
  const query = 'select * from Promotions NATURAL JOIN FDSPromotions where managerId=$1';
  const values = [req.query.mid];
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

router.route('/promotions/add').post((req, res) => {
  const query1 = 'insert into promotions values (DEFAULT, 1, $1, $2::date, $3::date, $4, $5)';
  const values1 = [req.body.value, req.body.startDate, req.body.endDate, req.body.condition, req.body.description];

  db.query(query1, values1, (err1, res1) => {
    if (err1) {
      console.log(err1)
      res.status(400).json('Error: ' + err1)
    } else {
      // Get promoId of last row inserted into Promotions table.
      const query2 = 'select promoId from promotions order by promoId desc limit 1'
      db.query(query2, null, (err2, res2) => {
        if (err2) {
          console.log(err2)
          res.status(400).json('Error: ' + err2)
        } else {
          const promoId = res2.rows[0].promoid
          const query3 = 'insert into FDSPromotions values ($1, $2)'
          const values3 = [promoId, req.body.mid]
          db.query(query3, values3, (err3, res3) => {
            if (err3) {
              console.log(err3)
              res.status(400).json('Error: ' + err3)
            } else {
              res.status(200).json('success')
            }
          })
        }
      })
    }
  })
})

router.route('/promotions/update').get((req, res) => {
  console.log(req);
  const query1 = 'update promotions SET type=$1, value=$2, startDate=$3, endDate=$4, condition=$5, description=$6 where promoId=$7';
  const values1 = [req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description, req.query.pid];
  db.query(query1, values1, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      console.log(result);
      console.log('insert success');
    }
    // db.end()
  })


  const query2 = 'update RestaurantPromotions set restaurantId=$2 where promoId=$1';
  const values2 = [req.query.pid, req.query.rid];
  db.query(query2, values2, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      console.log('insert success');
      res.status(200).json(true);
    }
    // db.end()
  })
})

// For each month, the total number of new customers, the total number of orders, and the total cost of all orders.

//total number of nem customers
//  xxx/managers/new_customers?year=2020&month=1
router.route('/num_of_customers').get((req, res) => {
  let start_time_str = req.query.year + "-" + req.query.month + "-1"         // "yyyy-mm-01 00:00:00"
  let end_time_str = req.query.year + "-" + req.query.month + "-1"

  const query =
    'select coalesce(count(userId), 0) as num from users where registrationDate>=$1::timestamp AND registrationDate<=$2::timestamp + interval \'1 month\' - interval \'1 day\' AND type=1';
  const values = [start_time_str, end_time_str];

  // db.connect()
  db.query(query, values, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      res.status(200).json(result.rows[0])
    }
    // db.end()
  })
})

// Total number of new customers given a range.
router.route('/num_of_customers/range').get((req, res) => {
  let start_time_str = req.query.from_year + "-" + req.query.from_month + "-" + req.query.from_day;          // "yyyy-mm-01 00:00:00"
  let end_time_str = req.query.to_year + "-" + req.query.to_month + "-" + req.query.to_day;

  const query = 'select coalesce(count(userId), 0) as num from users where registrationDate>=$1::timestamp AND registrationDate<=$2::timestamp AND type=1';
  console.log(query)
  const values = [start_time_str, end_time_str];

  // db.connect()
  db.query(query, values, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      res.status(200).json(result.rows[0])
    }
    // db.end()
  })
})

//total number of order
router.route('/num_of_orders').get((req, res) => {
  if (!req.query.year && !req.query.month) {
    const query = 'select coalesce(count(orderId), 0) as num from OrdersLog';

    db.query(query, null, (error, result) => {
      if (error) {
        console.log(error)
        res.status(400).json('Error: ' + error)
      } else {
        res.status(200).json(result.rows[0])
      }
    })
  }
  else {       // params: year, month, uid(optional)
    let start_time_str = req.query.year + "-" + req.query.month + "-1"         // "yyyy-mm-01 00:00:00"
    let end_time_str = req.query.year + "-" + req.query.month + "-1"

    const query = 'select coalesce(count(orderId), 0) as num from orderlogs where orderdate>=$1::timestamp AND orderdate<=$2::timestamp + interval \'1 month\' - interval \'1 day\'';
    const values = [start_time_str, end_time_str];

    db.query(query, values, (error, result) => {
      if (error) {
        console.log(error)
        res.status(400).json('Error: ' + error)
      } else {
        res.status(200).json(result.rows[0])
      }
    })
  }
})


//total cost of orders
router.route('/cost_of_orders').get((req, res) => {
  if (!req.query.year && !req.query.month) {
    const query = 'select coalesce(SUM(foodFee), 0) as num from orderlogs';

    db.query(query, null, (error, result) => {
      if (error) {
        console.log(error)
        res.status(400).json('Error: ' + error)
      } else {
        res.status(200).json(result.rows[0])
      }
    })
  } else {
    let start_time_str = req.query.year + "-" + req.query.month + "-1"         // "yyyy-mm-01 00:00:00"
    let end_time_str = req.query.year + "-" + req.query.month + "-1"

    const query = 'select coalesce(SUM(foodFee), 0) as num from orderlogs where orderdate>=$1::timestamp AND orderdate<=$2::timestamp + interval \'1 month\' - interval \'1 day\'';
    const values = [start_time_str, end_time_str]
    db.query(query, values, (error, result) => {
      if (error) {
        console.log(error)
        res.status(400).json('Error: ' + error)
      } else {
        console.log(result.rows)
        res.status(200).json(result.rows[0])
      }
    })
  }
})


//For each hour and for each delivery location area, the total number of orders placed at that hour for that location area
//num_of_orders?postal_code=112233&timestamp=155555500000000
router.route('/num_of_orders2').get((req, res) => {
  const start_stamp = new Date(parseInt(req.query.timestamp));
  const end_stamp = new Date(parseInt(req.query.timestamp) + 3600000);
  const start_time = start_stamp.getFullYear() + '-' + start_stamp.getMonth() + '-' + start_stamp.getDate() + ' ' + start_stamp.getHours() + ':' + start_stamp.getMinutes() + ':' + start_stamp.getSeconds();
  const end_time = end_stamp.getFullYear() + '-' + end_stamp.getMonth() + '-' + end_stamp.getDate() + ' ' + end_stamp.getHours() + ':' + end_stamp.getMinutes() + ':' + end_stamp.getSeconds();
  const query = 'select count(oid) from OrdersLog where postal_code=$1 AND order_timestamp>=$2 AND order_timestamp<=$3';
  const values = [req.query.postal_code, start_time, end_time];

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
