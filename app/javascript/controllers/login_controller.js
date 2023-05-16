import { Controller } from "@hotwired/stimulus"
import { waitForClerk } from "utils/clerk";

// Connects to data-controller="login"
export default class extends Controller {
  static values = {
    ready: Boolean
  }

  async connect() {
    await waitForClerk();
    this.readyValue = true;
  }

  async trigger() {
    window.Clerk.openSignIn({
      redirectUrl: window.location.origin
    });
  }
}
