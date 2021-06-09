import './main.css';
import * as serviceWorker from './serviceWorker';
import {Elm} from "./Main.elm";
import {elmAppId} from "./js/config";

const apiEndpoint = process.env.ELM_APP_API_ENDPOINT

Elm.Main.init({
  node: document.getElementById(elmAppId),
  flags: {
    host: window.location.href,
    apiEndpoint
  }
});

serviceWorker.unregister();
