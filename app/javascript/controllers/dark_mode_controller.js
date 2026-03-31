import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.syncIcon()
  }

  toggle() {
    const dark = !document.documentElement.classList.contains("dark")
    document.documentElement.classList.toggle("dark", dark)
    localStorage.setItem("darkMode", dark)
    this.syncIcon()
  }

  syncIcon() {
    if (this.hasIconTarget) {
      const dark = document.documentElement.classList.contains("dark")
      this.iconTarget.textContent = dark ? "☀️" : "🌙"
    }
  }
}
