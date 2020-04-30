import React from 'react'
import { Button, InputGroup, InputGroupAddon, Input } from 'reactstrap'
import { Link } from 'react-router-dom'

class Header extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    return (
      <div className='header'>
        <h6 style={{ flex: 2 }}>Toggle Side Panel Placeholder</h6>
        <Link to='/' style={{ flex: 1, fontSize: '18px' }}>{'<Logo?>'}</Link>
        <InputGroup style={{ flex: 12 }}>
          <Input type='search' placeholder='Search for foods or restaurants...' />
          <InputGroupAddon addonType="append">
            <Button color='primary'>
              Search
            </Button>
          </InputGroupAddon>
        </InputGroup>
        {(this.props.isLoggedIn) ?
          <Link
            to='/accountinfo'
            style={{ flex: 1, fontSize: '18px', textAlign: 'center' }}>
            Account
          </Link>
          :
          <Link
            to='/login'
            style={{ flex: 1, fontSize: '18px', textAlign: 'center' }}>
            Login
          </Link>

        }
        {(!this.props.isLoggedIn) ?
          <Link
            to='/register'
            style={{ flex: 1, fontSize: '18px', textAlign: 'center' }}>
            Register
          </Link>
          :
          <Link
            onClick={this.props.handleLogout}
            style={{ flex: 1, fontSize: '18px', textAlign: 'center' }}>
            Log Out
          </Link>
        }
      </div>
    )
  }
}

export default Header