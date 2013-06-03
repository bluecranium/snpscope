snpscope
========

* Computes overlap of SNPs with regulatory elements and export to CSV or the UCSC Genome Browser

* Uses shiny to launch a web-based user interface. This interface allows either a CSV download or the creation of a UCSC Genome Browser (http://genome.ucsc.edu/) via the rtracklayer package.

## Installation
	install.github(...)

## Running
	library(snpscope)
	runWebApp()