# Gapminder Analysis — Shiny App

## Background

This app is an interactive visualization built on top of a prior data analysis task completed as part of the \*\*R for Data Science\*\* skill assessment. The logic and structure of that analysis were preserved here and wrapped into an interactive Shiny interface.

> Note: the analytical approach was later revisited and refined in a separate \*\*Python for Data Science\*\* assessment, where some methodological choices were reconsidered.
---

## Dataset

The app uses a cleaned version of the Gapminder dataset (`gapminder\_clean.csv`), which contains country-level indicators across multiple years (1962–2007).

---
## Features
### Scatter Plot tab

- **Flexible axes** — different variables can be mapped to X and Y
- **Color and size mapping** — additional variables can be encoded visually; both can be set to `None`
- **Year slider** — snaps to years with actual data only; supports **Play animation** to watch trends over time
- **Logarithmic scale** — can be toggled independently for X and Y axes; original values are shown as labels
- **Trend line** — optional linear (`lm`) or smooth (`loess`) fit across all points
- **Dynamic title** — updates to reflect current axis selection
- **Tooltip** — hover over a point to see country name and axis values
- **Highlight country** — type a country name to mark it in red on the plot
- **Country data table** — click a point or type a country name to see all available data for that country in the selected year; empty columns are hidden automatically
- **Summary metrics** — correlation coefficient and number of countries shown (with NA count) displayed alongside the plot

### Boxplot comparison tab

- **Variable selection** — choose any variable to compare across continents
- **Continent filter** — select two or more continents; Reset button restores default selection
- **Boxplot** — shows distribution with individual data points overlaid (jitter)
- **Tukey HSD plot** — visualizes pairwise differences between all selected continents after ANOVA; blue = statistically significant difference (p < 0.05), confidence intervals shown for each pair

---

## How to run

link: https://lmvl12.shinyapps.io/Gapminder/

```r
# Install dependencies if needed
install.packages(c("shiny", "tidyverse", "plotly", "scales", "broom", "shinyWidgets", "bslib", "DT"))

# Run the app
shiny::runApp("Gapminder")
```

