import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  instance;

  static values = {
    options: { type: Array, default: [] },
  };

  connect() {
    if (!this.element.hidden) {
      let options;
      if (this.element.dataset.create) {
        options = {
          wrapperClass: "ts-wrapper form-input",
          createOnBlur: true,
          create: true,
        };
      } else {
        const hasEmptyOption =
          this.element.querySelectorAll("option[value='']").length > 0;
        const ismultiple = this.element.multiple;
        options = {
          allowEmptyOption: hasEmptyOption,
          maxOptions: null,
          wrapperClass: "ts-wrapper form-input",
          onDelete: function (values, event) {
            return ismultiple || !(values.length == 1 && !hasEmptyOption);
          },
        };
      }
      this.instance = new TomSelect(this.element, options);
      this.instance.addOptions(
        this.optionsValue.map((tag) => {
          return { text: tag, value: tag };
        })
      );
    }
  }

  disconnect() {
    this.instance.destroy();
  }
}
