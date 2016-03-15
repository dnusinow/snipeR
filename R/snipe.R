snipe <- function(treatment, control,
                  njobs = 1, nperms.per.job = 1000000, species = 9606,
                  dbpath = "snipe_maps") {
  
  string <- read.string(dbpath, species)
  e2sym <- read.genemap(dbpath, species)
  syms <- e2sym$GeneSym[match(rownames(string), e2sym$ID)]
  desc <- e2sym$GeneDesc[match(rownames(string), e2sym$ID)]

  id.map <- read.idmap(dbpath, species)
  treat.obs <- read.proteomics(treatment, dbpath, species, string, id.map)
  control.obs <- read.proteomics(control, dbpath, species, string, id.map)  
  obs.scores <- as.vector(Score.Chi(as.vector(string %*% treat.obs),
                                    as.vector(string %*% control.obs),
                                    sum(treat.obs), sum(control.obs)))
  
  obs.sizes <- as.vector(treat.obs + control.obs)
  treat.obs.sum <- sum(treat.obs)
  control.obs.sum <- sum(control.obs)

  nperms <- njobs * nperms.per.job
  p <- treat.obs.sum / (treat.obs.sum + control.obs.sum)

  scores <- foreach(1:njobs, .combine = cbind) %dopar% {    
    greater.than.obs <- matrix(data = 0, nrow = nrow(string), ncol = 1)
    best.scores <- vector(length = nperms.per.job, mode = "numeric")
    
    for(i in 1:nperms.per.job) {
      treatment.perm <- rbinom(nrow(string), size = obs.sizes, prob = p)
      control.perm <- obs.sizes - treatment.perm
      perm.scores <- Score.Chi(as.vector(string %*% treatment.perm),
                               as.vector(string %*% control.perm), 
                               treat.obs.sum, control.obs.sum)
      
      idx <- which(perm.scores >= obs.scores)
      greater.than.obs[idx] <- greater.than.obs[idx] + 1
      
      best.scores[i] <- max(perm.scores)
    }
    retval <- c(greater.than.obs, best.scores)
  }

  greater.than.obs <- vector(length = length(nrow(string)), mode = "numeric")
  best.scores <- c()
  if(class(scores) != "list") {
    scores <- cbind(scores)
  }
  for(i in 1:ncol(scores)) {
    greater.than.obs <- greater.than.obs + scores[1:nrow(string), i]
    start.idx <- nrow(string) + 1
    end.idx <- length(scores[,i])
    best.scores <- c(best.scores, scores[start.idx:end.idx, i])
  }
  uncorrected.pvalues <- greater.than.obs / nperms
  corrected.pvalues <- sapply(obs.scores, function(score) {
    (length(which(score <= best.scores))) / length(best.scores)
  })

  ## Assemble output
  out <- cbind(rownames(string), syms, desc,
               as.vector(treat.obs), as.vector(control.obs),
               obs.scores, 
               uncorrected.pvalues, corrected.pvalues)
  colnames(out) <- c("Ensembl", "GeneSymbol", "GeneDescription",
                     "Treatment Observed Count",
                     "Control Observed Count",
                     "Observed Chi Score", 
                     "Uncorrected P-Value", "Corrected P-Value")
  out <- out[order(as.numeric(out[,8]), as.numeric(out[,7]), out[,2], out[,1]),]
}
