import React from 'react'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom'
import Header from './components/Header'
import Body from './components/Body'
import Footer from './components/Footer'
import './App.css'

class App extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      items: [],
      isLoggedIn: true,
      userId: null
    }

    // Function bindings.
  }

  render() {
    return (
      <div className='App'>
        <Router>
          <Header isLoggedIn={this.state.isLoggedIn} />
          <Body />
          <Footer />
        </Router>
      </div>
    )
  }
}

export default App
