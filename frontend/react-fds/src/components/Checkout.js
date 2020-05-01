import React from 'react'


class Checkout extends React.Component {
  constructor(props) {
    super(props)

    this.state = {

    }


  }

  handleAddToCart(e) {

  }
  render() {
    return (
      <div className='checkout'>
        1) Make database query to get customer credit cards.<br />
        2) Make user fill up a form (payment method, delivery location (need postal), etc).<br />
        3) When form submitted, perform database operation accordingly.<br />
      </div>
    )
  }
}

export default Checkout