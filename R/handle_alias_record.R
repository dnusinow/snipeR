handle.alias.record <- function(rec, species) {
  sym.regex <- "Ensembl_UniProt_GN"
  prot.regex <- "Ensembl_UniProt_DE"
  species.idx <- 1
  id.idx <- 2
  alias.idx <- 3
  source.idx <- 4
  
  new.rec <- c("", "", "")
  if ( rec[species.idx] != species ) {
    return(new.rec)
  }

  if ( length(grep(sym.regex, rec[source.idx])) != 0 ) {
    new.rec[1] <- rec[id.idx]
    new.rec[2] <- rec[alias.idx]
  }
  if ( length(grep(prot.regex, rec[source.idx])) != 0 ) {
    new.rec[1] <- rec[id.idx]
    new.rec[3] <- rec[alias.idx]
  }
  return(new.rec)
}
