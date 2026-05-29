import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "front", "back", "ratings"]

  connect() {
    this.flipped = false
  }

  flip() {
    if (this.flipped) return
    this.flipped = true
    this.cardTarget.style.transform = "rotateY(180deg)"
    this.ratingsTarget.classList.remove("d-none")
  }
}
