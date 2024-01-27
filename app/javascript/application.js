//= require activestorage

// Dependencies
import { RalixApp } from 'ralix'
import "@hotwired/turbo-rails"
// ActionText: https://guides.rubyonrails.org/action_text_overview.html
import "trix"
import "@rails/actiontext"

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
//import './fetch-api-data';
//fetchApiData();

// /Carlessian code
////////////////////////////////////


// Controllers
import AppCtrl      from './controllers/app'
import ArticlesCtrl from './controllers/articles'

// Components
import RemoteModal  from './components/remote_modal'
import Tooltip      from './components/tooltip'

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
