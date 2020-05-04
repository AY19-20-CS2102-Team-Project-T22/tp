const router = require('express').Router()
const db = require('../db')

// Get delivery cost depending on the region where a location belongs.
router.route('/cost/').get((req, res) => {
  const postalCode = req.query.postalcode
  // const postalSector = parseInt(postalCode.substring(0, 2)) || 0
  // console.log(postalSector)
  // res.status(200).json('hallo')
  // console.log(postalCode)
  // Extract the first two digits of postalCode.
  const postalSector = parseInt(postalCode.substring(0, 2))

  if (postalSector == 0) {
    console.log('I GOT HERE')
    res.status(400).json('Error: Non-integer postal code detected.')
    return
  }

  const value = [postalSector]
  const query = 
  `
  SELECT cost
  FROM DeliveryCost
  WHERE region=(SELECT region FROM DeliveryAreas da WHERE da.postal_sector=$1)
  `
  db.query(query, value, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      if (result.rows.length === 1) {
        res.status(200).json(result.rows[0])
      } else [
        res.status(400).json('Error: Invalid postal code')
      ]
    }
  })
})

module.exports = router