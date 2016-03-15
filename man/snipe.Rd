\name{snipe}
\alias{snipe}
\title{Run SNIPE Analysis}
\description{
  Run SNIPE analysis on a pair of data sets. Can split the calculation
  load amongst multiple cores on a single machine.
}
\usage{
snipe(treatment, control, species, njobs = 1, nperms.per.job = 1000000, dbpath = "snipe_maps")
}
\arguments{
  \item{treatment}{Path to the file containing the treatment data.}
  \item{control}{Path to the file containing the control data.}
  \item{species}{NCBI Taxon ID for the species the data applies to.}
  \item{njobs}{Number of jobs to divide the work in to.}
  \item{nperms.per.job}{Number of permutations per job to run.}
  \item{dbpath}{Pathway to databases including STRING and ID maps.}
}
\details{
}
\value{
  Returns a table containing the following fields: Ensembl Protein ID
  (from STRING), Official Gene Symbol, Protein Description, Observed
  Spectral Count in the treatment, Observed spectral count in the
  control, Observed Chi score, uncorrected p-value, and multiple test
  corrected p-value.
}
\author{
  David Nusinow \email{dnusinow@partners.org}
}
\seealso{
  \code{\link{download.missing.maps}}
}
\examples{
data("Tooth_Proteins")
\dontrun{snipe.out <- snipe(treatment = tooth_germ, control= oral_tissue, njobs = 5, nperms.per.job = 200000, species = 10090, dbpath = "~/nethome/data/snipe_maps")}
}
\keyword{cluster}