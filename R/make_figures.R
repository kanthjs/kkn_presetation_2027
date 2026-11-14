# Slide figures for the KKU 2027 talk.
# Reads summary CSVs from the analysis project (read-only) and writes PNGs to images/.
# Usage: Rscript R/make_figures.R [path/to/summaries/BS]

suppressPackageStartupMessages(library(tidyverse))

args <- commandArgs(trailingOnly = TRUE)
data_dir <- if (length(args)) args[[1]] else
  "D:/Github/p_tonkhao/projects/ricedisease_model/summaries/BS"

# ---- theme: matches kku.scss --------------------------------------------------
bg     <- "#FBFAF4"
green  <- "#1F4E2C"
leaf   <- "#6BAA3C"
gold   <- "#D9A51F"
rust   <- "#B4472B"
grey   <- "#A9AEA6"

grp_cols <- c("No epidemic" = leaf,
              "Intermediate"            = gold,
              "Epidemic"        = rust)
grp_of <- function(trt) factor(case_when(
  trt %in% c("T2", "T3", "T8") ~ "Epidemic",
  trt == "T7"                  ~ "Intermediate",
  TRUE                         ~ "No epidemic"), levels = names(grp_cols))

theme_slide <- function(base_size = 24) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background  = element_rect(fill = bg, colour = NA),
      panel.background = element_rect(fill = bg, colour = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#E4E3D8", linewidth = .5),
      axis.title = element_text(colour = green, face = "bold"),
      axis.text  = element_text(colour = "#444444"),
      legend.position = "top", legend.justification = "left",
      legend.title = element_blank(), legend.text = element_text(size = rel(.85)),
      legend.margin = margin(0, 0, 0, 0), legend.box.margin = margin(0, 0, -6, 0),
      plot.margin = margin(12, 24, 12, 12)
    )
}
save_fig <- function(name, plot, w = 10, h = 6.6) {
  ggsave(file.path("images", name), plot, width = w, height = h, dpi = 200, bg = bg)
  cat("wrote images/", name, "\n", sep = "")
}

# ---- data ---------------------------------------------------------------------
sev   <- read_csv(file.path(data_dir, "severity_by_treatment_date.csv"), show_col_types = FALSE)
plots <- read_csv(file.path(data_dir, "bla_yield_gap_by_plot.csv"), show_col_types = FALSE)
gap   <- read_csv(file.path(data_dir, "bla_yield_gap_by_treatment.csv"), show_col_types = FALSE)
stopifnot(nrow(plots) == 32, nrow(gap) == 8)

sev   <- mutate(sev, grp = grp_of(treatment))
plots <- mutate(plots, grp = grp_of(treatment))
y_att <- plots$y_att[[1]]
bl_fit <- coef(lm(bl ~ audpc, data = plots))          # exact: bl is linear in AUDPC

# ---- 1. disease progress curves ------------------------------------------------
ends <- sev |> filter(dat == max(dat), treatment %in% c("T2", "T3", "T8", "T7")) |>
  mutate(severity_mean = severity_mean + c(T2 = -1.6, T8 = 1.6, T3 = 0, T7 = 1.2)[treatment])
p_dpc <- ggplot(sev, aes(dat, severity_mean, group = treatment, colour = grp)) +
  geom_errorbar(aes(ymin = severity_mean - severity_se, ymax = severity_mean + severity_se),
                width = 1.5, linewidth = .6, alpha = .6) +
  geom_line(linewidth = 1.6) +
  geom_point(size = 3.2) +
  geom_text(data = ends, aes(label = treatment), hjust = -0.35, size = 7.5,
            fontface = "bold", show.legend = FALSE) +
  scale_colour_manual(values = grp_cols) +
  scale_x_continuous(breaks = c(7, 21, 35, 50, 64, 84, 96), expand = expansion(mult = c(.02, .09))) +
  labs(x = "Days after transplanting (DAT)", y = "Severity (%)") +
  theme_slide() +
  guides(colour = guide_legend(override.aes = list(linewidth = 2, size = 4)))
save_fig("fig_dpc.png", p_dpc)

# ---- 2. OLS ---------------------------------------------------------------------
p_ols <- ggplot(plots, aes(audpc, yield_kg_rai)) +
  geom_smooth(method = "lm", formula = y ~ x, colour = green, fill = green,
              alpha = .12, linewidth = 1.6) +
  geom_point(aes(colour = grp), size = 5, alpha = .9) +
  scale_colour_manual(values = grp_cols) +
  labs(x = "AUDPC (% \u00d7 days)", y = "Grain yield (kg/rai)") +
  theme_slide()
save_fig("fig_ols.png", p_ols)

