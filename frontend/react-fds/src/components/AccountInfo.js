import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import { Link } from 'react-router-dom'
import UserSideBar from './UserSideBar'

class AccountInfo extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      uid: props.userId,
      accountType: props.userType,
      old_firstName: '',
      old_lastName: '',
      old_username: '',
      old_password: '',
      old_email: '',
      old_contactNo: '',
      firstName: null,
      lastName: null,
      username: null,
      password: null,
      email: null,
      contactNo: null
    }

    this.handleDropdownChange = this.handleDropdownChange.bind(this)
    this.handleFirstNameChange = this.handleFirstNameChange.bind(this)
    this.handleLastNameChange = this.handleLastNameChange.bind(this)
    this.handleUsernameChange = this.handleUsernameChange.bind(this)
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
    this.handleEmailChange = this.handleEmailChange.bind(this)
    this.handleContactChange = this.handleContactChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.getAccountInfo();
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
    console.log("before:");
    console.log(this.state);
    this.setState({ old_username: data.username });
    this.setState({ old_password: data.userpassword});
    this.setState({ old_firstName: data.firstname });
    this.setState({ old_lastName: data.lastname });
    this.setState({ old_email: data.email});
    this.setState({ old_contactNo: data.phonenumber});
    
    this.setState({ username: data.username });
    this.setState({ password: data.userpassword});
    this.setState({ firstName: data.firstname });
    this.setState({ lastName: data.lastname });
    this.setState({ email: data.email});
    this.setState({ contactNo: data.phonenumber});
    console.log("after");
    console.log(this.state);
  }

  getAccountInfo() {
    console.log(this.state);
    axios.get(
        'http://localhost:5000/account_info?uid='
        +this.state.uid
    ).then(res => {
      this.initPage(res.data);
    }
    ).catch(err => {
      // Display error.
      alert(err)
    })
  }

  handleSubmit(e) {
    e.preventDefault()

    // HTTP POST request to backend.
    // Send account information over HTTP (Non-secure).
    let url = 'http://localhost:5000/account_info/modify';
    let data = {
      userId: this.state.uid,
      type: this.state.accountType,
      firstName: this.state.firstName,
      lastName: this.state.lastName,
      userName: this.state.username,
      email: this.state.email,
      userPassword: this.state.password,
      phoneNumber: parseInt(this.state.contactNo)
    };
    axios.post(url, data)
      .then(res => {
        alert('You have successfully modified.')
        window.location = '/'
      })
      .catch(err => {
        // Display error.
        alert(err)
      })
  }

  render() {
    return (
      <div className = 'body'>
      <UserSideBar
        firstName = {this.props.firstName}
      ></UserSideBar>
      <div className = 'item-display' style={{color: 'white'}}>
        {/*
        <div>
          <Label> hello, {this.state.old_username} </Label> <br></br>
          <Label> your firstname: {this.state.old_firstName} </Label> <br></br>
          <Label> your lastname: {this.state.old_lastName} </Label> <br></br>
          <Label> your mail: {this.state.old_email} </Label> <br></br>
          <Label> your contactNo : {this.state.old_contactNo} </Label> <br></br>
        </div>
        <Link
          to='/accountinfo/credit_card'
        >
        Manage your credit card
        </Link>
        */}
        <div className='modify'>
        <div style={{ flex: 1 }}></div>
        <Form style={{ flex: 1 }} onSubmit={this.handleSubmit}>
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>Modify your information</h2>
          <FormGroup>
            <Label>First Name</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.firstName}
              onChange={this.handleFirstNameChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>Last Name</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.lastName}
              onChange={this.handleLastNameChange}
            />
          </FormGroup>

          { /* Username and Password */}
          <FormGroup>
            <Label>Username</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.username}
              onChange={this.handleUsernameChange}
            />
          </FormGroup>

          <FormGroup>
            <Label>password</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.password}
              onChange={this.handlePasswordChange}
            />
          </FormGroup>

          { /* Email and Phone number */}
          <FormGroup>
            <Label>Email</Label>
            <Input
              type='email'
              placeholder
              value={this.state.email}
              onChange={this.handleEmailChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>Contact Number</Label>
            <Input type='text'
              placeholder
              value={this.state.contactNo}
              onChange={this.handleContactChange}
            />
          </FormGroup>

          <Button
            style={{ width: '100%', marginBottom: '10px' }}
            type='submit'
            color='primary'
          >
            Modify
          </Button>
          <Link to='/'>
            <Button
              style={{ width: '100%' }}
              color='secondary'
            >
              Cancel
            </Button>
          </Link>
        </Form>
        <div style={{ flex: 1 }}></div>
      </div>
    </div>
    </div>
    )
  }
}

export default AccountInfo
