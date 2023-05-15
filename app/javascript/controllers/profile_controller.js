import { Controller } from "@hotwired/stimulus"
import { waitForClerk } from "utils/clerk";

// Connects to data-controller="profile"
export default class extends Controller {
  static values = {
    ready: Boolean
  }

  async connect() {
    await waitForClerk();
    const clerk = window.Clerk;
    const el = document.createElement("div");
    this.element.appendChild(el);
    clerk.mountUserButton(el, {
      afterSignOutUrl: window.location.origin,
    });
    this.readyValue = true;
  }
}
