## read.explicit.string is a utility function for testing. Not to be
## generally used. It assumes that the file format is a simple one
## with no header and no species prefix on the ID's. Each line is tab
## separated with the values being protein1, protein2, and a score of
## some sort.
read.explicit.string <- function(spath, cutoff = NULL) {
  string.df <- read.delim(spath, stringsAsFactors = FALSE)
  names(string.df) <- c("protein1", "protein2", "score")

  if(! is.null(cutoff)) string.df <- subset(string.df, score >= cutoff)

  string.nodes <- unique(string.df$protein1)
  string.nnodes <- length(string.nodes)
  string <- Matrix(data = 0, ncol = string.nnodes, nrow = string.nnodes,
                   sparse = TRUE)
  rownames(string) <- string.nodes
  colnames(string) <- string.nodes
  string[cbind(1:string.nnodes, 1:string.nnodes)] <- 1
  string[cbind(match(string.df$protein1, string.nodes),
               match(string.df$protein2, string.nodes))] <- 1
  return(string)
}
