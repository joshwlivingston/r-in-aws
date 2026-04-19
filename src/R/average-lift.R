#' Fit a Lift Model
#'
#' An S7 generic for fitting the lift "model." The default method for
#' [LiftAnalysis] runs a "simulation" by scaling the spend column and adding
#' random noise.
#'
#' @param model A model object. Currently supports [LiftAnalysis].
#' @param ... Passed to methods. See details.
#'
#' @details
#' The following arguments are supported in methods:
#' \describe{
#'   \item{scaling_factor}{
#'     Numeric scaling factor applied to spend values. Default is `1.5`.}
#' }
#'
#'
#' @return A `LiftSimResults` object (s3-classed numeric vector) containing the
#'   simulated lift values.
#'
#' @examples
#' \dontrun{
#' source <- S3DataSource()
#' model <- LiftAnalysis(data_source = source)
#' results <- fit(model, scaling_factor = 2.0)
#' }
#'
#' @seealso [LiftAnalysis], [average_lift()]
#'
#' @export
fit <- S7::new_generic("fit", "model")
S7::method(fit, LiftAnalysis) <- function(model, scaling_factor = 1.5) {
  res <-
    model@data[[model@data_spend_column]] *
    scaling_factor +
    rnorm(nrow(model@data), mean = 0, sd = 0.1)
  as_LiftSimResults(res)
}

#' Calculate Average Lift
#'
#' An S7 generic for calculating the average lift from simulation results.
#'
#' @param x A `LiftSimResults` object returned by [fit()].
#' @param ... Passed to methods. See details.
#'
#' @details
#' The following arguments are supported in methods:
#' \describe{
#'   \item{na.rm}{
#'      Should missing values be removed? Default is `FALSE`}
#' }
#'
#' @return A single numeric value representing the mean lift.
#'
#' @examples
#' \dontrun{
#' source <- S3DataSource()
#' model <- LiftAnalysis(data_source = source)
#' results <- fit(model)
#' average_lift(results)
#' }
#'
#' @seealso [fit()], [LiftAnalysis]
#'
#' @export
average_lift <- S7::new_generic("average_lift", "x")
S7::method(average_lift, LiftSimResults) <- function(x, na.rm = FALSE) {
  mean(x, na.rm = na.rm)
}
