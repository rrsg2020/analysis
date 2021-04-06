library("reticulate")
library("Metrics")
library("ggplot2")
library("epiR")
library("lme4")
library("irr")
library("sjPlot")
library("plotly")
requiredPackages = c('reticulate', 'Metrics', 'ggplot2', 'epiR', 'lme4', 'irr', 'sjPlot', 'plotly',
                     'shiny', 'shinythemes', 'shinydashboard')
for(p in requiredPackages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

path_to_CSVfile = paste(RepoDir, "databases\\", sep = "")
path_to_src = paste(RepoDir, "src\\", sep = "")
path_to_stats = paste(path_to_src, "StatisticalAnalysis\\", sep = "")

runApp('ShinyDashboard')