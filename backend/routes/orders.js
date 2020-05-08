const router = require('express').Router()
const db = require('../db')

router.route('/add').post((req, res) => {
  const query = 'select create_new_order_success($1, $2, $3, $4, $5, $6, $7, $8, $9)';
  console.log(req.body);
  const values = [req.body.cid, 
                  req.body.restid,
                  req.body.pay,
                  req.body.cardNo,
                  req.body.foodFee,
                  req.body.delFee,
                  req.body.delLoc,
                  req.body.promoId,
                  req.body.orderArr
                ];
  db.query(query, values, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      // console.log(result.rows)
      res.status(200).json(result.rows)
    }
  })
})

module.exports = router