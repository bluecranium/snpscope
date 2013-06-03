#' snpscope
#'
#' @name snpscope
#' @docType package

runWebApp <- function()
{
	shiny::runApp(system.file('webapp', package='snpscope'))
}