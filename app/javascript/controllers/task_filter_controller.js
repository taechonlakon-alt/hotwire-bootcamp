import { Controller } from "@hotwired/stimulus"

// Filters task rows in the page without a request (All / Todo / Done).
// Rows added or replaced by Turbo Streams or broadcasts are filtered as they connect.
export default class extends Controller {
  static targets = [ "filter", "item", "count" ]
  static values = { current: { type: String, default: "all" } }

  connect() {
    // Controls start hidden so they never show when JavaScript is off.
    this.filterTargets.forEach((button) => button.hidden = false)
    if (this.hasCountTarget) this.countTarget.hidden = false
  }

  select({ params: { status } }) {
    this.currentValue = status
  }

  currentValueChanged() {
    this.#apply()
  }

  itemTargetConnected() {
    this.#apply()
  }

  itemTargetDisconnected() {
    this.#apply()
  }

  #apply() {
    let visible = 0

    this.itemTargets.forEach((item) => {
      const show = this.#matches(item.dataset.status)
      item.hidden = !show
      if (show) visible++
    })

    this.filterTargets.forEach((button) => {
      button.setAttribute("aria-pressed", button.dataset.taskFilterStatusParam === this.currentValue)
    })

    if (this.hasCountTarget) {
      this.countTarget.textContent = `Showing ${visible} of ${this.itemTargets.length}`
    }
  }

  #matches(status) {
    switch (this.currentValue) {
      case "todo": return status !== "done"
      case "done": return status === "done"
      default: return true
    }
  }
}
