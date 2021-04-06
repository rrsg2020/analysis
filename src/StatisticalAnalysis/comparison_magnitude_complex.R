comparison_magnitude_complex <- function(cases,listSpheres){
  pValues = data.frame()
  meanMag = data.frame()
  meanComp = data.frame()
  diff_Mag_Comp <- data.frame()
  diff_Perc_Mag_Comp <- data.frame()
  cnt <- 1
  for (j in seq(1,length(cases))){
    for (k in seq(1,14)){
      magData = as.numeric(unlist(listSpheres[[cases[j]]][k]))
      compData = as.numeric(unlist(listSpheres[[cases[j]+1]][k]))
      
      meanMag[k,j] = mean(magData)
      meanComp[k,j] = mean(compData)
      
      ##DIFERENCE BETWEEN MAGNITUDE AND COMPLEX
      diff_Mag_Comp[k,j] = mean(magData) - mean(compData)
      diff_Perc_Mag_Comp[k,j] = 100*abs(mean(magData) - mean(compData))/mean(magData)
      
      ##STATISTICAL TESTS (COMPARE MEANS)
      #Test for normality of data
      magnitudeNormTest = shapiro.test(magData)
      complexNormTest = shapiro.test(compData)
      #Test for equal variances
      eqVarTest = bartlett.test(list(magData,compData))
      #t-test with equal variances, unequal variances and non-parametric test (normality test failure)
      if (magnitudeNormTest[2]>0.05 && complexNormTest[2]>0.05 && eqVarTest[3]>0.05){
        tTest = t.test(magData,compData,var.equal = TRUE)
        pValues[cnt,k] = tTest[3]
      } else if (magnitudeNormTest[2]>0.05 && complexNormTest[2]>0.05 && eqVarTest[3]<0.05){
        tTest = t.test(magData,compData,var.equal = FALSE)
        pValues[cnt,k] = tTest[3]
      } else if (magnitudeNormTest[2]<0.05 || complexNormTest[2]<0.05) {
        wTest = wilcox.test(magData,compData, paired = FALSE)
        pValues[cnt,k] = wTest[3]
      }
    }
    
    phantomTemperature = as.numeric(data[j,"phantom.temperature"])
    phantomVersion = as.numeric(data[j,"phantom.version"])
    if (phantomVersion<42){
      refT1 = temperature_correction(phantomTemperature,phantomVersion)
    } else {
      refT1 = temperature_correction(phantomTemperature,phantomVersion)
    }
    
    id = data[cases[j],"id"]
    sid <- as.matrix(rep(id,14))
    sph <- as.matrix(1:14)
    t1 <- as.matrix(refT1)
    
    ##CORRELATION ANALYSIS
    corrTest <- cor.test(meanMag[,j], meanComp[,j], method = 'pearson')
    Pearson_test <- data.frame(id, corrTest$estimate, corrTest$p.value)
    
    #DIFFERENCE AND PERCENTAGE DIFFERENCE
    data_Mag_Comp <- data.frame(sid, sph, t1, diff_Mag_Comp[,j], diff_Perc_Mag_Comp[,j])
    corr_Mag_Comp <- data.frame(sid, sph, meanMag[,j], meanComp[,j])
    
    if (j==1){
      dataTmp = rbind(data.frame(), data_Mag_Comp)
      corrTmp = rbind(data.frame(), corr_Mag_Comp)
      PearsonTmp = rbind(data.frame(), Pearson_test)
    }
    else{
      dataComparison = rbind(dataTmp, data_Mag_Comp)
      dataCorrelation = rbind(corrTmp, corr_Mag_Comp)
      dataPearson = rbind(PearsonTmp, Pearson_test)
      dataTmp <- dataComparison
      corrTmp <- dataCorrelation
      PearsonTmp <- dataPearson
    }
  }
  
  colnames(dataComparison) <- c('sid', 'sph', 'refT1', 'diff', 'percDiff')
  colnames(dataCorrelation) <- c('sid', 'sph', 'Magnitude', 'Complex')
  colnames(dataPearson) <- c('Site', 'R', 'p-Value')
  
  returnComparison <- list("dataMagComp" = dataComparison,
                           "dataCorr" = dataCorrelation,
                           "PearsonCorr" = dataPearson,
                           "pValues" = pValues)
  
  return(returnComparison)
}