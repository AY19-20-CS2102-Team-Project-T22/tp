const { Pool } = require('pg')

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT || 5432,
})

// client.connect()

module.exports = {
  pool: pool,
  query: (text, params, callback) => {
    const start = Date.now()
    return pool.query(text, params, (err, res) => {
      // Logging.
      const duration = Date.now() - start
      console.log('Executed query', { text, duration })

      callback(err, res)
    })
  },
  getClient: (callback) => {
    pool.connect((err, client, done) => {
      if (err) {
        console.error('Error acquiring client,', err.stack)
      }
      callback(err, client, done)
    })
  }
}