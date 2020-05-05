import React from 'react'
import { Redirect, Link } from 'react-router-dom';
import { Button, Input, InputGroup, InputGroupAddon, Label, Form, FormGroup } from 'reactstrap'

class AutoCompleteSearch extends React.Component {
    constructor(props) {
        super(props)
        {console.log("ACS CONSTRUCTOR " + this.props.itemsOnDisplay)}
        this.state = {
            suggestions : [],
            selectedItem : [],
            text : '',
        };

        //this.onTextChange.bind(this)
        this.suggestionSelected.bind(this)
        this.renderSuggestions = this.renderSuggestions.bind(this)
        this.onTextChanged = this.onTextChanged.bind(this)


    }

    /*onTextChange = (e) => {
        const searchText = e.target.value;
        const { itemsOnDisplay } = this.props;
        let suggestions = [];
        if( searchText.length > 0) {
            const regex = new RegExp(`${searchText}`, `i`);
            suggestions = itemsOnDisplay.sort().filter((itm,i) => regex.test(itm.fname) || regex.test(itm.rname));
            
            console.log("SUGGESTIONS ARE : " + suggestions)
            
        }
        this.setState(() => ({suggestions, text : searchText}));
        
    }*/

    onTextChanged(e) {
        this.setState({ text : e.target.value})
    }

    suggestionSelected (itm, i) {
        this.setState(() => ({
            selectedItem: (itm, i),
            text: itm.fname,
            suggestions : [],
        }))
    }

    renderSuggestions () {
        const {suggestions} = this.state;
        if(suggestions.length === 0) {
            return null;
        }
        return (
            
            <ul>
               {suggestions.map((item, i ) => <li onClick = {() => this.props.handleFquery(item.fname)}>{item.fname}</li>)}
            </ul>
        );
    }
    

    render () {
        const { text } = this.state;
        const { suggestions } = this.state;
        return (
            <div class="input-group mb-3" style={{ marginLeft: '10px', marginTop : '15px', marginRight : '10px'}}>
                <input 
                    type="text" 
                    class="form-control" 
                    placeholder='Search for foods...' 
                    onChange = {this.props.handleFqueryChange} 
                    value = {this.props.fquery}
                >
                </input>
            <div class="input-group-append">
            <Button class="btn btn-outline-secondary" type="button" color='primary' onClick={this.props.updateItemsDisplayed}>Button</Button>
            </div>
            </div>

        )
    }

}
export default AutoCompleteSearch