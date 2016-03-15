read.idmap <- function(dbpath, species) {
  dbfiles <- dir(dbpath)
  ipi2ensp.file.name <- dbfiles[which(dbfiles == "idmapping_selected.tab.gz")[1]]
  if ( is.null(ipi2ensp.file.name) ) {
    stop("Could not find file at", fpath, "\nPlease install it")
  }
  fpath <- file.path(dbpath, ipi2ensp.file.name)
  if (! file.exists(fpath)) {
    stop("Could not find file at", fpath, "\nPlease install it")
  }
  species.idx <- 14
  ipi.idx <- 8
  ensp.idx <- 22
  ipi2ensp <- NULL
  all.selmap <- NULL
  file.con <- gzfile(fpath, open = "r")
  repeat {
    buf <- scan(file.con, what = "character", sep = "\n",
                nmax = 100000, quiet = TRUE)
    buf <- grep(paste(as.character(species), "\\t", sep = ""),
                      buf, value = TRUE)
    if(length(buf) == 0) { break }
    selmap <- t(sapply(strsplit(buf, "\t"),
                       function(rec) {
                         rec[c(species.idx, ipi.idx, ensp.idx)] }))
    selmap <- selmap[selmap[,1] == species,]
    if(length(selmap[,1]) == 0) { next }
    all.selmap <- rbind(all.selmap, selmap)
  }
  close(file.con)

  
  for(l in 1:length(all.selmap[,1])) {
    ipis <- unique(unlist(Filter(function(s) {s != ""},
                                 strsplit(all.selmap[l,2], "; *"))))
    ensps <- unique(unlist(Filter(function(s) {s != ""},
                                  strsplit(all.selmap[l,3], "; *"))))
    if(is.null(ipis) | is.null(ensps)) { next }

    ## This crazy line creates all permutations
    mapfrag <- cbind(as.vector(replicate(length(ensps), ipis))[order(as.vector(replicate(length(ensps), 1:length(ipis))))],
                     ensps[as.vector(replicate(length(ipis), 1:length(ensps)))])
    ipi2ensp <- rbind(ipi2ensp, mapfrag)
  }
  
  ipi2ensp <- as.data.frame(ipi2ensp)
  names(ipi2ensp) <- c("IPI", "Ensembl")
  return(ipi2ensp)
}
