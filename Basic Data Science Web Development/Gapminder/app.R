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
          sliderTextInput("year",
                          "Year",
                          grid = TRUE,
                          choices = available_years,
                          selected = min(available_years)),
          checkboxInput("log_x", "Log scale X", FALSE),
          checkboxInput("log_y", "Log scale Y", FALSE)
          ),

        # Show a plot of the generated distribution
        mainPanel(
          plotlyOutput("plot")
        )
    )
)

# Define server logic 
server <- function(input, output) {
  output$plot <- renderPlotly({
    plot_data <- gapminder_data |> 
      filter(Year == as.numeric(input$year))
    
    p <- ggplot(plot_data, aes(.data[[input$x]], .data[[input$y]])) +
      geom_point(aes(color = .data[[input$color]]))
    if (input$log_x) p <- p + scale_x_log10()
    if (input$log_y) p <- p + scale_y_log10()
    ggplotly(p)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
