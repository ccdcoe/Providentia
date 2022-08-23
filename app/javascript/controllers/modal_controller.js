import { Modal } from "tailwindcss-stimulus-components";

export default class extends Modal {
  _backgroundHTML() {
    return `<div id="${this.backgroundId}" class="fixed inset-0 z-40 bg-gray-900/50 dark:bg-gray-900/80"></div>`;
  }
}
