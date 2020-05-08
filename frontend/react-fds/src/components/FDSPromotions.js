import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
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
      promotions: null,
      new_promo_type: null,
      new_promo_value: null,
      new_promo_startDate: null,
      new_promo_endDate: null,
      new_promo_condition: null,
      new_promo_description: null,
      new_promo_restaurant: null,
      new_promo_rid: null
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
    this.getPromotions();
  }

  updatePromotions(data){
    this.setState({promotions: data});
  }

  handleTypeChange(e){
    this.setState({new_promo_type: e.target.value});
  }

  handleValueChange(e){
    this.setState({new_promo_value: e.target.value});
  }

  handleStartDateChange(e){
    this.setState({new_promo_startDate: e.target.value});
  }

  handleEndDateChange(e){
    this.setState({new_promo_endDate: e.target.value});
  }

  handleConditionChange(e){
    this.setState({new_promo_condition: e.target.value});
  }

  handleDescriptionChange(e){
    this.setState({new_promo_description: e.target.value});
  }

  handleRestChange(e){
    this.setState({new_promo_restaurant: e.target.value});
  }

  handleRidChange(data){
    this.setState({new_promo_rid: data[0].rid});
  }

  getPromotions(){
    axios.get('http://localhost:5000/managers/promotions?mid='+this.state.mid).then(res => {
      this.updatePromotions(res.data);
    }).catch(err => {alert(err)});
  }

  getRid(rname){
  axios.get('http://localhost:5000/restaurants/getRid?rname='+rname).then(res => {     
    }).catch(err => {alert(err)});
  }

  addPromotions(e){
    e.preventDefault()
    alert('adding new promotion');
    let rname = this.state.new_promo_restaurant;
    axios.get('http://localhost:5000/restaurants/getRid?rname='+rname).then(res => {
        let rid = res.data[0].rid;
        const url = 'http://localhost:5000/managers/promotions/add?mid='+this.state.mid+'&type='+this.state.new_promo_type+'&value='+this.state.new_promo_value+'&startDate='+this.state.new_promo_startDate+'&endDate='+this.state.new_promo_endDate+'&condition='+this.state.new_promo_condition+'&description='+this.state.new_promo_description+'&rid='+rid;
        axios.get(url).then(res => {
          this.updatePromotions(res.data);
        }).catch(err => {alert(err)});
    }).catch(err => {alert(err)});
  }

  updatePromotions(e){
    //TODO
    // 1. visit /promotions/get_promoId with old promotion information (req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description)
    // 2. visit /promotions/update  with new promotion information and promoId
  }

  deletePromotions(e){
    //TODO
    // 1. visit /promotions/get_promoId with old promotion information (req.query.type, req.query.value, req.query.startDate, req.query.endDate, req.query.condition, req.query.description)
    // 2. visit /promotions/delete with promoId
  }

  render() {
    return (
      <div className=''>
        FDS Promotions Page

        <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>Promotions</h2>
        
        { console.log(this.state.promotions)/* TODO: show this.state.promotions here. */}
        
        <div className='modify'>
        <div style={{ flex: 1 }}></div>
        <Form style={{ flex: 1 }} onSubmit={this.addPromotions}>
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>add new promotion</h2>
          <FormGroup>
            <Label>promotion type</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.new_promo_type}
              onChange={this.handleTypeChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>promotion value</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.new_promo_value}
              onChange={this.handleValueChange}
            />
          </FormGroup>

          { /* Username and Password */}
          <FormGroup>
            <Label>promotion startDate</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.new_promo_startDate}
              onChange={this.handleStartDateChange}
            />
          </FormGroup>

          <FormGroup>
            <Label>promotion endDate</Label>
            <Input
              type='text'
              required
              placeholder
              value={this.state.new_promo_endDate}
              onChange={this.handleEndDateChange}
            />
          </FormGroup>

          { /* Email and Phone number */}
          <FormGroup>
            <Label>promotion condition</Label>
            <Input
              type='text'
              placeholder
              value={this.state.new_promo_condition}
              onChange={this.handleConditionChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>promotion description</Label>
            <Input type='text'
              placeholder
              value={this.state.new_promo_description}
              onChange={this.handleDescriptionChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>promotion restaurant</Label>
            <Input type='text'
              placeholder
              value={this.state.new_promo_restaurant}
              onChange={this.handleRestChange}
            />
          </FormGroup>
          <Button
            style={{ width: '100%', marginBottom: '10px' }}
            type='submit'
            color='primary'
          >
            Add
          </Button>
        </Form>
        <div style={{ flex: 1 }}></div>
      </div>
    </div>
    )
  }
}

export default FDSPromotions