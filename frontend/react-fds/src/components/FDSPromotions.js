import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input, ListGroup, ListGroupItem } from 'reactstrap'
import { Link } from 'react-router-dom'
import RiderHomePage from './RiderHomePage';

/*
 * FDS Managers manages FDS promotions
 * Able to perform the following:
 * 1) Add new promotions
 * 2) Remove promotions
 * 3) Update/Edit promotions
 */
class FDSPromotions extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      mid: this.props.userId,
      promotions: ['test1', 'test2'],
      new_promo_value: '',
      new_promo_startDate: new Date(),
      new_promo_endDate: new Date(
        (new Date()).getFullYear(),
        (new Date()).getMonth(),
        (new Date()).getDate() + 1),
      new_promo_condition: '',
      new_promo_description: '',

      curr_promo_type: null,
      curr_promo_value: null,
      curr_promo_startDate: null,
      curr_promo_endDate: null,
      curr_promo_condition: null,
      curr_promo_description: null,

      showNewPromoPanel: false
    }
    this.getPromotions = this.getPromotions.bind(this);
    this.updatePromotions = this.updatePromotions.bind(this);
    this.handleValueChange = this.handleValueChange.bind(this);
    this.handleStartDateChange = this.handleStartDateChange.bind(this);
    this.handleEndDateChange = this.handleEndDateChange.bind(this);
    this.handleConditionChange = this.handleConditionChange.bind(this);
    this.handleDescriptionChange = this.handleDescriptionChange.bind(this);
    this.addPromotions = this.addPromotions.bind(this);
    this.updatePromotions = this.updatePromotions.bind(this);
    this.displayPromotions = this.displayPromotions.bind(this);
    this.handleToggleBtnClick = this.handleToggleBtnClick.bind(this);
    this.handleAddNewPromo = this.handleAddNewPromo.bind(this);
    this.clearNewPromoFields = this.clearNewPromoFields.bind(this);
    this.getPromotions();
  }

  clearNewPromoFields() {
    this.setState({
      new_promo_value: '',
      new_promo_startDate: new Date(),
      new_promo_endDate: new Date(
        (new Date()).getFullYear(),
        (new Date()).getMonth(),
        (new Date()).getDate() + 1),
      new_promo_condition: '',
      new_promo_description: ''
    })
  }

  handleAddNewPromo(e) {
    e.preventDefault()

    // Construct new promotion as object.
    const dataToSend = {
      mid: this.props.userId,
      value: this.state.new_promo_value,
      description: this.state.new_promo_description,
      startDate: new Date(this.state.new_promo_startDate).toISOString(),
      endDate: new Date(this.state.new_promo_endDate).toISOString(),
      condition: this.state.new_promo_condition
    }
    axios.post('http://localhost:5000/managers/promotions/add', dataToSend)
    .then(res => {
      alert('You have successfully added a new promotion.')
      this.clearNewPromoFields()
      this.getPromotions()
    })
    .catch(err => alert(err))
  }

  updatePromotions(data) {
    this.setState({ promotions: data });
  }

  handleValueChange(e) {
    this.setState({ new_promo_value: e.target.value });
  }

  handleStartDateChange(e) {
    this.setState({ new_promo_startDate: e.target.value });
  }

  handleEndDateChange(e) {
    this.setState({ new_promo_endDate: e.target.value });
  }

  handleConditionChange(e) {
    this.setState({ new_promo_condition: e.target.value });
  }

  handleDescriptionChange(e) {
    this.setState({ new_promo_description: e.target.value });
  }

  getPromotions() {
    axios.get('http://localhost:5000/managers/promotions?mid=' + this.props.userId).
      then(res => {
        this.setState({ promotions: res.data })
      }).catch(err => { alert(err) });
  }

  addPromotions(e) {
    e.preventDefault()
    alert('adding new promotion');
    let rname = this.state.new_promo_restaurant;
    axios.get('http://localhost:5000/restaurants/getRid?rname=' + rname).then(res => {
      let rid = res.data[0].rid;
      const url = 'http://localhost:5000/managers/promotions/add?mid=' + this.state.mid + '&type=' + this.state.new_promo_type + '&value=' + this.state.new_promo_value + '&startDate=' + this.state.new_promo_startDate + '&endDate=' + this.state.new_promo_endDate + '&condition=' + this.state.new_promo_condition + '&description=' + this.state.new_promo_description + '&rid=' + rid;
      axios.get(url).then(res => {
        this.updatePromotions(res.data);
      }).catch(err => { alert(err) });
    }).catch(err => { alert(err) });
  }

  updatePromotions(e) {
    //TODO
    // 1. visit /promotions/get_promoId with old promotion information (req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description)
    // 2. visit /promotions/update  with new promotion information and promoId
    // axios.get('http://localhost:5000/managers/promotions/get_promoId/'
    // + '?type=' + this.state.curr_promo_type
    // + '&value=' + this.state.curr_promo_value
    // + '&startDate=' + this.state.curr_promo_startDate
    // + '&endDate=' + this.state.curr_promo_endDate
    // + '&condition=' + this.state.curr_promo_condition
    // + '&description=' + this.state.curr_promo_description
    // )
    // .then(res => {

    // })
    // .catch(err => alert(err))
  }

  displayPromotions() {
    let promoList = this.state.promotions.map((item, i) => {
      return (
        <ListGroupItem style={{ color: 'black', marginBottom: '7px' }}>
          Promo #{i + 1}<br />
          Description:<br />
          {item.description}<br />
          Promo starts on: {new Date(item.startdate).toLocaleString()}<br />
          Promo ends on: {new Date(item.enddate).toLocaleString()}
        </ListGroupItem>
      )
    })

    return promoList
  }

  handleToggleBtnClick(e) {
    e.preventDefault()

    this.setState(prev => ({ showNewPromoPanel: !prev.showNewPromoPanel }))
  }

  render() {
    return (
      <div className='fdspromotions'>
        <div
          style={{
            flex: '1',
            display: 'flex',
            flexFlow: 'column nowrap',
            overflowY: 'auto'
          }}
        >
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>
            Current Promotions{' '}
            <Button onClick={this.handleToggleBtnClick}>
              Add New Promotion
            </Button>
          </h2>
          <ListGroup>
            {this.displayPromotions()}
          </ListGroup>
        </div>
        {this.state.showNewPromoPanel &&
          <div
            style={{
              marginLeft: '10px',
              width: '370px'
            }}
          >
            <h3>Add New Promotion</h3>
            <Form onSubmit={this.handleAddNewPromo}>
              <FormGroup>
                <Label>
                  Promo Description:
                </Label>
                <Input
                  type='text'
                  required
                  placeholder=''
                  value={this.state.new_promo_description}
                  onChange={this.handleDescriptionChange}
                />
              </FormGroup>
              <FormGroup>
                <Label>
                  Discount:
                </Label>
                <Input
                  type='text'
                  required
                  placeholder=''
                  value={this.state.new_promo_value}
                  onChange={this.handleValueChange}
                />
              </FormGroup>
              <FormGroup>
                <Label>
                  Start Date:
                </Label>
                <Input
                  type='date'
                  required
                  placeholder=''
                  value={this.state.new_promo_startDate}
                  // defaultValue={this.state.new_promo_startDate}
                  onChange={this.handleStartDateChange}
                />
              </FormGroup>
              <FormGroup>
                <Label>
                  End Date:
                </Label>
                <Input
                  type='date'
                  required
                  placeholder=''
                  value={this.state.new_promo_endDate}
                  // defaultValue={this.state.new_promo_endDate}
                  onChange={this.handleEndDateChange}
                />
              </FormGroup>
              <FormGroup>
                <Label>
                  Condition:
                </Label>
                <Input
                  type='text'
                  required
                  placeholder=''
                  value={this.state.new_promo_condition}
                  // defaultValue={this.state.new_promo_endDate}
                  onChange={this.handleConditionChange}
                />
              </FormGroup>
              <FormGroup>
                <Button type='submit'>
                  Add
                </Button>
              </FormGroup>
            </Form>
          </div>
        }
      </div>
    )
  }
}

export default FDSPromotions