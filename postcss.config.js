module.exports = ({ env }) => ({
  plugins: [
    require("postcss-import"),
    require("tailwindcss/nesting"),
    require("tailwindcss"),
    require("postcss-preset-env")({
      features: { "nesting-rules": false },
    }),
    env === "production" ? require("cssnano") : false,
  ],
});
