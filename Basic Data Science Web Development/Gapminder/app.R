library(shiny)
library(tidyverse)
library(plotly)        # interactive plots
library(scales)        # axis label formatting
library(broom)         # tidy() for model outputs
library(shinyWidgets)  # sliderTextInput
library(bslib)         # modern UI theming


# ── Data ──────────────────────────────────────────────────────────────────────
gapminder_data <- read_csv("gapminder_clean.csv", col_select = -1)  # skip index column
available_years <- sort(unique(gapminder_data$Year))                    # for slider choices
plot_vars <- names(gapminder_data)[!names(gapminder_data) %in% c("Country Name", "Year")]  # numeric/categorical vars only

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- fluidPage(
  theme = bs_theme(
    bootswatch = "flatly",  # Bootstrap preset theme
    primary = "#00897B",    # overrides default blue accent
    navbar_bg = "#00897B"   # navbar background color
  ),
  h2("Gapminder Analysis Shiny",
     style = "color: #00897B; font-weight: bold; padding: 15px 0;"
  ),
  layout_sidebar(
    # ── Sidebar ───────────────────────────────────────────────────────────────
    sidebar = sidebar(
      bg = "#333333",  # dark background for contrast
      
      # Controls visible only on Scatter plot tab
      # condition uses JS expression referencing input$tabs value
      conditionalPanel(
        condition = "input.tabs == 'Scatter plot'",
        selectInput("x", "X variable", choices = plot_vars, selected = "gdpPercap"),
        selectInput("y", "Y variable", choices = plot_vars, selected = "CO2 emissions (metric tons per capita)"),
        selectInput("color", "Map to color", choices = c("None", plot_vars), selected = "continent"),  # "None" disables mapping
        selectInput("size", "Map to size", choices = c("None", plot_vars), selected = "pop"),           # "None" disables mapping
        sliderTextInput("year", "Year",
                        grid = TRUE,               # show tick marks for each year
                        choices = available_years, # snaps to real years only
                        selected = min(available_years),
                        animate = TRUE             # enables Play button for animation
        ),
        checkboxInput("log_x", "Log scale X", FALSE),  # default: linear
        checkboxInput("log_y", "Log scale Y", FALSE),  # default: linear
        checkboxInput("trend", "Show trend line"),      # default: FALSE
        selectInput("smooth_method", "Trend line type",
                    choices = c("Linear" = "lm", "Smooth" = "loess"),  # lm = straight line, loess = curve
                    selected = "lm"
        )
      ),
      
      # Controls visible only on Boxplot tab
      conditionalPanel(
        condition = "input.tabs == 'Boxplot comparison'",
        selectInput("box_var", "Variable to compare", choices = plot_vars),
        selectizeInput("box_continents", "Select continents",
                       choices = unique(gapminder_data$continent) |> na.omit(),  # exclude NA continent
                       selected = c("Asia", "Europe"),
                       multiple = TRUE  # allows selecting 2+ continents
        ),
        actionButton("reset_continents", "Reset", class = "btn-sm btn-secondary")  # btn-sm = small button
      ),
      
      # Always visible regardless of active tab
      actionButton("about", "About", icon = icon("info-circle"), class = "btn-primary")
    ),
    
    # ── Main panel ────────────────────────────────────────────────────────────
    tabsetPanel(
      id = "tabs",  # id needed for conditionalPanel to reference input$tabs
      
      # ── Tab 1: Scatter plot ───────────────────────────────────────────────
      tabPanel(
        "Scatter plot",
        layout_columns(
          col_widths = c(8, 4),  # Bootstrap 12-col grid: plot=8, sidebar=4
          card(plotlyOutput("plot")),
          card(
            textInput("highlight_country", "Highlight country",
                      placeholder = "Enter country name"  # greyed hint text
            ),
            br(),  # vertical spacer
            textOutput("correlation"),
            br(),
            strong("Countries shown:"),  # bold label
            textOutput("n_countries")
          )
        ),
        uiOutput("country_card")  # rendered conditionally after click/search
      ),
      
      # ── Tab 2: Boxplot comparison ─────────────────────────────────────────
      tabPanel(
        "Boxplot comparison",
        layout_columns(  # equal width columns by default
          card(plotOutput("boxplot", height = "400px")),
          card(plotOutput("tukey_plot", height = "400px"))  # post-hoc pairwise test
        )
      )
    )
  )
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  
  # ── Reactive data ──────────────────────────────────────────────────────────
  
  # Stores last plotly click; NULL when nothing clicked
  click_data <- reactiveVal(NULL)
  observeEvent(event_data("plotly_click", source = "plot"), {
    click_data(event_data("plotly_click", source = "plot"))  # update on each click
  })
  
  # Scatter data: filtered by year, NA continents excluded, highlight flag added
  plot_data <- reactive({
    gapminder_data |>
      filter(Year == as.numeric(input$year), !is.na(continent)) |>
      mutate(highlight = ifelse(
        tolower(trimws(`Country Name`)) == tolower(trimws(input$highlight_country)),  # case-insensitive match
        "selected", "normal"
      ))
  })
  
  # Boxplot data: filtered by selected continents, NA dropped for chosen variable
  box_data <- reactive({
    req(input$box_continents)  # stop if no continents selected
    gapminder_data |>
      filter(continent %in% input$box_continents) |>
      drop_na(all_of(input$box_var))  # remove rows where box_var is NA
  })
  
  # Returns country name from click or text input; NULL if neither provided
  selected_country <- reactive({
    click <- click_data()
    if (!is.null(click)) return(click$customdata)  # click takes priority over text
    
    if (nchar(trimws(input$highlight_country)) > 0) {  # trimws removes accidental spaces
      matched <- gapminder_data$`Country Name`[
        tolower(trimws(gapminder_data$`Country Name`)) == tolower(trimws(input$highlight_country))
      ]
      if (length(matched) > 0) return(matched[1])  # return first match
    }
    return(NULL)
  })
  
  # ── Scatter plot ───────────────────────────────────────────────────────────
  output$plot <- renderPlotly({
    # Base plot with country name in tooltip and as customdata for click detection
    p <- ggplot(plot_data(), aes(
      .data[[input$x]], .data[[input$y]],  # .data[[]] allows dynamic column names
      text = `Country Name`,               # shown in plotly tooltip
      customdata = `Country Name`          # returned by event_data() on click
    )) +
      labs(title = paste(input$y, "vs", input$x)) +
      theme(plot.title = element_text(hjust = 0.5))  # center title
    
    # Add points with conditional aesthetic mapping
    if (input$color != "None" & input$size != "None") {
      p <- p + geom_point(aes(color = .data[[input$color]], size = .data[[input$size]]))
    } else if (input$color != "None") {
      p <- p + geom_point(aes(color = .data[[input$color]]))
    } else if (input$size != "None") {
      p <- p + geom_point(aes(size = .data[[input$size]]))
    } else {
      p <- p + geom_point()
    }
    
    # Overlay red point on top of highlighted country
    p <- p + geom_point(
      data = filter(plot_data(), highlight == "selected"),
      color = "red", size = 3  # fixed size, not mapped to variable
    )
    
    # Log scale with original values as labels (not scientific notation)
    if (input$log_x) p <- p + scale_x_log10(labels = scales::comma)
    if (input$log_y) p <- p + scale_y_log10(labels = scales::comma)
    
    # Trend line: group=1 forces single line across all color groups
    if (input$trend) p <- p + geom_smooth(
      method = input$smooth_method,
      se = TRUE,                      # show confidence interval ribbon
      mapping = aes(group = 1)        # ignore color grouping
    )
    
    # Convert to interactive plotly; show only selected tooltip fields
    ggplotly(p, source = "plot", tooltip = c("text", "x", "y"))
  })
  
  # ── Summary metrics ────────────────────────────────────────────────────────
  
  # Pearson correlation between X and Y for selected year
  output$correlation <- renderText({
    cor_data <- gapminder_data |>
      filter(Year == as.numeric(input$year)) |>
      select(all_of(c(input$x, input$y))) |>
      drop_na()  # cor() requires complete cases
    paste("Correlation:", round(cor(cor_data[[input$x]], cor_data[[input$y]]), 3))
  })
  
  # Count of countries with non-NA values for both axes
  output$n_countries <- renderText({
    complete <- plot_data() |>
      select(all_of(c(input$x, input$y))) |>
      drop_na() |>
      nrow()
    paste0(complete, " shown (", nrow(plot_data()) - complete, " removed due to missing data)")
  })
  
  # ── Country data table ─────────────────────────────────────────────────────
  
  # Renders card only when country is selected; shows hint otherwise
  output$country_card <- renderUI({
    if (is.null(selected_country())) {
      return(p("Click on a point or enter a country name to see data.",
               style = "color: gray; font-style: italic; padding: 10px;"
      ))
    }
    card(
      card_header("Country data"),
      DT::dataTableOutput("country_table")
    )
  })
  
  output$country_table <- DT::renderDataTable({
    if (is.null(selected_country())) return(NULL)
    gapminder_data |>
      filter(`Country Name` == selected_country(), Year == as.numeric(input$year)) |>
      select(where(~ !all(is.na(.)))) |>       # drop columns that are entirely NA
      mutate(across(where(is.numeric), ~ round(., 2)))  # round all numeric to 2 decimals
  },
  options = list(
    dom = "t",          # "t" = table only, no search/pagination/info
    ordering = FALSE    # disable column sort arrows
  ),
  rownames = FALSE      # hide row index column
  )
  
  # ── Boxplot ────────────────────────────────────────────────────────────────
  output$boxplot <- renderPlot({
    ggplot(box_data(), aes(x = continent, y = .data[[input$box_var]], fill = continent)) +
      geom_boxplot(alpha = 0.7) +               # semi-transparent boxes
      geom_jitter(width = 0.2, alpha = 0.3) +   # show individual points with slight spread
      labs(title = paste("Comparison:", input$box_var), x = "Continent", y = input$box_var) +
      theme_classic(base_size = 16) +            # base_size scales all text proportionally
      theme(legend.position = "none") +          # color already shown on x axis
      scale_fill_brewer(palette = "Accent")      # colorblind-friendly palette
  })
  
  # ── Tukey plot (pairwise post-hoc test after ANOVA) ────────────────────────
  output$tukey_plot <- renderPlot({
    # ANOVA: tests if any continent differs significantly
    res_anova <- aov(as.formula(paste0("`", input$box_var, "` ~ continent")), data = box_data())
    
    # Tukey HSD: pairwise comparisons with adjusted p-values
    tukey_data <- TukeyHSD(res_anova) |>
      tidy() |>                                        # convert to data frame
      mutate(significant = adj.p.value < 0.05)         # TRUE = statistically significant
    
    ggplot(tukey_data, aes(x = estimate, y = reorder(contrast, estimate), color = significant)) +
      geom_vline(xintercept = 0, linetype = "solid", color = "grey50") +  # "no difference" line
      annotate("label",
               x = 0, y = Inf,           # Inf = top of plot area
               label = "No Difference",
               vjust = 1.5, hjust = 0.7, # fine-tune label position
               color = "grey50", fill = "white",
               label.size = 0.5, fontface = "italic"
      ) +
      geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),  # 95% confidence interval
                     height = 0.3, linewidth = 1
      ) +
      geom_point(size = 2) +  # point estimate of difference
      theme_classic(base_size = 16) +
      scale_color_manual(values = c("black", "blue"), guide = "none") +  # blue = significant
      labs(
        title = "Pairwise Differences by Continent",
        subtitle = "Blue indicates significant difference (p < 0.05)",
        x = "Difference in means", y = ""
      )
  })
  
  # ── Modals & observers ─────────────────────────────────────────────────────
  
  # About modal dialog
  observeEvent(input$about, {
    showModal(modalDialog(
      title = "About this app",
      HTML("
        <p>This app allows you to explore the Gapminder dataset interactively.</p>
        <ul>
          <li><b>Scatter plot</b> — choose any variables for X and Y axes, map color and size to additional variables</li>
          <li><b>Scale & trend</b> — switch to logarithmic scale, add a linear or smooth trend line</li>
          <li><b>Boxplot</b> — compare distributions across continents</li>
          <li><b>Country data</b> — click on a point or type a country name to see its full data for a selected year</li>
          <li><b>Animation</b> — highlight a country and press Play to watch its trajectory over time. Try China — its rise in gdpPercap is remarkable</li>
        </ul>
      "),
      easyClose = TRUE,       # close by clicking outside
      footer = modalButton("Got it!")
    ))
  })
  
  # Reset continent selection to default
  observeEvent(input$reset_continents, {
    updateSelectizeInput(session, "box_continents", selected = c("Asia", "Europe"))
  })
}

# ── Run ───────────────────────────────────────────────────────────────────────
shinyApp(ui = ui, server = server)