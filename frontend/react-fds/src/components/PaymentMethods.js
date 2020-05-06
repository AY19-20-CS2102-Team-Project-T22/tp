import React from "react";
import axios from "axios";
import { Button, Form, FormGroup, Label, Input } from "reactstrap";
import { UncontrolledCollapse, CardBody, Card } from "reactstrap";
import { Link } from "react-router-dom";
import UserSidebar from "./UserSideBar";

class PaymentMethods extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      uid: props.userId,
      creditCards: [],
    };

    this.displayCreditCards = this.displayCreditCards.bind(this);
    this.getPaymentMethods();
  }

  initPage(data) {
    console.log("CREDIT CARD RECORDS : " + data);
    this.setState({ creditCards: data });
  }

  getPaymentMethods() {
    console.log("UID IS : " + this.state.uid);
    axios
      .get("http://localhost:5000/customers/creditcards/?uid=" + this.state.uid)
      .then((res) => {
        this.initPage(res.data);
      })
      .catch((err) => {
        // Display error.
        alert(err);
      });
  }

  handleDeletePaymentMethod(cc_no) {
    console.log("UID IS : " + this.state.uid + " CC IS : " + cc_no);
    axios
      .delete(
        "http://localhost:5000/customers/creditcards/delete/?uid=" +
          this.state.uid +
          "&card_no=" +
          cc_no
      )
      .then((res) => {
        alert(res.data);
        this.getPaymentMethods();
      })
      .catch((err) => {
        // Display error.
        alert(err);
      });
  }

  displayCreditCards(creditCards) {
    let iterator = 0;
    console.log("CCS:" + creditCards);
    let ccs = creditCards.map((cc) => {
      iterator++;
      return (
        <div style={{ width: "100%", marginBottom: "1rem" }}>
          <Button color="primary" id={"toggler" + iterator}>
            Card number : {cc.card_no}
          </Button>
          <UncontrolledCollapse toggler={"#toggler" + iterator}>
            <Card>
              <CardBody>
                Card number : {cc.card_no}
                <br></br>
                {console.log(cc.card_no)}
                Name : {cc.name_on_card} <br></br>
                Expiry date : {cc.expiry_date} <br></br>
                Card type : {cc.card_type} <br></br>
                <Button
                  color="primary"
                  style={{ float: "right", marginRight: "5px" }}
                  onClick={() => this.handleDeletePaymentMethod(cc.card_no)}
                >
                  Delete
                </Button>
              </CardBody>
            </Card>
          </UncontrolledCollapse>
        </div>
      );
    });

    return ccs;
  }

  render() {
    const { creditCards } = this.state.creditCards;

    return (
      <div className="body">
        <UserSidebar firstName={this.props.firstName}></UserSidebar>
        <div className="item-display">
          {this.displayCreditCards(this.state.creditCards)}
          <div style={{ width: "100%", marginBottom: "1rem" }}>
            <Button color="primary" id="addPayment">
              Add payment method
            </Button>
            <UncontrolledCollapse toggler="#addPayment">
              <Card>
                <CardBody>
                  Card number : <br></br>
                  Name : <br></br>
                  Expiry date : Card type : <br></br>
                </CardBody>
              </Card>
            </UncontrolledCollapse>
          </div>
        </div>
      </div>
    );
  }
}

export default PaymentMethods;
