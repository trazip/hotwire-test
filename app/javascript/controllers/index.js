// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js or *_controller.ts.

import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

window.Stimulus = Application.start()
const context = require.context("controllers", true, /_controller\.(js|ts)$/)
Stimulus.load(definitionsFromContext(context))

import { Alert, Autosave, Dropdown, Modal, Tabs, Popover, Toggle, Slideover } from "tailwindcss-stimulus-components"
Stimulus.register('alert', Alert)
Stimulus.register('autosave', Autosave)
Stimulus.register('dropdown', Dropdown)
Stimulus.register('modal', Modal)
Stimulus.register('tabs', Tabs)
Stimulus.register('popover', Popover)
Stimulus.register('toggle', Toggle)
Stimulus.register('slideover', Slideover)
