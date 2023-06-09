import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  connect() {
    if (!this.element.hidden) {
      const hasEmptyOption =
        this.element.querySelectorAll("option[value='']").length > 0;
      const ismultiple = this.element.multiple;
      new TomSelect(this.element, {
        allowEmptyOption: hasEmptyOption,
        maxOptions: null,
        wrapperClass: "ts-wrapper form-input",
        onDelete: function (values, event) {
          return ismultiple || !(values.length == 1 && !hasEmptyOption);
        },
      });
    }
  }
}
