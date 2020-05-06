import React from 'react'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'
import Header from './Header'
import Body from './Body'

class CustomersHomepage extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      // States for application login status.
      isLoggedIn: true,
      userId: 19,
      userType: 1,
      firstName: null,

      // State for full list of items on the Menu table.
      items: [],

      // State for food items display page.
      itemsOnDisplay: [],
      itemsOnDisplayFilter: [],

      // State for restaurant list.
      restaurants: [],
      restaurantsFilter: [],

      // State for food query.
      fquery: '',

      // State for food categories list.
      foodCategories: [],
      foodCategoriesFilter: [],

      // State for local item cart.
      cart: [],

      // State for viewing filter panel.
      showFilterPanel: true
    }
  }
  
  render() {
    return (
      <div className='customer-page'>
        <Header
          isLoggedIn={this.state.isLoggedIn}
          handleLogout={this.handleLogout}
          toggleFilterPanel={this.toggleFilterPanel}
          itemsOnDisplay={this.state.itemsOnDisplay}
          updateItemsDisplayed={this.updateItemsDisplayed}
          filterItemList={this.filterItemList}
          handleFqueryChange={this.handleFqueryChange}
          fquery={this.fquery}
        />
        <Body
          isLoggedIn={this.state.isLoggedIn}
          userId={this.state.userId}
          items={this.state.items}
          itemsOnDisplay={this.state.itemsOnDisplay}
          cart={this.state.cart}
          updateItemsDisplayed={this.updateItemsDisplayed}
          showFilterPanel={this.state.showFilterPanel}
          restaurants={this.state.restaurants}
          restaurantsFilter={this.state.restaurantsFilter}
          foodCategories={this.state.foodCategories}
          foodCategoriesFilter={this.state.foodCategoriesFilter}
          handleRChange={this.handleRChange}
          handleFCChange={this.handleFCChange}
          handleAllBtn={this.handleAllBtn}
          handleClearBtn={this.handleClearBtn}
          handleAddToCart={this.handleAddToCart}
          handleRemoveFromCart={this.handleRemoveFromCart}
        />
      </div>
    )
  }
}

export default CustomersHomepage