# Quality Gates Skill

## When to Invoke This Skill

Invoke before:
- Marking any documentation task as complete
- Committing to main (which deploys to GitHub Pages)
- Merging documentation branches

## Gate 1: Jekyll Build (BLOCKING)

```bash
bundle exec jekyll build --quiet
```

Pass condition: exit code 0
Fail condition: any non-zero exit code

Common failures:
- Malformed YAML front matter in a post
- Broken `{% post_url %}` tag (target post doesn't exist)
- Invalid Liquid template syntax
- Chirpy theme configuration error

**If this gate fails, no other gates matter. Fix the build first.**

If bundle/Jekyll not available, this gate is skipped with a warning.

## Gate 2: Front Matter Completeness (BLOCKING)

Every `.md` file in `_posts/` must have ALL of these fields:

```bash
# Check for missing descriptions
missing_desc=$(grep -rL "^description:" _posts/ 2>/dev/null)
# Check for missing categories
missing_cats=$(grep -rL "^categories:" _posts/ 2>/dev/null)
# Check for missing toc
missing_toc=$(grep -rL "^toc:" _posts/ 2>/dev/null)
```

Pass condition: all commands return empty output
Fail condition: any files returned = those posts are missing required fields

Required fields:
- `title:` — non-empty string
- `date:` — format `YYYY-MM-DD HH:MM:SS +0000`
- `categories:` — YAML list with exactly one item
- `tags:` — YAML list with 3-6 items
- `description:` — string (ideally 150-160 chars)
- `toc: true`

## Gate 3: No Deprecated Ports (BLOCKING)

```bash
grep -rn "1500[07]\b" _posts/ _tabs/ 2>/dev/null
```

Pass condition: no output
Fail condition: any matches

Ports 15000 and 15777 were deprecated in Satisfactory Patch 1.0.
They must never appear in documentation as required ports.

## Gate 4: Product Name Consistency (BLOCKING)

```bash
grep -rni "\bficsitops\b" _posts/ _tabs/ 2>/dev/null
grep -rni "ficsit monitor\b" _posts/ _tabs/ 2>/dev/null  # wrong: missing dot
```

Pass condition: no output
Fail condition: old product name found

Correct: `FICSIT.monitor` (with dot, capital M)
Wrong: `FicsitOps`, `ficsitops`, `ficsit monitor`, `FICSIT Monitor`

## Gate 5: Internal Links Valid (BLOCKING)

```bash
./tools/test.sh
```

Pass condition: html-proofer exits 0 (or exits with only external link failures)
Fail condition: broken internal links (`href="/posts/..."` targeting a non-existent post)

The `post_url` Liquid tag catches this at build time (Gate 1).
html-proofer provides a second check on the rendered HTML.

## Gate 6: No Credentials Exposed (BLOCKING)

```bash
grep -rn "APP_KEY=base64:\|DB_PASSWORD=[^$'\"]" _posts/ 2>/dev/null
grep -rn "ghp_[A-Za-z0-9]\{36\}" _posts/ 2>/dev/null
grep -rn "Bearer [A-Za-z0-9._-]\{40,\}" _posts/ 2>/dev/null
```

Pass condition: no output
Fail condition: real credentials detected

Use placeholders in all examples: `YOUR_API_TOKEN`, `your-admin-password`, `YOUR_PERSONAL_ACCESS_TOKEN`

---

## Warning Gates (non-blocking, but report)

### W1: Description Length

```bash
grep -rn "^description:" _posts/ | awk -F': ' '{
  len = length($2)
  if (len < 100 || len > 200) print NR": "FILENAME" — description length "len
}'
```

Target: 150-160 chars. Acceptable: 100-200 chars. Flag outside this range.

### W2: Code Block Language Specifiers

```bash
grep -cn "^\`\`\`$" _posts/*.md 2>/dev/null | grep -v ":0"
```

Any matches = posts with code blocks missing language identifiers.

### W3: Wrong FRM Endpoint Name

```bash
grep -rn "\bgetExtractors\b" _posts/ 2>/dev/null
```

Correct is `getExtractor` (singular). This is a warning because it's easy to miss.

---

## Pre-commit Runbook

Run all gates in order:

```bash
# Gate 1
bundle exec jekyll build --quiet && echo "G1: PASS" || echo "G1: FAIL"

# Gate 2
[[ -z "$(grep -rL "^description:" _posts/ 2>/dev/null)" ]] && echo "G2: PASS" || echo "G2: FAIL"

# Gate 3
[[ -z "$(grep -rn "1500[07]" _posts/ 2>/dev/null)" ]] && echo "G3: PASS" || echo "G3: FAIL"

# Gate 4
[[ -z "$(grep -rni "\bficsitops\b" _posts/ 2>/dev/null)" ]] && echo "G4: PASS" || echo "G4: FAIL"

# Gate 5
./tools/test.sh && echo "G5: PASS" || echo "G5: FAIL (check for broken links)"

# Gate 6
[[ -z "$(grep -rn "APP_KEY=base64:\|ghp_[A-Za-z0-9]\{36\}" _posts/ 2>/dev/null)" ]] && \
  echo "G6: PASS" || echo "G6: FAIL — SECURITY ISSUE"
```

All 6 gates must PASS before pushing to main.
