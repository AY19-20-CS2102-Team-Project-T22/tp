const router = require('express').Router()
const db = require('../db')

router.route('/add').post((req, res) => {
  let orderList = req.body.orders

  // let query = 
  // `
  // insert into Orders
  // values
  // (1, 1, 2, 5.50, 1, 2.20, now(), 'BLK 130 BUKIT BATOK WEST AVE 6 #12-342', '650130', 0, null),
  // (1, 1, 4, 2.50, 1, 2.20, now(), 'BLK 130 BUKIT BATOK WEST AVE 6 #12-342', '650130', 0, null),
  // (1, 1, 6, 1.50, 1, 2.20, now(), 'BLK 130 BUKIT BATOK WEST AVE 6 #12-342', '650130', 0, null),
  // (1, 1, 8, 6.50, 1, 2.20, now(), 'BLK 130 BUKIT BATOK WEST AVE 6 #12-342', '650130', 0, null),
  // (1, 1, 9, 0.50, 3, 2.20, now(), 'BLK 130 BUKIT BATOK WEST AVE 6 #12-342', '650130', 0, null),
  // (1, 1, 10, 1.00, 2, 2.20, now(), 'BLK 130 BUKIT BATOK WEST AVE 6 #12-342', '650130', 0, null)
  // `
  db.client.query('BEGIN', (error, result) => {
    if (error) {
      res.status(400).json('error')
      return
    }

    let query = `INSERT INTO Orders VALUES `
    let values = []
    let index = 1
    orderList.forEach(async (item, i) => {
      query +=
      `
      (
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
      ),`
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
    })

    query = query.substring(0, query.length - 1)
    // console.log(query)

    db.client.query(query, values, (error, result) => {
      if (error) {
        console.log(error.stack)
        res.status(400).json('error on insert operation')
        return
      } else {
        res.status(200).json('success')
        db.client.query('COMMIT', (error, result) => {
          if (error) {
            console.log(error.stack)
            res.status(400).json('error committing')
            return
          }
        })
      }
    })
  })

  // ;(async () => {
  //   try {
  //     await db.client.query('BEGIN')

  //     orderList.forEach(async (item, i) => {
  //       let index = 1
  //       let query = `
  //       INSERT INTO Orders VALUES (
  //         $${index++},
  //         $${index++},
  //         $${index++},
  //         $${index++},
  //         $${index++},
  //         $${index++},
  //         NOW(),
  //         $${index++},
  //         $${index++},
  //         $${index++},
  //         $${index++}
  //         )
  //       `

  //       let values = []
  //       values.push(req.body.uid)
  //       values.push(req.body.rid)
  //       values.push(item.fid)
  //       values.push(item.unitPrice)
  //       values.push(item.qty)
  //       values.push(req.body.deliveryCost)
  //       values.push(req.body.address)
  //       values.push(req.body.postalCode)
  //       values.push(req.body.paymentMethod)
  //       values.push(req.body.cardNo)

  //       await db.client.query(query, values)
  //     })

  //     await db.client.query('COMMIT')
  //   } catch (e) {
  //     await db.client.query('ROLLBACK')
  //     res.status(400).json('Transaction failed.')
  //     return
  //   } finally {
  //     res.status(200).json('Transaction successful.')
  //   }
  // })().
  // catch(e => {
  //   console.error(e.stack)
  //   res.status(400).json('Transaction failed.')
  // })
})

module.exports = router