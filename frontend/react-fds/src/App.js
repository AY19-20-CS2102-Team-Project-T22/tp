import React from 'react'
import {
  BrowserRouter as Router,
  Route,
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
      // States for application login status.
      isLoggedIn: false,
      userId: null,

      // States for food items display page.
      items: [],
      filter: '',

      // State for item cart.
      cart: [],

      // State for viewing filter panel.
      showFilterPanel: true
    }

    // Function bindings.
    this.updateUserId = this.updateUserId.bind(this)
    this.handleLogout = this.handleLogout.bind(this)
    this.toggleFilterPanel = this.toggleFilterPanel.bind(this)
  }

  toggleFilterPanel() {
    this.setState(prev => ({
      showFilterPanel: !prev.showFilterPanel
    }))
  }

  addToCart(e) {
    this.setState(prev => ({
      cart: [...prev, this.state.items[e.target.value]]
    }))
  }

  updateUserId(uid) {
    this.setState({ userId: uid, isLoggedIn: true })
  }

  handleLogout() {
    this.setState({ isLoggedIn: false, userId: null })
    alert('You have been logged out.')
  }

  render() {
    console.log(this.state.isLoggedIn)
    return (
      <div className='App'>
        <Router>
          <Route path='/login' exact>
            <Login
              isLoggedIn={this.state.isLoggedIn}
              userId={this.state.userId}
              updateUserId={this.updateUserId}
            />
          </Route>
          <Route path='/register' exact>
            <Registration />
          </Route>
          <Route path='/' exact>
            <Header
              isLoggedIn={this.state.isLoggedIn}
              handleLogout={this.handleLogout}
              toggleFilterPanel={this.toggleFilterPanel}
            />
            <Body
              items={this.state.items}
              filter={this.state.filter}
              showFilterPanel={this.state.showFilterPanel}
            />
            <Footer />
          </Route>
        </Router>
      </div>
    )
  }
}

export default App
