const router = require('express').Router()
const db = require('../db')

// Get all rows from Restaurants table.
router.route('/').get((req, res) => {
  const query = 
  `
  SELECT rid, rname
  FROM Restaurants
  ORDER BY rid
  `
  db.query(query, null, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      res.status(200).json(result.rows)
    }
  })
})

module.exports = router