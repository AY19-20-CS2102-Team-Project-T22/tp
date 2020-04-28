import React from 'react'
import Home from './Home'
import About from './About'
import Users from './Users'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'

class Body extends React.Component {
  render() {
    return (
      <div className='body'>
        <Route path='/' exact>
          <Home />
        </Route>
        <Route path='/about'>
          <About />
        </Route>
        <Route path='/users'>
          <Users />
        </Route>
      </div>
    )
  }
}

export default Body