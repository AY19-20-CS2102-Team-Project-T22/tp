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

      add_cc_no: "",
      add_cc_type: "",
      add_cc_name: "",
      add_cc_expiry: "",
      add_cc_cvv: "",
    };

    this.displayCreditCards = this.displayCreditCards.bind(this);
    //this.handleAddPaymentMethod = this.handleAddPaymentMethod.bind(this);
    this.getPaymentMethods();

    this.handleAddCvvChange = this.handleAddCvvChange.bind(this);
    this.handleAddExpiryChange = this.handleAddExpiryChange.bind(this);
    this.handleAddNoChange = this.handleAddNoChange.bind(this);
    this.handleAddTypeChange = this.handleAddTypeChange.bind(this);
    this.handleAddNameChange = this.handleAddNameChange.bind(this);
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

  handleAddPaymentMethod() {
    console.log("ADD PRESSED");
    let data = {
      uid: this.state.uid,
      card_no: this.state.add_cc_no,
      card_cvv: this.state.add_cc_cvv,
      card_name: this.state.add_cc_name,
      card_type: this.state.add_cc_type,
      card_expiry: this.state.add_cc_expiry,
    };
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

  handleAddCvvChange(e) {
    this.setState({ add_cc_cvv: e.target.value });
  }

  handleAddExpiryChange(e) {
    this.setState({ add_cc_expiry: e.target.value });
  }

  handleAddNameChange(e) {
    this.setState({ add_cc_name: e.target.value });
  }

  handleAddNoChange(e) {
    this.setState({ add_cc_no: e.target.value });
  }

  handleAddTypeChange(e) {
    this.setState({ add_cc_type: e.target.value });
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
                  <FormGroup>
                    <Input
                      type="text"
                      required
                      placeholder="Card Number"
                      value={this.state.add_cc_no}
                      onChange={this.handleAddNoChange}
                    />
                  </FormGroup>
                  <FormGroup>
                    <Input
                      type="text"
                      required
                      placeholder="Type"
                      value={this.state.add_cc_type}
                      onChange={this.handleAddTypeChange}
                    />
                  </FormGroup>
                  <FormGroup>
                    <Input
                      type="text"
                      required
                      placeholder="Enter name on card"
                      value={this.state.add_cc_name}
                      onChange={this.handleAddNameChange}
                    />
                  </FormGroup>
                  <FormGroup>
                    <Input
                      type="text"
                      required
                      placeholder="Expiry date"
                      value={this.state.add_cc_expiry}
                      onChange={this.handleAddExpiryChange}
                    />
                  </FormGroup>
                  <FormGroup>
                    <Input
                      type="password"
                      required
                      placeholder="Enter CVV"
                      value={this.state.add_cc_cvv}
                      onChange={this.handleAddCvvChange}
                    />
                  </FormGroup>
                  <Button
                    color="primary"
                    style={{ float: "right", marginRight: "5px" }}
                    onClick={() => this.handleAddPaymentMethod()}
                  >
                    Add
                  </Button>
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
