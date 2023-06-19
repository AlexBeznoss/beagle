import { Controller } from "@hotwired/stimulus"
import { H } from "highlight.run"

// Connects to data-controller="highlight-track"
export default class extends Controller {
  connect() {
    H.init('6gl3olg9', {
      tracingOrigins: true,
      networkRecording: {
        enabled: true,
        recordHeadersAndBody: true,
        urlBlocklist: [],
      },
    });
  }
}
