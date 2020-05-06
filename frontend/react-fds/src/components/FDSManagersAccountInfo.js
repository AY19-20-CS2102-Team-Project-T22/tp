import React from 'react'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'

class FDSManagersAccountInfo extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      firstName: '',
      lastName: '',


    }
  }

  render() {
    return (
      <div className='managers-page-body-mainbody-accountinfo'>
        <div style={{ flex: '1' }} />
        <Form style={{ flex: '1' }}>
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>Create an account</h2>
          <FormGroup>
            <Label>Username</Label>
            <Input
              type='text'
              required
              placeholder='Enter first name'
              value={this.state.firstName}
              onChange={this.handleFirstNameChange}
            />
            <Button>Edit</Button>
          </FormGroup>
          <FormGroup>
            <Label>Password</Label>
            <Input
              type='password'
              required
              placeholder='Enter first name'
              value={this.state.firstName}
              onChange={this.handleFirstNameChange}
            />
            <Button>Edit</Button>
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
            <Button>Edit</Button>
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
            <Button>Edit</Button>
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
            <Button>Edit</Button>
          </FormGroup>
          <FormGroup>
            <Label>Contact Number</Label>
            <Input
              type='text'
              placeholder='Enter contact no.'
              value={this.state.contactNo}
              onChange={this.handleContactChange}
            />
            <Button>Edit</Button>
          </FormGroup>
        </Form>
        <div style={{ flex: '1' }} />
      </div>
    )
  }
}

export default FDSManagersAccountInfo