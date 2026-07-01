# Hyva Course boilerplate

A ready-to-run, **dockerized** Magento 2 + Hyvä setup for the **Hyvä Learning Module**. It comes pre-wired with the company-standard magebit-docker infrastructure (Traefik, ECR images) and the `d/` command wrappers, so you start on the same setup we use on real projects instead of a bare host.

No Magento code is committed here — you pull it with Composer (per the courses below). This repo only provides the Docker layer, the `d/` wrappers, and setup instructions.

---

## Prerequisites

1. **magebit-docker** installed on your machine, and this project added to its `projects.yml` + certificate generated.
   → See Coda: **[Dockerize your first project](https://coda.io/d/_dvWq9UAfB3w/Dockerize-your-first-project_suenx3Fs)** (covers magebit-docker setup, AWS ECR login to pull images, `projects.yml`, `make certs`, and the `d/` commands).
2. **AWS CLI** configured + ECR login (to pull the Docker images).
3. **auth.json** with your keys — copy the sample and fill it in:
   ```bash
   cp auth.json.sample auth.json
   ```
   - `repo.magento.com` — your Magento Marketplace public/private keys.
   - `hyva-themes.repo.packagist.com` — your **free** Hyvä access key (register at hyva.io; the Hyvä theme is free/open source).

---

## Setup

1. Branch off `master` as `feature/HC-<your-number>` and work there (never commit to `master`).
2. Add `hyva-course` to magebit-docker `projects.yml` and generate the cert (see the Coda guide above).
3. Start the stack:
   ```bash
   d/docker-compose up -d
   ```
4. Install Magento and Hyvä **by following the Academy courses**, using the `d/` wrappers:
   - **Installing Magento** — https://academy.magebit.com/course/view.php?id=159
   - **Installing Hyvä** — https://academy.magebit.com/course/view.php?id=182
   (composer install → `d/magento setup:upgrade` → build Tailwind → create your child theme → set it active).
5. Point `d/node-tailwind` at your child theme (edit the `THEME_TAILWIND` line), then run the watcher:
   ```bash
   d/node-tailwind run watch
   ```
6. Open **https://magebit-hyva-course.docker**.

---

## Commands (`d/` wrappers)

Run everything through these — not the host:

| Command | Purpose |
|---|---|
| `d/magento …` | `bin/magento` inside the PHP container |
| `d/composer …` | Composer |
| `d/npm …` / `d/node …` | npm / node |
| `d/node-tailwind run watch\|build` | Tailwind build in your child theme |
| `d/mysql` | MySQL shell |
| `d/phpcs` / `d/phpstan` | code standards (set up per project) |

---

## About this course

Part of the **Hyvä Learning Module**. Each candidate works on their own `feature/HC-<number>` branch and opens a PR for review. `master` is protected — PRs only.
