import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = [ "icon" ]

  initialize() {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
       window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      localStorage.theme = "dark";
      document.documentElement.classList.add("dark");
      this.isDarkMode = true;
    } else {
      localStorage.theme = "light";
      document.documentElement.classList.remove("dark");
      this.isDarkMode = false;
    }

    this.updateIcons();
  }

  switchTheme() {
    if (localStorage.theme === "dark") {
      localStorage.theme = "light";
      document.documentElement.classList.remove("dark");
      this.isDarkMode = false;
    } else {
      localStorage.theme = "dark";
      document.documentElement.classList.add("dark");
      this.isDarkMode = true;
    }

    this.updateIcons();
  }

  updateIcons() {
    const toAdd = this.isDarkMode ? 'bxs-sun' : 'bxs-moon';
    const toRemove = this.isDarkMode ? 'bxs-moon' : 'bxs-sun';

    this.iconTargets.forEach((el) => {
      el.classList.remove(toRemove);
      el.classList.add(toAdd);
    })
  }
}
