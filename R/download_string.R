download.string <- function(dbpath) {
  if( ! require(stringr) ) {
    stop("Could not load the stringr library. Please load it or download and install STRING by hand\n")
  }
  dl.page.con <- url("http://string.embl.de/newstring_cgi/show_download_page.pl")
  dl.page.lines <- readLines(dl.page.con)
  close(dl.page.con)
  dl.line <- grep("protein\\.links\\.v", dl.page.lines, value = TRUE)[[1]]
  string.links.url <- sub('"', "", str_extract(dl.line, "http://string\\.embl\\.de.*protein\\.links\\.v.\\..\\.txt\\.gz\""))
  string.file.name <- str_extract(string.links.url, "protein\\.links.*gz")
  ret <- download.file(string.links.url, file.path(dbpath, string.file.name))
  if (ret != 0) {
    stop("Could not download STRING from", string.links.url,
         "\nPlease install by hand.")
  }
  string.raw.to.sqlite(dbpath, force.regen = TRUE)

  dl.line <- grep("protein\\.aliases\\.v", dl.page.lines, value = TRUE)[[1]]
  string.links.url <- sub('"', "", str_extract(dl.line, "http://string\\.embl\\.de.*protein\\.aliases\\.v.\\..\\.txt\\.gz\""))
  string.aliases.file.name <- str_extract(string.links.url, "protein\\.aliases.*gz")
  ret <- download.file(string.links.url, file.path(dbpath,
                                                   string.aliases.file.name))
  if (ret != 0) {
    stop("Could not download STRING Aliases from", string.links.url,
         "\nPlease install by hand.")
  }
  string.aliases.to.sqlite(dbpath, force.regen = TRUE)
}
