import { application } from "./application"

import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"


import AlertController from "./alert_controller"
application.register("alert", AlertController)

import CookieConsentController from "./cookie_consent_controller"
application.register("cookie-consent", CookieConsentController)

import LoadingController from "./loading_controller"
application.register("loading", LoadingController)

lazyLoadControllersFrom("controllers", application)