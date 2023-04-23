import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation"
export default class extends Controller {
  static targets = ['mobile'];

  isOpened = false;
  bodyClasses = ['max-h-screen', 'overflow-hidden', 'relative'];
  mobileClasses = ['opacity-100', 'opinter-events-auto'];

  connect() {
    this.toggle = this.toggle.bind(this);
  }

  toggle() {
    this._toggleClasses(document.body, this.bodyClasses);
    this._toggleClasses(this.mobileTarget, this.mobileClasses);
    this.isOpened = !this.isOpened;

  }

  _toggleClasses(el, klasses) {
    for (const [_, klass] of Object.entries(klasses)) {
      el.classList.toggle(klass);
    }
  }
}
