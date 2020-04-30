const router = require('express').Router()
const db = require('../db')

// Handles login request.
router.route('/login').get((req, res) => {
  const query = 'SELECT uid, username, password FROM Users WHERE username=$1'
  const values = [req.query.username]
  // db.connect()
  db.query(query, values, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      console.log(result.rows)

      // The query should return only one row of data -> array length = 1.
      res.status(200).json(result.rows[0]) // Sends password (Non-secure).
    }
    // db.end()
  })
})

// Handles user registration request. Supports all four types.
router.route('/:type/add').post((req, res) => {
  let query = ''
  switch (req.params.type) {
    case 'customers':
      query = 'INSERT INTO Customers VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, NOW())'
      break;
    case 'riders':
      query = 'INSERT INTO Riders VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, NOW())'
      break;
    case 'staff':
      query = 'INSERT INTO Staff VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, NOW())'
      break;
    case 'fdsmanagers':
      query = 'INSERT INTO FDSManagers VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, NOW())'
      break;
    default:
      res.status(400).json('Error: Bad request')
  }
  const values = [
    req.body.username,
    req.body.password,
    req.body.firstName,
    req.body.lastName,
    (req.body.email != '') ? req.body.email : null,
    (req.body.contactNo != '') ? req.body.contactNo : null
  ]
  // db.connect()
  db.query(query, values, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      console.log(result)
      res.status(200).json(result)
    }
    // db.end()
  })
})

// Handles user queries with arbitrary params (search filters).

module.exports = router