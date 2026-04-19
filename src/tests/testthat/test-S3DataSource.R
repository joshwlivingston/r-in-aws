test_that("S3DataSource accepts injected client", {
  mock_client <- create_mock_s3_client("spend\n1.0\n2.0\n")

  withr::with_envvar(
    c(S3_BUCKET_NAME = "test-bucket", S3_DATA_KEY = "test-key"),
    {
      source <- S3DataSource(client = mock_client)
      expect_equal(source@bucket, "test-bucket")
      expect_equal(source@key, "test-key")
      expect_identical(source@client, mock_client)
    }
  )
})

test_that("S3DataSource validates environment variables", {
  mock_client <- create_mock_s3_client("spend\n1.0\n")

  withr::with_envvar(
    list(S3_BUCKET_NAME = "", S3_DATA_KEY = "test-key"),
    {
      expect_error(
        S3DataSource(client = mock_client),
        "must be set as an environment variable$"
      )
    }
  )
})
