export default [
  {
    selector: "edge",
    style: {
      "curve-style": "taxi",
      width: 2,
      "taxi-direction": "upward",
      "target-arrow-shape": "triangle",
      "arrow-scale": 0.8,
    },
  },
  {
    selector: "node",
    style: {
      label: "data(name)",
      "text-valign": "top",
      "text-halign": "center",
      "text-margin-y": "-10px",
    },
  },
  // {
  //   selector: "node[group]:parent",
  //   style: {
  //     color: "#fff",
  //     "text-background-color": "#888",
  //     "text-background-opacity": 1,
  //     "text-background-shape": "rectangle",
  //     "text-background-padding": "6px",
  //     "text-border-color": "#000",
  //     "text-border-width": 1,
  //     "text-border-opacity": 1,
  //   },
  // },
  // {
  //   selector: "node:child",
  //   style: {
  //     label: "data(name)",
  //     "text-valign": "bottom",
  //     "text-halign": "center",
  //     "text-wrap": "wrap",
  //     "text-overflow-wrap": "anywhere",
  //     "font-size": "11",
  //     "text-max-width": "55",
  //     "text-margin-y": "8px",
  //     padding: 1,
  //   },
  // },
  {
    selector: "node:child[team]",
    style: {
      "background-color": "data(team)",
    },
  },
];
