import './main.css';
import * as serviceWorker from './serviceWorker';
import {Elm} from "./Main.elm";
import {elmAppId} from "./js/config";
import {verifyPhone} from "./js/phone";
import {verifyEmail} from "./js/email-validator";

const apiEndpoint = process.env.ELM_APP_API_ENDPOINT

const urlObj = new URL(window.location.href)
const pathName = urlObj.pathname
const committeeID = pathName.replace('/committee/', '')

const validateCommitteeID = () =>{
  if (committeeID === 'ian-cain') {
    return 'MA'
  } else return 'NY'
}


const app = Elm.Main.init({
  node: document.getElementById(elmAppId),
  flags: {
    host: window.location.href,
    apiEndpoint,
    jurisdiction: validateCommitteeID()
  }
});

app.ports.sendNumber.subscribe((number) => {
  app.ports.isValidNumReceiver.send(verifyPhone(number).isValid)
})

app.ports.sendEmail.subscribe((email) =>{
  app.ports.isValidEmailReceiver.send(verifyEmail(email))
})

serviceWorker.unregister()
