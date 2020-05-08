import React from 'react'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import axios from 'axios'

class FDSManagersAccountInfo extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      newUsername: '',
      newPassword: '',
      newFirstName: '',
      newLastName: '',
      newEmail: '',
      newContactNo: '',

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
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  handleFirstNameChange(e) {
    this.setState({ newFirstName: e.target.value })
  }

  handleLastNameChange(e) {
    this.setState({ newLastName: e.target.value })
  }

  handleUsernameChange(e) {
    this.setState({ newUsername: e.target.value })
  }

  handlePasswordChange(e) {
    this.setState({ newPassword: e.target.value })
  }

  handleEmailChange(e) {
    this.setState({ newEmail: e.target.value })
  }

  handleContactChange(e) {
    this.setState({ newContactNo: e.target.value })
  }

  toggleEdit(e) {
    let field = parseInt(e.target.value)
    switch (field) {
      case 0:
        if (this.state.editUsername) {
          this.setState({ newUsername: '' })
        }
        this.setState(prev => ({ editUsername: !prev.editUsername }))
        break
      case 1:
        if (this.state.editPassword) {
          this.setState({ newPassword: '' })
        }
        this.setState(prev => ({ editPassword: !prev.editPassword }))
        break
      case 2:
        if (this.state.editFirstName) {
          this.setState({ newFirstName: '' })
        }
        this.setState(prev => ({ editFirstName: !prev.editFirstName }))
        break
      case 3:
        if (this.state.editLastName) {
          this.setState({ newLastName: '' })
        }
        this.setState(prev => ({ editLastName: !prev.editLastName }))
        break
      case 4:
        if (this.state.editEmail) {
          this.setState({ newEmail: '' })
        }
        this.setState(prev => ({ editEmail: !prev.editEmail }))
        break
      case 5:
        if (this.state.editContactNo) {
          this.setState({ newContactNo: '' })
        }
        this.setState(prev => ({ editContactNo: !prev.editContactNo }))
        break
      default:
      // nothing
    }
  }

  handleSubmit(e) {
    e.preventDefault()

    // Construct new user info as object.
    const dataToSend = {
      userId: this.props.mid,
      userName: this.state.newUsername,
      userPassword: this.state.newPassword,
      lastName: this.state.newLastName,
      firstName: this.state.newFirstName,
      phoneNumber: this.state.newContactNo,
      email: this.state.newEmail
    }
    axios.post('http://localhost:5000/account_info/modify', dataToSend)
    .then(res => {
      alert('Profile has been successfully update.')

      this.props.getUserData()
    })
    .catch(err => alert(err))
  }

  render() {
    return (
      <div className='managers-page-body-mainbody-accountinfo'>
        <div style={{ flex: '1' }} />
        <Form style={{ flex: '1' }} onSubmit={this.handleSubmit}>
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>Profile</h2>
          <FormGroup>
            <Label>Username</Label>
            <Input
              disabled={!this.state.editUsername}
              type='text'
              required={!this.state.editUsername}
              placeholder={this.props.username}
              value={this.state.newUsername}
              onChange={this.handleUsernameChange}
            />
            <Button
              value={0}
              onClick={this.toggleEdit}
            >
              {!this.state.editUsername? 'Edit' : 'Cancel'}
            </Button>
          </FormGroup>
          <FormGroup>
            <Label>Password</Label>
            <Input
              disabled={!this.state.editPassword}
              type='password'
              required
              placeholder={this.props.password}
              value={this.state.newPassword}
              onChange={this.handlePasswordChange}
            />
            <Button
              value={1}
              onClick={this.toggleEdit}
            >
              {!this.state.editPassword? 'Edit' : 'Cancel'}
            </Button>
          </FormGroup>
          <FormGroup>
            <Label>First Name</Label>
            <Input
              disabled={!this.state.editFirstName}
              type='text'
              required
              placeholder={this.props.firstName}
              value={this.state.newFirstName}
              onChange={this.handleFirstNameChange}
            />
            <Button
              value={2}
              onClick={this.toggleEdit}
            >
              {!this.state.editFirstName? 'Edit' : 'Cancel'}
            </Button>
          </FormGroup>
          <FormGroup>
            <Label>Last Name</Label>
            <Input
              disabled={!this.state.editLastName}
              type='text'
              required
              placeholder={this.props.lastName}
              value={this.state.newLastName}
              onChange={this.handleLastNameChange}
            />
            <Button
              value={3}
              onClick={this.toggleEdit}
            >
              {!this.state.editLastName? 'Edit' : 'Cancel'}
            </Button>
          </FormGroup>
          <FormGroup>
            <Label>Email</Label>
            <Input
              disabled={!this.state.editEmail}
              type='email'
              placeholder={this.props.email}
              value={this.state.newEmail}
              onChange={this.handleEmailChange}
            />
            <Button
              value={4}
              onClick={this.toggleEdit}
            >
              {!this.state.editEmail? 'Edit' : 'Cancel'}
            </Button>
          </FormGroup>
          <FormGroup>
            <Label>Contact Number</Label>
            <Input
              disabled={!this.state.editContactNo}
              type='text'
              placeholder={this.props.contact}
              value={this.state.newContactNo}
              onChange={this.handleContactChange}
            />
            <Button
              value={5}
              onClick={this.toggleEdit}
            >
              {!this.state.editContactNo? 'Edit' : 'Cancel'}
            </Button>
          </FormGroup>
          <Button
            type='submit'
            color='primary'
            style={{ width: '100%' }}
            disabled={!(
              this.state.editUsername
              || this.state.editPassword
              || this.state.editFirstName
              || this.state.editLastName
              || this.state.editEmail
              || this.state.editContactNo)
            }
          >
            Confirm edit
          </Button>
        </Form>
        <div style={{ flex: '1' }} />
      </div>
    )
  }
}

export default FDSManagersAccountInfo