import React from 'react'
import { Form, FormGroup, Label, Input, Button } from 'reactstrap'

class FilterPanel extends React.Component {
  constructor(props) {
    super(props)

    this.state = {}

    this.displayRestaurant = this.displayRestaurant.bind(this)
    this.displayFoodCategories = this.displayFoodCategories.bind(this)
  }

  displayRestaurant(arr) {
    let checkboxList = []

    arr.forEach((item, i) => {
      checkboxList.push(
        <FormGroup check key={i}>
          <Label check>
            <Input
              type='checkbox'
              value={i}
              checked={this.props.restaurantsFilter[i]}
              onChange={this.props.handleRChange}
            />{item.rname}
          </Label>
        </FormGroup>
      )
    })

    return checkboxList
  }

  displayFoodCategories(arr) {
    let checkboxList = []

    arr.forEach((item, i) => {
      checkboxList.push(
        <FormGroup check key={i}>
          <Label check>
            <Input
              type='checkbox'
              value={i}
              checked={this.props.foodCategoriesFilter[i]}
              onChange={this.props.handleFCChange}
            />{item.fcname}
          </Label>
        </FormGroup>
      )
    })

    return checkboxList
  }

  render() {
    return (
      <div className='filter-panel'>
        <Form onSubmit={this.props.updateItemsDisplayed} style={{ color: 'white' }}>
          <h5>Filters</h5><br />
          <h5>Restaurants{' '}</h5>
          <Button value={1} onClick={this.props.handleAllBtn}>All</Button>{' '}
          <Button value={1} onClick={this.props.handleClearBtn}>Clear</Button>
          {this.displayRestaurant(this.props.restaurants)}
          <br /><h5>Categories{' '}</h5>
          <Button value={2} onClick={this.props.handleAllBtn}>All</Button>{' '}
          <Button value={2} onClick={this.props.handleClearBtn}>Clear</Button>
          {this.displayFoodCategories(this.props.foodCategories)}
          <Button
            style={{ width: '100%', marginTop: '40px', marginBottom: '20px' }}
            type='submit'>
            Apply filters
            </Button>
        </Form>

      </div>
    )
  }
}

export default FilterPanel;
