\name{string.aliases.to.sqlite}
\alias{string.aliases.to.sqlite}
\title{Convert STRING Links Aliases Flat File in to SQLite Tables}
\description{
  snipeR utilizes STRING in the form of a local SQLite table in order to
  speed program startup. This function takes the path to the aliases file
  downloaded from the STRING website and outputs a SQLite database for
  use by snipeR.
}
\usage{
string.aliases.to.sqlite(dbpath = "snipe_maps", force.regen = TRUE)
}
\arguments{
  \item{dbpath}{The path to the directory where the data files have been
	downloaded. The SQLite database is also created here. Defaults to
	"snipe_maps"}
  \item{force.regen}{Boolean that determines if, given that the SQLite
  database already exists, it should be deleted and a new one
  generated. This provides a safety check against destroying an already
  existing database and having to wait for a potentially lengthy
  processing operation to generate the new one. Defaults to \code{FALSE}.}
}
\details{
  snipeR requires the STRING database to be accesible. Because this
  database is distributed as a flat list of aliases for all species
  and sources, this
  can be a very large file to parse each time the \code{\link{snipe}}
  function is called. To speed up the process, snipeR expects this file
  to be processed in to a local relational SQLite database where each
  species-specific table includes only the gene symbol and long protein description
  mapped to each IPI ID. This function takes a
  path to either the string links file itself or the directory where it
  is stored and will output a SQLite database in the same
  directory. This means that the \code{dbpath} directory needs to be
  writable for the user.
}
\value{
  Returns \code{TRUE} if everything succeeded.
}
\author{
  David Nusinow \email{dnusinow@partners.org}
}
\seealso{
  \code{\link{snipe}}, \code{\link{download.missing.maps}}, \code{\link{string.raw.to.sqlite}}.
}
\examples{
\dontrun{string.aliases.to.sqlite(dbpath = "~/data/snipe_maps")}
\dontrun{string.aliases.to.sqlite(dbpath = "~/data/snipe_maps", force.regen = TRUE)}
}
\keyword{cluster}