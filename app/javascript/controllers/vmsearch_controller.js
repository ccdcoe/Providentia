import { Controller } from "@hotwired/stimulus";
import debounce from "debounce";
export default class extends Controller {
  connect() {
    const form = this.element;
    const debounced_submit = debounce(() => form.requestSubmit(), 1000);
    const doSubmit = function (event) {
      if (document.activeElement == event.target) {
        debounced_submit();
      } else {
        form.requestSubmit();
      }
    };
    form.addEventListener("focusout", doSubmit);
    form.addEventListener("input", doSubmit);
  }
}
