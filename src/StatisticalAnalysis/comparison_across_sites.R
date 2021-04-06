comparison_across_sites <- function(site){
  meanSite = data.frame()
  for (j in seq(1,length(site))){
    for (k in seq(1,14)){
      siteData = as.numeric(unlist(listSpheres[[site[j]]][k]))
      
      meanSite[k,j] = mean(siteData)
      
      ##DIFERENCE BETWEEN MAGNITUDE AND COMPLEX
      #diff_Mag_Comp[k,j] = mean(magData) - mean(compData)
      #diff_Perc_Mag_Comp[k,j] = 100*abs(mean(magData) - mean(compData))/mean(magData)
      
      ##STATISTICAL TESTS (COMPARE MEANS)
      
    }
    
    phantomTemperature = as.numeric(data[j,"phantom.temperature"])
    phantomVersion = as.numeric(data[j,"phantom.version"])
    if (phantomVersion<42){
      refT1 = temperature_correction(phantomTemperature,phantomVersion)
    } else {
      refT1 = temperature_correction(phantomTemperature,phantomVersion)
    }
    
    id = data[site[j],"id"]
    sid <- as.matrix(rep(id,14))
    sph <- as.matrix(1:14)
    t1 <- as.matrix(refT1)
    
    data_Site <- data.frame(sid, sph, t1, meanSite[,j])
    
    if (j==1){
      dataTmp = rbind(data.frame(), data_Site)
    }
    else{
      dataSite2plot = rbind(dataTmp, data_Site)
      dataTmp <- dataSite2plot
    }
  }
  
  ##ONE-WAY ANOVA##
  multComparisons <- list()
  for (j in seq(1,14)){
    flag = 1
    anovaGer <- data.frame(T1=numeric(),group=numeric())
    
    for (k in site){
      if (flag==1){
        firstIndex = 0
        lastIndex = 0
      }
      sample = as.numeric(unlist(listSpheres[[k]][j]))
      lastIndex = length(sample)
      anovaGer[(1+firstIndex):(firstIndex+lastIndex),1] = sample
      anovaGer[(1+firstIndex):(firstIndex+lastIndex),2] = rep(as.numeric(data[k,"id"]),length(sample))
      
      firstIndex = firstIndex + length(sample)
      flag = 0
    }
    anovaGer$group <- as.factor(anovaGer$group)
    res.aov <- aov(T1 ~ group, data = anovaGer)
    multComparisons[j] = TukeyHSD(res.aov)
  }
  
  colnames(dataSite2plot) <- c('Site', 'Sphere', 'refT1', 'Mean')
  
  returnComparison <- list("dataSite" = dataSite2plot,
                           "ANOVA" = multComparisons)
  
  return(returnComparison)
}
