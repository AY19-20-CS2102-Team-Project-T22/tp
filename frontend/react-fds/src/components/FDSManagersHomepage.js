import React from 'react'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'
import { ListGroup, ListGroupItem } from 'reactstrap'
import FDSManagersAccountInfo from './FDSManagersAccountInfo'
import FDSStatistics from './FDSStatistics'

class FDSManagersHomepage extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      name: 'Placeholder Name',
      renderedPage: 0
    }
    this.renderMainPanel = this.renderMainPanel.bind(this)
    this.handleListItem = this.handleListItem.bind(this)
  }

  componentDidMount() {
    // Get FDS manager info.

  }

  renderMainPanel(page) {
    switch (page) {
      case 0: // account info
        return (
          <FDSManagersAccountInfo />
        )
      case 1: // promotions
        return (
          <div>
            Promotions
          </div>
        )
      case 2: // statistics
        return (
          <FDSStatistics />
        )
    }
  }

  handleListItem(e) {
    console.log(e.target.value)
    this.setState({ renderedPage: parseInt(e.target.value) })
  }

  render() {
    return (
      <div className='managers-page-container'>
        <div className='managers-page-header'>
          <h2 style={{ flex: '1' }}>Welcome, {this.state.name}</h2>
          <h3>Logout</h3>
        </div>
        <div className='managers-page-body'>
          <div className='managers-page-body-sidepanel'>
            <ListGroup>
              <ListGroupItem value={0} onClick={this.handleListItem} color='danger' tag='button' action>Account Info</ListGroupItem>
              <ListGroupItem value={1} onClick={this.handleListItem} color='danger' tag='button' action>Promotions</ListGroupItem>
              <ListGroupItem value={2} onClick={this.handleListItem} color='danger' tag='button' action>Statistics</ListGroupItem>
            </ListGroup>
          </div>
          <div className='managers-page-body-mainbody'>
            {this.renderMainPanel(this.state.renderedPage)}
          </div>
        </div>
      </div>
    )
  }
}

export default FDSManagersHomepage