test_that("mr() produces known results & basic output", {
  data(delay)
  
  ## basic version
  mr_d1 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    nsample = 1000, 
    partial = "auto"
  )
  ### results from Dunn & Kalish section 5.2
  expect_lt(mr_d1$p, 0.78)
  expect_gt(mr_d1$p, 0.72)
  
  expect_equal(mr_d1$fit,  0.1721, tolerance = 0.0002)
  
  ## approximate version
  mr_d2 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    nsample = 1000, 
    partial = "auto", 
    approx = TRUE 
  )
  expect_lt(mr_d2$p, 0.78)
  expect_gt(mr_d2$p, 0.71)
  
  expect_equal(mr_d2$fit,  0.1721, tolerance = 0.0002)
  
  mr_delay_nt <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE,
    partial = "auto" 
  )
  ### results from Dunn & Kalish section 5.2
  
  expect_equal(mr_delay_nt$fit,  0.1721, tolerance = 0.0002)
  expect_equal(mr_delay_nt$p,  NA)
  
  expect_output(print(mr_delay_nt), "MR fit to 8 data points with call:")
  expect_output(print(mr_delay_nt), "p-value \\(based on 0 samples\\): NA")
  
  expect_output(summary(mr_delay_nt), "MR fit to 8 data points with call:")
  expect_output(summary(mr_delay_nt), "Estimated cell means:")
  expect_output(summary(mr_delay_nt), "rule.based information.integration within  between")
  
})
