import { Controller } from "@hotwired/stimulus"
import { initClerk } from "utils/clerk";

// Connects to data-controller="login"
export default class extends Controller {
  isLoaded = false;

  async connect() {
    this.clerk = await initClerk();
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
