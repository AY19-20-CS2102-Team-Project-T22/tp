const router = require('express').Router()
const db = require('../db')

// Get all rows from FoodCategories table.
router.route('/').get((req, res) => {
  const query = 
  `
  SELECT fcid, fcname
  FROM FoodCategories
  ORDER BY fcid
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