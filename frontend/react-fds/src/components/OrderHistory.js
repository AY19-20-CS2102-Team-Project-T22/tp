import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import { Link } from 'react-router-dom'
import UserSidebar from './UserSideBar'

class OrderHistory extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      uid: props.userId,
      orderHistory:[
        {
            fid: null
        }
      ]
    }

    this.handleDropdownChange = this.handleDropdownChange.bind(this)
    this.handleFirstNameChange = this.handleFirstNameChange.bind(this)
    this.handleLastNameChange = this.handleLastNameChange.bind(this)
    this.handleUsernameChange = this.handleUsernameChange.bind(this)
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
    this.handleEmailChange = this.handleEmailChange.bind(this)
    this.handleContactChange = this.handleContactChange.bind(this)

    this.getOrderHistroy();
  }

  handleDropdownChange(e) {
    this.setState({ accountType: e.target.value })
  }

  handleFirstNameChange(e) {
    this.setState({ firstName: e.target.value })
  }

  handleLastNameChange(e) {
    this.setState({ lastName: e.target.value })
  }

  handleUsernameChange(e) {
    this.setState({ username: e.target.value })
  }

  handlePasswordChange(e) {
    this.setState({ password: e.target.value })
  }

  handleEmailChange(e) {
    this.setState({ email: e.target.value })
  }

  handleContactChange(e) {
    this.setState({ contactNo: e.target.value })
  }


  initPage(data){
    console.log("history:"+data);
    this.setState({ old_username: data.username });
    this.setState({ old_password: data.password});
    this.setState({ old_firstName: data.first_name });
    this.setState({ old_lastName: data.last_name });
    this.setState({ old_email: data.email});
    this.setState({ old_contactNo: data.contact_no});
    
    this.setState({ username: data.username });
    this.setState({ password: data.password});
    this.setState({ firstName: data.first_name });
    this.setState({ lastName: data.last_name });
    this.setState({ email: data.email});
    this.setState({ contactNo: data.contact_no});
  }

  getOrderHistroy() {
    axios.get(
        'http://localhost:5000/customers/orderHistory?uid='
        +this.state.uid
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
        <div className ='item-display'></div>
      </div>
    )
  }
}

export default OrderHistory
