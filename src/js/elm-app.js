import {Elm} from "../Main.elm";
import {elmAppId} from "./config";

export const mount = () => {
  Elm.Main.init({
    node: document.getElementById(elmAppId),
  });
}
