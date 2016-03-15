library('Matrix')
library('foreach')
library('RSQLite')

.onLoad <- function(libname, pkgname) {
  has.backend <- tryCatch({times(2) %dopar% rnorm(1)}, warning = function(ex) { return(FALSE) })
  if( ! has.backend) {
    backend <- library(doMC, logical.return = TRUE)
    if(backend) {
      library('doMC')
      registerDoMC()
      backend <- "doMC"
      cat("Loading done.\n")
    } else {
      backend <- library(doSMP, logical.return = TRUE)
      if(backend) {
        library('doSMP')
        registerDoSMP()
        backend <- "doSMP"
      }
    }
  }
}
