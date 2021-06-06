import {Elm} from "../Main.elm";
import {elmAppId} from "./config";

console.log(window.location.href)

export const mount = () => {
  Elm.Main.init({
    node: document.getElementById(elmAppId),
    flags: window.location.href
  });
}
