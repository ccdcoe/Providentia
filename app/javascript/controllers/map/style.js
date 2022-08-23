export default [
  {
    selector: "core",
    css: {
      "active-bg-size": 0, //The size of the active background indicator.
    },
  },
  {
    selector: "node",
    css: {
      // label: "data(name)",
      width: "160px",
      height: "60px",
      "background-opacity": "0",
    },
  },
  //GROUP
  {
    selector: "$node > node",
    css: {
      "background-color": "#fff",
      "background-opacity": "1",
      "border-width": "1px",
      "border-color": "#dcdcdc",

      //LABEL
      label: "data(name)",
      color: "#000",
      shape: "rectangle",
      "text-opacity": "0.56",
      "font-size": "36px",
      "text-transform": "uppercase",
      "text-wrap": "none",
      "text-overflow-wrap": "ellipsis",
      "padding-top": "16px",
      "padding-left": "16px",
      "padding-bottom": "16px",
      "padding-right": "16px",
    },
  },
  {
    selector: ":parent",
    css: {
      "text-valign": "top",
      "text-halign": "center",
    },
  },
  //EDGE
  {
    selector: "edge",
    style: {
      "curve-style": "taxi",
      width: 1,
      "taxi-direction": "upward",
      "target-arrow-shape": "triangle",
      "arrow-scale": 0.8,
    },
  },
  {
    selector: "edge.hover",
    style: {
      width: 2,
      "line-color": "#239df9",
    },
  },
  {
    selector: "edge:selected",
    style: {
      width: 1,
      "line-color": "#239df9",
    },
  },
];
