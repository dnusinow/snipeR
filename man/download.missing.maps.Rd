\name{download.missing.maps}
\alias{download.missing.maps}
\title{Download ID Maps For snipeR}
\description{
  snipeR requires several data files including the STRING network
  database and files to map between different ID types. This function
  will download any missing files to a local directory.
}
\usage{
download.missing.maps(dbpath = "snipe_maps")
}
\arguments{
  \item{dbpath}{The path to the directory where the data files will be
	downloaded. Defaults to "snipe_maps"}
}
\details{
  Several files must be downloaded for snipeR to work. If necessary, a new
  directory in dbpath will be created and files will be downloaded to
  there. If you have previously downloaded these files you may copy or
  symlink them to this location so you don't have to re-download
  them. This can save many hours of time, and we recommend it.
  
  Because these files can be quite large, it can take several hours to
  finish downloading even on a fast connection. As a result, if
  download.missing.maps has to download several files it will require
  confirmation before it downloads or else it will exit the
  program. This will provide you the opportunity to copy or symlink
  pre-downloaded files to the dbpath (or point dbpath at an old
  download).

  Note that this function will be called by \code{\link{snipe}} so
  access to it is mainly provided so that you can pre-cache the data files.
}
\value{
  Returns \code{TRUE} if everything succeeded.
}
\author{
  David Nusinow \email{dnusinow@partners.org}
}
\seealso{
  \code{\link{snipe}}, \code{\link{string.raw.to.sqlite}}, \code{\link{string.aliases.to.sqlite}}.
}
\examples{
\dontrun{download.missing.maps()}
\dontrun{download.missing.maps(dbpath = "~/string_maps")}
}
\keyword{cluster}