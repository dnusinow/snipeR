read.genemap <- function(dbpath, species) {
  drv <- dbDriver("SQLite")
  if(file.info(dbpath)$isdir) {
    rawfiles <- dir(dbpath)
    string.file.names <- grep("string_aliases.*\\.sqlite", rawfiles, value = TRUE)
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
  genemap <- fetch(rs, n = -1)
  dbClearResult(rs)
  dbDisconnect(con)
  
  return(genemap)
}


## read.genemap <- function(dbpath, species) {
##   dbfiles <- dir(dbpath)
##   string.aliases.file.name <- grep("protein\\.aliases", dbfiles, value = TRUE)[1]
##   if ( is.null(string.aliases.file.name) ) {
##     stop("String Aliases File not found at", fpath, "\nPlease install it")
##   } 
##   aliases.fpath <- file.path(dbpath, string.aliases.file.name)
##   if(! file.exists(aliases.fpath)) {
##     stop("String Aliases File not found at", aliases.fpath, "\nPlease install it.")
##   }
##   species.regex <- paste("^", species, sep = "")

##   tmp.map <- NULL
##   species.found <- FALSE
##   file.con <- gzfile(aliases.fpath, open = "r")
##   repeat {
##     buf <- scan(file.con, what = "character", sep = "\n", nmax = 10000,
##                 quiet = TRUE)
##     if(length(buf) == 0) { break }
    
##     buf <- grep(species.regex, buf, value = TRUE)
##     if(length(buf) > 0) {
##       species.found <- TRUE
##       records <- lapply(strsplit(buf, "\t"), handle.alias.record,
##                         species = species)
##       tmp.map <- c(tmp.map, records)
##     }
##     else if(species.found == TRUE) { break }
##   }
##   close(file.con)

##   first.rec <- unlist(tmp.map[1])
##   alias.map <- data.frame(ID = as.character(first.rec[1]),
##                           GeneSym = as.character(first.rec[2]),
##                           GeneDesc = as.character(first.rec[3]),
##                           stringsAsFactors = FALSE)
##   for( i in 2:length(tmp.map) ) {
##     rec <- unlist(tmp.map[i])
##     rec[1] <- as.character(rec[1])
##     rec[2] <- as.character(rec[2])
##     rec[3] <- as.character(rec[3])
##     if ( rec[1] == "" ) {
##       next
##     }
##     idx <- which(alias.map[,1] == rec[1])
##     if ( length(idx) > 1 ) {            # Sanity check
##       stop("Something has gone wrong with building the gene symbol map. Too many of the same id's for ", tmp.map[i,1], "\n")
##     }
##     if ( length(idx) == 0 ) {
##       alias.map <- rbind(alias.map, rec)
##     } else {
##       if ( alias.map[idx,2] == "" ) {
##         alias.map[idx,2] <- rec[2]
##       }
##       if ( alias.map[idx,3] == "" ) {
##         alias.map[idx,3] <- rec[3]
##       }
##     }
##   }
  
##   return(alias.map)
## }
