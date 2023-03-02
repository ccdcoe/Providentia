import { Modal } from "tailwindcss-stimulus-components";
import { useHotkeys } from "stimulus-use/hotkeys";

const clamp = (value, min, max) => {
  if (value < min) return min;
  if (value > max) return max;
  return value;
};

export default class extends Modal {
  static targets = ["container", "input", "form", "list"];
  static values = { focusIndex: Number };

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

  submit() {
    this.formTarget.requestSubmit();
  }

  listTargetConnected(element) {
    this.focusIndex = 0;
    this.focusIndexValueChanged();
  }

  listTargetDisconnected(element) {
    this.focusIndex = 0;
    this.focusIndexValueChanged();
  }

  focusUp(e) {
    e.preventDefault();
    this.focusIndexValue = clamp(
      this.focusIndexValue - 1,
      0,
      this.listTargets.length
    );
  }

  focusDown(e) {
    e.preventDefault();
    this.focusIndexValue = clamp(
      this.focusIndexValue + 1,
      0,
      this.listTargets.length - 1
    );
  }

  focusOn(e) {
    this.focusIndexValue = Array.from(this.listTargets).indexOf(e.target);
  }

  focusIndexValueChanged() {
    this.listTargets.forEach((element, index) => {
      element.setAttribute("aria-selected", index === this.focusIndexValue);
    });
  }

  followFocusLink(e) {
    e.preventDefault();
    e.stopPropagation();
    if (this.listTargets[this.focusIndexValue]) {
      this.listTargets[this.focusIndexValue].querySelector("a").click();
    }
  }
}
