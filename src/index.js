import './main.css';
import * as serviceWorker from './serviceWorker';
import {Elm} from "./Main.elm";
import {elmAppId} from "./js/config";
import {verifyPhone} from "./js/phone";
import {verifyEmail} from "./js/email-validator";

const apiEndpoint = process.env.ELM_APP_API_ENDPOINT
const config = JSON.parse(document.getElementById("config").text)

const app = Elm.Main.init({
  node: document.getElementById(elmAppId),
  flags: {
    host: window.location.href,
    apiEndpoint,
    jurisdiction: config.jurisdiction
  }
});

app.ports.sendNumber.subscribe((number) => {
  app.ports.isValidNumReceiver.send(verifyPhone(number).isValid)
})

app.ports.sendEmail.subscribe((email) =>{
  app.ports.isValidEmailReceiver.send(verifyEmail(email))
})

serviceWorker.unregister()
