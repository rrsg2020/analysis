library(shiny)
library(shinythemes)
library(shinydashboard)
library(gridExtra)

path_to_src = "PATH/TO/SRC/"
source(paste(path_to_src, "StatisticalAnalysis\\allStats.R", sep = ""))

# Define UI for application that draws a histogram
ui <- navbarPage("T1 mapping challenge statistics", theme = shinytheme("flatly"),
                 tabPanel("Reliability",
                         sidebarLayout(
                         sidebarPanel(
                             radioButtons(inputId = "typeplot",
                                          label = "Choose the type of plot to display",
                                          choices = c("Bland-Altman", "Dispersion"),
                                          selected = "Bland-Altman")
                         ),
                         
                         mainPanel(
                             h3("Plots"),
                             plotOutput(outputId = "distPlot"),
                             h3("Correlation coefficients"),
                             tableOutput(outputId = "corrTable")
                         )
                     )
                 ),
                 tabPanel("Bias",
                          sidebarLayout(
                              sidebarPanel(
                                  radioButtons(inputId = "typeplot2",
                                               label = "Choose the type of plot to display",
                                               choices = c("Standard Deviation", "Root Mean Square Error"),
                                               selected = "Standard Deviation")
                              ),
                              
                              mainPanel(
                                  h3("Plots"),
                                  plotOutput(outputId = "distPlot2")
                              )
                          ))
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$distPlot <- renderPlot({
        if (input$typeplot == "Bland-Altman"){
            plotType <- stats$Bland_Altman
        }
        if (input$typeplot == "Dispersion"){
            plotType <- stats$Dispersion
        }
        plot1 = plotType[[1]]
        plot2 = plotType[[2]]
        plot3 = plotType[[3]]
        plot4 = plotType[[4]]
        grid.arrange(plot1,plot2,plot3,plot4, ncol = 2)
    })
    
    output$corrTable <- renderTable(stats$Correlation_coefficients)
    
    output$distPlot2 <- renderPlot({
        if (input$typeplot2 == "Standard Deviation"){
            plotType2 <- stats$STD
        }
        if (input$typeplot2 == "Root Mean Square Error"){
            plotType2 <- stats$RMSE
        }
        plot12 = plotType2[[1]]
        plot22 = plotType2[[2]]
        plot32 = plotType2[[3]]
        plot42 = plotType2[[4]]
        grid.arrange(plot12,plot22,plot32,plot42, ncol = 2)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
