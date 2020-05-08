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
import { Table } from 'reactstrap'
import { Dropdown, DropdownToggle, DropdownMenu, DropdownItem } from 'reactstrap'

/*
 * Page for FDS Managers to view statistics about the
 * application.
 */

let month = new Array()
month[0] = "JAN"
month[1] = "FEB"
month[2] = "MAR"
month[3] = "APR"
month[4] = "MAY"
month[5] = "JUN"
month[6] = "JUL"
month[7] = "AUG"
month[8] = "SEP"
month[9] = "OCT"
month[10] = "NOV"
month[11] = "DEC"

class FDSStatistics extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      newCustomersTotal: null,
      from: new Date(
        (new Date()).getFullYear(),
        (new Date()).getMonth() - 1,
        (new Date()).getDate())
        .toISOString(),
      to: new Date().toISOString(),

      totalOrders: 'placeholder',

      dropdownOpen: false,
      dropdownValue: new Date().getFullYear(),

      table: []
    }

    this.handleFromDateChange = this.handleFromDateChange.bind(this)
    this.handleToDateChange = this.handleToDateChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.toggleDropdownOpen = this.toggleDropdownOpen.bind(this)
    this.getYears = this.getYears.bind(this)
    this.generateTable = this.generateTable.bind(this)
    this.prepareData = this.prepareData.bind(this)
  }

  toggleDropdownOpen() {
    this.setState(prev => ({ dropdownOpen: !prev.dropdownOpen }))
  }

  getYears() {
    let currYear = new Date().getFullYear()

    let yearsArr = []
    for (let i = 0; i < 10; i++) {
      yearsArr.push(currYear - i)
    }

    return yearsArr.map((each) => {
      return (
        <DropdownItem
          value={each}
          onClick={e => this.setState({ dropdownValue: e.target.value })}
        >
          {each}
        </ DropdownItem>
      )
    })
  }

  generateTable() {

  }

  handleFromDateChange(e) {
    if (e.target.value !== '') {
      let fromDate = new Date(e.target.value).toISOString()
      console.log(fromDate)
      this.setState({ from: fromDate })
    }
  }

  handleToDateChange(e) {
    if (e.target.value !== '') {
      let toDate = new Date(e.target.value).toISOString()
      console.log(toDate)
      this.setState({ to: toDate })
    }
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
        this.setState({ newCustomersTotal: res.data.num })
      })
      .catch(err => {
        alert(err)
      })
  }

  prepareData(e) {
    let tableRows = []
    this.setState({ table: [] })
    for (let i = 0; i < 12; i++) {
      // Get total number of new customers.
      let monthIndex = i + 1

      axios.get('http://localhost:5000/managers/num_of_customers/'
        + '?year=' + this.state.dropdownValue
        + '&month=' + monthIndex
      )
        .then(res1 => {
          let newCustomers = res1.data.num

          axios.get('http://localhost:5000/managers/num_of_orders/'
            + '?year=' + this.state.dropdownValue
            + '&month=' + monthIndex
          )
            .then(res2 => {
              let orderCount = res2.data.num
              axios.get('http://localhost:5000/managers/cost_of_orders/'
                + '?year=' + this.state.dropdownValue
                + '&month=' + monthIndex
              )
                .then(res3 => {
                  let totalOrderCost = res3.data.num
                  let currTable = [...this.state.table]
                  currTable.push(
                    <tr style={{ color: 'white' }}>
                      <th scope="row">{month[i]}</th>
                      <td>{newCustomers}</td>
                      <td>{orderCount}</td>
                      <td>{totalOrderCost}</td>
                    </tr>
                  )
                  this.setState({ table: currTable })
                })
                .catch(err3 => alert(err3))
            })
            .catch(err2 => alert(err2))

        })
        .catch(err => alert(err))
    }
  }

  render() {
    return (
      <div className='fds-stats'>
        <div className='fds-stat-subheaders'>
          <h3 style={{ fontWeight: 'bold' }}>STATISTICS</h3>
        </div>
        <div style={{ overflowY: 'auto' }}>
          <Dropdown isOpen={this.state.dropdownOpen} toggle={this.toggleDropdownOpen}>
            <DropdownToggle caret>
              {this.state.dropdownValue}
            </DropdownToggle>
            <DropdownMenu>
              {this.getYears()}
            </DropdownMenu>
          </Dropdown>

          <Button onClick={this.prepareData}>Apply</Button>

          <Table>
            <thead>
              <tr
                style={{
                  color: 'white',
                  fontWeight: 'bold',
                  fontSize: '20px'
                }}
              >
                <th>Month</th>
                <th>New Customers</th>
                <th>Total Orders</th>
                <th>Total Orders Cost</th>
              </tr>
            </thead>
            <tbody>
              {this.state.table}
            </tbody>
          </Table>

        </div>

      </div>
    )
  }
}

export default FDSStatistics