import React from 'react'
import { Link } from 'react-router-dom'
import { Button, InputGroup, InputGroupAddon, Input } from 'reactstrap'
import IconButton from '@material-ui/core/IconButton'
import FastfoodIcon from '@material-ui/icons/Fastfood'
import MenuIcon from '@material-ui/icons/Menu'

class Header extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    return (
      <div className='header'>
        <IconButton
          onClick={this.props.toggleFilterPanel}
          style={{
            width: '50px',
            height: '50px',
            marginLeft: '10px',
            marginRight: '10px',
          }}
        >
          <MenuIcon style={{ color: 'white' }} />
        </IconButton>
        <Link
          to='/'
          style={{
            height: '80%',
            width: '45px'
          }}
        >
          <FastfoodIcon
            style={{
              color: 'white',
              backgroundColor: 'orangered',
              width: '100%',
              height: '100%'
            }}
          />
        </Link>
        <InputGroup style={{ marginLeft: '20px', marginRight: '20px', flex: 1 }}>
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
            style={{
              fontSize: '18px',
              textAlign: 'center',
              marginRight: '10px',
              marginLeft: '20px',
              color: 'white',
              fontWeight: 'bold'
            }}
          >
            Account
          </Link>
          :
          <Link
            to='/login'
            style={{
              fontSize: '18px',
              textAlign: 'center',
              marginRight: '10px',
              marginLeft: '20px',
              color: 'white',
              fontWeight: 'bold'
            }}
          >
            Login
          </Link>
        }
        {(!this.props.isLoggedIn) ?
          <Link
            to='/register'
            style={{
              fontSize: '18px',
              textAlign: 'center',
              marginRight: '20px',
              marginLeft: '10px',
              color: 'white',
              fontWeight: 'bold'
            }}
          >
            Register
          </Link>
          :
          <Link
            onClick={this.props.handleLogout}
            style={{
              fontSize: '18px',
              textAlign: 'center',
              marginRight: '20px',
              marginLeft: '10px',
              color: 'white',
              fontWeight: 'bold'
            }}
          >
            Log Out
          </Link>
        }
      </div>
    )
  }
}

export default Header