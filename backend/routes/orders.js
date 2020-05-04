const router = require('express').Router()
const db = require('../db')

router.route('/add').post((req, res) => {
  let orderList = req.body.orders

  ;(async () => {
    try {
      await db.client.query('BEGIN')

      orderList.forEach(async (item, i) => {
        let index = 1
        let query = `
        INSERT INTO Orders VALUES (
          $${index++},
          $${index++},
          $${index++},
          $${index++},
          $${index++},
          $${index++},
          NOW(),
          $${index++},
          $${index++},
          $${index++},
          $${index++}
          )
        `
  
        let values = []
        values.push(req.body.uid)
        values.push(req.body.rid)
        values.push(item.fid)
        values.push(item.unitPrice)
        values.push(item.qty)
        values.push(req.body.deliveryCost)
        values.push(req.body.address)
        values.push(req.body.postalCode)
        values.push(req.body.paymentMethod)
        values.push(req.body.cardNo)

        await db.client.query(query, values)
      })

      await db.client.query('COMMIT')
    } catch (e) {
      await client.query('ROLLBACK')
      res.status(400).json('Transaction failed.')
      return
    } finally {
      res.status(200).json('Transaction successful.')
    }
  })().
  catch(e => {
    console.error(e.stack)
    res.status(400).json('Transaction failed.')
  })
})

module.exports = router