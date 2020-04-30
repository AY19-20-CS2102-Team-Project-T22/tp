import React from 'react'
import FoodItem from './FoodItem'

class ItemDisplay extends React.Component {
  constructor(props) {
    super(props)

    this.state = {}

    this.displayItems = this.displayItems.bind(this)
  }

  displayItems(items) {
    console.log(items)
    let menu = items.map((eachItem, i) => {
      return <FoodItem item={eachItem} key={i} />
    })

    return menu
  }

  render() {
    return (
      <div className='item-display'>
        {this.displayItems(this.props.items)}
      </div>
    )
  }
}

export default ItemDisplay;
