import {elmAppId} from "./config";


const set = (key, val) => {
  const stateString = localStorage.getItem(elmAppId)
  const state = JSON.parse(stateString)
  const newState = {
    ...state,
    [key]: val
  }
  const newStateString = JSON.stringify(newState)
  window.localStorage.setItem(elmAppId, newStateString)
}

export const getStateString = () => {
  return window.localStorage.getItem(elmAppId)
}
