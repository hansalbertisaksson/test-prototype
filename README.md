# test-prototype

A starting point for a prototype built with AI. It builds from the shared [test-core](https://github.com/hansalbertisaksson/test-core) (house rules, skills and checks). Pages are React with [shadcn/ui](https://ui.shadcn.com) components, and publishes itself to GitHub Pages on every push to `main`.

## Start a new prototype

1. Click **Use this template**, then **Create a new repository**. Make it public.
2. Wait about a minute for the first build. The live link is `https://<owner>.github.io/<repo>/`.
3. Clone it, `cd` into it and run `claude`. Opening the project fetches the shared core, turns on the checks and starts a preview at http://localhost:8000.
4. Say what you want to make. It asks a few kickoff questions first and writes `docs/brief.md`, then builds from it.
5. See how it's built at `https://<owner>.github.io/<repo>/kit/`.

Without Claude, run `./scripts/start.sh` for the same setup and preview. It needs Node 20 or newer. Add a component with `npx shadcn@latest add <name>`.

If the first build is green but the link shows a 404, open **Settings**, then **Pages**, and choose **Deploy from a branch** with `gh-pages` and `/ (root)`. You only do this once.

## How it fits together

| Path | What it is |
| --- | --- |
| `src/` | The app: `App.tsx` is the start page, `components/ui/` holds the shadcn components |
| `src/index.css` | The theme. Change the look here |
| `docs/` | The brief and the decisions log for this prototype |
| `AGENTS.md` | Rules for this project, on top of the shared house rules |
| `.core/` | The shared core, read-only, mounted as a git submodule |
| `.buildkit` | Which profile applies (`prototype`) |

The same checks run in three places: on `git commit`, after Claude edits a file, and in CI. Only CI is required. The others just tell you sooner.
