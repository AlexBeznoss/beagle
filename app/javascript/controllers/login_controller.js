import { Controller } from "@hotwired/stimulus"
import { initClerk } from "utils/clerk";

// Connects to data-controller="login"
export default class extends Controller {
  static values = {
    ready: Boolean
  }

  async connect() {
    this.clerk = await initClerk();
    this.readyValue = true;
  }

  async trigger() {
    if (!this.clerk.isReady()) {
      await this.clerk.load();
    }

    this._openSignIn();
  }

  _openSignIn() {
    this.clerk.openSignIn({
      redirectUrl: window.location.origin
    });
  }
}
