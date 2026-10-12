# React App (Vite + React 19)

A small React application used by the `04 - Using Actions` workflow to demonstrate
third-party actions. It was originally scaffolded with Create React App and has since been
migrated to Vite, because CRA was deprecated by the React team in February 2025.

## Available Scripts

| Script | What it does |
| --- | --- |
| `npm run dev` | Starts the Vite dev server on http://localhost:5173 with hot module replacement. |
| `npm run test` | Runs the Vitest suite once and exits. This is what CI runs. |
| `npm run build` | Type-checks with `tsc -b`, then produces a production bundle in `dist/`. |
| `npm run preview` | Serves the built `dist/` output locally to check the production build. |
| `npm run lint` | Lints with oxlint. Prints nothing when there is nothing to report. |

To work on the app:

```bash
npm ci
npm run test
```

Unlike `react-scripts test`, `vitest run` is non-interactive by default, so the same
`npm run test` command works locally and in CI — no `CI=true` prefix needed. Use
`npx vitest` (without `run`) if you want the interactive watch mode.

## Toolchain

| Package | Version | Role |
| --- | --- | --- |
| `react` / `react-dom` | 19.3 | UI library |
| `vite` | 8.3 | Dev server and production bundler |
| `@vitejs/plugin-react` | 6.1 | React support for Vite (JSX, Fast Refresh) |
| `vitest` | 5.0 | Test runner, sharing Vite's config and transform pipeline |
| `jsdom` | 30.1 | DOM implementation the tests render into |
| `@testing-library/react` | 16.3 | Component rendering and queries |
| `@testing-library/jest-dom` | 7.0 | DOM matchers such as `toBeInTheDocument()` |
| `typescript` | 7.0 | Type checking (`tsc -b`, no emit) |
| `oxlint` | 1.x | Linter |

## Project Layout

```
index.html           Vite entry point (was public/index.html under CRA)
vite.config.ts       Vite + Vitest configuration
tsconfig.json        Project references -> tsconfig.app.json, tsconfig.node.json
.oxlintrc.json       Lint configuration
public/              Static assets copied verbatim into the build
src/main.tsx         React entry point (was src/index.tsx under CRA)
src/App.tsx          The component under test
src/App.test.tsx     Vitest test
src/setupTests.ts    Registers jest-dom matchers with Vitest
src/vite-env.d.ts    Vite client type declarations
```

Test configuration lives under the `test` key in `vite.config.ts`, which is why that file
imports `defineConfig` from `vitest/config` rather than from `vite`.

## Notes on the Migration

- The build output directory changed from `build/` to `dist/`.
- Environment variables are exposed as `import.meta.env.VITE_*` instead of
  `process.env.REACT_APP_*`.
- `reportWebVitals.ts` and `react-app-env.d.ts` were CRA-specific and have been removed,
  along with `public/manifest.json` and the PWA logo assets, which nothing referenced.
- The test file imports `expect` and `test` from `vitest` explicitly rather than relying on
  Jest globals. Set `test.globals: true` in `vite.config.ts` if you prefer the implicit
  style.
