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
      new_promo_type: null,
      new_promo_value: null,
      new_promo_startDate: null,
      new_promo_endDate: null,
      new_promo_condition: null,
      new_promo_description: null,
      new_promo_restaurant: null,
      new_promo_rid: null,

      curr_promo_type: null,
      curr_promo_value: null,
      curr_promo_startDate: null,
      curr_promo_endDate: null,
      curr_promo_condition: null,
      curr_promo_description: null,
      curr_promo_restaurant: null,
      curr_promo_rid: null,

      showNewPromoPanel: false
    }
    this.getPromotions = this.getPromotions.bind(this);
    this.updatePromotions = this.updatePromotions.bind(this);
    this.handleTypeChange = this.handleTypeChange.bind(this);
    this.handleValueChange = this.handleValueChange.bind(this);
    this.handleStartDateChange = this.handleStartDateChange.bind(this);
    this.handleEndDateChange = this.handleEndDateChange.bind(this);
    this.handleConditionChange = this.handleConditionChange.bind(this);
    this.handleDescriptionChange = this.handleDescriptionChange.bind(this);
    this.handleRestChange = this.handleRestChange.bind(this);
    this.handleRidChange = this.handleRidChange.bind(this);
    this.addPromotions = this.addPromotions.bind(this);
    this.updatePromotions = this.updatePromotions.bind(this);
    this.deletePromotions = this.deletePromotions.bind(this);
    this.getRid = this.getRid.bind(this);
    this.displayPromotions = this.displayPromotions.bind(this);
    this.handleToggleBtnClick = this.handleToggleBtnClick.bind(this);
    this.getPromotions();
  }

  updatePromotions(data) {
    this.setState({ promotions: data });
  }

  handleTypeChange(e) {
    this.setState({ new_promo_type: e.target.value });
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

  handleRestChange(e) {
    this.setState({ new_promo_restaurant: e.target.value });
  }

  handleRidChange(data) {
    this.setState({ new_promo_rid: data[0].rid });
  }

  getPromotions() {
    axios.get('http://localhost:5000/managers/promotions?mid=' + this.props.userId).
      then(res => {
        this.setState({ promotions: res.data })
      }).catch(err => { alert(err) });
  }

  getRid(rname) {
    axios.get('http://localhost:5000/restaurants/getRid?rname=' + rname).then(res => {
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

  deletePromotions(e) {
    //TODO
    // 1. visit /promotions/get_promoId with old promotion information (req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description)
    // 2. visit /promotions/delete with promoId
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
            flexFlow: 'column nowrap'
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
            Add New Promotion
          </div>
        }
      </div>
    )
  }
}

export default FDSPromotions