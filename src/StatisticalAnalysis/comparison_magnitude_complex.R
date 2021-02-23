comparison_magnitude_complex <- function(cases,listSpheres){
  pValues = data.frame()
  for (j in seq(1,14)){
    cnt <- 1
    for (k in cases){
      magData = as.numeric(unlist(listSpheres[[k[]]][j]))
      compData = as.numeric(unlist(listSpheres[[k+1]][j]))
      #Test for normality of data
      magnitudeNormTest = shapiro.test(magData)
      complexNormTest = shapiro.test(compData)
      #Test for equal variances
      eqVarTest = bartlett.test(list(magData,compData))
      #t-test with equal variances, unequal variances and non-parametric test (normality test failure)
      if (magnitudeNormTest[2]>0.05 && complexNormTest[2]>0.05 && eqVarTest[3]>0.05){
        tTest = t.test(magData,compData,var.equal = TRUE)
        pValues[cnt,j] = tTest[3]
      } else if (magnitudeNormTest[2]>0.05 && complexNormTest[2]>0.05 && eqVarTest[3]<0.05){
        tTest = t.test(magData,compData,var.equal = FALSE)
        pValues[cnt,j] = tTest[3]
      } else if (magnitudeNormTest[2]<0.05 || complexNormTest[2]<0.05) {
        wTest = wilcox.test(magData,compData, paired = FALSE)
        pValues[cnt,j] = wTest[3]
      }
      cnt = cnt + 1
    }
  }
  
  #test = magData[[25]][1] - compData[[25]][1]
  
  return(pValues)
}