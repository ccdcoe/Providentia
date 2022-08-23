import { dom } from "@fortawesome/fontawesome-svg-core";
import { Controller } from "@hotwired/stimulus";
import cytoscape from "cytoscape";
import nodeHtmlLabel from "cytoscape-node-html-label";
import elk from "cytoscape-elk";
import style from "./map/style.js";
import full_style from "./map/full_style.js";

nodeHtmlLabel(cytoscape);
cytoscape.use(elk);

export default class extends Controller {
  static targets = ["radio", "container"];
  full_map = false;

  connect() {
    this.init_cytoscape();
    dom.watch({
      autoReplaceSvgRoot: this.containerTarget,
      observeMutationsRoot: this.containerTarget,
    });
  }

  init_cytoscape() {
    Promise.all([
      this.generate_data_fetch_promise(),
      this.retrieve_style(),
    ]).then((values) => {
      let [elements, style] = values;
      this.cy = cytoscape({
        container: this.containerTarget,
        boxSelectionEnabled: false,
        autoungrabify: true,
        autounselectify: true,
        elements: elements,
        layout: {
          name: "elk",
          elk: {
            algorithm: "layered",
            "elk.direction": "UP",
            "elk.layered.nodePlacement.bk.fixedAlignment": "LEFT_UP",
            "elk.port.side": "SOUTH",
            "elk.portConstraints": "FIXED_SIDE",
            "elk.spacing.nodeNode": 150,
            "elk.layered.spacing.edgeEdgeBetweenLayers": 55,
            "elk.layered.spacing.edgeNodeBetweenLayers": 75,
            "elk.spacing.componentComponent": 30,
          },
          padding: 10,
        },
        wheelSensitivity: 0.3,
        style: style,
      });
      this.init_labels();
    });
  }

  init_labels() {
    this.cy.nodeHtmlLabel([
      {
        query: ".host",
        halign: "center",
        valign: "center",
        halignBox: "center",
        valignBox: "center",
        tpl: function (data) {
          return `<div class='w-40'>
              <div class="px-1 bg-${
                data.team.ui_color
              }-500 text-gray-200 text-[.8rem] flex items-center">
                <i class="${data.os.icon} mr-1" title="${data.os.name}"></i>
                <span class="leading-2 break-all whitespace-pre-wrap">${
                  data.name
                }</span>
              </div>
              <div class="bg-${data.team.ui_color}-200 text-${
            data.team.ui_color
          }-600 text-[.8rem] p-1">
                ${data.addresses.slice(0, 2).join("<br>")}
              </div>
          </div>`;
        },
      },
    ]);
  }

  generate_data_fetch_promise() {
    return new Promise((resolve, reject) => {
      const url = new URL(
        this.element.dataset.graphEndpoint,
        window.location.origin
      );
      if (this.full_map) {
        url.searchParams.append("full_map", this.full_map);
      }

      fetch(url, {
        headers: {
          Accept: "application/json",
        },
        credentials: "include",
      })
        .then((response) => response.json())
        .then((json) => {
          resolve([
            ...json.result.groups.map((node) => {
              return {
                group: "nodes",
                data: Object.assign(node, { group: true }),
                classes: node.classes,
              };
            }),
            ...json.result.nodes.map((node) => {
              return {
                group: "nodes",
                data: node,
                classes: node.classes,
              };
            }),
            ...json.result.edges.map((edge) => {
              return {
                group: "edges",
                data: edge,
                classes: edge.classes,
              };
            }),
          ]);
        });
    });
  }

  retrieve_style() {
    return new Promise((resolve, _reject) => {
      resolve(this.full_map ? full_style : style);
    });
  }

  change_mode(event) {
    this.full_map = event.target.checked;
    this.cy.destroy();
    this.init_cytoscape();
  }
}
