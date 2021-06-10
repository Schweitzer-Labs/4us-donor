import ReactDOM from "react-dom";
import React from "react";
import {PlaidLink} from "react-plaid-link";
import * as State from "./state"

export const plaidRenderAndOpen = (linkToken, callback) => {

  const plaidLinkElement = document.getElementById('plaid-link')


  const onSuccess = publicToken => {
    State.setPlaidPublicToken(publicToken);
    ReactDOM.unmountComponentAtNode(plaidLinkElement);
    callback(publicToken);
  }

  ReactDOM.render(
    React.createElement(PlaidLink, {token: linkToken, onSuccess}),
    plaidLinkElement
  );


  setTimeout(() => {
    const button = document.querySelector('#plaid-link button')
    button.click()
  }, 1000)

}
