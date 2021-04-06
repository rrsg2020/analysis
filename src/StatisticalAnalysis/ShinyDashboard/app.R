source(paste(path_to_stats, "allStats.R", sep = ""))

# Define UI for application that draws a histogram
ui <- navbarPage("T1 mapping challenge statistics", theme = shinytheme("flatly"),
                 
                 #TAB 1
                 tabPanel("Magnitud VS Complex",
                          sidebarLayout(
                              sidebarPanel(
                                  selectizeInput(
                                      inputId = "DiffSitesID", 
                                      label = "Select a site", 
                                      choices = unique(magVScomp$dataMagComp$sid),
                                      #selected = "1.001",
                                      multiple = TRUE
                                  ),
                                  
                                  radioButtons(inputId = "typeComparison",
                                               label = "Choose the type of plot to display",
                                               choices = c("Difference", "Difference (%)"),
                                               #selected = "Difference")
                                  ),
                                  
                                  selectizeInput(
                                      inputId = "CorrSitesID", 
                                      label = "Select a site to show a dispersion plot", 
                                      choices = unique(magVScomp$dataCorr$sid),
                                      #selected = "1.001",
                                      multiple = FALSE
                                  ),
                                  
                                  h2("Correlation coefficients"),
                                  tableOutput(outputId = "PearsonCorr"),
                                  
                                  helpText("Mathieu, B., et al. MathieuPaperName")
                                  
                              ),
                              
                              mainPanel(
                                  h3("Difference between Magnitude and Complex"),
                                  plotlyOutput(outputId = "MagComp"),
                                  h3("Correlation between Magnitude and Complex"),
                                  plotlyOutput(outputId = "CorrMagComp")
                              )
                          )
                 ),
                 
                 #TAB 2
                 tabPanel("Comparison across sites",
                          tabsetPanel(sidebarLayout(
                              sidebarPanel(
                                  selectizeInput(
                                      inputId = "SiteUSID", 
                                      label = "Select a site", 
                                      choices = unique(SiteUS$dataSite$Site),
                                      multiple = TRUE
                                  ),
                                  
                                  helpText("Mathieu, B., et al. MathieuPaperName")
                                  
                              ),
                              
                              mainPanel(
                                  h3("US Data"),
                                  plotlyOutput(outputId = "CompUS")
                              )
                          )
                          ),
                          tabsetPanel(sidebarLayout(
                              sidebarPanel(
                                  selectizeInput(
                                      inputId = "SiteGermanyID", 
                                      label = "Select a site", 
                                      choices = unique(SiteGermany$dataSite$Site),
                                      multiple = TRUE
                                  ),
                                  
                                  helpText("Mathieu, B., et al. MathieuPaperName")
                                  
                              ),
                              
                              mainPanel(
                                  h3("Germany Data"),
                                  plotlyOutput(outputId = "CompGermany")
                              )
                          )
                          )
                 ),

                 #TAB 3
                 tabPanel("Reference VS Measured T1",
                         sidebarLayout(
                             sidebarPanel(
                                 selectizeInput(
                                     inputId = "RefMeasSitesID", 
                                     label = "Select a site", 
                                     choices = unique(RefVSMeas$BAData$sid),
                                     #selected = "1.001",
                                     multiple = FALSE
                                 ),
                                 
                                 h2("Correlation coefficients"),
                                 tableOutput(outputId = "CorrRefMeas"),
                                 
                                 helpText("Mathieu, B., et al. MathieuPaperName")
                         ),
                         
                         mainPanel(
                             h3("Bland-Altman analysis"),
                             plotlyOutput(outputId = "BAPlot"),
                             h3("Correlation analysis"),
                             plotlyOutput(outputId = "CorrRefMeasPlot"),
                         )
                     )
                 ),
                 
                 #TAB 4
                 tabPanel("Comparison Canada - Germany",
                          sidebarLayout(
                              sidebarPanel(
                                  selectInput(inputId = "selectCompSite",
                                                label = "Choose a site:",
                                                choices = c("Canada", "Germany"),
                                                selected = "Canada"),
                                  
                                  h2("Correlation coefficients"),
                                  tableOutput(outputId = "CorrCanGer"),
                                  
                                  helpText("Mathieu, B., et al. MathieuPaperName")
                                  
                              ),
                              
                              mainPanel(
                                  h3("Bland-Altman plot"),
                                  plotlyOutput(outputId = "BA4"),
                                  h3("Dispersion plot"),
                                  plotlyOutput(outputId = "Disp4")
                              )
                          )
                 ),
                 
                 #TAB 5
                 tabPanel("Bias",
                          sidebarLayout(
                              sidebarPanel(
                                  selectizeInput(
                                      inputId = "biasSitesID", 
                                      label = "Select a site", 
                                      choices = unique(RefVSMeas$stdData$sid),
                                      #selected = "1.001",
                                      multiple = TRUE
                                  ),
                                  
                                  radioButtons(inputId = "typeBiasPlot",
                                               label = "Choose the type of plot to display",
                                               choices = c("Standard Deviation", "Root Mean Square Error"),
                                               selected = "Standard Deviation"),
                                  
                                  helpText("Mathieu, B., et al. MathieuPaperName")
                              ),
                              
                              mainPanel(
                                  h3("Plots"),
                                  plotlyOutput(outputId = "biasPlots")
                              )
                          )
                
                ),
                
                #TAB 6
                tabPanel("LMEM",
                         sidebarLayout(
                             sidebarPanel(
                                 selectizeInput(
                                     inputId = "boxPlotSite", 
                                     label = "Select a site", 
                                     choices = unique(sitesLMEM$dataLME$sid),
                                     #selected = "1.001",
                                     multiple = FALSE
                                 ),
                                 
                                 radioButtons(inputId = "diagnosticLME",
                                              label = "LME Diagnostic",
                                              choices = c("Linearity", "Normality of Residuals"),
                                              selected = "Linearity"),
                                 
                                 helpText("Mathieu, B., et al. MathieuPaperName")
                             ),
                             
                             mainPanel(
                                 h3("Linear Mixed Effects Model"),
                                 plotlyOutput(outputId = "boxPlotLME"),
                                 h3("LME Model Summary"),
                                 htmlOutput(outputId = "summaryLME"),
                                 h3("Linear Mixed Effects Model Diagnostic"),
                                 plotOutput(outputId = "diagLME")
                             )
                         ))
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    #TAB 1
    MagCom_colors <- setNames(rainbow(nrow(magVScomp$dataMagComp)), magVScomp$dataMagComp$sid)
    output$MagComp <- renderPlotly({
        if (input$typeComparison == "Difference"){
            plot_ly(magVScomp$dataMagComp, x = ~refT1, y = ~diff, split = ~sid, color = ~sid, colors = MagCom_colors) %>%
                filter(sid %in% input$DiffSitesID) %>%
                #group_by(sid) %>%
                add_trace(type = 'scatter', mode = 'lines+markers',
                          hoverinfo = 'text',
                          text = ~paste('<br> Site: ', sid,
                                        '<br> Difference: ', signif(diff,3),
                                        '<br> Sphere: ', sph)) %>%
                layout(xaxis = list(title = "Reference T1 value (ms)"), yaxis = list(title = "Absolute T1 difference (ms)"))
        }
        else if (input$typeComparison == "Difference (%)"){
            plot_ly(magVScomp$dataMagComp, x = ~refT1, y = ~percDiff, split = ~sid, color = ~sid, colors = MagCom_colors) %>%
                filter(sid %in% input$DiffSitesID) %>%
                #group_by(sid) %>%
                add_trace(type = 'scatter', mode = 'lines+markers',
                          hoverinfo = 'text',
                          text = ~paste('<br> Site: ', sid,
                                        '<br> Difference (%): ', signif(percDiff,4),
                                        '<br> Sphere: ', sph)) %>%
                layout(xaxis = list(title = "Reference T1 value (ms)"), yaxis = list(title = "Percentual T1 difference (%)"))
        }
    })
        
    output$CorrMagComp <- renderPlotly({
        p <- ggplot(data = filter(magVScomp$dataCorr, sid %in% input$CorrSitesID)) +
            geom_point(aes(x = Complex, y = Magnitude,
                           text = paste0('<br> Complex: ', signif(Complex,5),
                                        '<br> Magnitude: ', signif(Magnitude,5),
                                        '<br> Sphere: ', sph)),
                       color = "black", size = 1.5) +
            labs(x = "Complex T1 value (ms)", y = "Magnitude T1 value (ms)") +
            geom_smooth(aes(x = Complex, y = Magnitude), method = "lm", se = TRUE, color = "red", lwd = 0.5,
                        text = paste('<br> Confidence intervals: ')) +
            geom_abline(intercept = 0, slope = 1, lwd = 0.7, col = "blue") +
            theme(axis.line = element_line(colour = "black"), 
                  panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(), 
                  panel.border = element_blank(), 
                  panel.background = element_blank()) +
            theme_bw() + theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                               axis.title = element_text(size = 12),
                               axis.text = element_text(size = 12))
        
        ggplotly(p, tooltip = "text")
    })
    
    output$PearsonCorr <- renderTable(magVScomp$PearsonCorr)
    
    #TAB 2
    US_colors <- setNames(rainbow(nrow(SiteUS$dataSite)), SiteUS$dataSite$Site)
    output$CompUS <- renderPlotly({
        plot_ly(SiteUS$dataSite, x = ~refT1, y = ~Mean, split = ~Site, color = ~Site, colors = US_colors) %>%
            filter(Site %in% input$SiteUSID) %>%
            #group_by(sid) %>%
            add_trace(type = 'scatter', mode = 'lines+markers',
                      hoverinfo = 'text',
                      text = ~paste('<br> Site: ', Site,
                                    '<br> Mean: ', signif(Mean,5),
                                    '<br> Sphere: ', Sphere)) %>%
            layout(xaxis = list(title = "Reference T1 value (ms)"), yaxis = list(title = "T1 value (ms)"))
    })
    
    Germany_colors <- setNames(rainbow(nrow(SiteGermany$dataSite)), SiteGermany$dataSite$Site)
    output$CompGermany <- renderPlotly({
        plot_ly(SiteGermany$dataSite, x = ~refT1, y = ~Mean, split = ~Site, color = ~Site, colors = Germany_colors) %>%
            filter(Site %in% input$SiteGermanyID) %>%
            #group_by(sid) %>%
            add_trace(type = 'scatter', mode = 'lines+markers',
                      hoverinfo = 'text',
                      text = ~paste('<br> Site: ', Site,
                                    '<br> Mean: ', signif(Mean,5),
                                    '<br> Sphere: ', Sphere)) %>%
            layout(xaxis = list(title = "Reference T1 value (ms)"), yaxis = list(title = "T1 value (ms)"))
    })
    
    
    #TAB 3
    output$BAPlot <- renderPlotly({
        p <- ggplot(data = filter(RefVSMeas$BAData, sid %in% input$RefMeasSitesID)) +
            geom_point(aes(x = average, y = difference,
                           text = paste('<br> Average: ', signif(average,5),
                                        '<br> Difference: ', signif(difference,4),
                                        '<br> Sphere: ', sph)), 
                       pch = 1, size = 1.5, col = "black") +
            labs(x = "Average T1 (ms)", 
                 y = "Measured - Reference") +
            geom_smooth(aes(x = average, y = difference), method = "lm", se = TRUE, fill = "lightgrey", lwd = 0.1, lty = 5) +
            ylim(mean(RefVSMeas$BAData$difference) - 4 * sd(RefVSMeas$BAData$difference), 
                 mean(RefVSMeas$BAData$difference) + 4 * sd(RefVSMeas$BAData$difference)) +
            # Línea de bias
            geom_hline(yintercept = mean(RefVSMeas$BAData$difference), lwd = 1) +
            # Línea en y=0
            geom_hline(yintercept = 0, lty = 3, col = "grey30") +
            # Limits of Agreement
            geom_hline(yintercept = mean(RefVSMeas$BAData$difference) + 
                           1.96 * sd(RefVSMeas$BAData$difference), 
                       lty = 2, col = "firebrick") +
            geom_hline(yintercept = mean(RefVSMeas$BAData$difference) - 
                           1.96 * sd(RefVSMeas$BAData$difference), 
                       lty = 2, col = "firebrick") +
            theme(panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank()) +
            geom_text(label = "Bias", x = 2000, y = 30, size = 3, 
                      colour = "black") +
            geom_text(label = "+1.96SD", x = 2000, y = 190, size = 3, 
                      colour = "firebrick") +
            geom_text(label = "-1.96SD", x = 2000, y = -110, size = 3, 
                      colour = "firebrick") +
            theme_bw() + theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                               axis.title = element_text(size = 12),
                               axis.text = element_text(size = 12))
        ggplotly(p, tooltip = "text")
    })
    
    output$CorrRefMeasPlot <- renderPlotly({
        p <- ggplot(data = filter(RefVSMeas$BAData, sid %in% input$RefMeasSitesID)) +
            geom_point(aes(x = reference, y = measValue,
                           text = paste('<br> Measured Value: ', signif(measValue,6),
                                        '<br> Reference Value: ', signif(reference,6),
                                        '<br> Sphere: ', sph)),
                       color = "black", size = 1.5) +
            labs(x = "Reference T1 value (ms)", y = "Measured T1 value (ms)") +
            geom_smooth(aes(x = reference, y = measValue), method = "lm", se = TRUE, color = "red", lwd = 0.5) +
            geom_abline(intercept = 0, slope = 1, lwd = 0.7, col = "blue") +
            theme(axis.line = element_line(colour = "black"), 
                  panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(), 
                  panel.border = element_blank(), 
                  panel.background = element_blank()) +
            theme_bw() + theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                               axis.title = element_text(size = 12),
                               axis.text = element_text(size = 12))
        ggplotly(p, tooltip = "text")
    })
    
    output$CorrRefMeas <- renderTable(RefVSMeas$Correlation_coefficients)
    
    #TAB 4
    output$BA4 <- renderPlotly({
        if (input$selectCompSite == "Canada"){
            RefVSMeas = measuredT1_against_referenceT1(scans = Canada)
        }
        else if (input$selectCompSite == "Germany"){
            RefVSMeas = measuredT1_against_referenceT1(scans = Germany)
        }
        
        p <- ggplot(data = RefVSMeas$BAData) +
            geom_point(aes(x = average, y = perc_difference, fill = sid,
                           text = paste('<br> Difference (%): ', signif(perc_difference,4),
                                        '<br> Average T1: ', signif(average,5),
                                        '<BR> Reference T1: ', signif(reference,5),
                                        '<br> Sphere: ', sph)), 
                       pch = 1, size = 1.5, col = "black") +
            labs(x = "Average T1 (ms)", 
                 y = "Difference (%)") +
            ylim(mean(RefVSMeas$BAData$perc_difference) - 4 * sd(RefVSMeas$BAData$perc_difference), 
                 mean(RefVSMeas$BAData$perc_difference) + 4 * sd(RefVSMeas$BAData$perc_difference)) +
            # Bias line
            geom_hline(yintercept = mean(RefVSMeas$BAData$perc_difference), lwd = 1) +
            # Line: y=0
            #geom_hline(yintercept = 0, lty = 3, col = "grey30") +
            # Limits of Agreement
            geom_hline(yintercept = mean(RefVSMeas$BAData$perc_difference) + 
                           1.96 * sd(RefVSMeas$BAData$perc_difference), 
                       lty = 2, col = "firebrick") +
            geom_hline(yintercept = mean(RefVSMeas$BAData$perc_difference) - 
                           1.96 * sd(RefVSMeas$BAData$perc_difference), 
                       lty = 2, col = "firebrick") +
            theme(panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank()) +
            geom_text(label = "Bias", x = 1800, y = mean(RefVSMeas$BAData$perc_difference) + 10, size = 3, 
                      colour = "black") +
            geom_text(label = "+1.96SD", x = 1800, y = mean(RefVSMeas$BAData$perc_difference) + 
                          1.96 * sd(RefVSMeas$BAData$perc_difference) + 10, size = 3, 
                      colour = "firebrick") +
            geom_text(label = "-1.96SD", x = 1800, y = mean(RefVSMeas$BAData$perc_difference) - 
                          1.96 * sd(RefVSMeas$BAData$perc_difference) - 10, size = 3, 
                      colour = "firebrick") +
            theme_bw() + theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                               axis.title = element_text(size = 12),
                               axis.text = element_text(size = 12))
        ggplotly(p, tooltip = "text")
    })
    
    output$Disp4 <- renderPlotly({
        if (input$selectCompSite == "Canada"){
            RefVSMeas = measuredT1_against_referenceT1(scans = Canada)
        }
        else if (input$selectCompSite == "Germany"){
            RefVSMeas = measuredT1_against_referenceT1(scans = Germany)
        }
 
        p <- ggplot(data = RefVSMeas$BAData) +
            geom_point(aes(x = reference, y = measValue, fill = sid,
                           text = paste('<br> Measured T1 Value: ', signif(measValue,6),
                                        '<br> Reference T1 Value: ', signif(reference,6),
                                        '<br> Sphere: ', sph)),
                       color = "black", size = 1.5) +
            labs(x = "Reference T1 value (ms)", y = "Measured T1 value (ms)") +
            geom_smooth(aes(x = reference, y = measValue), method = "lm", formula = y~x,
                        se = FALSE, color = "red", lwd = 0.5) +
            geom_abline(intercept = 0, slope = 1, lwd = 0.7, col = "blue") +
            theme(axis.line = element_line(colour = "black"), 
                  panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(), 
                  panel.border = element_blank(), 
                  panel.background = element_blank()) +
            theme_bw() + theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                               axis.title = element_text(size = 12),
                               axis.text = element_text(size = 12))
        ggplotly(p, tooltip = "text")
    })
    
    output$CorrCanGer <- renderTable({
        if (input$selectCompSite == "Canada"){
            RefVSMeas = measuredT1_against_referenceT1(scans = Canada)
        }
        else if (input$selectCompSite == "Germany"){
            RefVSMeas = measuredT1_against_referenceT1(scans = Germany)
        }
        
        RefVSMeas$corr_coef_site
    })
    
        #req(input$SitesID)
        #if (identical(input$SitesID, "")) return(NULL)
        #plot_ly(RefVSMeas$stdData, x = ~sph, y = ~stdValues, split = ~sid) %>%
        #    filter(sid %in% input$SitesID) %>%
        #    #group_by(sid) %>%
        #    add_lines()

    #output$multPlot <- renderPlotly({
    #    req(input$SitesID)
    #    if (identical(input$SitesID, "")) return(NULL)
    #    multPlot <- ggplot(RefVSMeas$test, aes(x = RefVSMeas$test$sph, y = RefVSMeas$test$stdValues)) +
    #        geom_line(size = 1.5) +
    #        scale_colour_manual(values = c("darkred", "blue", "dark green", "red"))
    #    ggplotly(multPlot)
    #})
    
    #TAB 5
    Bias_colors <- setNames(rainbow(nrow(RefVSMeas$stdData)), RefVSMeas$stdData$sid)
    output$biasPlots <- renderPlotly({
        if (input$typeBiasPlot == "Standard Deviation"){
            plot_ly(RefVSMeas$stdData, x = ~refT1, y = ~stdValues, split = ~sid, color = ~sid, colors = Bias_colors) %>%
                filter(sid %in% input$biasSitesID) %>%
                #group_by(sid) %>%
                add_trace(type = 'scatter', mode = 'lines+markers',
                          hoverinfo = 'text',
                          text = ~paste('<br> Site: ', sid,
                                        '<br> SD: ', signif(stdValues,3),
                                        '<br> Sphere: ', sph)) %>%
                layout(xaxis = list(title = "Reference T1 value (ms)"), yaxis = list(title = "Standard Deviation (ms)"))
        }
        else if (input$typeBiasPlot == "Root Mean Square Error"){
            plot_ly(RefVSMeas$rmseData, x = ~refT1, y = ~rmseValues, split = ~sid, color = ~sid, colors = Bias_colors) %>%
                filter(sid %in% input$biasSitesID) %>%
                #group_by(sid) %>%
                add_trace(type = 'scatter', mode = 'lines+markers',
                          hoverinfo = 'text',
                          text = ~paste('<br> Site: ', sid,
                                        '<br> RMSE (%): ', signif(rmseValues,4),
                                        '<br> Sphere: ', sph)) %>%
                layout(xaxis = list(title = "Reference T1 value (ms)"), yaxis = list(title = "RMSE (ms)"))
        }
    })
    
    #TAB 6
    output$boxPlotLME <- renderPlotly({
        p <- ggplot(data = filter(sitesLMEM$dataLME, sid %in% input$boxPlotSite)) +
            geom_boxplot(aes(x = sphere, y = dataSphere, fill = factor(sphere))) +
            geom_jitter(aes(x = sphere, y = dataSphere, fill = factor(sphere),
                        text = paste('<br> Measured Value: ', signif(dataSphere,6),
                                     '<br> Reference Value: ', signif(t1ref,6),
                                     '<br> Sphere: ', sphere)),
                        position = position_nudge(x=0.4)) +
            labs(x = "Reference T1 value (ms)", y = "Measured T1 value (ms)", color = "Sphere") +
            scale_x_reverse() +
            scale_x_discrete(labels = c("14"="21.35","13"="30.32","12"="42.78","11"="60.06","10"="85.35",
                                          "9"="120.89","8"="174.70","7"="240.71","6"="341.99","5"="485.90",
                                          "4"="692.25","3"="994.84","2"="1342.53","1"="1911.16"))
            theme(axis.line = element_line(colour = "black"), 
                  panel.grid.major = element_blank(), 
                  panel.grid.minor = element_blank(), 
                  panel.border = element_blank(), 
                  panel.background = element_blank()) +
            theme_classic() + theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                               axis.title = element_text(size = 12),
                               axis.text = element_text(size = 12))
        ggplotly(p, tooltip = "text")
    })
    
    firstLME <- lmer(dataSphere ~ t1ref + MRIversion + (1 + MRIversion|sid), data = sitesLMEM$dataLME)
    
    output$summaryLME <- renderUI({HTML(tab_model(firstLME, show.se = TRUE)$knitr)})
    
    output$diagLME <- renderPlot({
        if (input$diagnosticLME == "Linearity"){
            plot(fitted(firstLME),residuals(firstLME))
        }
        else if (input$diagnosticLME == "Normality of Residuals"){
            hist(residuals(firstLME))
        }
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
