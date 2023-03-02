import { Modal } from "tailwindcss-stimulus-components";
import { useHotkeys } from "stimulus-use";

export default class extends Modal {
  static targets = ["container", "input", "form"];

  connect() {
    super.connect();
    useHotkeys(this, {
      "ctrl+k": [this.open],
    });
  }

  _backgroundHTML() {
    return `<div id="${this.backgroundId}" class="fixed inset-0 z-40 bg-gray-900/50 dark:bg-gray-900/80"></div>`;
  }

  open(e) {
    super.open(e);
    // custom stuff

    this.inputTarget.value = "";
    this.inputTarget.focus();
  }

  submit(e) {
    this.formTarget.requestSubmit();
  }
}
