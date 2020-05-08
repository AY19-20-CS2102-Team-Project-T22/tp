import React from 'react'
import { ListGroup, ListGroupItem } from 'reactstrap'
import FDSManagersAccountInfo from './FDSManagersAccountInfo'
import FDSPromotions from './FDSPromotions'
import FDSStatistics from './FDSStatistics'
import axios from 'axios'

class FDSManagersHomepage extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      mid: this.props.userId,
      username: '',
      password: '',
      firstName: '',
      lastName: '',
      email: '',
      contact: '',

      name: 'Placeholder Name',
      renderedPage: 0
    }
    this.renderMainPanel = this.renderMainPanel.bind(this)
    this.handleListItem = this.handleListItem.bind(this)
    this.getUserData = this.getUserData.bind(this)
  }

  renderMainPanel(page) {
    switch (page) {
      case 0: // account info
        return (
          <FDSManagersAccountInfo
            mid={this.state.mid}
            username={this.state.username}
            password={this.state.password}
            firstName={this.state.firstName}
            lastName={this.state.lastName}
            email={this.state.email}
            contact={this.state.contact}
            getUserData={this.getUserData}
          />
        )
      case 1: // promotions
        return (
          <FDSPromotions
            userId={this.state.mid}
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
    this.setState({ renderedPage: parseInt(e.target.value) })
  }

  getUserData() {
    // Get user information.
    axios.get('http://localhost:5000/account_info?uid=' + this.props.userId)
      .then(res => {
        console.log('successfully retrieved user data')
        this.setState({
          username: res.data.username,
          password: res.data.userpassword,
          firstName: res.data.firstname,
          lastName: res.data.lastname,
          contact: res.data.phonenumber,
          email: res.data.email
        })
      })
      .catch(err => {
        alert(err)
      })
  }

  render() {
    return (
      <div className='managers-page-container'>
        <div className='managers-page-header'>
          <h2 style={{ flex: '1' }}>Welcome, {this.state.firstName} {this.state.lastName}</h2>
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