const router = require('express').Router()
const db = require('../db')

// Handles login request.
router.route('/login').post((req, res) => {
  const query = 'SELECT * FROM Users WHERE username=$1'
  const values = [req.body.userName];
  // db.connect()
  db.query(query, values, (error, result) => {
    if (error) {
      res.status(400).json('Error: ' + error);
    } else {
      if(result.rows[0].userpassword === req.body.userPassword){
        switch(result.rows[0].type){
          case 1:
          case 2:
          case 3:
          case 4:
            //TODO: update last login date.
            break;
          default:
            break;
        }
        res.status(200).json(true);
      }else{
        res.status(200).json(false);
      }
    }
    // db.end()
  })
})

// Handles user registration request. Supports all four types.
router.route('/registration').post((req, res) => {
  let query = '';
  console.log("type:"+req.body.type);
  switch (req.body.type) {
    case 'customers':
      console.log("yes");
      query = 'INSERT INTO Users VALUES (DEFAULT, 1, $1, $2, $3, $4, $5, NOW(), $6, true)';
      query2 = 'INSERT INTO Customers VALUES ($1, NOW(), DEFAULT, DEFAULT, DEFAULT)';
      break;
    case 'riders':
      query = 'INSERT INTO Users VALUES (DEFAULT, 2, $1, $2, $3, $4, $5, NOW(), $6, true)';
      query2 = 'INSERT INTO DeliveryRiders($1, 1)'; //default full time
      break;
    case 'staff':
      query = 'INSERT INTO Users VALUES (DEFAULT, 3, $1, $2, $3, $4, $5, NOW(), $6, true)';
      query2 = 'INSERT INTO RestaurantStaffs VALUES ($1, -1)';
      break;
    case 'fdsmanagers':
      query = 'INSERT INTO Users VALUES (DEFAULT, 4, $1, $2, $3, $4, $5, NOW(), $6, true)';
      query2 = 'INSERT INTO FDSManagers VALUES ($1)';
      break;
    default:
      console.log("no");
      res.status(400).json('Error: Bad request')
  }
  const values = [
    req.body.userName,
    req.body.userPassword,
    req.body.lastName,
    req.body.firstName,
    (req.body.phoneNumber != '') ? req.body.phoneNumber : null,
    (req.body.email != '') ? req.body.email : null
  ]

  console.log(values);

  // db.connect()
  db.query(query, values, (error, result) => {
    if (error) {
      res.status(400).json('Error: ' + error)
    } else {
    }
    // db.end()
  })

  
  const getUserId = 'select userId from Users where userName=$1';
  const getUserIdValues = [req.body.userName];
  let userId = 0;
  db.query(getUserId, getUserIdValues, (error, result) => {
    if (error) {
      console.log("something is error");
      res.status(400).json('Error: ' + error)
    } else {
      userId = result.rows[0].userid;
      const values2 = [userId];
      console.log("userId:"+userId);
      
      db.query(query2, values2, (error, result) => {
        if (error) {
          console.log("something is error");
          res.status(400).json('Error: ' + error)
        } else {
          res.status(200).json(true);
        }
        // db.end()
      })
    }
    // db.end()
  })
  
})

module.exports = router