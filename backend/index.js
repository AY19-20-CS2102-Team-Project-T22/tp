/* FDS Server */

const express = require('express')
const app = express()
const port = 3001

require('dotenv').config()

/* Testing query
console.log('Executing a query...')
const db = require('./db')
const testQuery = 'select now()'
const str = 'create table users(sid integer, name varchar(80))'
db.query(testQuery, null, (err, res) => {
  if (err) {
    console.error(err)
  }
  db.end()
})
*/

app.use(express.json())

// Start server.
app.listen(port, () => {
  console.log(`Server is running on port ${port}.`)
})