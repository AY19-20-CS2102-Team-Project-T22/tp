import React from 'react'
import axios from 'axios'
import {
  Button,
  Form,
  FormGroup,
  Label,
  Input,
  ListGroup,
  ListGroupItem,
  Badge
} from 'reactstrap'

class Checkout extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      cc: [],
      recentLocations: [],
      address: '',
      postalCode: '',
      selectedLoc: 6,
      paymentMethod: 0,
      orderCost: 0.0,
      deliveryCost: 0.0,
      totalCost: 0.0
    }

    this.handleAddressDropdownChange = this.handleAddressDropdownChange.bind(this)
    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.handlePostalChange = this.handlePostalChange.bind(this)
    this.handlePaymentMethodChange = this.handlePaymentMethodChange.bind(this)
    this.handleDeliveryCostCalc = this.handleDeliveryCostCalc.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.displayItemsInCart = this.displayItemsInCart.bind(this)
    this.calcOrderCost = this.calcOrderCost.bind(this)
    this.calcDeliveryCost = this.calcDeliveryCost.bind(this)
    this.populateWithRegisteredCCs = this.populateWithRegisteredCCs.bind(this)
  }

  handleAddressDropdownChange(e) {
    this.setState({ selectedLoc: e.target.value })
  }

  handleAddressChange(e) {
    this.setState({ address: e.target.value })
  }

  handlePostalChange(e) {
    this.setState({ postalCode: e.target.value })
  }

  handlePaymentMethodChange(e) {
    this.setState({ paymentMethod: e.target.value })
  }

  handleSubmit(e) {
    e.preventDefault()

    // Get the restaurant id for this order.
    const restaurantId = this.props.items[this.props.cart[0]].rid

    // Calculate final delivery cost.
    axios.get(
      'http://localhost:5000/delivery/cost?postalcode='
      + this.state.postalCode
    )
      .then(res => {
        let cost = parseFloat(res.data.cost)

        // Get the fid and quantity for each unique item in cart.
        let sortedCart = this.props.cart.sort()
        let orderList = []
        let quantity
        for (let i = 0; i < sortedCart.length; i += quantity) {
          quantity = 1
          let idx = sortedCart[i]
          for (let j = i + 1; j < sortedCart.length; j++) {
            if (idx === sortedCart[j]) {
              quantity++
            } else {
              break
            }
          }
          orderList.push({
            fid: this.props.items[idx].fid,
            unitPrice: this.props.items[idx].unit_price,
            qty: quantity,
          })
        }

        // Get credit card number.
        let ccNo = null
        if (this.state.paymentMethod !== 0) {
          ccNo = this.state.cc[this.state.paymentMethod - 1].card_no
        }

        // Insert new order to database
        const dataToSend = {
          uid: this.props.userId,
          rid: restaurantId,
          orders: orderList,
          address: this.state.address,
          postalCode: this.state.postalCode,
          deliveryCost: cost,
          paymentMethod: this.state.paymentMethod,
          cardNo: ccNo
        }

        axios.post('http://localhost:5000/orders/add', dataToSend)
          .then(res => {
            console.log('successfully inserted order to db')
          })
          .catch(err => {
            alert(err)
          })
      })
      .catch(err => {
        alert(err)
      })
  }

  displayItemsInCart() {
    let sortedCart = this.props.cart.sort()
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
        <ListGroupItem
          className='cart-item'
          key={idx}
        >
          <div
            style={{
              fontWeight: 'bold',
              width: '190px',
              flex: '1',
              marginRight: '10px'
            }}
          >
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
          <div
            style={{
              width: '70px',
              textAlign: 'end',
              fontSize: '16px',
              fontWeight: 'bold'
            }}
          >
            ${(parseFloat(this.props.items[idx].unit_price) * qty).toFixed(2)}
          </div>
        </ListGroupItem>
      )
    }

    return cartList
  }

  calcOrderCost() {
    let totalCost = 0.0
    this.props.cart.forEach(item => {
      totalCost += parseFloat(this.props.items[item].unit_price)
    })
    // this.setState({ orderCost: totalCost })
    return totalCost
  }

  handleDeliveryCostCalc(e) {
    if (this.state.selectedLoc == 6) {
      this.calcDeliveryCost()
    } else {
      let cost = this.state.recentLocations[this.state.selectedLoc].delivery_cost
      this.setState({ deliveryCost: cost })
    }
  }

  calcDeliveryCost() {
    // Get delivery cost depending on region.
    axios.get(
      'http://localhost:5000/delivery/cost?postalcode='
      + this.state.postalCode
    )
      .then(res => {
        let cost = parseFloat(res.data.cost)
        this.setState({ deliveryCost: cost })
      })
      .catch(err => {
        alert(err)
      })
  }

  populateWithRegisteredCCs() {
    return this.state.cc.map((eachItem, i) => {
      // Extract last 4 digits of card number.
      let lastFourDigits =
        eachItem.card_no.
          substring(eachItem.card_no.length - 4, eachItem.card_no.length)
      return (
        <option value={i + 1}>Credit card ending with {lastFourDigits}</option>
      )
    })
  }

  componentDidMount() {
    // Retrieve credit cards registered for user (if any).
    axios.get(
      'http://localhost:5000/users/customers/'
      + this.props.userId
      + '/creditcards'
    )
      .then(res => {
        this.setState({ cc: res.data })
      })
      .catch(err => {
        alert(err)
      })

    // Retrieve past delivery addresses entered by user (if any).

  }

  componentDidUpdate() {
    // this.calcOrderCost()
    // this.calcDeliveryCost()
    // this.setState(prev => ({
    //   totalCost: prev.orderCost + prev.deliveryCost
    // }))
  }

  render() {


    return (
      // <div className='checkout'>
      //   1) Make database query to get customer credit cards.<br />
      //   2) Make user fill up a form (payment method, delivery location (need postal), etc).<br />
      //   3) When form submitted, perform database operation accordingly.<br />
      // </div>
      <div className='checkout'>
        <div
          style={{
            flex: '1',
            paddingRight: '20px',
          }}>
          <h3>Orders</h3>
          <ListGroup>
            {this.displayItemsInCart()}
          </ListGroup>
        </div>
        <div style={{ flex: '1', overflowY: 'auto' }}>
          <Form onSubmit={this.handleSubmit}>
            <h3>Additional Information</h3><br />
            <FormGroup>
              <Label>Delivery Address</Label>
              <Input
                type="select"
                defaultValue={this.state.selectedLoc}
                value={this.state.selectedLoc}
                onChange={this.handleAddressDropdownChange}
              >
                <option value={0}>Location 1</option>
                <option value={1}>Location 2</option>
                <option value={2}>Location 3</option>
                <option value={3}>Location 4</option>
                <option value={4}>Location 5</option>
                <option value={6}>Other</option>
              </Input>
            </FormGroup>
            <FormGroup>
              <Label>New Delivery Address</Label>
              <Input
                disabled={this.state.selectedLoc != 6}
                type='text'
                required={this.state.selectedLoc == 6}
                value={this.state.address}
                onChange={this.handleAddressChange}
              />
              <br />
              <Button
                color='primary'
                style={{
                  width: '100%'
                }}
                onClick={this.handleDeliveryCostCalc}
              >
                Calculate delivery cost
              </Button>
            </FormGroup>
            <FormGroup>
              <Label>Postal Code</Label>
              <Input
                disabled={this.state.selectedLoc != 6}
                type='text'
                required={this.state.selectedLoc == 6}
                required
                value={this.state.postalCode}
                onChange={this.handlePostalChange}
              />
            </FormGroup>
            <FormGroup>
              <Label>Payment Method</Label>
              <Input
                type="select"
                defaultValue={this.state.paymentMethod}
                value={this.state.paymentMethod}
                onChange={this.handlePaymentMethodChange}
              >
                <option value={0}>Cash</option>
                {this.populateWithRegisteredCCs()}
                {/* <option value={1}>Credit card ending with xxxx</option>
                <option value={2}>Credit card ending with yyyy</option> */}
              </Input>
            </FormGroup>
            <Button
              style={{ width: '100%' }}
              type='submit'
              color='primary'
            >
              Proceed to Order
            </Button>
          </Form>
        </div>
        <div
          style={{
            paddingLeft: '20px',
            flex: '1',
            display: 'flex',
            justifyContent: 'center'
          }}>
          Order Cost: {this.calcOrderCost().toFixed(2)}<br />
          Delivery Cost: {this.state.deliveryCost.toFixed(2)}<br />
          Total Cost: {(this.calcOrderCost() + this.state.deliveryCost).toFixed(2)}
        </div>
      </div>
    )
  }
}

export default Checkout