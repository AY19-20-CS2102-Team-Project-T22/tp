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
      // Find real array index of item from `this.state.items`.
      let itemIdx = 0
      this.props.items.forEach((f, idx) => {
        if (eachItem.fid === f.fid && eachItem.rname === f.rname) {
          itemIdx = idx
        }
      })
      return (
        <FoodItem
          item={eachItem}
          handleAddToCart={this.props.handleAddToCart}
          itemIndex={itemIdx}
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
            alignItems: 'center',
            boxShadow: '0px 3px 5px 2px rgba(0,0,0,0.3)'
          }}
        >
          <h3 style={{ fontWeight: 'bold' }}>
            Pick a restaurant > Add foods/drinks to cart > Checkout
          </h3>
        </div>
        {this.displayItems(this.props.itemsOnDisplay)}
        <div style={{ width: '100%', height: '20px' }}></div>
      </div>
    )
  }
}

export default ItemDisplay;
