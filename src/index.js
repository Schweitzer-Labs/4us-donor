import './main.css';
import * as serviceWorker from './serviceWorker';
import * as ElmApp from "./js/elm-app"


ElmApp.mount()

serviceWorker.unregister();
