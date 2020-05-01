import React from 'react'
import FoodItem from './FoodItem'

class ItemDisplay extends React.Component {
  constructor(props) {
    super(props)

    this.state = {}

    this.displayItems = this.displayItems.bind(this)
  }

  displayItems(items) {
    let menu = items.map((eachItem, i) => {
      return (
        <FoodItem
          item={eachItem}
          handleAddToCart={this.props.handleAddToCart}
          itemIndex={i}
          key={i}
        />
      )
    })

    return menu
  }

  render() {
    return (
      <div className='item-display'>
        {this.displayItems(this.props.itemsOnDisplay)}
      </div>
    )
  }
}

export default ItemDisplay;
