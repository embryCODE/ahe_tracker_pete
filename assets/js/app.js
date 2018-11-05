import "tachyons"
import "../styles/app.css"

import "phoenix_html"

import { Elm } from '../elm/src/Main.elm'
Elm.Main.init({ node: document.getElementById('elm') })
