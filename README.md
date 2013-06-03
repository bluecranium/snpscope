snpscope
========

* Computes overlap of SNPs with regulatory elements and exports to CSV or the UCSC Genome Browser

* Uses shiny to launch a web-based user interface. This interface allows either a CSV download or the creation of a UCSC Genome Browser session via the rtracklayer package.

## Installation
	library(devtools)
	options(repos=c("http://cran.rstudio.com","http://www.bioconductor.org/packages/release/bioc"))
	install_github("snpscope", username="bluecranium")

## Running
	library(snpscope)
	runWebApp()

## Notes

* Adding custom tracks from BED files and CSV Download of overlaps do not work from within the package yet

* Need to implement a file chooser so the path to the BED files can be set from the interface