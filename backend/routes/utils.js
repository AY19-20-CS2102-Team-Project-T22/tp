const router = require('express').Router()
const db = require('../db')

router.route('/timestamp').get((req, res) => {
  const query = 
  `
  select now()
  `
  const values = []
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