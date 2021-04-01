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

export const setOnboardingToken = token => {
  set('onboardingToken', token)
}

export const setPlaidPublicToken = token => {
  set('plaidPublicToken', token)
}

export const setStripeCode = token => {
  set('stripeCode', token)
}

export const getStateString = () => {
  return window.localStorage.getItem(elmAppId)
}
