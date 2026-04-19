test_that("fit returns type double LiftSimResults", {
  source <- create_mock_data_source("spend\n1.0\n2.0\n3.0\n")
  model <- LiftAnalysis(data_source = source)

  set.seed(123)
  result <- fit(model, scaling_factor = 1.0)

  expect_s3_class(result, "LiftSimResults")
  expect_type(result, "double")
  expect_length(result, nrow(model@data))
})

test_that("fit applies scaling factor", {
  source <- create_mock_data_source("spend\n10.0\n")
  model <- LiftAnalysis(data_source = source)

  set.seed(42)
  result_1x <- fit(model, scaling_factor = 1.0)

  set.seed(42)
  result_2x <- fit(model, scaling_factor = 2.0)

  # With same seed, noise is identical, so difference is purely from scaling
  expect_equal(result_2x[1] - result_1x[1], 10.0)
})

test_that("average_lift calculates mean", {
  sim_results <- as_LiftSimResults(c(1.0, 2.0, 3.0, 4.0, 5.0))
  result <- average_lift(sim_results)

  expect_equal(result, 3.0)
})

test_that("average_lift handles NA values", {
  sim_results <- as_LiftSimResults(c(1.0, NA, 3.0))

  expect_true(is.na(average_lift(sim_results)))
  expect_equal(average_lift(sim_results, na.rm = TRUE), 2.0)
})
