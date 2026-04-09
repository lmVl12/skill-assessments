
## Project: Gapminder Global Trends Analysis

### Overview 
A comprehensive exploratory data analysis (EDA) and statistical reporting project using the Gapminder dataset. The study focuses on the intersection of economic development, environmental impact, and demographic shifts over a 50-year period.

### Pipeline
``` mermaid
graph TD
    A["Raw Data: gapminder_clean.csv"] --> B{Exploratory Analysis}
    B --> C1[Correlation Analysis]
    C1 --> D1["Pearson Test: GDP vs CO2"]
    D1 --> E1["Outlier Investigation: Kuwait 1962"]
    B --> C2[Comparative Analysis]
    C2 --> D2[Normality Check]
    D2 -- "Shapiro-Wilk " --> E2["Non-parametric: Wilcoxon Test"]
    B --> C3[Variance Analysis]
    C3 --> D3["One-way ANOVA: Energy by Continent"]
    D3 --> E4["Post-hoc: Tukey HSD Test"]
    E1 --> F["Interactive HTML Report"]
    E2 --> F
    E4 --> F
```    

### Key Findings

-   Confirmed a strong positive correlation between national wealth and carbon footprint.
-   Statistically demonstrated that continental location is a significant predictor of energy consumption patterns.
-   Found no significant difference in median import-to-GDP ratios between Europe and Asia post-1990, despite differing distribution shapes.

**Key Libraries**

-   **tidyverse:** Core suite for data manipulation and visualization.
-   **plotly:** Dynamic and interactive web-based plots.
-   **naniar:** Specialized tools for missing data analysis.
-   **broom:** Tidy statistical model outputs.
-   **kableExtra:** Advanced styling for statistical tables.