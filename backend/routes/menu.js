const router = require('express').Router()
const db = require('../db')

// Get all rows from Menu table.
router.route('/').get((req, res) => {
  const query = 
  `
  SELECT fid, 
	       (SELECT rname FROM Restaurants r WHERE m.rid=r.rid),
         unit_price,
         is_available,
         fname,
         (SELECT fcname FROM FoodCategories fc WHERE f.category=fc.fcid)
  from Menu m NATURAL JOIN Foods f
  ORDER BY fname
  `
  db.query(query, null, (error, result) => {
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