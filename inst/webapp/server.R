library(shiny)
library(rtracklayer)
library(NCBI2R)
library(stringr)
library(reshape)
library(plyr)

shinyServer(function(input, output) {

	rv <- reactiveValues(status="Ready: Choose options and press \"Create\"")

	output$status <- renderText({
		rv$status
	})

	runcount <- 0

	# Reactive Handler for Download CSV Button
  	output$csv <- downloadHandler(
    	filename = "summary.csv",
    	contentType="text/plain",
   		content = function(file) {
   			trackList <- list()

			# Get map locations for input SNP set
			tags <- unlist(str_split(isolate(input$snps),","))
			print(class(tags))
			tags <- str_replace(tags," ", "")

			ncbi.tags <- AnnotateSNPList(tags)
			trackList["QuerySNPs"] <- with(ncbi.tags, GRanges(seqnames=paste("chr",chr,sep=""), ranges=IRanges(start=chrpos, end=chrpos), name=marker))

			# Add SNPs in LD with the queries
			if(isolate(input$ld)==TRUE)
			{
				for(tag in tags)
				{
					ncbi.ld <- GetSNPProxyInfo(tag, FlankingDistance=isolate(input$flank), method="r2", keepmode=3, pop=isolate(input$pop), showurl=TRUE)
					#print(ncbi.ld)
					ncbi.ld <- ncbi.ld[ncbi.ld$r2 >= isolate(input$r2),]
					ld.snps <- unique(c(ncbi.ld$SNPA, ncbi.ld$SNPB))
					print(ld.snps)
					# Obtain hg19 map positions for the SNPs
					ncbi.out <- AnnotateSNPList(ld.snps)
					ld.name <- paste(tag,"LD",isolate(input$r2),sep="-")
					trackList[ld.name] <- with(ncbi.out, GRanges(seqnames=paste("chr",chr,sep=""), ranges=IRanges(start=chrpos, end=chrpos), name=marker))
				}
			}

			# Make one master list of SNPs and turn it into a GRanges
			snps.gr <- GRanges()
			for(i in 1:length(trackList))
			{
				snps.gr <- c(snps.gr, trackList[[i]])
			}

			# Load Up the BEDs to intersect with
			trackList <- list()

			beds.path <- dir("custom_tracks", full.names=TRUE)
			beds.names <- dir("custom_tracks")

			for(i in 1:length(beds.names))
			{
				#awk '{OFS="\t"; print $2,$3+1,$4,$5}' disabled_tracks/wgEncodeRegDnaseClusteredV2.bed > custom_tracks/dnase.bed
				# Load and import BED
				bed.table <- read.table(file=beds.path[i], sep="\t", header=FALSE, skip=1, stringsAsFactors=FALSE)

				# Turn into GRanges
				# Add to our track list
				trackList[beds.names[i]] <- with(bed.table, GRanges(seqnames=V1, ranges=IRanges(start=V2, end=V3), name=V4))
			}

			# Collapse into one GRanges
			tracks.gr <- GRanges()
			for(i in 1:length(trackList))
			{
				trackList[[i]]$track <- names(trackList)[i]
				tracks.gr <- c(tracks.gr, trackList[[i]])
			}

			# Calculate intersections for each SNP at each custom track
			track_intersect <- function(seq.ranges, track.ranges, window=0)
			{
				fo <- as.data.frame(findOverlaps(seq.ranges, track.ranges, maxgap=window))
				osnp <- data.frame(snp.id=seq.ranges[fo$queryHits,]$name, snp.chr=as.vector(seqnames(seq.ranges[fo$queryHits,])), snp.pos=start(seq.ranges[fo$queryHits,]))
				otrack <- data.frame(track.name=track.ranges[fo$subjectHits,]$track, track.id=track.ranges[fo$subjectHits,]$name, track.chr=as.vector(seqnames(track.ranges[fo$subjectHits,])), track.start=start(track.ranges[fo$subjectHits,]), track.end=end(track.ranges[fo$subjectHits,]), track.strand=as.vector(strand(track.ranges[fo$subjectHits,])))
				data.frame(osnp, otrack)
			}

			overlap.table <- track_intersect(snps.gr, tracks.gr)

			# Summary of counts by feature type for each SNP
			s1 <- ddply(overlap.table, .(snp.id,track.name), nrow)
			s2 <- cast(s1, snp.id ~ track.name)

			# Add in SNP position
			#s2$genome <- "hg19"
			#s2$chr <- snps[match(s2$snp.id, snps$snp128.id),]$chr
			#s2$pos <- snps[match(s2$snp.id, snps$snp128.id),]$pos

			# Save the CSV
      		write.csv(s2, file=file, row.names=FALSE)
   		}
   	)
	# Reactive Handler for Launch Browser Session Button
	observe({
		input$launch

		runcount <<- runcount + 1
		if(runcount>1)
		{
			trackList <- list()

			# Get map locations for input SNP set
			rv$status <- paste(isolate(rv$status), "Mapping Input SNPs...",sep="\n")
			tags <- unlist(str_split(isolate(input$snps),","))
			print(class(tags))
			tags <- str_replace(tags," ", "")

			ncbi.tags <- AnnotateSNPList(tags)
			trackList["QuerySNPs"] <- with(ncbi.tags, GenomicData(genome="hg19", chrom=paste("chr",chr,sep=""), ranges=IRanges(start=chrpos, end=chrpos), name=marker, asRangedData=TRUE))
			rv$status <- paste(isolate(rv$status), "done.",sep="")

			# Set default view to be region around the first input SNP
			region <- with(ncbi.tags[1,], GRangesForUCSCGenome(genome="hg19", chrom=paste("chr",chr,sep=""), ranges=IRanges(start=chrpos-500, end=chrpos+500)))

			# Add SNPs in LD with the queries
			if(isolate(input$ld)==TRUE)
			{
				for(tag in tags)
				{
					ncbi.ld <- GetSNPProxyInfo(tag, FlankingDistance=isolate(input$flank), method="r2", keepmode=3, pop=isolate(input$pop), showurl=TRUE)
					#print(ncbi.ld)
					ncbi.ld <- ncbi.ld[ncbi.ld$r2 >= isolate(input$r2),]
					ld.snps <- unique(c(ncbi.ld$SNPA, ncbi.ld$SNPB))
					print(ld.snps)
					# Obtain hg19 map positions for the SNPs
					ncbi.out <- AnnotateSNPList(ld.snps)
					ld.name <- paste(tag,"LD",isolate(input$r2),sep="-")
					trackList[ld.name] <- with(ncbi.out, GenomicData(genome="hg19", chrom=paste("chr",chr,sep=""), ranges=IRanges(start=chrpos, end=chrpos), name=marker, asRangedData=TRUE))
				}
			}

			# Add custom BED tracks from the custom_tracks folder
			if(isolate(input$bed)==TRUE)
			{
				beds.path <- dir("custom_tracks", full.names=TRUE)
				beds.names <- dir("custom_tracks")

				for(i in 1:length(beds.names))
				{
					#awk '{OFS="\t"; print $2,$3+1,$4,$5}' disabled_tracks/wgEncodeRegDnaseClusteredV2.bed > custom_tracks/dnase.bed
					rv$status <- paste(isolate(rv$status), "Adding Custom Track: ",beds.names[i],sep="\n")
					# Load and import BED
					bed.table <- read.table(file=beds.path[i], sep="\t", header=FALSE, skip=1, stringsAsFactors=FALSE)

					# Turn into GRanges
					# Add to our track list
					trackList[beds.names[i]] <- with(bed.table, GenomicData(genome="hg19", chrom=V1, ranges=IRanges(start=V2, end=V3), name=V4, asRangedData=TRUE))
				}
			}

			# Add all tracks in trackList to the active session
			rv$status <- paste(isolate(rv$status), "Creating Session...",sep="\n")
			session <- browserSession("UCSC")

			for(i in 1:length(trackList))
			{
				print(paste("Adding Track: ", names(trackList[i]),sep=""))
				track(session, names(trackList)[i]) <- trackList[[i]]
			}

			# Set options/defaults for tracks
			tracks.mine <- names(trackList)
			names(tracks.mine) <- rep("pack", length(trackList))
			tracks.base <- c("Base Position", "knownGene")
			names(tracks.base) <- c("full", "full")
			tracks <- c(tracks.mine, tracks.base)

			# Send view to local web browser
			view <- browserView(session, region, tracks)
			rv$status <- paste(isolate(rv$status), "done!",sep="")

		}
	})

})

