import { Controller } from "@hotwired/stimulus"
import { initClerk } from "utils/clerk";

// Connects to data-controller="profile"
export default class extends Controller {
  static values = {
    ready: Boolean
  }

  async connect() {
    const clerk = await initClerk();
    const el = document.createElement("div");
    this.element.appendChild(el);
    clerk.mountUserButton(el, {
      afterSignOutUrl: window.location.origin,
    });
    this.readyValue = true;
  }
}
