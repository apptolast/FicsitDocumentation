---
description: Rules for managing assets (images, CSS, favicons) in the documentation site
globs: ["assets/**"]
---

# Assets Rules

## Directory Organization

```
assets/
├── img/
│   ├── posts/         ← screenshots and diagrams used within post content
│   ├── og/            ← Open Graph images (exactly 1200×630 PNG, one per post)
│   └── favicons/      ← favicon set (replace with FICSIT.monitor brand when ready)
└── css/
    └── custom.scss    ← optional custom CSS (create only if needed)
```

## Post Images (`assets/img/posts/`)

- Format: PNG or WebP preferred; JPEG acceptable for photos
- **Maximum size: 500KB per image** — compress before committing
- Naming: `{post-slug}-{description}.png`
  Example: `frm-installation-step1.png`, `dashboard-power-panel.png`
- Use descriptive filenames that reflect content
- Reference in posts: `![Alt text](/assets/img/posts/filename.png){: .shadow }`

## Open Graph Images (`assets/img/og/`)

- **Exact dimensions: 1200×630 pixels**
- Format: PNG
- Naming: `{post-slug}-og.png`
  Example: `quick-start-og.png`, `frm-installation-og.png`
- One OG image per post (reference in post's front matter)
- Should include: product name/logo, page title, FICSIT.monitor branding
- Background: dark theme matching the site (dark navy/black)

## Open Graph Front Matter Reference

```yaml
image:
  path: /assets/img/og/post-slug-og.png
  alt: "FICSIT.monitor — [Page Title]"
```

## Favicons (`assets/img/favicons/`)

Standard Chirpy favicon set. Replace with FICSIT.monitor branding when brand assets
are available. Required sizes: 16×16, 32×32, 180×180 (apple-touch), 192×192, 512×512.

Do NOT delete the existing placeholder favicons — the site needs them to build correctly.

## Custom CSS (`assets/css/custom.scss`)

Only create this file if customization is needed. Must start with Jekyll front matter:

```scss
---
---

/* FICSIT.monitor Documentation custom styles */
```

Keep overrides minimal — the dark Chirpy theme already matches the product aesthetic.

## No Custom JavaScript

Do NOT add custom JavaScript files to assets/. The Chirpy theme handles all required
interactivity (search, TOC, dark/light toggle, etc.). Adding custom JS can break the
theme's progressive enhancement.

Exception: if a future Chirpy version explicitly documents a custom JS extension point.

## Git Considerations

- Compress images before committing (tools: ImageOptim, pngquant, cwebp)
- Never commit binary files > 1MB to the repository
- Do not commit placeholder/draft images — only final images
- OG images can be generated later; posts without OG images will use the site's default
