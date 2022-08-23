import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];
  static values = { open: Boolean };
  showClass = "!translate-x-0";

  toggle(event) {
    event.stopPropagation();
    this.openValue = !this.openValue;
  }

  hide(event) {
    if (this.menuTarget.contains(event.target) === false && this.openValue) {
      this.openValue = false;
    }
  }

  openValueChanged() {
    if (this.openValue) {
      this._show();
    } else {
      this._hide();
    }
  }

  _show() {
    setTimeout(
      (() => {
        this.menuTarget.classList.add(this.showClass);
      }).bind(this)
    );
  }

  _hide() {
    setTimeout(
      (() => {
        this.menuTarget.classList.remove(this.showClass);
      }).bind(this)
    );
  }
}
