import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  connect() {
    if (!this.element.hidden) {
      new TomSelect(this.element, {
        allowEmptyOption: true,
        maxOptions: null,
        wrapperClass: "ts-wrapper form-input",
      });
    }
  }
}
