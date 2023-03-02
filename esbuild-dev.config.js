#!/usr/bin/env node

const path = require("path");
const chokidar = require("chokidar");
const rails = require("esbuild-rails");
const http = require("http");

const clients = [];

http
  .createServer((req, res) => {
    return clients.push(
      res.writeHead(200, {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        "Access-Control-Allow-Origin": "*",
        Connection: "keep-alive",
      })
    );
  })
  .listen(8082);

async function builder() {
  let result = await require("esbuild").build({
    entryPoints: ["application.js"],
    bundle: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    absWorkingDir: path.join(process.cwd(), "app/javascript"),
    logLevel: "info",
    incremental: true,
    banner: {
      js: ' (() => new EventSource("http://localhost:8082").onmessage = () => location.reload())();',
    },
    plugins: [rails()],
  });
  chokidar
    .watch([
      "./app/javascript/**/*.js",
      "./app/views/**/*.html.haml",
      "./app/assets/stylesheets/*.css",
    ])
    .on("all", (event, path) => {
      if (path.includes("javascript")) {
        result.rebuild();
      }
      clients.forEach((res) => res.write("data: update\n\n"));
      clients.length = 0;
    });
}
builder();
