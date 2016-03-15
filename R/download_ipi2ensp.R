download.ipi2ensp <- function(dbpath) {
  ipi2ensp.url <- "ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz"
  ret <- download.file(ipi2ensp.url,
                       file.path(dbpath, "idmapping_selected.tab.gz"))
  if (ret != 0) {
    stop("Could not download idmapping_selected.tab.gz from", ipi2ensp.url,
         "\nPlease install by hand.")
  }
}
