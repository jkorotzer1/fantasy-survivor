import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values  = { deadline: String }

  connect() {
    this.deadline = new Date(this.deadlineValue)
    this.update()
    this.timer = setInterval(() => this.update(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  update() {
    const now  = new Date()
    const diff = this.deadline - now

    if (diff <= 0) {
      this.displayText("Picks locked")
      clearInterval(this.timer)
      return
    }

    const days    = Math.floor(diff / (1000 * 60 * 60 * 24))
    const hours   = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((diff % (1000 * 60)) / 1000)

    let parts = []
    if (days > 0)    parts.push(`${days}d`)
    if (hours > 0)   parts.push(`${hours}h`)
    if (minutes > 0) parts.push(`${minutes}m`)
    parts.push(`${seconds}s`)

    this.displayText(`Locks in ${parts.join(" ")}`)
  }

  displayText(text) {
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = text
    } else {
      this.element.textContent = text
    }
  }
}
