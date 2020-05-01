import React from 'react'
import {
  BrowserRouter as Router,
  Route,
} from 'react-router-dom'
import axios from 'axios'
import Header from './components/Header'
import Body from './components/Body'
// import Footer from './components/Footer'
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

      // State for full list of items on the Menu table.
      items: [],

      // States for food items display page.
      itemsOnDisplay: [],
      filter: '',

      // State for item cart.
      cart: [],

      // State for viewing filter panel.
      showFilterPanel: true
    }

    // Function bindings.
    this.initItems = this.initItems.bind(this)
    this.updateUserId = this.updateUserId.bind(this)
    this.handleLogout = this.handleLogout.bind(this)
    this.toggleFilterPanel = this.toggleFilterPanel.bind(this)
    this.handleAddToCart = this.handleAddToCart.bind(this)
    this.handleRemoveFromCart = this.handleRemoveFromCart.bind(this)
    this.updateItemsDisplayed = this.updateItemsDisplayed.bind(this)
  }

  toggleFilterPanel() {
    this.setState(prev => ({
      showFilterPanel: !prev.showFilterPanel
    }))
  }

  handleAddToCart(e) {
    // Check if food item belong to the same restaurant.

    // Check if this is the first item.
    if (this.state.cart.length > 0) {
      // Get restaurant name from first item.
      let restaurant = this.state.items[this.state.cart[0]].rname

      if (this.state.items[e.target.value].rname !== restaurant) {
        alert('Please select items from a single restaurant for each order.')
        return
      }
    }

    // Check if item already exists in cart.
    // If yes, increment its quantity.
    // Otherwise, insert as new element.
    let itemToAdd = parseInt(e.target.value)
    if (this.state.cart.includes(itemToAdd)) {
    }
    
    this.setState(prev => ({
      cart: [...prev.cart, itemToAdd]
    }))
  }

  handleRemoveFromCart(e) {

  }

  updateUserId(uid) {
    this.setState({ userId: uid, isLoggedIn: true })
  }

  handleLogout() {
    this.setState({ isLoggedIn: false, userId: null })
    alert('You have been logged out.')
  }

  initItems(menu) {
    this.setState({ items: menu, itemsOnDisplay: menu })
  }

  updateItemsDisplayed(filter) {

  }

  componentDidMount() {
    // Retrieve all food items from menu from the database.
    axios.get('http://localhost:5000/menu')
    .then(res => {
      this.initItems(res.data)
    })
    .catch(err => {
      alert(err)
    })
  }

  render() {
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
              itemsOnDisplay={this.state.itemsOnDisplay}
              cart={this.state.cart}
              filter={this.state.filter}
              showFilterPanel={this.state.showFilterPanel}
              handleAddToCart={this.handleAddToCart}
            />
          </Route>
        </Router>
      </div>
    )
  }
}

export default App
