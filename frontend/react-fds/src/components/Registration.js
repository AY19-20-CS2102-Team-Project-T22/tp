import React from 'react'
import { Button, Form, FormGroup, Label, Input, FormText } from 'reactstrap'

import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'

class Registration extends React.Component {
  render() {
    return (
      <div className='register'>
        <div style={{ flex: 1 }}></div>
        <Form style={{ flex: 1 }}>
          <h2 style={{ marginBottom: '25px' }}>Create an account</h2>
          { /* First name and Last name */ }
          <FormGroup>
            <Label for='firstName'>First Name</Label>
            <Input type='text' id='firstName' placeholder='Enter first name' />
          </FormGroup>
          <FormGroup>
            <Label for='lastName'>Last Name</Label>
            <Input type='text' id='lastName' placeholder='Enter password' />
          </FormGroup>

          { /* Username and Password */ }
          <FormGroup>
            <Label for='username'>Username</Label>
            <Input type='text' id='username' placeholder='Enter username' />
          </FormGroup>
          <FormGroup>
            <Label for='password'>Password</Label>
            <Input type='password' id='password' placeholder='Enter password' />
          </FormGroup>
          <Button>Register</Button>
        </Form>
        <div style={{ flex: 1 }}></div>
      </div>
    )
  }
}

export default Registration