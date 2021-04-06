Running Stats Shiny Dashboard
===================================

- Open up an R session.
- Introduce the following commands in the R console.

		RepoDir = file.path("path/to/the/rrsg2020/analysis/repository/")
		setwd(paste(RepoDir, "src/StatisticalAnalysis", sep = ""))
		path_to_python = "path/to/python/installation"
		source('runDashboard.R')
