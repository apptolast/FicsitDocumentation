---
description: Rules for writing Jekyll/Chirpy documentation posts in _posts/
globs: ["_posts/**/*.md"]
---

# Content Writing Rules

## Front Matter (ALL fields required)

Every post in `_posts/` MUST have all of these fields:

```yaml
---
title: "Title in Sentence Case"
date: 2026-04-15 00:00:00 +0000
categories: [single-category-name]
tags: [satisfactory, ficsitmonitor, tag3, tag4]
description: "SEO meta description exactly 150-160 characters long for best results."
toc: true
---
```

- `categories`: always a list with **exactly one item**
- `tags`: always a list with **3-6 items**; always include `satisfactory` and `ficsitmonitor`
- `description`: **150-160 characters** — this is the Google snippet and og:description
- `toc: true` — always enable table of contents
- `pin: false` — omit this field unless explicitly pinning

## Chirpy Callout Syntax

Use these for important notices. Each has a distinct color in the Chirpy theme:

```markdown
> This is a helpful tip.
{: .prompt-tip }
```

```markdown
> This is informational context.
{: .prompt-info }
```

```markdown
> This is a caution warning.
{: .prompt-warning }
```

```markdown
> This is a critical danger notice.
{: .prompt-danger }
```

Do NOT use HTML `<div class="...">` callouts — they break the Chirpy theme.

## Code Blocks — ALWAYS specify language

```bash
# CORRECT
```

```yaml
# CORRECT
```

```
# WRONG — no language specifier
```

Language identifiers to use:
- Shell commands: `bash`
- YAML/K8s manifests: `yaml`
- JSON requests/responses: `json`
- PHP: `php`
- JavaScript/TypeScript: `js` / `ts`
- Generic output: `text`
- Environment files: `bash` (treat as bash)

## Internal Links

Use Jekyll's `post_url` tag for internal links — this generates correct URLs and
will cause a build failure if the target post doesn't exist (catches broken links):

```markdown
[Link text]({% post_url 2026-04-15-target-slug %})
```

Do NOT use relative paths like `../frm-installation/` — these break with Chirpy's
permalink structure.

## Images

```markdown
![Alt text describing the image](/assets/img/posts/filename.png){: .shadow }
```

- All post images go in `assets/img/posts/`
- Use descriptive, meaningful alt text
- Append `{: .shadow }` for a subtle drop shadow (Chirpy built-in)

## Tone and Style

- **Technical, precise, direct** — developers are the audience
- Use the product name **FICSIT.monitor** consistently (with the dot, capitalize M)
- Call it the "dashboard", not the "app" or "tool"
- Use "factory" without apology — the audience plays Satisfactory
- Avoid: "simply", "just", "easy", "trivial", "obviously"
- Do use: exact numbers, real field names, actual port numbers
- Each section starts with a clear statement, not a question
- Prerequisites section lists what the reader must have done before this page

## Standard Page Structure

```markdown
## Overview
[2-3 sentence intro explaining what this page covers and why it matters]

## Prerequisites
- [Prerequisite 1 with link]
- [Prerequisite 2 with link]

## [Main content sections]
...

## Next Steps
- [Link to natural follow-up page]
- [Link to related page]
```

## Technical Accuracy Rules — CRITICAL

These facts are verified against the source code. Do not deviate:

| Topic | Correct value |
|-------|--------------|
| Required ports | 7777 (TCP+UDP), 8888 (TCP), 8080 (TCP), 8081 (TCP) |
| Deprecated ports | 15000, 15777 — NEVER list as required |
| Port forwarding | NOT supported (external must equal internal) |
| FRM endpoint: extractors | `getExtractor` (singular) |
| Product name | FICSIT.monitor |
| Free tier servers | 1 server |
| Free tier polling | 30 seconds |
| Pro tier monthly | 19€/month |
| Dashboard URL | https://satisfactory-dashboard.pablohgdev.com |

When in doubt, check `@docs/technical-spec.md`. Never invent API field names,
endpoint names, or pricing numbers.
