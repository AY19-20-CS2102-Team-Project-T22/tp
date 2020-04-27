/* FDS Server */

const express = require('express')
const app = express()
const port = 3001

require('dotenv').config()

/* Testing query
console.log('Executing a query...')
const db = require('./db')
const testQuery = 'select now()'
const str = 'select * from Customers'
db.query(str, null, (err, res) => {
  if (err) {
    console.error(err)
  } else {
    res.rows.forEach((item) => {
      // console.log(parseInt(item.points) + 2.5)
      console.log(item.phone_no)
    })
  }
  db.end()
})
*/

app.use(express.json())

// Start server.
app.listen(port, () => {
  console.log(`Server is running on port ${port}.`)
})