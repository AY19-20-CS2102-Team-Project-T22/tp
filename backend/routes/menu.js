const router = require('express').Router()
const db = require('../db')

// Get all rows from Menu table.

router.route('/').get((req, res) => {
  const query = 
  `
  select foodId as fid,
        (select name as rname from Restaurants r where Foods.restaurantId=r.restaurantId),
        price as unit_price,
        (quantity>0) as is_available,
        name as fname,
        (select category as fcname from FoodCategories fc where Foods.foodId=fc.foodId)
  from Foods
  order by fname
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
  if (req.query.rid === '' || req.query.fcname === '') {
    res.status(200).json([])
  } else {
    const query = 
    `
    WITH AllMenuTable as (
      select 
        foodId as fid,
        (select name as rname from Restaurants r where Foods.restaurantId=r.restaurantId),
        price as unit_price,
        (quantity>0) as is_available,
        name as fname,
        (select fc.category as fcname from FoodCategories fc where Foods.foodId=fc.foodId)
      from Foods
      order by fname
      )
      
      SELECT *
      FROM AllMenuTable a
      WHERE 
      (SELECT restaurantId FROM Restaurants r WHERE a.rname=r.name) IN (` + req.query.rid + `)
      AND 
      fcname IN (` + req.query.fcname + `)
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