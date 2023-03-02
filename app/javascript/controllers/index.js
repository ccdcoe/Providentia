import { application } from "./application";
import { registerControllers } from "stimulus-vite-helpers";

const controllers = import.meta.globEager("./**/*_controller.js");
registerControllers(application, controllers);

import { Dropdown } from "tailwindcss-stimulus-components";
application.register("dropdown", Dropdown);
