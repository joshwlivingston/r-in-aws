# src/R/00_S7.R
#
# Place S7 classes at top of directory to allow them to be found by downstream
# methods

# helpers ####
S7_check_length_one <- function(value) {
  if (!(identical(length(value), 1L) || identical(length(value), 1.0))) {
    return("must be length-one")
  }
}

getenv_if_nonempty <- function(value) {
  val <- Sys.getenv(value)
  if (!nzchar(val)) {
    lab <- deparse(substitute(value))
    stop(sprintf("%s must be set as an environment variable", lab))
  }
  return(val)
}

S7_check_valid_file_path <- function(value) {
  length_one <- S7_check_length_one(value)
  if (!is.null(length_one)) {
    return(length_one)
  }
  if (!file.exists(value)) {
    return(sprintf("File not found: %s", value))
  }
}

# S3DataSource ####
#' S3 Data Source
#'
#' An S7 class representing an S3 data source configuration. Reads bucket and
#' key from environment variables `S3_BUCKET_NAME` and `S3_DATA_KEY`.
#'
#' @param client Optional S3 client. If `NULL` (default), creates a new client
#'   via [paws.storage::s3()].
#'
#' @return An `S3DataSource` object with read-only properties:
#' \describe{
#'   \item{bucket}{S3 bucket name from `S3_BUCKET_NAME` env var}
#'   \item{key}{S3 object key from `S3_DATA_KEY` env var}
#'   \item{client}{S3 client for API operations}
#' }
#'
#' @examples
#' \dontrun{
#' Sys.setenv(S3_BUCKET_NAME = "my-bucket", S3_DATA_KEY = "data.csv")
#' source <- S3DataSource()
#' }
#'
#' @export
S3DataSource <- S7::new_class(
  name = "S3DataSource",
  properties = list(
    bucket = S7::new_property(
      class = S7::class_character,
      # getter without setter = read-only
      getter = function(self) {
        return(self@bucket)
      }
    ),
    key = S7::new_property(
      class = S7::class_character,
      getter = function(self) {
        return(self@key)
      }
    ),
    client = S7::new_property(
      # paws.storage::s3() returns unclassed list
      class = S7::class_list,
      getter = function(self) {
        return(self@client)
      }
    )
  ),
  constructor = function(client = NULL) {
    S7::new_object(
      S7::S7_object,
      bucket = getenv_if_nonempty("S3_BUCKET_NAME"),
      key = getenv_if_nonempty("S3_DATA_KEY"),
      client = if (is.null(client)) paws.storage::s3() else client
    )
  }
)

# LiftAnalysis ####
#' Lift Analysis Model
#'
#' An S7 class for performing a mocked up lift analysis. Fetches data from an
#' AWS S3 source on construction and validates that the specified spend column
#' exists and is numeric.
#'
#' @param data_source An [S3DataSource] object specifying where to fetch data.
#' @param data_spend_column Name of the spend column in the data. Default is
#'   `"spend"`.
#'
#' @return A `LiftAnalysis` object with properties:
#' \describe{
#'   \item{data}{Data frame fetched from S3}
#'   \item{data_source}{The S3DataSource used to fetch data}
#'   \item{data_spend_column}{Name of the spend column}
#' }
#'
#' @examples
#' \dontrun{
#' source <- S3DataSource()
#' model <- LiftAnalysis(data_source = source)
#' results <- fit(model, scaling_factor = 1.5)
#' average_lift(results)
#' }
#'
#' @seealso [fit()], [average_lift()]
#'
#' @export
LiftAnalysis <- S7::new_class(
  name = "LiftAnalysis",
  properties = list(
    data = S7::class_data.frame,
    data_source = S3DataSource,
    data_spend_column = S7::new_property(
      class = S7::class_character,
      validator = S7_check_length_one,
    )
  ),
  constructor = function(
    data_source,
    data_spend_column = "spend"
  ) {
    S7::new_object(
      S7::S7_object,
      data = fetch_data(data_source),
      data_source = data_source,
      data_spend_column = data_spend_column
    )
  },
  validator = function(self) {
    if (!(self@data_spend_column %in% names(self@data))) {
      print(self@data)
      return(sprintf(
        "Column not found in self@data: `%s`",
        self@data_spend_column
      ))
    }
    if (!is.numeric(self@data[[self@data_spend_column]])) {
      return(sprintf(
        "Column in self@data is not numeric: `%s`",
        self@data_spend_column
      ))
    }
  }
)

# LiftSimResults ####
LiftSimResults <- S7::new_S3_class(
  class = "LiftSimResults",
  constructor = function(.data) NULL
)
as_LiftSimResults <- function(x) {
  structure(x, class = unique(c("LiftSimResults", class(x))))
}
