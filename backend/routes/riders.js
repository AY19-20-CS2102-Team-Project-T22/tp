const router = require('express').Router()
const db = require('../db')

/*
CREATE TABLE OrdersLog (
	oid					SERIAL,
	order_timestamp		TIMESTAMPTZ NOT NULL,
	order_cost			NUMERIC NOT NULL,
	delivery_cost		NUMERIC NOT NULL,
	rider_id			INTEGER,
	address				VARCHAR(50) NOT NULL,
	postal_code			VARCHAR(6) NOT NULL,
	depart_for_r		TIMESTAMPTZ,
	arrived_at_r		TIMESTAMPTZ,
	depart_for_c		TIMESTAMPTZ,
	arrived_at_c		TIMESTAMPTZ,

	PRIMARY KEY (oid, order_timestamp)
);
*/

//Queries database for order history
router.route('/orderHistory').get((req, res) => {
    let query = 'select oid, order_timestamp, order_cost, delivery_cost, address, \
                postal_code, depart_for_r, arrived_at_r, depart_for_c from OrdersLog where rider_id=$1';
    let values = [req.query.rider_id];     //rider_id is necessary
    if (req.params.order_timestamp) {   //order_timestamp filter
        query += ' AND order_timestamp=$' + (values.length+1).toString();
        values.push(req.params.order_timestamp);
    }
    if (req.params.address) {   //address filter
        query += ' AND address=$' + (values.length+1).toString();
        values.push(req.params.address);
    }
    if (req.params.postal_code) {   //postal_code filter
        query += ' AND postal_code=$' + (values.length+1).toString();
        values.push(req.params.postal_code);
    }
    if (req.params.depart_for_r) {   //depart_for_r filter
        query += ' AND depart_for_r=$' + (values.length+1).toString();
        values.push(req.params.depart_for_r);
    }
    if (req.params.arrived_at_r) {   //arrived_at_r filter
        query += ' AND arrived_at_r=$' + (values.length+1).toString();
        values.push(req.params.arrived_at_r);
    }
    if (req.params.depart_for_c) {   //depart_for_c filter
        query += ' AND depart_for_c=$' + (values.length+1).toString();
        values.push(req.params.depart_for_c);
    }
    if (req.params.arrived_at_c) {   //arrived_at_c filter
        query += ' AND arrived_at_c=$' + (values.length+1).toString();
        values.push(req.params.arrived_at_c);
    }
    
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
