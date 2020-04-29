import React from 'react'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'
import Header from './components/Header'
import Body from './components/Body'
import Footer from './components/Footer'
import Login from './components/Login'
import Registration from './components/Registration'
import './App.css'

class App extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      items: [],
      isLoggedIn: false,
      userId: null
    }

    // Function bindings.
  }

  render() {
    return (
      <div className='App'>
        <Router>
          <Route path='/login' exact>
            <Login />
          </Route>
          <Route path='/register' exact>
            <Registration />
          </Route>
          <Route path='/' exact>
            <Header isLoggedIn={this.state.isLoggedIn} />
            <Body />
            <Footer />
          </Route>
          
        </Router>
      </div>
    )
  }
}

export default App
