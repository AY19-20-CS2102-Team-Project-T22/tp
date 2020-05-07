import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input, ListGroup, ListGroupItem } from 'reactstrap'
import { Link } from 'react-router-dom'
import UserSidebar from './UserSideBar'

/*
CREATE TABLE Orderlogs (
	orderId				SERIAL,
	customerId			INTEGER,
	riderId				INTEGER,
	restaurantId		INTEGER,
	orderDate			DATE NOT NULL,
	orderTime			TIME[5], // five types of time
	paymentMethod		INTEGER NOT NULL CHECK (paymentMethod = 1 or paymentMethod = 2),
	cardNo				BIGINT,
	foodFee 			DECIMAL NOT NULL,
	deliveryFee			DECIMAL NOT NULL,
	deliveryLocation	INTEGER NOT NULL,
	promoId				INTEGER,
	ratings 			INTEGER,

	PRIMARY KEY (orderId),
	FOREIGN KEY (customerId) REFERENCES Customers(customerId) ON DELETE SET NULL,
	FOREIGN KEY (riderId) REFERENCES DeliveryRiders(riderId) ON DELETE SET NULL,
	FOREIGN KEY (restaurantId) REFERENCES Restaurants(restaurantId) ON DELETE SET NULL,
	FOREIGN KEY (promoId) REFERENCES Promotions(promoId),
	CHECK (paymentMethod = 1 AND cardNo IS NOT NULL)

)
*/
class OrderHistory extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      orderHistory: [],
      selectedOrderIndex: 0
    }

    this.getOrderHistory = this.getOrderHistory.bind(this)
    this.initPage = this.initPage.bind(this)
    this.handleListClick = this.handleListClick.bind(this)
  }

  handleListClick(e) {
    let orderIndex = parseInt(e.target.value)

    this.setState({ selectedOrderIndex: orderIndex })
  }

  initPage(data) {
    this.setState({ orderHistory: data })
  }

  getOrderHistory() {
    axios.get(
      'http://localhost:5000/customers/orderHistory/?uid='
      + this.props.userId
    ).then(res => {
      this.initPage(res.data);
    }
    ).catch(err => {
      // Display error.
      alert(err)
    })
  }

  componentDidMount() {
    this.getOrderHistory()
  }

  render() {
    return (
      <div className='order-history'>
        <UserSidebar firstName={this.props.firstName} />
        <div className='order-history-mainpanel'>
          <h2 style={{ fontWeight: 'bold' }}>Order History</h2>
          <ListGroup>
            <ListGroupItem
              value={0}
              onClick={this.handleListClick}
              tag='button'
              style={{ marginBottom: '20px' }}
            >
              Order # 1 $100.00 <br />
              Some Date <br />
              Click for more detail
            </ListGroupItem>
            <ListGroupItem
              value={0}
              onClick={this.handleListClick}
              tag='button'
              style={{ marginBottom: '20px' }}
            >
              Order # 2 $10.00 <br />
              Some Date <br />
              Click for more detail
            </ListGroupItem>
            <ListGroupItem
              value={0}
              onClick={this.handleListClick}
              tag='button'
              style={{ marginBottom: '20px' }}
            >
              Order # 3 $40.00 <br />
              Some Date <br />
              Click for more detail
            </ListGroupItem>
          </ListGroup>

        </div>
        <div className='order-history-details'>
          <h3>Order Details</h3>
          <ListGroup>
            <ListGroupItem
              style={{
                color: 'black',
                fontWeight: 'bold',
                fontSize: '17px',
                marginBottom: '20px'
              }}
            >
              Food name<br />
              Restaurant name<br />
              Qty<br />
              Cost
            </ListGroupItem>
            <ListGroupItem
              style={{
                color: 'black',
                fontWeight: 'bold',
                fontSize: '17px',
                marginBottom: '20px'
              }}
            >
              Food name<br />
              Restaurant name<br />
              Qty<br />
              Cost
            </ListGroupItem>
          </ListGroup>
        </div>
      </div>
    )
  }
}

export default OrderHistory
