import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  update(event) {
    event.currentTarget.requestSubmit();
  }

  delete(event) {
    const form = event.currentTarget.closest("form");
    if (
      form.dataset.confirm !== "false" &&
      window.confirm(form.dataset.confirm || "Are you sure?")
    ) {
      form.addEventListener("formdata", (e) => {
        const formData = e.formData;
        formData.set("_method", "delete");
      });
      form.requestSubmit();
    }
  }
}
