import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  update(event) {
    event.currentTarget.requestSubmit();
  }

  delete(event) {
    const form = event.currentTarget.closest("form");
    form.addEventListener("formdata", (e) => {
      const formData = e.formData;
      formData.set("_method", "delete");
    });
    form.requestSubmit();
  }
}
