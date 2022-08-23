import { Controller } from "@hotwired/stimulus";
import tippy from "tippy.js";

export default class extends Controller {
  connect() {
    tippy(this.element, {
      content: this.element.dataset.tooltip,
    });
  }
}
