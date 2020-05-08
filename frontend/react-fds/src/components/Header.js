import React from 'react'
import { Link } from 'react-router-dom'
import IconButton from '@material-ui/core/IconButton'
import FastfoodIcon from '@material-ui/icons/Fastfood'
import MenuIcon from '@material-ui/icons/Menu'
import SearchBar from './SearchBar'

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
              backgroundColor: 'rgb(230, 61, 0)',
              width: '100%',
              height: '100%'
            }}
          />
        </Link>

        <SearchBar
          itemsOnDisplay={this.props.itemsOnDisplay}
          updateItemsDisplayed={this.props.updateItemsDisplayed}
          handleFqueryChange={this.props.handleFqueryChange}
          fquery={this.fquery}
        />

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

        <Link
          to='/'
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
      </div>
    )
  }
}

export default Header