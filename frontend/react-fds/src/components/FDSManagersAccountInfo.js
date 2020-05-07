import React from 'react'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'

class FDSManagersAccountInfo extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      username: '',
      password: '',
      firstName: '',
      lastName: '',
      email: '',
      contactNo: '',

      editUsername: false,
      editPassword: false,
      editFirstName: false,
      editLastName: false,
      editEmail: false,
      editContactNo: false
    }

    this.handleFirstNameChange = this.handleFirstNameChange.bind(this)
    this.handleLastNameChange = this.handleLastNameChange.bind(this)
    this.handleUsernameChange = this.handleUsernameChange.bind(this)
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
    this.handleEmailChange = this.handleEmailChange.bind(this)
    this.handleContactChange = this.handleContactChange.bind(this)
    this.toggleEdit = this.toggleEdit.bind(this)
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

  toggleEdit(e) {
    let field = parseInt(e.target.value)
    switch (field) {
      case 0:
        this.setState(prev => ({ editUsername: !prev.editUsername}))
        break
      case 1:
        break
      case 2:
        break
      case 3:
        break
      case 4:
        break
      case 5:
        break
      default:
        // nothing
    }
  }

  render() {
    return (
      <div className='managers-page-body-mainbody-accountinfo'>
        <div style={{ flex: '1' }} />
        <Form style={{ flex: '1' }}>
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>Profile</h2>
          <FormGroup>
            <Label>Username</Label>
            <Input
              disabled={!this.state.editUsername}
              type='text'
              required={!this.state.editUsername}
              placeholder=''
              value={this.state.username}
              onChange={this.handleUsernameChange}
            />
            <Button
              value={0}
              onClick={this.toggleEdit}
            >
              Edit
            </Button>
          </FormGroup>
          <FormGroup>
            <Label>Password</Label>
            <Input
              disabled
              type='password'
              required
              placeholder=''
              value={this.state.firstName}
              onChange={this.handleFirstNameChange}
            />
            <Button>Edit</Button>
          </FormGroup>
          <FormGroup>
            <Label>First Name</Label>
            <Input
              disabled
              type='text'
              required
              placeholder=''
              value={this.state.firstName}
              onChange={this.handleFirstNameChange}
            />
            <Button>Edit</Button>
          </FormGroup>
          <FormGroup>
            <Label>Last Name</Label>
            <Input
              disabled
              type='text'
              required
              placeholder=''
              value={this.state.lastName}
              onChange={this.handleLastNameChange}
            />
            <Button>Edit</Button>
          </FormGroup>
          <FormGroup>
            <Label>Email</Label>
            <Input
              disabled
              type='email'
              placeholder=''
              value={this.state.email}
              onChange={this.handleEmailChange}
            />
            <Button>Edit</Button>
          </FormGroup>
          <FormGroup>
            <Label>Contact Number</Label>
            <Input
              disabled
              type='text'
              placeholder=''
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