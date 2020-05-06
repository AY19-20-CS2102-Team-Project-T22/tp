import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import { Link } from 'react-router-dom'

class CreditCard extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      uid: props.userId,
    }

  }


  initPage(data){
    console.log("before:");
    console.log(this.state);
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
    let url = 'http://localhost:5000/credit_card/modify';
    let data = {
      uid: this.state.uid,
      type: this.state.accountType,
      firstName: this.state.firstName,
      lastName: this.state.lastName,
      username: this.state.username,
      email: this.state.email,
      password: this.state.password,
      contactNo: parseInt(this.state.contactNo)
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


  //card_no, cvv_no, card_type, name_on_card, expiry_date
  render() {
    return (
      <div>
      <Label>Manage your credit card</Label>
      <div className='modify'>
      <div style={{ flex: 1 }}></div>
      <Form style={{ flex: 1 }} onSubmit={this.handleSubmit}>
        <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>add new credit card</h2>
        <FormGroup>
          <Label>card number</Label>
          <Input
            type='text'
            required
            placeholder
            value
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
    )
  }
}

export default CreditCard
