library(shiny)

# Custom action button for doing the session launch
eventButton <- function(inputId, value) {
  tagList(
    singleton(tags$head(tags$script(src = "eventbutton.js"))),
    tags$button(id = inputId,
                class = "eventbutton btn",
                type = "button",
                as.character(value))
  )
}

makeTrackList <- function(do=TRUE)
{
  beds <- dir("custom_tracks")
  #for(bed in beds)
  #{
    #checkboxInput(inputId = bed, label = strong(bed), value = FALSE)
    #cat(bed)
  #}
}

shinyUI(bootstrapPage(

  #checkboxInput(inputId = "a1", label = strong("Add Fetal Heart DNaseI"), value = FALSE),

  #checkboxInput(inputId = "a2", label = strong("Add H7-hESC DNaseI"), value = FALSE),

  #checkboxInput(inputId = "a3", label = strong("Add H7-hESC Histone Modifications"), value = FALSE),

  #checkboxInput(inputId = "pwm", label = strong("Add Motif Positions Based on PWM Matching"), value = FALSE),


  #conditionalPanel(condition = "input.pwm == true",
  #  numericInput("cut", "Strength Filter (0-1):", 0.05)
  #) ,


  #checkboxInput(inputId = "snp", label = strong("Add SNPs of Interest"), value = FALSE),

  #conditionalPanel(condition = "input.snp == true",
   #     textInput("rs", "SNP rsIDs (comma separated):", ""),
    #numericInput("r2", "R^2 Cutoff for Pariwise LD:", 0.80),
    #selectInput("pop", label="Population:", c("CEU","JPH"), selected = "CEU", multiple = FALSE)
  #),
h4("SNP Inputs"),
numericInput("snps", "List of SNP rs IDs (comma separated):", ""),
checkboxInput(inputId = "ld", label = strong("Generate tracks of all SNPs in LD"), value = FALSE),
conditionalPanel(condition = "input.ld == true",
    numericInput("flank", "Flanking Distance (bp):", 500000),
    numericInput("r2", "R^2 Cutoff for Pariwise LD:", 0.80),
    selectInput("pop", label="Population:", c("CEU"), selected = "CEU", multiple = FALSE)
    ),
h4("Custom Tracks"),
  checkboxInput(inputId = "bed", label = strong("Add Custom Tracks from BED files in \"custom_tracks\" folder"), value = FALSE),
conditionalPanel(condition = "input.bed == true",
downloadButton("csv", "Download Overlap Summary CSV")
    ),
h4("Actions"),
eventButton(inputId = "launch", value="Create Genome Browser Session"),
#eventButton(inputId = "save", value="Download Overlaps CSV"),
h4("Status"),

verbatimTextOutput("status")

))

