import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["container"]

  connect() {
    this._clickListener = this._clickListener.bind(this);
  }
  
  disconnect() {
    document.removeEventListener('click', this._clickListener);
  }

  toggle() {
    if (this.containerTarget.classList.contains("hidden")) {
      this.containerTarget.classList.remove("hidden");
      document.addEventListener('click', this._clickListener);
    } else {
      this._hideTarget();
    }
  }

  _clickListener(event) {
    const toHide = !this.element.contains(event.target) || event.target.tagName === 'A';

    if (toHide) {
      this._hideTarget();
      document.removeEventListener('click', this._clickListener);
    }
  }

  _hideTarget() {
    this.containerTarget.classList.add("hidden");
  }
}
