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
    const get_pid_values =  [req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description];
    db.query(get_pid, get_pid_values, (error, result) => {
        if(error){
            console.log(error);
            res.status(400).json('Error: ' + error);
        }
        else{
            res.status(200).json(result.rows);
        }
    });
})

router.route('/promotions').get((req, res) => {
    const query = 'select *, rp.restaurantId from Promotions NATURAL JOIN RestaurantPromotions rp NATURAL JOIN FDSPromotions where managerId=$1';
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

router.route('/promotions/add').get((req, res) => {
    console.log(req);
    const query1 = 'insert into promotions values (DEFAULT, $1, $2, $3, $4, $5, $6)';
    const values1 = [req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description];
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
    const get_pid = 'select promoId as pid from promotions where type=$1 AND discountvalue=$2 AND startDate=$3 AND endDate=$4 AND condition=$5 AND description=$6';
    const get_pid_values =  [req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description];
    db.query(get_pid, get_pid_values, (error, result) => {
        if(error){
            console.log(error);
            res.status(400).json('Error: ' + error);
        }
        const pid = result.rows[0].pid;
        console.log("pid:"+pid);
        const query2 = 'insert into RestaurantPromotions values ($1, $2)';
        const values2 = [pid, req.query.rid];
        db.query(query2, values2, (error, result) => {
            if (error) {
              console.log(error)
              res.status(400).json('Error: ' + error)
            } else {
                console.log('insert success');
            }
            // db.end()
        })
        const query3 = 'insert into FDSPromotions values ($1, $2)';
        const values3 = [pid, req.query.mid];
        db.query(query3, values3, (error, result) => {
            if (error) {
              console.log(error)
              res.status(400).json('Error: ' + error)
            } else {
                res.status(200).json(true);
            }
            // db.end()
        })
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

router.route('/promotions/delete').get((req, res) => {
    const query1 = 'delete from FDSPromotions where promoId=$1';
    const values1 = [req.query.pid];
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
    const query2 = 'delete from RestaurantPromotions where promoId=$1';
    const values2 = [req.query.pid];
    db.query(query2, values2, (error, result) => {
        if (error) {
            console.log(error)
            res.status(400).json('Error: ' + error)
        } else {
            console.log('insert success');
        }
        // db.end()
    })
    const query3 = 'delete from promotions where promoId=$1';
    const values3 = [req.query.pid];
    db.query(query3, values3, (error, result) => {
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
    const query = 'select count(uid) as num from customers where registration_date>=$1 AND registration_date<=$2';
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
    else{       // params: year, month, uid(optional)
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


//For each hour and for each delivery location area, the total number of orders placed at that hour for that location area
//num_of_orders?postal_code=112233&timestamp=155555500000000
router.route('/num_of_orders2').get((req, res) => {
    const start_stamp = new Date(parseInt(req.query.timestamp));
    const end_stamp = new Date(parseInt(req.query.timestamp)+3600000);
    const start_time = start_stamp.getFullYear() + '-' + start_stamp.getMonth()+ '-' + start_stamp.getDate() + ' ' + start_stamp.getHours() + ':' + start_stamp.getMinutes() + ':' + start_stamp.getSeconds();
    const end_time = end_stamp.getFullYear() + '-' + end_stamp.getMonth()+ '-' + end_stamp.getDate() + ' ' + end_stamp.getHours() + ':' + end_stamp.getMinutes() + ':' + end_stamp.getSeconds();
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
