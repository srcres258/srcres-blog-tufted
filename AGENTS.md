# AGENTS.md — srcres Blog (Tufted)

Typst-powered static blog using the [Tufted](https://github.com/vsheg/tufted) template. No JS framework, no CI, just `make`.

## Build

```shell
make html
```

- Compiles every `content/<path>.typ` → `_site/<path>.html` (unless path starts with `_`)
- Copies `assets/` → `_site/assets/`
- `make clean` wipes `_site/`

## Content structure

```
content/index.typ          →  _site/index.html       (homepage)
content/blog/index.typ     →  _site/blog/index.html   (post listing)
content/blog/<slug>/index.typ  →  _site/blog/<slug>/index.html (post)
content/docs/index.typ     →  _site/docs/index.html
content/cv/index.typ       →  _site/cv/index.html
```

All `.typ` files import `template` and `tufted` from their parent dir or `config.typ`:

```typst
#import "../index.typ": template, tufted
#show: template
```

Or with a custom title:

```typst
#show: template.with(title: "My Page Title")
```

## Blog posts

Blog post directories follow the naming convention: `YYYY-MM-DD-slug/`.

Two patterns are in use:

### Pattern A: Pure Typst

Write the post body directly in the `.typ` file using Typst markup.

```typst
#import "../index.typ": template, tufted
#show: template

= Post Title

Body text here.
```

### Pattern B: Markdown rendered via cmarker

Write the post body in `post.md`, then render it from the `.typ` file:

```typst
#import "../index.typ": template, tufted
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": mitex
#show: template.with(title: "Post Title")

= Post Title

#let md-content = read("post.md")

#let def-dict = (
  image: (source, alt: none, format: auto) => figure(image(
    source, alt: alt, format: format,
  )),
)

#cmarker.render(md-content, math: mitex, scope: def-dict)
```

### Blog listing (`content/blog/index.typ`)

The post listing is **manually maintained**. Each post entry is a hand-written `#link()` in the appropriate year section. When adding a new post, you must:

1. Create `content/blog/YYYY-MM-DD-slug/index.typ`
2. Add a `#link("YYYY-MM-DD-slug/")[Title]` entry under the correct year heading in `content/blog/index.typ`

## Key packages

| Package | Version | Use |
|---|---|---|
| `@preview/tufted` | 0.1.1 | Page template (defined in `config.typ`) |
| `@preview/cmarker` | 0.1.8 | Render Markdown → Typst |
| `@preview/mitex` | 0.2.6 | LaTeX math in Markdown |
| `@preview/lilaq` | 0.6.0 | Diagrams/charts |
| `@preview/citegeist` | 0.2.2 | BibTeX bibliography |

## CSS

Two stylesheets are served:
- `tufted.css` — Tufte CSS customizations (navbar, margin notes, footnotes, math, post tiles)
- `custom.css` — user overrides (currently empty)

These live in `assets/` and are referenced by the Tufted template, not manually linked in `.typ` files.

## Files prefixed with `_`

Files/dirs starting with `_` (like `_test_math.typ`) are excluded from the build by the Makefile. Use this for drafts and experiments.

## `.deepseek/`

Contains auto-generated `instructions.md` from a previous DeepSeek TUI session. Low-signal; safe to ignore or delete.
