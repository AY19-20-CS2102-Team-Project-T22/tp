const router = require('express').Router()
const db = require('../db')

// return account info
router.route('/').get((req, res) => {
  const query = 'SELECT * FROM Users WHERE userId=$1'
  const values = [req.query.uid]
  db.query(query, values, (error, result) => {
    if (error) {
      console.log(error)
      res.status(400).json('Error: ' + error)
    } else {
      console.log(result.rows)
      // The query should return only one row of data -> array length = 1.
      res.status(200).json(result.rows[0])
    }
    // db.end()
  })
})


//Handles userinfo modifications
router.route('/modify').post((req, res) => {
    let query = '';  
    let values = [];
    if (req.body.userName) {
      query = 'UPDATE Users SET userName=$2 where userId=$1';
      values = [req.body.userId, req.body.userName];
      db.query(query, values, (error, result) => {
        if (error) {
          res.status(400).json('Error: ' + error);
        } else {
          console.log("update success");
        }
      })
    }

    if (req.body.userPassword) {
      query = 'UPDATE Users SET userPassword=$2 where userId=$1';
      values = [req.body.userId, req.body.userPassword];
      db.query(query, values, (error, result) => {
        if (error) {
          res.status(400).json('Error: ' + error);
        } else {
          console.log("update success");
        }
      })
    }

    if (req.body.lastName) {
      query = 'UPDATE Users SET lastName=$2 where userId=$1';
      values = [req.body.userId, req.body.lastName];
      db.query(query, values, (error, result) => {
        if (error) {
          res.status(400).json('Error: ' + error);
        } else {
          console.log("update success");
        }
      })
    }

    if (req.body.firstName) {
      query = 'UPDATE Users SET firstName=$2 where userId=$1';
      values = [req.body.userId, req.body.firstName];
      db.query(query, values, (error, result) => {
        if (error) {
          res.status(400).json('Error: ' + error);
        } else {
          console.log("update success");
        }
      })
    }

    if (req.body.phoneNumber) {
      query = 'UPDATE Users SET phoneNumber=$2 where userId=$1';
      values = [req.body.userId, req.body.phoneNumber];
      db.query(query, values, (error, result) => {
        if (error) {
          res.status(400).json('Error: ' + error);
        } else {
          console.log("update success");
        }
      })
    }

    if (req.body.email) {
      query = 'UPDATE Users SET email=$2 where userId=$1';
      values = [req.body.userId, req.body.email];
      db.query(query, values, (error, result) => {
        if (error) {
          res.status(400).json('Error: ' + error);
        } else {
          console.log("update success");
        }
      })
    }
    res.status(200).json(true);
})

module.exports = router
