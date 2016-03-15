string.aliases.to.sqlite <- function(dbpath, force.regen = FALSE) {
  if(file.info(dbpath)$isdir) {
    rawfiles <- dir(dbpath)
    string.file.name <- grep("protein\\.aliases", rawfiles, value = TRUE)[1]
    if ( is.null(string.file.name) ) {
      stop("String raw aliases file not found at", fpath, "\nPlease install it")
    } 
    fpath <- file.path(dbpath, string.file.name)
  } else {
    string.file.name <- basename(dbpath)
    fpath <- dbpath
    dbpath <- dirname(dbpath)
  }
  if(! file.exists(fpath)) {
    stop("String aliases file not found at", fpath, "\nPlease install it")
  }

  ## Ewwwwww
  string.version <- sub("\\.", "_",
                        sub(".txt", "",
                            sub(".txt.gz", "",
                                sub("protein.aliases.", "", string.file.name))))

  drv <- dbDriver("SQLite")
  sqlite.fname <- paste("string_aliases_", string.version, ".sqlite", sep = "")
  sqlite.fpath <- file.path(dbpath, sqlite.fname)

  if(file.exists(sqlite.fpath)) {
    if(!force.regen) {
      stop(paste("SQLite database already exists at", sqlite.fpath,
                 ". Not regenerating. Either delete the file manually or re-run this function with force.regen = TRUE)"))
    } else {
      if(unlink(sqlite.fpath)) {
        stop("Couldn't delete the old SQLite database.")
      }
    }
  }
  
  con <- dbConnect(drv, dbname = sqlite.fpath)

  if(length(grep("\\.gz$", string.file.name))) {
    file.con <- gzfile(fpath, open = "r")
  } else {
    file.con <- file(fpath, open = "r")
  }

  string.header <- readLines(con = file.con, n = 1)
  cur.species <- ""
  cur.table <- NULL
  i <- 0
  repeat {
    buf <- scan(file.con, what = list(species = "character", protein = "character",
                            alias = "character", source = "integer"),
                nmax = 10000, quiet = TRUE, sep = "\t", quote = NULL)

    if(length(buf) != 4) {
      stop("Buffer didn't scan out as a 4-length list")
    }
    
    if(length(buf$protein) == 0) {
      if(! is.null(cur.table)) {
        cur.table <- proc.string.alias.table(cur.table)
        if(nrow(cur.table) != 0) {
          ret <- dbWriteTable(con, paste("Species_", cur.species, sep = ""), cur.table)
        }
        break
      }
    }
    
    buf.table <- as.data.frame(do.call("cbind", buf))
    buf.table$species <- as.character(buf.table$species)
    found.species <- unique(buf.table$species)
    ## print(found.species)
    ## if((length(found.species) > 1) & (found.species[1] == "9606")) {
    ##   write.table(buf.table, "~/Desktop/Buffer_Dump.tsv", sep = "\t")
    ##   stop("Hit the breakpoint")
    ## }
    ## cat("Made buf.table\n")

    ## This if statement triggers if we happened to hit the last
    ## record of a given species on our previous read-in and now we're
    ## on a new species
    if((found.species[1] != cur.species) & (length(cur.table))) {
      cur.table <- proc.string.alias.table(cur.table)
      if(nrow(cur.table) != 0) {
        ret <- dbWriteTable(con, paste("Species_", cur.species, sep = ""), cur.table)
      }
      cur.table <- NULL
      i <- i + 1
    }

    ## In this case we've read across a boundary between species and
    ## need to write out the full species record and transition to
    ## processing the new one
    while(length(found.species) > 1) {
      tmp.buf.table <- subset(buf.table, species == cur.species)
      cur.table <- as.data.frame(rbind(cur.table, tmp.buf.table))
      cur.table <- proc.string.alias.table(cur.table)
      if(nrow(cur.table) != 0) {
        ret <- dbWriteTable(con, paste("Species_", found.species[1], sep = ""), cur.table)
      }
      cur.table <- NULL

      old.found.species <- found.species[1]
      found.species <- found.species[seq(2, length(found.species))]
      buf.table <- subset(buf.table, species != cur.species)
      ## print(found.species)
      i <- i + 1
    }
    cur.species <- found.species
    
    ## Here we've read in a number of records on our current species
    ## and need to simply append them and move on
    if(length(found.species) == 1) {    # Sanity check
      cur.species <- found.species
      cur.table <- as.data.frame(rbind(cur.table, buf.table))
      ## cat("Bound the table to the current table\n")
    } else {
      stop("There should be 1 and only 1 found species here. Instead we have something else.")
    }

    ## if(i == 5) {                        #DEBUGGING
    ##   close(file.con)
    ##   dbDisconnect(con)
    ##   return()
    ## }
  }

  close(file.con)
  dbDisconnect(con)
}
