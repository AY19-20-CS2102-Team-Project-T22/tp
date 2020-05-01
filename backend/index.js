/* FDS Server */

const express = require('express')
const cors = require('cors')
const app = express()
const port = 5000

require('dotenv').config()

app.use(cors())
app.use(express.json())

const usersRouter = require('./routes/users')
const menuRouter = require('./routes/menu')
const accountRouter = require('./routes/account_info')
app.use('/users', usersRouter)
app.use('/menu', menuRouter)
app.use('/account_info', accountRouter)

/* Testing query
console.log('Executing a query...')
const db = require('./db')
const testQuery = 'select now()'
db.query(testQuery, null, (err, res) => {
  if (err) {
    console.error(err)
  } else {
    res.rows.forEach((item) => {
      console.log(item)
    })
  }
  db.end()
})
*/

// Start server.
app.listen(port, () => {
  console.log(`Server is running on port ${port}.`)
})