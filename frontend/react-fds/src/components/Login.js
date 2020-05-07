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

    const data = {
      userName:this.state.username,
      userPassword: this.state.password
    };
    // HTTP GET request to backend.
    // Check if input user info exists in database.
    axios.post('http://localhost:5000/users/login', data)
      .then(res => {
        if (res.data) {
          // Check if password matches.
            alert('You are logged in');
            console.log(res.data);
            let typeStr = '';
            switch(res.data.type){
              case 1:
                typeStr = 'customers';
                break;
              case 2:
                typeStr = 'riders';
                break;
              case 3:
                typeStr = 'staff';
                break;
              case 4:
                typeStr = 'fdsmanagers';
                break;
              default:
                console.log("unexpected type");
            }
            this.props.updateUser(res.data.userid, res.data.type, typeStr) //FIXME: here should be res.data.type. return user_type attribute in Users table
        } else {
          alert('Error: No such user found or Wrong password');
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