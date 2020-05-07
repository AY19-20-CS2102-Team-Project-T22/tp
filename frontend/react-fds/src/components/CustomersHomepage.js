import React from 'react'
import Header from './Header'
import Body from './Body'

class CustomersHomepage extends React.Component {
  constructor(props) {
    super(props)
    this.props = {}
  }

  render() {
    return (
      <div className='customers-homepage'>
        <Header
          isLoggedIn={this.props.isLoggedIn}
          handleLogout={this.props.handleLogout}
          toggleFilterPanel={this.props.toggleFilterPanel}
          userTypeStr={this.props.userTypeStr}
        />
        <Body
          isLoggedIn={this.props.isLoggedIn}
          userId={this.props.userId}
          items={this.props.items}
          itemsOnDisplay={this.props.itemsOnDisplay}
          cart={this.props.cart}
          updateItemsDisplayed={this.props.updateItemsDisplayed}
          showFilterPanel={this.props.showFilterPanel}
          restaurants={this.props.restaurants}
          restaurantsFilter={this.props.restaurantsFilter}
          foodCategories={this.props.foodCategories}
          foodCategoriesFilter={this.props.foodCategoriesFilter}
          handleRChange={this.props.handleRChange}
          handleFCChange={this.props.handleFCChange}
          handleAllBtn={this.props.handleAllBtn}
          handleClearBtn={this.props.handleClearBtn}
          handleAddToCart={this.props.handleAddToCart}
          handleRemoveFromCart={this.props.handleRemoveFromCart}
        />
      </div>
    )
  }
}

export default CustomersHomepage
