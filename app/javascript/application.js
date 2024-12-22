//= require activestorage

// Dependencies
import { RalixApp } from 'ralix'
import "@hotwired/turbo-rails"
// ActionText: https://guides.rubyonrails.org/action_text_overview.html
import "trix"
import "@rails/actiontext"

// copied from https://stackoverflow.com/questions/61867995/how-to-embed-an-iframe-with-actiontext-trix-on-ruby-on-rails
//import Trix from "trix"
//import Rails from "@rails/ujs"


import "chartkick/chart.js"
// importmap: but thats not me
//import "chartkick"
//import "Chart.bundle"
//= require activestorage

////////////////////////////////////
// Carlessian custom code
////////////////////////////////////
// Fatto con Bard ma non sembra fungere e mi da errore..
// Import the fetch-api-data.js file
// //     import './fetch-api-data';
//fetchApiData();

// /Carlessian code
////////////////////////////////////


// Controllers
import AppCtrl      from './controllers/app'
import ArticlesCtrl from './controllers/articles'

// Components
import RemoteModal  from './components/remote_modal'
import Tooltip      from './components/tooltip'

// Add this if you want to customize Trix behavior
addEventListener("trix-initialize", event => {
  // Trix is ready
  const trix = event.target
})

const App = new RalixApp({
  routes: {
    '/articles$': ArticlesCtrl,
    '/.*': AppCtrl
  },
  components: [
    RemoteModal,
    Tooltip
  ]
})

App.start()
