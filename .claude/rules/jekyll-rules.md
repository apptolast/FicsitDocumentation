---
description: Rules for Jekyll configuration, _tabs, _data files, and theme customization
globs: ["_config.yml", "_data/**", "_tabs/**", "_includes/**", "assets/css/**", "Gemfile"]
---

# Jekyll / Chirpy Rules

## _config.yml — Target Values

Set these exact values (do not change structure or other settings):

```yaml
title: "FICSIT.monitor Docs"
tagline: "Real-time monitoring for Satisfactory dedicated servers"
description: >-
  Official documentation for FICSIT.monitor — real-time Satisfactory server
  monitoring with FRM integration, power panels, production metrics, and alerts.
lang: en
theme_mode: dark
toc: true
```

Also set the social and author section:
```yaml
social:
  name: Pablo Hurtado Gonzalo
  email: pablohurtadohg@gmail.com
  links:
    - https://github.com/PabloHurtadoGonzalo86

github:
  username: PabloHurtadoGonzalo86
```

Do NOT change:
- `theme: jekyll-theme-chirpy` (the theme itself)
- `kramdown` settings (controls syntax highlighting)
- `compress_html` settings
- `jekyll-archives` settings
- The `exclude:` list (docs/ must stay excluded)

## The `docs/` exclusion — DO NOT REMOVE

The `_config.yml` has `exclude: [docs, ...]`. This means files in `docs/` are
NOT processed by Jekyll and do NOT appear on the published website.

`docs/technical-spec.md` and `docs/architecture.md` are agent reference files,
not documentation pages. Never remove `docs` from the exclude list.

## Chirpy Tabs (_tabs/ directory)

Tab files control the top navigation. They use special front matter:

```yaml
---
title: Documentation
icon: fas fa-book
order: 1
---
```

Target tab configuration:

| File | title | icon | order |
|------|-------|------|-------|
| `about.md` | Documentation | `fas fa-book` | 1 |
| `categories.md` | By Topic | `fas fa-stream` | 2 |
| `archives.md` | Changelog | `fas fa-archive` | 3 |
| `tags.md` | Tags | `fas fa-tags` | 4 |

The `about.md` file is the Documentation hub — it should list all doc categories
and link to key pages.

## _data/contact.yml

Keep the existing structure. Update to add Discord:

```yaml
- type: discord
  icon: "fab fa-discord"
  url: "https://discord.gg/your-server"   # update when available
```

Keep: github, email
Can remove: twitter (if not active), rss

## _data/share.yml

Keep: Twitter/X, Reddit (good for Satisfactory community)
Can remove: Facebook, Telegram (less relevant for developer/gamer audience)

## Post Front Matter for Images (OG image)

When a post has an Open Graph image:

```yaml
image:
  path: /assets/img/og/post-slug-og.png
  alt: "Descriptive alt text for the image"
```

OG images must be exactly **1200×630 pixels** PNG format.

## Gemfile

DO NOT modify the Gemfile. It is locked to:
- `jekyll-theme-chirpy ~> 7.5`
- `html-proofer ~> 5.0`

Changing these versions may break the build or GitHub Actions workflow.

## Custom CSS

If custom styling is needed, create `assets/css/custom.scss`:

```scss
---
---

/* Custom overrides for FICSIT.monitor documentation */

/* Primary accent color (optional — matches FICSIT orange) */
:root {
  --link-color: #f97316;
}
```

Chirpy picks up this file automatically. Keep overrides minimal.

## Build Validation After Changes

After any `_config.yml` change, always verify:

```bash
bundle exec jekyll build --quiet
```

If the build fails, revert the change and investigate the error.
