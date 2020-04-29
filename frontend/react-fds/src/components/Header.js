import React from 'react'
import { Button, InputGroup, InputGroupText, InputGroupAddon, Input } from 'reactstrap'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'

class Header extends React.Component {
  constructor(props) {
    super(props)
  }

  // componentDidMount() {
  //   console.log('did mount')
  // }

  // componentDidUpdate() {
  //   console.log('did update')
  // }

  render() {
    return (
      <div className='header'>
        <h6 style={{ flex: 2 }}>Toggle Side Panel Placeholder</h6>
        <Link to='/' style={{ flex: 1, fontSize: '18px' }}>{'<Home>'}</Link>
        <InputGroup style={{ flex: 12 }}>
          <Input placeholder='Search for foods or restaurants...' />
          <InputGroupAddon addonType="append">
            <Button>
              Submit
            </Button>
          </InputGroupAddon>
        </InputGroup>
        {this.props.isLoggedIn &&
          <Link
            to='/accountinfo'
            style={{ flex: 1, fontSize: '18px', textAlign: 'center' }}>
            Account
          </Link>
        }
        <Link
          to='/login'
          style={{ flex: 1, fontSize: '18px', textAlign: 'center' }}>
          Log in
        </Link>
      </div>
    )
  }
}

export default Header