import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import { Link } from 'react-router-dom'
import UserSidebar from './UserSideBar'

class OrderHistory extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      orderHistory:[
        {
            fid: null
        }
      ]
    }

    this.getOrderHistroy();
  }

  initPage(data){
    this.setState({ orderHistory : data})
  }

  getOrderHistroy() {
    axios.get(
        'http://localhost:5000/customers/orderHistory/?uid='
        +this.props.userId
    ).then(res => {
      this.initPage(res.data);
    }
    ).catch(err => {
      // Display error.
      alert(err)
    })
  }

  render() {
    return (
      <div className='body'>
        <UserSidebar firstName = {this.props.firstName}>
        </UserSidebar>
        <div className ='item-display'>


        </div>
      </div>
    )
  }
}

export default OrderHistory
