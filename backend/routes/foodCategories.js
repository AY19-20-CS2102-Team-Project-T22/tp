const router = require('express').Router()
const db = require('../db')
/*
SELECT foodId, 
category,
(SELECT name as fcname from Foods where Foods.foodId=FoodCategories.foodId)
FROM FoodCategories
ORDER BY foodId
*/
// Get all rows from FoodCategories table.
router.route('/').get((req, res) => {
  const query = 'SELECT DISTINCT category as fcname FROM FoodCategories';
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