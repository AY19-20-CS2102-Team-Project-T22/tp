import React from 'react'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'
import { ListGroup, ListGroupItem } from 'reactstrap'
import FDSManagersAccountInfo from './FDSManagersAccountInfo'
import FDSPromotions from './FDSPromotions'
import FDSStatistics from './FDSStatistics'

class FDSManagersHomepage extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      mid: this.props.userId,
      name: 'Placeholder Name',
      renderedPage: 0
    }
    this.renderMainPanel = this.renderMainPanel.bind(this)
    this.handleListItem = this.handleListItem.bind(this)
  }

  renderMainPanel(page) {
    switch (page) {
      case 0: // account info
        return (
          <FDSManagersAccountInfo />
        )
      case 1: // promotions
        return (
          <FDSPromotions 
            userId = {this.state.mid}
          />
        )
      case 2: // all fds promotions
          return (
            <div>
              all promotions
            </div>
          )
      case 3: // statistics
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
              <ListGroupItem value={1} onClick={this.handleListItem} color='danger' tag='button' action>My Promotions</ListGroupItem>
              <ListGroupItem value={2} onClick={this.handleListItem} color='danger' tag='button' action>All FDS Promotions</ListGroupItem>
              <ListGroupItem value={3} onClick={this.handleListItem} color='danger' tag='button' action>Statistics</ListGroupItem>
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