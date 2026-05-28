library(shiny)
library(tidyverse) # Core suite for data manipulation and visualization
library(plotly) # Dynamic and interactive web-based plots
library(scales) # Tools for formatting axis labels and legends
library(naniar) # Specialized tools for missing data analysis
library(broom) # Converts statistical models into tidy data frames
library(knitr) # General-purpose tool for dynamic report generation
library(kableExtra) # Advanced styling for HTML and PDF tables
library(viridis)
library(shinyWidgets)

gapminder_data <- read_csv("../gapminder_clean.csv", col_select = -1)
available_years <- sort(unique(gapminder_data$Year))

# Define UI for application 
ui <- fluidPage(
    titlePanel("Gapminder Analysis"),
    sidebarLayout(
        sidebarPanel(
          selectInput("x", "X variable", choices = names(gapminder_data), selected = "gdpPercap"),
          selectInput("y", "Y variable", choices = names(gapminder_data), selected = "CO2 emissions (metric tons per capita)"),
          selectInput("color", "Map to color", choices = names(gapminder_data), selected = "continent"),
          selectInput("size", "Map to size", choices = names(gapminder_data), selected = "pop"),
          sliderTextInput("year",
                          "Year",
                          grid = TRUE,
                          choices = available_years,
                          selected = min(available_years),
                          animate = TRUE),
          checkboxInput("log_x", "Log scale X", FALSE),
          checkboxInput("log_y", "Log scale Y", FALSE),
          checkboxInput("trend", "Show trend line"),
          selectInput("smooth_method", "Trend line type", 
                      choices = c("Linear" = "lm", "Smooth" = "loess"),
                      selected = "lm")
          ),

        # Show a plot of the generated distribution
        mainPanel(
            plotlyOutput("plot"),
            textInput("highlight_country", "Highlight country", placeholder = "Enter country name"),
            textOutput("correlation")
            )
        
    ),
    DT::dataTableOutput("country_table")
)
# Define server logic 
server <- function(input, output) {
  output$plot <- renderPlotly({
    plot_data <- gapminder_data |> 
      filter(Year == as.numeric(input$year)) |> 
      mutate(highlight = ifelse(
        tolower(trimws(`Country Name`)) == tolower(trimws(input$highlight_country)),
        "selected", "normal"
      ))
    
    total <- nrow(plot_data)
    complete <- plot_data |>
      select(all_of(c(input$x, input$y))) |>
      drop_na() |>
      nrow()
    
    p <- ggplot(plot_data, aes(.data[[input$x]], .data[[input$y]], text = `Country Name`)) +
      geom_point(aes(color = .data[[input$color]], size = .data[[input$size]]))+
      geom_point(data = filter(plot_data, highlight == "selected"),
                 color = "red", size = 3)
    if (input$log_x) p <- p + scale_x_log10()
    if (input$log_y) p <- p + scale_y_log10()
    if (input$trend) p <- p + geom_smooth(method = input$smooth_method, se = TRUE, mapping = aes(group = 1))
    ggplotly(p, source = "plot") |> 
      style(customdata = plot_data$`Country Name`) |> 
      layout(
        annotations = list(
          x = 0, y = -0.15,
          xref = "paper", yref = "paper",
          text = paste0("Showing ", complete, " countries (", total - complete, " removed due to missing data)"),
          showarrow = FALSE,
          font = list(size = 11),
          xanchor = "left"
      ),
      margin = list(b = 80))
  })
  output$correlation <- renderText({
    cor_data <- gapminder_data |>
      filter(Year == as.numeric(input$year)) |>
      select(all_of(c(input$x, input$y))) |>
      drop_na()
    
    cor_val <- cor(cor_data[[input$x]], cor_data[[input$y]])
    
    paste("Correlation:", round(cor_val, 3))
  })
  
  output$country_table <- DT::renderDataTable({
    click <- event_data("plotly_click", source = "plot")
    if (is.null(click)){
      return(NULL)
    }
    clicked_country <- click$customdata
    gapminder_data |>
      filter(`Country Name` == clicked_country, Year == as.numeric(input$year))
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
