#' Fetch Data from a Data Source
#'
#' An S7 generic for fetching data from various sources. The default method
#' for [S3DataSource] downloads a CSV file from S3 and returns it as a
#' data.table.
#'
#' @param source A data source object. Currently supports [S3DataSource].
#' @param ... Passed to methods
#'
#' @return A data.table containing the fetched data.
#'
#' @examples
#' \dontrun{
#' Sys.setenv(S3_BUCKET_NAME = "my-bucket", S3_DATA_KEY = "data.csv")
#' source <- S3DataSource()
#' data <- fetch_data(source)
#' }
#'
#' @seealso [S3DataSource]
#'
#' @export
fetch_data <- S7::new_generic("fetch_data", "source")
S7::method(fetch_data, S3DataSource) <- function(source) {
  message(sprintf("Fetching s3://%s/%s...", source@bucket, source@key))
  tmp_file <- file.path(tempdir(), "data_download.csv")
  tryCatch(
    {
      obj <- source@client$get_object(Bucket = source@bucket, Key = source@key)
      writeBin(obj$Body, tmp_file)
    },
    error = function(e) {
      stop(sprintf("Failed to download from S3: %s", e$message))
    }
  )
  return(fread(tmp_file))
}
