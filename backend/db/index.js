const { Client } = require('pg')

const client = new Client({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT || 5432,
})

client.connect()

module.exports = {
    query: (text, params, callback) => {
        const start = Date.now()
        return client.query(text, params, (err, res) => {
            // Logging.
            const duration = Date.now() - start
            console.log('Executed query', { text, duration, rows: res.rowCount })
            
            callback(err, res)
        })
    },
    end: () => client.end()
}