# ---- 3. boundary line + gap per plot -------------------------------------------
gap_cols <- c("Brown spot" = rust, "Other constraints" = grey)
seg <- plots |> mutate(y_mid = yield_kg_rai + yg_other, y_top = yield_kg_rai + yg_total)
p_bl <- ggplot(seg) +
  geom_segment(aes(audpc, yield_kg_rai, xend = audpc, yend = y_mid, colour = "Other constraints"),
               linewidth = 1.6) +
  geom_segment(aes(audpc, y_mid, xend = audpc, yend = y_top, colour = "Brown spot"),
               linewidth = 1.6) +
  geom_hline(yintercept = y_att, linetype = "dashed", colour = "#666666", linewidth = .8) +
  geom_abline(intercept = bl_fit[[1]], slope = bl_fit[[2]], colour = green, linewidth = 2) +
  geom_point(aes(audpc, yield_kg_rai), shape = 21, size = 4.5, fill = bg, colour = "#333333", stroke = 1.2) +
  annotate("text", x = 1230, y = y_att + 14, label = "attainable yield", hjust = 1,
           size = 6.5, colour = "#555555", fontface = "italic") +
  annotate("text", x = 900, y = 455, label = "boundary line (\u03c4 = 0.90)", hjust = 0.5,
           size = 6.5, colour = green, fontface = "bold") +
  annotate("segment", x = 900, y = 475, xend = 960, yend = 676, colour = green, linewidth = .7,
           arrow = arrow(length = unit(.18, "inches"))) +
  scale_colour_manual(values = gap_cols) +
  labs(x = "AUDPC (% \u00d7 days)", y = "Grain yield (kg/rai)") +
  theme_slide() +
  guides(colour = guide_legend(override.aes = list(linewidth = 4)))
save_fig("fig_boundary.png", p_bl)

# ---- 4. yield gap by treatment ---------------------------------------------------
bars <- gap |>
  select(treatment, "Brown spot" = yg_disease_mean, "Other constraints" = yg_other_mean) |>
  pivot_longer(-treatment, names_to = "component", values_to = "gap") |>
  mutate(component = factor(component, levels = c("Brown spot", "Other constraints")))
p_gap <- ggplot(bars, aes(treatment, gap, fill = component)) +
  geom_col(width = .68) +
  geom_text(data = gap, aes(treatment, yg_total_mean + 9,
                            label = sprintf("%.0f%%", pct_disease_of_gap)),
            inherit.aes = FALSE, size = 7.5, fontface = "bold",
            colour = ifelse(gap$pct_disease_of_gap > 20, rust, "#777777")) +
  scale_fill_manual(values = gap_cols) +
  scale_y_continuous(expand = expansion(mult = c(0, .08))) +
  labs(x = "Treatment", y = "Yield gap (kg/rai)") +
  theme_slide() + theme(panel.grid.major.x = element_blank())
save_fig("fig_gap.png", p_gap)

# ---- 5. concept schematic (simulated, illustrative only) ------------------------
set.seed(7)
n <- 70
sim <- tibble(x = runif(n, 0, 100)) |>
  mutate(ceiling = 100 - .45 * x, y = ceiling - rexp(n, 1 / 14)) |>
  filter(y > 25, !(x > 62 & x < 96 & y > 48 & y < 68), !(x > 5 & x < 40 & y > 75 & y < 86))
ex <- tibble(x = 62, ceiling = 100 - .45 * 62, y = 44)
p_con <- ggplot(sim, aes(x, y)) +
  geom_point(size = 4, colour = grey, alpha = .8) +
  geom_hline(yintercept = 100, linetype = "dashed", colour = "#666666", linewidth = .8) +
  geom_abline(intercept = 100, slope = -.45, colour = green, linewidth = 2) +
  geom_segment(data = ex, aes(xend = x, y = ceiling, yend = 100), colour = rust, linewidth = 3) +
  geom_segment(data = ex, aes(xend = x, y = y, yend = ceiling), colour = "#7F8782", linewidth = 3) +
  geom_point(data = ex, size = 6, shape = 21, fill = bg, colour = "#333333", stroke = 1.5) +
  annotate("text", x = 64.5, y = 86, label = "gap due to\ndisease", hjust = 0, size = 7,
           colour = rust, fontface = "bold", lineheight = .9) +
  annotate("text", x = 64.5, y = 58, label = "gap due to\nother constraints", hjust = 0, size = 7,
           colour = "#5F6662", fontface = "bold", lineheight = .9) +
  annotate("text", x = 0, y = 104, label = "attainable yield", hjust = 0, size = 6.5,
           colour = "#555555", fontface = "italic") +
  annotate("text", x = 8, y = 80, label = "boundary line", hjust = 0, size = 7,
           colour = green, fontface = "bold") +
  scale_y_continuous(limits = c(25, 106)) +
  labs(x = "Disease (AUDPC) \u2192", y = "Yield \u2192") +
  theme_slide() + theme(axis.text = element_blank(), panel.grid = element_blank(),
                        axis.line = element_line(colour = "#888888", linewidth = .8))
save_fig("fig_concept.png", p_con)
