import { Application } from "@hotwired/stimulus"
import CountdownController from "controllers/countdown_controller"
import DarkModeController from "controllers/dark_mode_controller"
import ReplyFormController from "controllers/reply_form_controller"
import PollFieldsController from "controllers/poll_fields_controller"

const application = Application.start()
application.debug = false
window.Stimulus = application

application.register("countdown", CountdownController)
application.register("dark-mode", DarkModeController)
application.register("reply-form", ReplyFormController)
application.register("poll-fields", PollFieldsController)
