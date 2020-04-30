import React from 'react'
import {
  Card, CardImg, CardText, CardBody,
  CardTitle, CardSubtitle, Button
} from 'reactstrap'
import FoodImage from '../images/placeholder_fooditem.jpg'

class FoodItem extends React.Component {
  constructor(props) {
    super(props)

    this.state = {}
  }

  render() {
    return (
      <Card className='food-item'>
        <CardImg top width="100%" src={FoodImage} alt="Card image cap" />
        <CardBody>
          <CardTitle>Food Name</CardTitle>
          <CardSubtitle>Food Category</CardSubtitle>
          <CardText>Some quick description about the food.</CardText>
          <Button style={{ width: '100%' }}>Add to cart</Button>
        </CardBody>
      </Card>
    )
  }
}

export default FoodItem;
