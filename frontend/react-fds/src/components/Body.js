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
        {this.props.showFilterPanel && <FilterPanel />}
        <ItemDisplay />
        <CartPanel />
      </div>
    )
  }
}

export default Body