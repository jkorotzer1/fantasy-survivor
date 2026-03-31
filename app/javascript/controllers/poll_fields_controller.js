import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  toggle(event) {
    this.containerTarget.classList.toggle("hidden", !event.target.checked)
  }
}
