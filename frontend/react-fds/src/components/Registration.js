import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import { Link } from 'react-router-dom'

class Registration extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      accountType: 'customers',
      firstName: '',
      lastName: '',
      username: '',
      password: '',
      email: '',
      contactNo: ''
    }

    this.handleDropdownChange = this.handleDropdownChange.bind(this)
    this.handleFirstNameChange = this.handleFirstNameChange.bind(this)
    this.handleLastNameChange = this.handleLastNameChange.bind(this)
    this.handleUsernameChange = this.handleUsernameChange.bind(this)
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
    this.handleEmailChange = this.handleEmailChange.bind(this)
    this.handleContactChange = this.handleContactChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
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

  handleSubmit(e) {
    e.preventDefault();
    const data = {
      type: this.state.accountType,
      userName: this.state.username,
      userPassword: this.state.password,
      lastName: this.state.lastName,
      firstName: this.state.firstName,
      phoneNumber: this.state.contactNo,
      email: this.state.email
    }
    const url = 'http://localhost:5000/users/registration';
    // HTTP POST request to backend.
    // Send account information over HTTP (Non-secure).
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
      <div className='register'>
        <div style={{ flex: 1 }}></div>
        <Form style={{ flex: 1 }} onSubmit={this.handleSubmit}>
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>Create an account</h2>
          { /* Dropdown for account type selection */}
          <FormGroup>
            <Label>Register as</Label>
            <Input
              type="select"
              defaultValue={this.state.accountType}
              onChange={this.handleDropdownChange}
            >
              <option value={'customers'}>Customer</option>
              <option value={'riders'}>Delivery Rider</option>
              <option value={'staffs'}>Restaurant Staff</option>
              <option value={'fdsmanagers'}>FDS Manager</option>
            </Input>
          </FormGroup>
          { /* First name and Last name */}
          <FormGroup>
            <Label>First Name</Label>
            <Input
              type='text'
              required
              placeholder='Enter first name'
              value={this.state.firstName}
              onChange={this.handleFirstNameChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>Last Name</Label>
            <Input
              type='text'
              required
              placeholder='Enter last name'
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
              placeholder='Enter username'
              value={this.state.username}
              onChange={this.handleUsernameChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>Password</Label>
            <Input
              type='password'
              required
              placeholder='Enter password'
              value={this.state.password}
              onChange={this.handlePasswordChange}
            />
          </FormGroup>

          { /* Email and Phone number */}
          <FormGroup>
            <Label>Email</Label>
            <Input
              type='email'
              placeholder='Enter email'
              value={this.state.email}
              onChange={this.handleEmailChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>Contact Number</Label>
            <Input type='text'
              placeholder='Enter contact no.'
              value={this.state.contactNo}
              onChange={this.handleContactChange}
            />
          </FormGroup>

          <Button
            style={{ width: '100%', marginBottom: '10px' }}
            type='submit'
            color='primary'
          >
            Register
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
    )
  }
}

export default Registration