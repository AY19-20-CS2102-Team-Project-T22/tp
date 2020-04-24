/* FDS Server */

const express = require('express')
const app = express()
const port = 3001
const { Pool, Client } = require('pg')

require('dotenv').config()

// Setup connection to postgress database server.
const client = new Client({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT || 5432,
})

app.use(express.json())

// Start server.
app.listen(port, () => {
  console.log(`Server is running on port ${port}.`)
})