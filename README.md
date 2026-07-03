# Hyvä Course Boilerplate

A ready-to-run, **dockerized** Magento 2 + Hyvä setup for the **Hyvä Learning Module**. It ships the company-standard magebit-docker infrastructure (Traefik, ECR images) and the `d/` command wrappers, so you start on the same setup we use on real projects instead of a bare host.

No Magento code is committed — it's pulled with Composer from the committed `composer.json` / `composer.lock` (Magento 2.4.7-p3 + Hyvä default theme). This repo provides the Docker layer, the `d/` wrappers, the composer manifest, and a `make` pipeline.

---

## Prerequisites (once per machine)

1. **magebit-docker** installed, and this project registered so Traefik serves `magebit-hyva-course.docker`. In your magebit-docker install add it to `projects.yml`:
   ```yaml
   projects:
     - magebit-hyva-course
   ```
   then generate the cert: `make certs-linux` (or `certs-osx` / `certs-wsl`).
   → New to this? See Coda: [Dockerize your first project](https://coda.io/d/_dvWq9UAfB3w/Dockerize-your-first-project_suenx3Fs).
2. **AWS CLI** configured + ECR login (to pull the Docker images).
3. **Composer credentials — set globally, never in this repo** (they live in `~/.composer/auth.json`):
   ```bash
   composer config --global --auth http-basic.repo.magento.com <public-key> <private-key>
   composer config --global --auth http-basic.hyva-themes.repo.packagist.com token <hyva-access-key>
   ```
   Register your own free keys — a Magento Marketplace account for the Magento keys, and a Hyvä Portal (hyva.io) account for the Hyvä access key. The Hyvä theme is free/open source, so there's no shared/paid license — each person uses their own free keys.

---

## Quick start

```bash
make build
```

One command: start the stack → `composer install` → install Magento (dev store) → sample data → activate the Hyvä theme → build Tailwind → reindex. When it finishes, open **https://magebit-hyva-course.docker/** (the admin URL is printed by the installer). Run `make help` to see every target.

Default admin login: `admin` / `Admin123!`.

---

## Working on the course

First switch to your own private repo (so nobody can see anyone else's work), then branch and build there — the same flow as the FAQ task:
 `git remote remove origin`
 `git remote add origin <your-private-repo-url>`
 `git push`
 `git checkout -b feature/hyva-course`
Don't commit or open PRs against this boilerplate repo. Open your PR from your private repo and share it with your reviewer.

New to branching / git flow? See Coda: [Git usage and deployments](https://coda.io/d/_dvWq9UAfB3w/Git-usage-and-deployments_suGsI5xv).

When you create your own child theme, point `d/node-tailwind` at it (edit the `THEME_TAILWIND` line) and run the watcher while you work:
```bash
d/node-tailwind run watch
```

---

## Commands

**`d/` wrappers** (run everything through these, not the host):

| Command | Purpose |
|---|---|
| `d/magento …` | `bin/magento` in the PHP container |
| `d/composer …` | Composer |
| `d/npm …` / `d/node …` | npm / node |
| `d/node-tailwind run watch\|build` | Tailwind build in your child theme |
| `d/mysql` | MySQL shell |
| `d/phpcs` / `d/phpstan` | code standards (set up per project) |

**`make` targets:** `build` (full pipeline), `up`, `down`, `composer`, `magento-install`, `sampledata`, `theme`, `tailwind`, `reindex`.

---

## Notes

- Runs in **developer mode** — no static-content deploy needed.
- **Varnish** is the full-page cache. `d/magento cache:flush` purges it (http_cache_hosts is set on install), so template changes show without restarting Varnish. Tailwind changes need the watcher (`d/node-tailwind run watch`).
- **Search** uses OpenSearch (the `opensearch` engine — correct for OpenSearch 2.x).
- Sample data has **no sales orders** — for the My Account order-grid task, place a couple of test orders via checkout.
- Production/CI credentials are provided via env/secrets, never committed.
