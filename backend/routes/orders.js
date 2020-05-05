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
  db.getClient((err, client, done) => {
    if (err) {
      res.status(400).json(err)
      done()
      return
    }

    client.query('BEGIN', (err1, res1) => {
      if (err1) {
        console.error(err1.stack)
        res.status(400).json(err1)
        done()
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

      query = query.substring(0, query.length - 1) // Remove last comma.

      client.query(query, values, (err2, res2) => {
        if (err2) {
          console.log(err2.stack)
          res.status(400).json(err2)
          done()
          return
        } else {
          client.query('COMMIT', (err3, res3) => {
            if (err3) {
              console.log(err3.stack)
              res.status(400).json(err3)
              done()
              return
            }
            res.status(200).json(res3)
            done()
          })
        }
      })
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