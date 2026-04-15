---
description: Run full validation pipeline on the documentation site
allowed-tools: Bash, Read, Glob, Grep
---

# /project:validate-docs

Run the complete validation pipeline before pushing to main (which triggers GitHub Pages deploy).

## Step 1: Jekyll Build

```bash
bundle exec jekyll build --quiet
```

Exit code 0 = pass. Any non-zero = FAIL. Report all error output.
The build will fail on: malformed YAML, broken Liquid tags, missing `post_url` targets.

## Step 2: html-proofer

```bash
./tools/test.sh
```

This runs the full build + html-proofer validation.
Checks: broken internal links, missing alt text on images, malformed HTML.
External links may fail if network unavailable — non-blocking if clearly unreachable.

## Step 3: Front Matter Completeness

```bash
# Posts missing description
grep -rL "^description:" _posts/ 2>/dev/null | sort

# Posts missing categories
grep -rL "^categories:" _posts/ 2>/dev/null | sort

# Posts missing toc
grep -rL "^toc:" _posts/ 2>/dev/null | sort

# Posts missing tags
grep -rL "^tags:" _posts/ 2>/dev/null | sort
```

Any files returned = error. Every post must have all required fields.

## Step 4: Technical Accuracy

```bash
# Deprecated ports must not appear as required ports
grep -rn "1500[07]" _posts/ 2>/dev/null && echo "ERROR: Deprecated ports found" || echo "OK: No deprecated ports"

# Wrong product name
grep -rni "\bficsitops\b" _posts/ _tabs/ 2>/dev/null && echo "ERROR: Wrong product name" || echo "OK: Product name consistent"

# Wrong FRM endpoint name
grep -rn "\bgetExtractors\b" _posts/ 2>/dev/null && echo "ERROR: Wrong FRM endpoint (should be getExtractor)" || echo "OK: FRM endpoints correct"
```

## Step 5: Security Spot-check

```bash
# Real credentials
grep -rn "APP_KEY=base64:\|DB_PASSWORD=[^$'\"]" _posts/ _tabs/ 2>/dev/null && echo "SECURITY: Possible credentials found"

# Real GitHub PATs
grep -rn "ghp_[A-Za-z0-9]\{36\}" _posts/ _tabs/ 2>/dev/null && echo "SECURITY: GitHub token found"

# Long bearer tokens
grep -rn "Bearer [A-Za-z0-9._-]\{40,\}" _posts/ _tabs/ 2>/dev/null && echo "SECURITY: Possible real token found"
```

## Step 6: Config Check

```bash
# Verify _config.yml has correct title (not still the Chirpy template)
grep "^title:" _config.yml

# Verify dark mode is set
grep "theme_mode:" _config.yml

# Count posts created
ls _posts/*.md 2>/dev/null | wc -l
```

## Summary Report

Report the following:
```
VALIDATION SUMMARY
==================
Jekyll build:        [PASS/FAIL]
html-proofer:        [PASS/FAIL]
Front matter:        [X posts complete / Y posts missing fields]
Deprecated ports:    [NONE / LIST FOUND]
Product name:        [CONSISTENT / ISSUES FOUND]
Security:            [CLEAR / ISSUES FOUND]
Config title:        [FICSIT.monitor Docs / STILL TEMPLATE]
Posts created:       [N]

OVERALL:             [READY TO DEPLOY / NEEDS FIXES]
```

$ARGUMENTS can provide specific areas to focus validation on.
