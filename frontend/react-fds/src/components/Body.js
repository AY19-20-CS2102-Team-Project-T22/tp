import React from 'react'
import FilterPanel from './FilterPanel'
import CartPanel from './CartPanel'
import ItemDisplay from './ItemDisplay'

class Body extends React.Component {
  constructor(props) {
    super(props)

    this.state = {

    }


  }

  handleAddToCart(e) {

  }
  render() {
    return (
      <div className='body'>
        {this.props.showFilterPanel &&
          <FilterPanel
            restaurants={this.props.restaurants}
            foodCategories={this.props.foodCategories}
            updateItemsDisplayed={this.props.updateItemsDisplayed}
            restaurantsFilter={this.props.restaurantsFilter}
            foodCategoriesFilter={this.props.foodCategoriesFilter}
            handleRChange={this.props.handleRChange}
            handleFCChange={this.props.handleFCChange}
            handleAllBtn={this.props.handleAllBtn}
            handleClearBtn={this.props.handleClearBtn}
          />
        }
        <ItemDisplay
          items={this.props.items}
          itemsOnDisplay={this.props.itemsOnDisplay}
          handleAddToCart={this.props.handleAddToCart}
        />
        <CartPanel
          items={this.props.items}
          itemsOnDisplay={this.props.itemsOnDisplay}
          cart={this.props.cart}
          handleRemoveFromCart={this.props.handleRemoveFromCart}
        />
      </div>
    )
  }
}

export default Body