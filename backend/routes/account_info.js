const router = require('express').Router()
const db = require('../db')

// return account info
router.route('/').get((req, res) => {
  const query = 'SELECT uid, username, password, first_name, last_name, email, contact_no FROM Users WHERE uid=$1'
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
    console.log(req.body.uid);
    let query = ''
    switch (req.body.type) {
      case 'customers':
        query = 'UPDATE Customers SET username=$1, password=$2, first_name=$3, last_name=$4, email=$5, contact_no=$6 where uid=$7'
        break;
      case 'riders':
        query = 'UPDATE Riders SET username=$1, password=$2, first_name=$3, last_name=$4, email=$5, contact_no=$6 where uid=$7'
        break;
      case 'staff':
        query = 'UPDATE Staffs SET username=$1, password=$2, first_name=$3, last_name=$4, email=$5, contact_no=$6 where uid=$7'
        break;
      case 'fdsmanagers':
        query = 'UPDATE FDSManagers SET username=$1, password=$2, first_name=$3, last_name=$4, email=$5, contact_no=$6 where uid=$7'
        break;
      default:
        res.status(400).json('Error: Bad request')
    }

    const values = [
      req.body.username,
      req.body.password,
      req.body.firstName,
      req.body.lastName,
      req.body.email,
      req.body.contactNo,
      req.body.uid
    ]

    db.query(query, values, (error, result) => {
      if (error) {
        console.log(error)
        res.status(400).json('Error: ' + error)
      } else {
        console.log(result)
        res.status(200).json(result)
      }
    })
}
)

/*
CREATE TABLE CreditCards (
	uid					INTEGER NOT NULL,
	card_no				BIGINT NOT NULL,
	cvv_no				VARCHAR(4) NOT NULL,
	name_on_card		VARCHAR(60) NOT NULL,
	card_type			VARCHAR(30) NOT NULL,
	expiry_date			DATE NOT NULL,

	PRIMARY KEY (uid, card_no),
	FOREIGN KEY (uid) REFERENCES Customers(uid) ON DELETE CASCADE
);
*/

// return credit card info
router.route('/credit_card').get((req, res) => {
  const query = 'select card_no, cvv_no, card_type, name_on_card, expiry_date from CreditCards WHERE uid=$1'
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

// add credit card info
router.route('/credit_card/add').post((req, res) => {
  //'INSERT INTO Customers VALUES (DEFAULT, $1, $2, $3, $4, $5, $6, NOW())'
  const query = 'insert into CreditCards values ($1, $2, $3, $4, $5, $6)';
  const values = [req.body.uid,
                  req.body.card_no, 
                  req.body.cvv_no, 
                  req.body.name_on_card,
                  req.body.card_type,
                  req.body.expiry_date
                ];
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

module.exports = router
