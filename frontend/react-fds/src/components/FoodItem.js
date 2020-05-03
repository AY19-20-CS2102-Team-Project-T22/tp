import React from 'react'
import {
  Card, CardImg, CardBody,
  CardTitle, CardSubtitle, Button
} from 'reactstrap'
import FoodImage from '../images/placeholder_fooditem.jpg'

class FoodItem extends React.Component {
  constructor(props) {
    super(props)

    this.state = {}
  }

  render() {
    let btnStyle
    if (this.props.item.is_available) {
      btnStyle = {
        width: '100%',
        backgroundColor: 'orangered',
        fontSize: '21px',
        fontWeight: 'bold'
      }
    } else {
      btnStyle = {
        width: '100%',
        backgroundColor: 'grey',
        fontSize: '21px',
        fontWeight: 'bold'
      }
    }
    
    return (
      <Card className='food-item'>
        <CardImg top width='100%' src={FoodImage} alt='Food_IMG' />
        <CardBody style={{ height: '100%', textAlign: 'center' }}>
          <CardSubtitle
            style={{
              fontSize: '15px'
            }}
          >
            {'(' + this.props.item.fcname + ')'}
          </CardSubtitle>
          <CardTitle
            style={{
              fontSize: '16px',
              height: '50px',
              overflowY: 'auto'
            }}
          >
            {this.props.item.fname}
          </CardTitle>
          <CardSubtitle
            style={{ 
              fontSize: '15px', 
              height: '70px'
             }}
          >
            Restaurant: <br />{this.props.item.rname}
          </CardSubtitle>
          <CardSubtitle
            style={{ fontSize: '24px', fontWeight: 'bold' }}
          >
            ${parseFloat(this.props.item.unit_price).toFixed(2)}
          </CardSubtitle>
          <Button
            disabled={!this.props.item.is_available}
            value={this.props.itemIndex}
            onClick={this.props.handleAddToCart}
            style={btnStyle}
          >
            {this.props.item.is_available? 'Add to cart' : 'Sold out'}
          </Button>
        </CardBody>
      </Card>
    )
  }
}

export default FoodItem;
