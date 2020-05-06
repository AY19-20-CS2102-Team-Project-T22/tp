const router = require('express').Router()
const db = require('../db')

// Get all rows from Menu table.
router.route('/').get((req, res) => {
  const query = 
  `
  select foodId as fid,
        (select name as rname from Restaurants r where Foods.restaurantId=r.restaurantId),
        (select quantity > 0 from Foods),
        name,
        (select category as fcname from FoodCategories fc where Foods.foodId=fc.foodId)
  from Foods Foods order by name
  `;
  db.query(query, null, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      res.status(200).json(result.rows)
    }
  })
})

router.route('/filter').get((req, res) => {
  if (req.query.rid === '' || req.query.fcid === '') {
    res.status(200).json([])
  } else {
    const query = 
    `
    WITH AllMenuTable as (
      SELECT fid, 
             (SELECT rname FROM Restaurants r WHERE m.rid=r.rid),
             unit_price,
             is_available,
             fname,
             (SELECT fcname FROM FoodCategories fc WHERE f.category=fc.fcid)
      FROM Menu m NATURAL JOIN Foods f
      ORDER BY fname
      )
      
      SELECT *
      FROM AllMenuTable a
      WHERE 
      (SELECT rid FROM Restaurants r WHERE a.rname=r.rname) IN (` + req.query.rid + `)
      AND 
      (SELECT fcid FROM FoodCategories fc WHERE a.fcname=fc.fcname) IN (` + req.query.fcid + `)
      ORDER BY a.fname;
    `
    db.query(query, null, (error, result) => {
      if (error) {
        console.log(error)
        res.status(400).json('Error: ' + error)
      } else {
        console.log(result.rows)
        res.status(200).json(result.rows)
      }
    })
  }

  
})

module.exports = router