read.string <- function(dbpath, species) {
  ## dbfiles <- dir(dbpath)
  ## string.file.name <- grep("protein\\.links", dbfiles, value = TRUE)[1]
  ## if ( is.null(string.file.name) ) {
  ##   stop("String DB not found at", fpath, "\nPlease install it")
  ## } 
  ## fpath <- file.path(dbpath, string.file.name)
  ## if(! file.exists(fpath)) {
  ##   stop("String DB not found at", fpath, "\nPlease install it")
  ## }
  ## species.regex <- paste("^", species, "\\.", sep = "")
  ## string.list <- NULL
  ## species.found <- FALSE

  ## if(length(grep("\\.gz$", string.file.name))) {
  ##   file.con <- gzfile(fpath, open = "r")
  ## } else {
  ##   file.con <- file(fpath, open = "r")
  ## }
  ## repeat {
  ##   buf <- scan(file.con, what = list(protein1 = "character",
  ##                           protein2 = "character", score = "integer"),
  ##               nmax = 10000, quiet = TRUE)
  ##   bufsel <- grep(species.regex, buf$protein1)
  ##   if(length(bufsel) > 0) {
  ##     species.found <- TRUE
  ##     tmp.buf <- cbind(buf$protein1, buf$protein2, buf$score)
  ##     if(is.null(string.list)) {
  ##       string.list <- tmp.buf[bufsel,]
  ##     }
  ##     else {
  ##       string.list <- rbind(string.list, tmp.buf[bufsel,])
  ##     }
  ##   }
  ##   else if(species.found == TRUE) { break }
  ##   if(length(buf$protein1) == 0) { break }
  ## }
  ## close(file.con)

  drv <- dbDriver("SQLite")
  if(file.info(dbpath)$isdir) {
    rawfiles <- dir(dbpath)
    string.file.names <- grep("string_links.*\\.sqlite", rawfiles, value = TRUE)
    string.file.name <- tail(string.file.names, 1)
    if ( is.null(string.file.name) ) {
      stop("SQLite database not found at", fpath, "\nPlease install it")
    } 
    fpath <- file.path(dbpath, string.file.name)
  } else {
    string.file.name <- basename(dbpath)
    fpath <- dbpath
    dbpath <- dirname(dbpath)
  }
  if(! file.exists(fpath)) {
    stop("STRING SQLite database not found at", fpath, "\nPlease run the string.raw.to.sqlite function on the downloaded STRING protein.links file.")
  }

  con <- dbConnect(drv, dbname = fpath)
  table.name <- paste("Species_", species, sep = "")
  rs <- dbSendQuery(con, paste("select * from", table.name))
  string.list <- fetch(rs, n = -1)
  dbClearResult(rs)
  dbDisconnect(con)

  ## string.list <- as.data.frame(string.list)
  ## names(string.list) <- c("protein1", "protein2", "score")
  ## string.list$protein1 <- sub(species.regex, "", string.list$protein1)
  ## string.list$protein2 <- sub(species.regex, "", string.list$protein2)  
  
  string.nodes <- unique(sort(c(string.list$protein1, string.list$protein2)))
  string.nnodes <- length(string.nodes)
  string <- Matrix(data = 0, ncol = string.nnodes, nrow = string.nnodes,
                   sparse = TRUE)
  rownames(string) <- string.nodes
  colnames(string) <- string.nodes
  string[cbind(1:string.nnodes, 1:string.nnodes)] <- 1
  string[cbind(match(string.list$protein1, string.nodes),
               match(string.list$protein2, string.nodes))] <- 1
  return(string)
}
