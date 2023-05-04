import { Controller } from "@hotwired/stimulus";
import throttle from "throttleit";

import { StreamLanguage } from "@codemirror/language";
import { yaml } from "@codemirror/legacy-modes/mode/yaml";
import { EditorView, minimalSetup } from "codemirror";
import { solarizedDark } from "cm6-theme-solarized-dark";

export default class extends Controller {
  editor;

  connect() {
    const textarea = this.element;
    const form = textarea.closest("form");
    const throttled_submit = throttle(() => form.requestSubmit(), 500);
    textarea.classList.add("hidden");

    const container = document.createElement("div");
    container.classList.add("bg-red-100", "w-full", "overflow-y-scroll");
    textarea.parentNode.appendChild(container);
    this.editor = new EditorView({
      doc: textarea.value.toString(),
      extensions: [
        minimalSetup,
        StreamLanguage.define(yaml),
        solarizedDark,
        EditorView.updateListener.of((v) => {
          if (v.docChanged) {
            textarea.value = v.state.doc.toString();
            throttled_submit();
          }
        }),
      ],
      parent: container,
    });
  }

  disconnect() {
    this.editor.destroy();
  }
}
