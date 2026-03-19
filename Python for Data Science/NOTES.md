
## Project: Gapminder Global Trends (Python Advanced Edition)

### Overview

An advanced longitudinal study of global socio-economic indicators. While replicating the core objectives of the R-based analysis, this Python version implements a more rigorous statistical framework, including factorial ANOVA and time-stratified normality testing to ensure robust discovery of global patterns.

### Pipeline
``` mermaid
graph TD 
A["Raw Data: gapminder_clean.csv"] --> B{Advanced EDA} 
B --> C1[Correlation Dynamics] 
C1 --> D1["Pearson correlation: 1962-2007"] 
D1 --> E1["Peak Correlation Discovery: 1967"] 
B --> C2["Two-way ANOVA: Continent * Year"] 
C2 --> D2[""Simple Effects: Annual ANOVA""] 
D2 --> E2["Post-hoc: Tukey HSD Comparison"] 
B --> C3[Comparative Stat] 
C3 --> D3["By-Year Validation: QQ-Grid"] 
D3 -- "Shapiro-Wilk per Year" --> E3["Mann-Whitney U (Non-parametric)"] 
E1 & E2 & E3 --> G["Interactive Report"]
```    
### Key Methodology Upgrades (vs. R Version) and Findings

-   **Temporal Factorization:** Used **Two-way ANOVA** to decouple the impact of geography (Continent) from temporal trends (Year), proving that continental disparities are consistent over decades.
    
-   **Stratified Normality Checks:** Instead of a single "pooled" normality test, implemented a **QQ-plot grid** and **Shapiro-Wilk** for each year individually, providing a bulletproof justification for non-parametric testing.
    
-   **Rank Stability Analysis:** Developed a longitudinal ranking system to identify "Population Density Champions" based on 50-year stability rather than single-year snapshots.
    
-   **Contextual Outlier Investigation:** Integrated historical petroleum industry data to explain the 1962 Kuwait carbon spike, moving from pure math to data storytelling.


**Key Libraries**

-   **Pandas & NumPy:** High-performance data manipulation.
-   **Plotly Express:** Interactive web-based visualizations.
-   **SciPy & Statsmodels:** Advanced statistical modeling 
-   **Ruff:** High-speed linting and formatting for clean code.