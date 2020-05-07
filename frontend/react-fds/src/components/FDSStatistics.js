import React from 'react'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'
import axios from 'axios'
import { ListGroup, ListGroupItem } from 'reactstrap'
import { Form, FormGroup, Label, Input, FormText, Button } from 'reactstrap';

/*
 * Page for FDS Managers to view statistics about the
 * application.
 */
class FDSStatistics extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      total: null,
      from: new Date().toISOString(),
      to: new Date().toISOString()
    }

    this.handleFromDateChange = this.handleFromDateChange.bind(this)
    this.handleToDateChange = this.handleToDateChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }


  handleFromDateChange(e) {
    let fromDate = new Date(e.target.value).toISOString()
    console.log(fromDate)
    this.setState({ from: fromDate })
  }

  handleToDateChange(e) {
    let toDate = new Date(e.target.value).toISOString()
    console.log(toDate)
    this.setState({ to: toDate })
  }

  handleSubmit(e) {
    e.preventDefault()

    let from = new Date(this.state.from)
    let to = new Date(this.state.to)
    let fromMonth = from.getMonth() + 1
    let toMonth = to.getMonth() + 1
    axios.get('http://localhost:5000/managers/num_of_customers/range'
      + '?from_year=' + from.getFullYear()
      + '&from_month=' + fromMonth
      + '&from_day=' + from.getDate()
      + '&to_year=' + to.getFullYear()
      + '&to_month=' + toMonth
      + '&to_day=' + to.getDate()
    )
      .then(res => {
        this.setState({ total: res.data.num })
      })
      .catch(err => {
        alert(err)
      })
  }

  render() {
    return (
      <div className=''>
        <h3>Total number of new customers</h3>
        <Form>
          <FormGroup>
            <Label>From</Label>
            <Input
              type="date"
              onChange={this.handleFromDateChange}
            />
          </FormGroup>
          <FormGroup>
            <Label>To</Label>
            <Input
              type="date"
              onChange={this.handleToDateChange}
            />
          </FormGroup>
          <Button type='submit' onClick={this.handleSubmit}>
            Submit
          </Button>
        </Form>
        <div>
          TOTAL NO OF CUSTOMERS FROM {this.state.from} TO {this.state.to} = {this.state.total}
        </div>

      </div>
    )
  }
}

export default FDSStatistics