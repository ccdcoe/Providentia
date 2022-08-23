// vendored js
import "element-matches-polyfill";
import mrujs from "mrujs";
import { Turbo } from "@hotwired/turbo-rails";
import { MrujsTurbo } from "mrujs/plugins";
// import "./channels/**/*_channel.js";
import "./controllers";

// visual
import "./src/fonts";

// init
// Turbo must be set before starting mrujs for proper compatibility with querySelectors.
window.Turbo = Turbo;
mrujs.start({
  plugins: [MrujsTurbo()],
});
