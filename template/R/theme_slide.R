# ggplot2 theme and palette that match the ricetalk slide theme.
# source("R/theme_slide.R"), then add `+ theme_slide()` to a plot and save with save_fig().

library(ggplot2)

rt_bg      <- "#FBFAF4"   # slide background
rt_primary <- "#1F4E2C"
rt_good    <- "#6BAA3C"
rt_accent  <- "#D9A51F"
rt_bad     <- "#B4472B"
rt_grey    <- "#A9AEA6"

theme_slide <- function(base_size = 24) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background  = element_rect(fill = rt_bg, colour = NA),
      panel.background = element_rect(fill = rt_bg, colour = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#E4E3D8", linewidth = .5),
      axis.title = element_text(colour = rt_primary, face = "bold"),
      axis.text  = element_text(colour = "#444444"),
      legend.position = "top", legend.justification = "left",
      legend.title = element_blank(),
      plot.margin = margin(12, 24, 12, 12)
    )
}

# 10 x 6.6 in at 200 dpi fills a 60%-wide column on a 1600 x 900 slide.
save_fig <- function(path, plot, w = 10, h = 6.6) {
  ggsave(path, plot, width = w, height = h, dpi = 200, bg = rt_bg)
}

# Example: Rscript R/theme_slide.R writes images/example.png
if (sys.nframe() == 0) {
  p <- ggplot(mtcars, aes(wt, mpg, colour = factor(am, labels = c("Group A", "Group B")))) +
    geom_point(size = 5, alpha = .9) +
    geom_smooth(aes(group = 1), method = "lm", formula = y ~ x,
                colour = rt_primary, fill = rt_primary, alpha = .12, linewidth = 1.6) +
    scale_colour_manual(values = c("Group A" = rt_good, "Group B" = rt_bad)) +
    labs(x = "Predictor (unit)", y = "Response (unit)") +
    theme_slide()
  dir.create("images", showWarnings = FALSE)
  save_fig("images/example.png", p)
}
