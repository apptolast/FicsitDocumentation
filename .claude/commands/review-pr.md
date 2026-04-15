---
description: Review documentation changes before merging to main (triggers GitHub Pages deploy)
allowed-tools: Bash, Read, Glob, Grep
---

# /project:review-pr

Pre-merge review checklist for documentation changes.
Pushing to `main` triggers GitHub Actions deployment to GitHub Pages.
This review ensures deployment will succeed and content is ready.

## 1. Check What's Changed

```bash
git status
git diff --stat HEAD
git log --oneline -10
```

Report: what files were modified, added, or deleted.

## 2. Jekyll Build Must Pass

```bash
bundle exec jekyll build --quiet
```

If this fails, DO NOT proceed. Fix the build first.

## 3. html-proofer Must Pass

```bash
./tools/test.sh
```

Broken internal links = BLOCK. External link failures = warning (mark as known issue).

## 4. Check Diff for Secrets

```bash
git diff HEAD | grep -E "APP_KEY|DB_PASSWORD|Bearer [A-Za-z0-9._-]{40}|ghp_[A-Za-z0-9]{36}" 2>/dev/null && echo "SECURITY: Possible secret in diff" || echo "OK: No secrets detected in diff"
```

## 5. New Posts: Verify Front Matter

For any new `.md` files in `_posts/`:
```bash
# Check each new post has all required fields
for f in $(git status --short | grep "^?" | grep "_posts/" | awk '{print $2}'); do
  echo "=== $f ==="
  grep -E "^(title|date|categories|tags|description|toc):" "$f" 2>/dev/null
done
```

## 6. _config.yml Changes (if any)

```bash
git diff HEAD _config.yml 2>/dev/null
```

If `_config.yml` was modified:
- Verify `exclude:` still includes `docs`
- Verify `theme: jekyll-theme-chirpy` is unchanged
- Verify `title` is "FICSIT.monitor Docs"

## 7. Asset Additions (if any)

```bash
# Check size of any new images
find assets/ -newer .git/index -name "*.png" -o -name "*.jpg" -o -name "*.webp" 2>/dev/null | xargs ls -lh 2>/dev/null
```

Flag any images > 500KB.

## 8. GitHub Actions Status

The deployment workflow is at `.github/workflows/pages-deploy.yml`.
It runs: `bundle exec jekyll build` → `html-proofer` → deploy.
If the local checks pass, the Actions workflow should pass too.

## Final Decision

```
PRE-MERGE REVIEW
================
Jekyll build:     [PASS/FAIL]
html-proofer:     [PASS/FAIL]
No secrets:       [CLEAR/ISSUES]
Front matter:     [COMPLETE/MISSING FIELDS]
Config integrity: [OK/ISSUES]
Asset sizes:      [OK/LARGE FILES]

DECISION: [READY TO MERGE / BLOCK — list reasons]
```

Push to main only when READY TO MERGE.
GitHub Actions will handle the deployment automatically.

$ARGUMENTS can specify a branch or commit range to review.
