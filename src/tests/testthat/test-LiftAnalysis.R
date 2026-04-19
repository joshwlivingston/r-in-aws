test_that("LiftAnalysis fetches data from mock source", {
  source <- create_mock_data_source("spend\n1.0\n2.0\n3.0\n")
  model <- LiftAnalysis(data_source = source)

  expect_s7_class(model, LiftAnalysis)
  expect_equal(nrow(model@data), 3)
  expect_equal(model@data$spend, c(1.0, 2.0, 3.0))
})

test_that("LiftAnalysis validates spend column exists", {
  source <- create_mock_data_source("other_col\n1.0\n2.0\n")

  expect_error(
    LiftAnalysis(data_source = source, data_spend_column = "spend"),
    "Column not found in self@data: `spend`"
  )
})

test_that("LiftAnalysis validates spend column is numeric", {
  source <- create_mock_data_source("spend\ncarrot\ncelery\n")

  expect_error(
    LiftAnalysis(data_source = source, data_spend_column = "spend"),
    "Column in self@data is not numeric: `spend`"
  )
})

test_that("LiftAnalysis allows custom spend column", {
  source <- create_mock_data_source("budget\n10.0\n20.0\n")
  model <- LiftAnalysis(data_source = source, data_spend_column = "budget")

  expect_equal(model@data_spend_column, "budget")
  expect_equal(model@data$budget, c(10.0, 20.0))
})
