import { application } from "./application";
import { registerControllers } from "stimulus-vite-helpers";

const controllers = import.meta.glob("./**/*_controller.js", { eager: true });
registerControllers(application, controllers);

import { Dropdown, Modal } from "tailwindcss-stimulus-components";

application.register("dropdown", Dropdown);
application.register("modal", Modal);
