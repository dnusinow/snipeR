download.missing.maps <- function(dbpath = "snipe_maps",
                                  permission.to.dl = NULL) {
  if( ! file.exists(dbpath) ) {
    tryCatch(dir.create(dbpath, recursive = TRUE))
  }
  cached.files <- dir(dbpath)

  ipi2ensp.needs.dl <- FALSE
  if( ! length(which(cached.files == "idmapping_selected.tab.gz")) ) {
    ipi2ensp.needs.dl <- TRUE
  }
  string.needs.dl <- FALSE
  if( ( ! length(grep("protein\\.links", cached.files)))
     | ( ! length(grep("protein\\.aliases", cached.files)))) {
    string.needs.dl <- TRUE
  }
  need.dl <- (ipi2ensp.needs.dl & string.needs.dl)
  
  if( ! need.dl ) {
    permission.to.dl <- FALSE
  }
  ## Ask permission to do this if necessary, or exit out
  while (is.null(permission.to.dl) & need.dl) {
    already.asked <- FALSE
    if ( already.asked == FALSE ) {
      alarm()
      cat("You appear to be missing data files necessary for snipeR to work. Some of these files are very big and can take a long time to download. snipeR can download them for you, or you can quit snipeR and install them yourself (see the documentation). Would you like snipeR to download them for you? Y/n ")
    } else {
      cat("Please answer Y/n ")
    }
    response <- readline()
    if ( response == "" |
        length(grep("^ye?s?", response, ignore.case = TRUE)) != 0 ) {
      permission.to.dl <- TRUE
    } else if ( length(grep("^no?", response, ignore.case = TRUE)) != 0 ) {
      permission.to.dl <- FALSE
    }
  }
  if (permission.to.dl == FALSE & need.dl == TRUE) {
    stop("Exiting. We don't have permission to download data. Please install by hand.\n")
  }
  
  if( ipi2ensp.needs.dl == TRUE & permission.to.dl == TRUE) {
    download.ipi2ensp(dbpath)
  }
  if( string.needs.dl == TRUE & permission.to.dl == TRUE) {
    download.string(dbpath)
  }
  TRUE
}
