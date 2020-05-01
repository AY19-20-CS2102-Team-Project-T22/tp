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
        <div
          style={{
            width: '100%',
            height: '60px',
            backgroundColor: 'yellow',
            marginBottom: '15px',
            padding: '0px 10px 0px 10px',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center'
          }}
        >
          <h3 style={{ fontWeight: 'bold' }}>
            Pick a restaurant > Add foods/drinks to cart > Checkout
          </h3>
        </div>
        {this.displayItems(this.props.itemsOnDisplay)}
      </div>
    )
  }
}

export default ItemDisplay;
