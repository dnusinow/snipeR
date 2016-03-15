# Installation

## Installing the R Packages

snipeR is provided as an R package. This may be installed using the
UNIX shell command

```
R CMD INSTALL snipeR_0.7.6.tar.gz
```

You may need to use the `-l` option to specify where R installs the
package to. See the manual
[R Installation and Administration](https://cran.r-project.org/doc/manuals/r-release/R-admin.html)
that comes with the R distribution.  You will also need to have
installed several external R packages including:

* Matrix (standard with R)
* foreach
* optparse
* stringr
* doMC
* RSQLite

We recommend using R's `install.packages()` function for this. If you
aren't familiar with this function, simply copy and paste the
following line of code in to your R session and after asking you which
mirror to use it'll install the packages for you:

```
install.packages(c("Matrix", "foreach", "optparse", "stringr", "doMC", "RSQLite"))
```

## Installing the Necessary Databases

Once you have installed the package you need to download the necessary
database files. The easiest way to do this is to use the
`download.missing.maps()` function provided with the package. Provide
this with a single optional path to where you want the downloaded
files to go and it will do the rest. Beware, some of these files (most
notably STRING) are quite large and can take a very long time to
download. If you would prefer to download these files by hand, you
will need:

* `protein.links.v8.x.txt.gz` and `protein.aliases.v8.x.txt.gz` from the [Downloads section](http://string.embl.de/newstring_cgi/show_download_page.pl?UserId=1OMrtvO2r30T&sessionId=nmQuP4DFRYIu) of the [STRING homepage](http://string.embl.de/). For the paper we used version 8.2, which can be found at http://string82.embl.de/

* [idmapping_selected.tab.gz](ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz) from [UniProt](http://www.uniprot.org/).

If you do download these files by hand then you'll need to run the
`string.aliases.to.sqlite()` and `string.raw.to.sqlite()` functions to
process these files in to SQLite databases. Each of these functions
requires only a single parameter: the location of the downloaded files
to be processed (either the path to the file itself or the directory
it is housed in.) You will need permissions to write to this
directory, as that is where the SQLite database is created. Please see
the documentation for these functions, included in the snipeR package
as standard R help files, for more detail.

# Usage

This is more fully documented in the R help for the `snipe()`
function. `snipe()` requires both a treatment and control data frame
for comparison, which can be passed directly to the function as
parameters. Alternatively, you may supply `snipe()` with paths to
tab-delimited text files for the treatment and control samples
containing the spectral counts and protein ID's. Ensembl Protein IDs
(STRING's native encoding) and IPI ID's are currently supported. You
will also need to supply a species taxonomy ID (i.e. 9606 for humans,
10090 for mouse) and a path to the location of the downloaded files
listed above. Other useful parameters include the path to the location
of various downloaded and processed database files (see Installation
above).

To adjust the sensitivity of the calculated p-values, you may supply a
number for permutations to be performed for each
protein. Additionally, you may speed performance on multicore UNIX
machines by supplying a number of jobs to split the load into. The
number of permutations is per-job, so if you want a million
permutations split across 10 CPUs, use 10 jobs and 100,000
permutations per job. This will not currently work across a cluster,
only on a local multicore machine.

The `snipe()` function returns a data frame that contains the output
of interest. This data frame can easily be written to disk using a
standard R command such as `write.table()`. We provide a shell script
named `snipe` in the snipeR directory that can be used as an example
for how to use the package. This has not been extensively tested, and
so should be primarily considered as a usage example.

Note also that we have not completed porting the program to Windows,
nor have we tested it on a MacOSX system. Although snipeR should
theoretically work on both of these systems, we can only say that it
works on Linux with any reasonable confidence right now.  

# Reproducing The SNIPE Paper

For the paper, the spectral counts for each replicate in each class
were summed to generate specific Tooth Germ and Oral Tissue files that
were then passed in to snipeR. To create these files easily we
recommend R's `merge()` function to match up the IPI ID's followed by
some simple summing and cleaning of the data. However, to speed this
process we have included these data in the snipeR distribution as data
frames that may be loaded in to R using the `data()` function passing
it name Tooth_Proteins. See the examples included in the help
documentation for the `snipe()` function for code to reproduce this
work.
