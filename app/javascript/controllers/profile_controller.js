import { Controller } from "@hotwired/stimulus"
import { initClerk } from "utils/clerk";

// Connects to data-controller="profile"
export default class extends Controller {
  async connect() {
    const clerk = await initClerk();
    const el = document.createElement("div");
    this.element.appendChild(el);
    clerk.mountUserButton(el, {
      afterSignOutAll: window.location.origin,
      afterSignOutOne: window.location.origin,
      afterSwitchSession: window.location.origin
    });
  }
}
