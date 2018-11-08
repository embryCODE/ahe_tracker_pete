import "tachyons"
import "../styles/app.css"

import "phoenix_html"

import { Elm } from '../elm/src/Main.elm'

const storedState = localStorage.getItem('elm-model-save')
const startingState = storedState ? JSON.parse(storedState) : null

const app = Elm.Main.init({
  node: document.getElementById('elm'),
  flags: startingState
})

app.ports.setStorage.subscribe(elmModel => {
  localStorage.setItem('elm-model-save', JSON.stringify(elmModel))
})


