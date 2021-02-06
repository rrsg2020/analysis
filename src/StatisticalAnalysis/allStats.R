library("reticulate")
library("Metrics")
library("ggplot2")
library("epiR")
library("irr")

path_to_CSVfile = "PATH/TO/DATABASES/"
path_to_src = "PATH/TO/SRC/"
path_to_python = "PATH/TO/PYTHON/INSTALLATION/"

data <- read.csv(paste(path_to_CSVfile, "3T_NIST_T1maps_database.csv", sep = ""))
data[] <- gsub("[][]", "", as.matrix(data))

submission <- 1:40
listSpheres = list()
list2append = list()
for (i in submission){
  for (j in seq(1,14)){
    dataSphere = gsub("\\. ","",data[i,j+grep("^T1...NIST.sphere.1$", colnames(data))-1])
    dataSphere = as.matrix(as.numeric(unlist(strsplit(dataSphere," "))))
    dataSphere = dataSphere[!is.na(dataSphere)]
    
    list2append[[j]] = dataSphere
  }
  listSpheres[[i]] = list2append
}

##COMPARE MAGNITUDE VS COMPLEX##
source(paste(path_to_src, "StatisticalAnalysis\\comparison_magnitude_complex.R", sep = ""))

cases <- c(1,seq(11,25,2),34,36)

#p-value > 0.5, there's no statistical difference between magnitude and complex
magVScomp <- comparison_magnitude_complex(cases,listSpheres)

##ANALYSIS WITHIN GROUPS ACROSS SITES
source(paste(path_to_src, "StatisticalAnalysis\\comparison_across_sites.R", sep = ""))

germany <- 34:37
site <- germany

comparisonSite <- comparison_across_sites(site = germany)

##Call Python script from R##
use_python(path_to_python, required=T)
source_python(paste(path_to_src, "nist.py", sep = ""))

##COMPARISON BETWEEN MEASURED AND REFERENCE T1 VALUES##
source(paste(path_to_src, "StatisticalAnalysis\\measuredT1_against_referenceT1.R", sep = ""))

scans <- 1:4
stats <- measuredT1_against_referenceT1(scans)


#dispersionList[[2]]
#BAList[[1]]
#stdList[[1]]
#rmseList[[1]]

