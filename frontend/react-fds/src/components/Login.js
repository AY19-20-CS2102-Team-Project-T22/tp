import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import { Link, Redirect } from 'react-router-dom'

class Login extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      username: '',
      password: ''
    }

    this.handleUsernameChange = this.handleUsernameChange.bind(this)
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  handleUsernameChange(e) {
    this.setState({ username: e.target.value })
  }

  handlePasswordChange(e) {
    this.setState({ password: e.target.value })
  }

  handleSubmit(e) {
    e.preventDefault()

    // HTTP GET request to backend.
    // Check if input user info exists in database.
    axios.get('http://localhost:5000/users/login/?username=' + this.state.username)
      .then(res => {
        if (res.data) {
          // Check if password matches.
          if (this.state.password === res.data.password) {
            alert('You are logged in as ' + res.data.first_name)
            this.props.updateUser(res.data.uid, 'customers', res.data.first_name) //FIXME: here should be res.data.type. return user_type attribute in Users table
          } else {
            alert('Error: You have entered an incorrect password.')
          }
        } else {
          alert('Error: No such user found.')
        }
      })
      .catch(err => {
        // Display error.
        alert(err)
      })
  }

  render() {
    return (
      <div className='login'>
        {(!this.props.isLoggedIn) ?
          <div>
            <Form onSubmit={this.handleSubmit}>
              <FormGroup>
                <Label>Username</Label>
                <Input
                  type='text'
                  required
                  placeholder='Username'
                  value={this.state.username}
                  onChange={this.handleUsernameChange}
                />
              </FormGroup>
              <FormGroup>
                <Label>Password</Label>
                <Input
                  type='password'
                  required
                  placeholder='Password'
                  value={this.state.password}
                  onChange={this.handlePasswordChange}
                />
              </FormGroup>
              <Button
                style={{ width: '100%' }}
                type='submit'
                color='primary'
              >
                Login
              </Button>
            </Form>
            <p>Don't have an account? <Link to='/register'>Register here.</Link></p>
          </div>
          :
          <Redirect to='/' />
        }
      </div>
    )
  }
}

export default Login