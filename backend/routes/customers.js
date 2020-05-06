const router = require('express').Router()
const db = require('../db')


router.route('/customers_info').get((req, res) => {
    const query = 'SELECT * from Customers where customerId=$1';
    const values = [req.query.customerId];
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

router.route('/creditcard_info').get((req, res) => {
  const query = 'SELECT * from CreditCards where customerId=$1';
  const values = [req.query.customerId];
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

router.route('/add_creditcard').post((req, res) => {
  const query = 'INSERT INTO CreditCards VALUES ($1, $2, $3)';
  const values = [req.body.cardNo, req.body.customerId, req.body.bank];
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
