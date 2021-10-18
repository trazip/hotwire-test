// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "controllers"
import jstz from 'jstz'

Rails.start()
ActiveStorage.start()

function setCookie(name, value) {
  let expires = new Date()
  expires.setTime(expires.getTime() + (24 * 60 * 60 * 1000))
  document.cookie = name + '=' + value + ';expires=' + expires.toUTCString()
}

const timezone = jstz.determine()
setCookie('timezone', timezone.name())
