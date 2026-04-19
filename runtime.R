# runtime.R
library(r.package)
data_source <- S3DataSource()
model <- LiftAnalysis(data_source = data_source)
calculate_lift <- function(scaling_factor = 1.5) {
  sim <- fit(model, scaling_factor = scaling_factor)
  return(list(lift = average_lift(sim)))
}
lambdr::start_lambda()
