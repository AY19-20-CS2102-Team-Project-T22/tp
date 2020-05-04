const router = require('express').Router()
const db = require('../db')

//Queries database for order history
router.route('/orderHistory').get((req, res) => {
    const query = 'SELECT rid, fid, unit_price, qty, delivery_cost, order_timestamp, address, postal_code from Orders where uid=$1'
    const values = [req.params.uid]
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
