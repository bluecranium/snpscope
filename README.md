snpscope
========

* Computes overlap of SNPs with regulatory elements and exports to CSV or the UCSC Genome Browser

* Uses shiny to launch a web-based user interface. This interface allows either a CSV download or the creation of a UCSC Genome Browser session via the rtracklayer package.

## Installation
	library(devtools)
	install_github("snpscope", username="bluecranium")

## Running
	library(snpscope)
	runWebApp()