read.proteomics <- function(fpath, dbpath, species, string, id.map) {
  if(is.data.frame(fpath)) {
    proteomics <- fpath
  } else {
    proteomics <- read.delim(fpath, stringsAsFactors = FALSE)
  }
  
  id.idx <- grep("reference|ipi|id|gene", names(proteomics), ignore.case = TRUE)[1]
  count.idx <- grep("count|total", names(proteomics), ignore.case = TRUE)[1]
  source.ids <- proteomics[,id.idx]
  id.type <- "ensp"
  ens.ids <- source.ids
  ## Translate ID's if need be. If not, assume it's in enembl proteins
  if ( length(grep("IPI", source.ids[1])) != 0 ) {
    id.type <- "ipi"
    source.ids <- gsub("^IPI:", "", source.ids)
    source.ids <- gsub("\\..?$", "", source.ids)
    ens.ids <- sapply(source.ids, function(ipi) {
      ens <- id.map$Ensembl[id.map$IPI == ipi]
      ens <- grep("^HAVANA", ens, value = TRUE, invert = TRUE)
      ens[1]
    })
  }

  ## Remove non-matches
  nomatch.idx <- which(is.na(match(ens.ids, rownames(string))))
  proteomics <- proteomics[- nomatch.idx,]
  ens.ids <- ens.ids[- nomatch.idx]
  
  ## Assign counts to their locations matching STRING and return
  ens.idxs <- match(ens.ids, rownames(string))
  counts <- matrix(data = 0, ncol = 1, nrow = nrow(string))
  counts[ens.idxs] <- proteomics[,count.idx]
  matrix(sapply(counts, function(x) x))
}
