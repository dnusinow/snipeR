Score.Chi <- function(x1, x2, y1, y2) {
  x <- x1 + x2
  y <- y1 + y2
  n1 <- x1 + y1
  n2 <- x2 + y2
  n <- x1 + x2 + y1 + y2
  m <- matrix(c(x1, y1, x2, y2), nrow = 2)

  chi <- 0
  E <- (x * n1) / n
  this.chi <- (x1 - E) / sqrt(E)
  chi <- chi + this.chi

  chi[which(is.nan(chi) | is.infinite(chi))] <- 0
  
  return(chi)
}
