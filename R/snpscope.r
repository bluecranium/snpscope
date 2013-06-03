# -----------------------------------------------------------------------------
#' Launch the web app interface
#'
#' Wrapper function to launch the web interface via shiny.
#' @export
runWebApp <- function()
{
	options(shiny.trace=TRUE)
	shiny::runApp(system.file('webapp', package='snpscope'))
}
# -----------------------------------------------------------------------------
