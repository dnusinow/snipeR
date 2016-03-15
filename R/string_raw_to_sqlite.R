string.raw.to.sqlite <- function(dbpath = "snipe_maps", force.regen = FALSE) {
  if(file.info(dbpath)$isdir) {
    rawfiles <- dir(dbpath)
    string.file.name <- grep("protein\\.links", rawfiles, value = TRUE)[1]
    if ( is.null(string.file.name) ) {
      stop("String raw file not found at", fpath, "\nPlease install it")
    } 
    fpath <- file.path(dbpath, string.file.name)
  } else {
    string.file.name <- basename(dbpath)
    fpath <- dbpath
    dbpath <- dirname(dbpath)
  }
  if(! file.exists(fpath)) {
    stop("String raw file not found at", fpath, "\nPlease install it")
  }

  ## Ewwwwww
  string.version <- sub("\\.", "_",
                        sub(".txt", "",
                            sub(".txt.gz", "",
                                sub("protein.links.", "", string.file.name))))

  drv <- dbDriver("SQLite")
  sqlite.fname <- paste("string_links_", string.version, ".sqlite", sep = "")
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
    buf <- scan(file.con, what = list(protein1 = "character",
                            protein2 = "character", score = "integer"),
                nmax = 10000, quiet = TRUE)

    if(length(buf$protein1) == 0) {
      if(! is.null(cur.table)) {
        species.regex <- paste("^", cur.species, "\\.", sep = "")
        cur.table$protein1 <- sub(species.regex, "", cur.table$protein1)
        cur.table$protein2 <- sub(species.regex, "", cur.table$protein2)
        ret <- dbWriteTable(con, paste("Species_", cur.species, sep = ""), cur.table)
        break
      }
    }
    
    found.species <- unique(sapply(strsplit(buf$protein1, "\\."), function(x) { x[[1]] }))
    buf.table <- as.data.frame(do.call("cbind", buf))

    ## This if statement triggers if we happened to hit the last
    ## record of a given species on our previous read-in and now we're
    ## on a new species
    if((found.species[1] != cur.species) & (length(cur.table))) {
      species.regex <- paste("^", cur.species, "\\.", sep = "")
      cur.table$protein1 <- sub(species.regex, "", cur.table$protein1)
      cur.table$protein2 <- sub(species.regex, "", cur.table$protein2)
      ret <- dbWriteTable(con, paste("Species_", cur.species, sep = ""), cur.table)
      cur.table <- NULL
      i <- i + 1
    }

    ## In this case we've read across a boundary between species and
    ## need to write out the full species record and transition to
    ## processing the new one
    while(length(found.species) > 1) {
      species.regex <- paste("^", found.species[1], "\\.", sep = "")
      tmp.buf.table <- buf.table[grep(species.regex, buf.table$protein1),]
      cur.table <- as.data.frame(rbind(cur.table, tmp.buf.table))
      cur.table$protein1 <- sub(species.regex, "", cur.table$protein1)
      cur.table$protein2 <- sub(species.regex, "", cur.table$protein2)  
      ret <- dbWriteTable(con, paste("Species_", found.species[1], sep = ""), cur.table)
      cur.table <- NULL

      old.found.species <- found.species[1]
      old.species.regex <- species.regex
      found.species <- found.species[seq(2, length(found.species))]
      species.regex <- paste("^", found.species[1], "\\.", sep = "")
      buf.table <- buf.table[which(! (grep(old.species.regex, buf.table$protein1) %in% seq(1, nrow(buf.table))))]
      ## buf.table <- buf.table[grep(species.regex, buf.table$protein1),]
      print(found.species)
      i <- i + 1
    }
    cur.species <- found.species
    
    ## Here we've read in a number of records on our current species
    ## and need to simply append them and move on
    if(length(found.species) == 1) {    # Sanity check
      cur.species <- found.species
      cur.table <- as.data.frame(rbind(cur.table, buf.table))
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
