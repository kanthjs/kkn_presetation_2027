# ricetalk: a Quarto revealjs template for research talks

A 16:9 slide format with cards, numbered section dividers, a big-number card,
a workflow diagram, and one-line "HOW" code chips. Built for the 28th
Agricultural Conference, Khon Kaen University (2027).

Requires Quarto 1.3 or later.

## Use it

Copy this `template/` folder to start a new talk, then render:

```bash
quarto render template.qmd
```

To add the format to an existing project, copy `_extensions/ricetalk/` into
the project and set the format in your `.qmd`:

```yaml
format: ricetalk-revealjs
```

If this folder is published as its own GitHub repository, others can start
from it with:

```bash
quarto use template <owner>/<repo>
```

## What is in the box

| File | Purpose |
|---|---|
| `_extensions/ricetalk/` | The format: theme (`ricetalk.scss`) and slide settings |
| `template.qmd` | Starter deck showing every component |
| `R/theme_slide.R` | ggplot2 theme and `save_fig()` that match the slides |
| `images/` | Put `profile.jpg`, `logo.png`, and figures here |

## Components

| Markup | Result |
|---|---|
| `::::: {.cards}` with `:::: {.card}` inside | Row of three cards |
| `.card-key`, `.card-alert`, `.card-grey`, `.card-num` | Card variants |
| `[Title]{.card-title}` | Card heading (do not use `####` inside a card: it splits the slide) |
| `[text]{.hl}` | Highlighted phrase |
| `[text]{.cite}`, `[text]{.muted}` | Citation line, grey text |
| `::: {.stat-card}` with `[33%]{.big-number}` | Big-number card |
| `::: {.how}` with one line of inline code | "HOW" code chip |
| `::: {.future}` | Next-steps strip |
| `## Title {.section-slide data-num="01" background-color="#1F4E2C"}` | Section divider |
| `{.code-slide visibility="uncounted"}` | Backup code slide |
| `.small-table` on a column | Smaller table text |
| `{.profile-photo}` on an image | Round photo |

## Change the colours

Edit the four variables at the top of `_extensions/ricetalk/ricetalk.scss`:
`$primary`, `$secondary`, `$accent`, `$alert`. If you change `$primary`, also
change the `background-color` on the title slide (`_extension.yml`) and on the
section dividers, and the colours in `R/theme_slide.R`.

## Fonts

Montserrat and Source Sans 3 load from Google Fonts. For a room without
internet, install both fonts on the presenting computer or render with:

```bash
quarto render template.qmd -M embed-resources:true
```
