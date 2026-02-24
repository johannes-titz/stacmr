test_that("symbolic partial order specification", {
  data(delay)
  mr_auto <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = "auto"
  )
  
  mr_symbolic <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "delay < `no delay`",
      block = "B1 < B2 < B3 < B4"
    )
  )
  
  expect_identical(mr_symbolic$partial, mr_auto$partial)
  expect_equal(mr_symbolic$estimate, mr_auto$estimate, ignore_attr = T)

  ## Partial order can also be specified partially symbolically:
  mr_pa1 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "auto",
      block = "B1 < B2 < B3 < B4"
    )
  )
  expect_identical(mr_pa1$partial, mr_auto$partial)
  expect_equal(mr_pa1$estimate, mr_auto$estimate, ignore_attr = T)
  
  mr_pa2 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "delay < `no delay`",
      block = "auto"
    )
  )
  expect_identical(mr_pa2$partial, mr_auto$partial)
  expect_equal(mr_pa2$estimate, mr_auto$estimate, ignore_attr = T)
  
  mr_pa3 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "`no delay`>delay",
      block = "auto"
    )
  )
  expect_identical(mr_pa3$partial, mr_auto$partial)
  expect_equal(mr_pa3$estimate, mr_auto$estimate, ignore_attr = T)

  mr_pa4 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "auto",
      block = "B4 > B3 > B2 > B1"
    )
  )
  expect_identical(mr_pa4$partial, mr_auto$partial)
  expect_equal(mr_pa4$estimate, mr_auto$estimate, ignore_attr = T)

  mr_sym2 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "`no delay`>delay",
      block = "B4 > B3 > B2 > B1"
    )
  )
  expect_identical(mr_sym2$partial, mr_auto$partial)
  expect_equal(mr_sym2$estimate, mr_auto$estimate, ignore_attr = T)
  
  mr_0 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE
  )
  expect_lt(mr_0$fit, mr_auto$fit)
  expect_equal(mr_0$fit, 0)
  expect_true(all(mr_0$partial == 0))
  expect_false(isTRUE(all.equal(mr_0$estimate, mr_auto$estimate)))
  
  mr_e1 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "`no delay` = delay",
      block = "B4 > B3 > B2 > B1"
    )
  )
  expect_gt(mr_e1$fit, mr_auto$fit)
  expect_gt(mean(mr_e1$partial), mean(mr_auto$partial))
  expect_false(isTRUE(all.equal(mr_e1$estimate, mr_auto$estimate)))
  
  mr_e2 <- mr(
    data = delay, 
    col_value = "pc", 
    col_participant = "participant",
    col_dv = "structure", 
    col_within = "block", 
    col_between = "delay", 
    test = FALSE, 
    partial = list(
      delay = "`no delay` = delay",
      block = "B4 = B3 = B2 = B1"
    )
  )
  expect_gt(mr_e2$fit, mr_e1$fit)
  expect_gt(mean(mr_e2$partial), mean(mr_e1$partial))
  expect_false(isTRUE(all.equal(mr_e2$estimate, mr_auto$estimate)))
  expect_false(isTRUE(all.equal(mr_e2$estimate, mr_e1$estimate)))
})
