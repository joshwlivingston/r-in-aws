# helper-mocks.R
#
# Test helpers for mocking AWS S3 dependencies

create_mock_s3_client <- function(csv_string) {
  list(
    get_object = function(Bucket, Key) {
      list(Body = charToRaw(csv_string))
    }
  )
}

create_mock_data_source <- function(csv_string) {
  withr::with_envvar(
    c(S3_BUCKET_NAME = "test-bucket", S3_DATA_KEY = "test-key"),
    S3DataSource(client = create_mock_s3_client(csv_string))
  )
}
