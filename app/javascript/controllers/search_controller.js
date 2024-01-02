import { Modal } from "tailwindcss-stimulus-components";
import { useHotkeys } from "stimulus-use/hotkeys";

const clamp = (value, min, max) => {
  if (value < min) return min;
  if (value > max) return max;
  return value;
};

export default class extends Modal {
  static targets = ["container", "background", "input", "form", "list"];
  static values = {
    open: { type: Boolean, default: false },
    restoreScroll: { type: Boolean, default: true },
    focusIndex: Number,
  };

  connect() {
    super.connect();
    useHotkeys(this, {
      "ctrl+k": [this.open],
    });
  }

  open(e) {
    super.open(e);
    // custom stuff
    e.preventDefault();

    this.inputTarget.value = "";
    setTimeout(
      function () {
        this.inputTarget.focus({ focusVisible: true });
      }.bind(this),
      100
    );
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
