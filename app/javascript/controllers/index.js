import { application } from "./application";
import controllers from "./**/*_controller.js";
controllers.forEach((controller) => {
  application.register(controller.name, controller.module.default);
});

import { Dropdown } from "tailwindcss-stimulus-components";
application.register("dropdown", Dropdown);
