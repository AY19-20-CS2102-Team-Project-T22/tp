import React from "react";
import { Button, Form, FormGroup, Label, Input } from "reactstrap";
import { Link } from "react-router-dom";
import StaffSideBar from "./StaffSideBar"

class StaffHomePage extends React.Component {

    render() {
        return (
            <div className='bodyNH'>
                <StaffSideBar></StaffSideBar>


            </div>
        )
    }

}

export default StaffHomePage