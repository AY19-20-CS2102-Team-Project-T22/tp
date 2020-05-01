import React from 'react'
import { Button, ListGroup, ListGroupItem, Badge } from 'reactstrap'

class CartPanel extends React.Component {
  constructor(props) {
    super(props)

    this.displayCartItems = this.displayCartItems.bind(this)
    this.calcTotalCost = this.calcTotalCost.bind(this)
  }

  displayCartItems(cart) {
    let sortedCart = cart.sort()
    let cartList = []
    let qty
    for (let i = 0; i < sortedCart.length; i += qty) {
      qty = 1
      let idx = sortedCart[i]
      for (let j = i + 1; j < sortedCart.length; j++) {
        if (idx === sortedCart[j]) {
          qty++
        } else {
          break
        }
      }
      cartList.push(
        <ListGroupItem className='cart-item' key={i}>
          <div style={{ fontWeight: 'bold', width: '200px' }}>
            {this.props.items[idx].fname}
          </div>
          <Badge
            color='warning'
            style={{
              fontSize: '15px',
              boxShadow: '1px 1px 2px 1px rgba(0,0,0,0.4)'
            }}
          >
            {qty}
          </Badge>
          <div style={{ flex: '1' }}></div>
          <h5>${parseFloat(this.props.items[idx].unit_price).toFixed(2)}</h5>
        </ListGroupItem>
      )
    }

    return cartList
  }

  calcTotalCost(cart) {
    let totalCost = 0.0
    cart.forEach(item => {
      totalCost += parseFloat(this.props.items[item].unit_price)
    })
    return totalCost
  }

  render() {
    return (
      <div className='cart-panel'>
        <div
          style={{
            textAlign: 'center',
            padding: '10px 0px 10px 0px',
            boxShadow: '0px 5px 5px 0px rgba(0,0,0,0.2)'
          }}>
          <h2>Cart</h2>
        </div>
        <div style={{ margin: '5px 0px 5px 0px', flex: '1', overflowY: 'auto' }}>
          <ListGroup>
            {this.displayCartItems(this.props.cart)}
          </ListGroup>
        </div>
        <div
          style={{
            height: '120px',
            color: 'white',
            fontSize: '21px',
            fontWeight: 'bold',
            padding: '10px',
            backgroundColor: 'orangered'
          }}
        >
          Total Cost: $ {this.calcTotalCost(this.props.cart).toFixed(2)}
          <Button
            color='primary'
            style={{
              marginTop: '10px',
              width: '100%',
              fontSize: '22px',
              fontWeight: 'bold'
            }}>
            Checkout
          </Button>
        </div>
      </div>
    )
  }
}

export default CartPanel;
