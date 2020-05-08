import React from 'react'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input } from 'reactstrap'
import { Link } from 'react-router-dom'
import UserSideBar from './UserSideBar'

class RiderHomePage extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      uid: props.userId,
      type: null,
      totalSalary: null,
      totalNumOrders: null,
      year: '1999',
      month: '01'
    }

    this.handleYearChange = this.handleYearChange.bind(this);
    this.handleMonthChange = this.handleMonthChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.getMonthSalary = this.getMonthSalary.bind(this);
    this.getRiderInfo();
  }

  updateType(data){
    console.log(data);
    this.setState({type: data[0].type});
  }

  updateTotalSalary(data){
    console.log(data);
    this.setState({totalSalary: data});
  }

  updateTotalNumOrders(data){
    console.log(data);
    this.setState({totalNumOrders: data[0].count});
  }

  handleYearChange(e){
    this.setState({year: e.target.value});
  }

  handleMonthChange(e){
    this.setState({month: e.target.value});
  }

  getRiderInfo() {
    axios.get('http://localhost:5000/riders/type?riderId='+this.state.uid).then(res => {
      this.updateType(res.data);
    }).catch(err => {alert(err)});
    axios.get('http://localhost:5000/riders/totalSalary?riderId='+this.state.uid).then(res => {
      this.updateTotalSalary(res.data);
    }).catch(err => {alert(err)});
    axios.get('http://localhost:5000/riders/totalNumOrders?riderId='+this.state.uid).then(res => {
      this.updateTotalNumOrders(res.data);
    }).catch(err => {alert(err)});
  }

  getMonthSalary(e){
    e.preventDefault();
    
  }

  handleSubmit(e) {
    e.preventDefault()
    let url = 'http://localhost:5000/riders/monthOrder?riderId='+ this.state.uid +'&year='+this.state.year+'&month='+this.state.month;
    axios.get(url).then(res => {
        console.log(res);
        alert('num of orders: ' + res.data[0].count + '\n');
      }).catch(err => { alert(err) });

    url = 'http://localhost:5000/riders/monthSalary?rid='+this.state.uid+ '&year='+this.state.year+'&month='+this.state.month;
    axios.get(url).then(res => {
        alert('mthSalary:'+res.data[0].totalmthsalary);
     });

    url = 'http://localhost:5000/riders/monthWorkingHours?rid='+this.state.uid+ '&year='+this.state.year+'&month='+this.state.month;
    axios.get(url).then(res => {
    })
  }

  render() {
    return (
      <div className = 'body'>
      <UserSideBar
        firstName = {'riders'}
      ></UserSideBar>
      <div className = 'item-display' style={{color: 'white'}}>
        {/*
        <div>
          <Label> hello, {this.state.old_username} </Label> <br></br>
          <Label> your firstname: {this.state.old_firstName} </Label> <br></br>
          <Label> your lastname: {this.state.old_lastName} </Label> <br></br>
          <Label> your mail: {this.state.old_email} </Label> <br></br>
          <Label> your contactNo : {this.state.old_contactNo} </Label> <br></br>
        </div>
        <Link
          to='/accountinfo/credit_card'
        >
        Manage your credit card
        </Link>
        */}
        <div className='modify'>
        <div style={{ flex: 1 }}></div>
        <Form style={{ flex: 1 }} onSubmit={this.handleSubmit}>
          <h2 style={{ marginTop: '10px', marginBottom: '35px' }}>Summary</h2>
          <FormGroup>
        <Label> You are a {this.state.type==1 ? 'fulltime':'partime'} rider</Label>
          </FormGroup>
          <FormGroup>
      <Label>Total Salary: {this.state.totalSalary}</Label>
          </FormGroup>

          { /* Username and Password */}
          <FormGroup>
            <Label>Total number of orders: {this.state.totalNumOrders}</Label>
          </FormGroup>

          <FormGroup>
            <Label></Label>
          </FormGroup>

          { /* Email and Phone number */}
          <FormGroup>
            <Label>year</Label>
            <Input
              name='year'
              type='text'
              required
              placeholder
              value={this.state.year}
              onChange={this.handleYearChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>month</Label>
            <Input
              name='year'
              type='text'
              required
              placeholder
              value={this.state.month}
              onChange={this.handleMonthChange}
            />
          </FormGroup>

          <Button
            style={{ width: '100%', marginBottom: '10px' }}
            type='submit'
            color='primary'
          >
            Search
          </Button>
          <Link to='/'>
            <Button
              style={{ width: '100%' }}
              color='secondary'
            >
              Cancel
            </Button>
          </Link>
        </Form>
        <div style={{ flex: 1 }}></div>
      </div>
    </div>
    </div>
    )
  }
}

export default RiderHomePage
