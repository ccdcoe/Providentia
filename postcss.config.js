export default {
  plugins: {
    "postcss-import": {},
    "tailwindcss/nesting": "postcss-nesting",
    tailwindcss: {},
    "postcss-preset-env": {
      features: { "nesting-rules": false },
    },
    ...(process.env.NODE_ENV === "production" ? { cssnano: {} } : {}),
  },
};
