#' Coupled Monotonic Regression
#'
#' `cmr` is the main function that conducts the CMR (state-trace) analysis for
#' continuous data. It takes the data as a `data.frame` and an optional partial
#' order and returns a fitted model object of class `stacmr`. It fits the
#' conjoint monotonic model to the data and calculates the *p*-value.
#'
#' @param  data `data.frame` containing data aggregated by participant and
#'   relevant variables in columns.
#' @param  col_value `character`. Name of column in `data` containing numerical
#'   values for analysis (i.e., responses).
#' @param col_participant `character`. Name of column in `data` containing the
#'   participant identifier.
#' @param col_dv `character`. Name of column in `data` containing the dependent
#'   variable(s) spanning the state-trace axes.
#' @param col_within `character`, optional. Name of column(s) in `data`
#'   containing the within-subjects variables.
#' @param col_between `character`, optional. Name of column(s) in `data`
#'   containing the between-subjects variables.
#' @param partial defines a partial order. Either a `character` or a named
#'   `list` of characters. See details for ways to specify a partial order.
#' @param test logical. If `TRUE` (the default) *p*-value is calculated based
#'   double-bootsrap procedure with `nsamples`. If `FALSE`, no test statistic is
#'   approximated and model is only fit.
#' @param nsample number of bootstrap samples to empirically approximate the
#'   null distribution (default is 1000, but about 10000 is probably better).
#'   Only used if `test = TRUE`.
#' @param  shrink Shrinkage parameter (see [sta_stats]). Default calculates
#'   optimum amount of shrinkage.
#' @param approx `FALSE` (the default) uses full algorithm, `TRUE` uses an
#'   approximate algorithm that should be used for large problems.
#' @param tolerance tolerance used during optimization for numerical stability
#'   (function values smaller than `tolerance` are set to 0)
#'
#' @examples
#'
#' data(delay)
#' # Fit and test CMR State-Trace Analysis Model
#' st_d1 <- cmr(
#'   data = delay,
#'   col_value = "pc",
#'   col_participant = "participant",
#'   col_dv = "structure",
#'   col_within = "block",
#'   col_between = "delay",
#'   nsample = 1e3
#' )
#' st_d1  # basic information about coupled-monotonic model
#'
#' summary(st_d1)  # basic information plus estimated cell means
#' str(st_d1, 1, give.attr = FALSE) # overview of information in fitted object
#'
#' # same model with approximate method gives same result here
#' st_d2 <- cmr(
#'   data = delay,
#'   col_value = "pc",
#'   col_participant = "participant",
#'   col_dv = "structure",
#'   col_within = "block",
#'   col_between = "delay",
#'   approx = TRUE,
#'   nsample = 1e3
#' )
#' summary(st_d2)
#'
#' # for delay data: order of factor-levels corresponds to expected partial order.
#' # Therefore, 'partial = "auto"' can be used to enforce this order.
#' st_d3 <- cmr(
#'   data = delay,
#'   col_value = "pc",
#'   col_participant = "participant",
#'   col_dv = "structure",
#'   col_within = "block",
#'   col_between = "delay",
#'   partial = "auto"
#' )
#' st_d3
#' summary(st_d3)
#'
#' @import rJava
#'
#' @export
cmr <- function (data, 
                 col_value, col_participant, col_dv, 
                 col_within, col_between, 
                 partial, 
                 test = TRUE,
                 nsample = 1000, 
                 shrink = -1, 
                 approx = FALSE, 
                 tolerance = 1e-4) {
  # wrapper function for staCMRx and jCMRfitsx
  # Fit and Test Multidimensional CMR
  # data is cell array of data or structured output from staSTATS 
  # partial will be transformed into partial order
  # shrink is parameter to control shrinkage of covariance matrix;
  # 0 = no shrinkage; 1 = diagonal matrix; -1 = calculate optimum
  # returns:
  # x = best fitting CMR values to y-means
  # fval = fit statistic
  # shrinkage = estimated shrinkage of covariance matrix
  # approx = F for full algorithm; T = approximate algorithm
  
  cl <- match.call()
  
  data_list <- prep_data(data = data, 
                    col_value = col_value, 
                    col_participant = col_participant, 
                    col_dv = col_dv, 
                    col_within = col_within, 
                    col_between = col_between)
  
  stats <- sta_stats(data = data, 
                     col_value = col_value, 
                     col_participant = col_participant, 
                     col_dv = col_dv, 
                     col_within = col_within, 
                     col_between = col_between)
  stats_df <- summary(stats)
  nvar <- length(stats) # is this correct? JT

  adj_mat <- make_adj_matrix(
    data = data,
    data_list = data_list, 
    col_within = col_within, 
    col_between = col_between,
    stats_df = stats_df,
    partial = partial
  )
  
  fit_out <- staCMRx(
    data_list,
    model = NULL,
    E = adj2list(adj_mat),
    shrink = shrink,
    tolerance = tolerance,
    proc = -1,
    approx = approx
  )
  
  ## prepare output from fit object
  estimate <- stats_df[,1:4]
  estimate[[1]] <- fit_out$x[[1]]
  estimate[[2]] <- fit_out$x[[2]]
  
  out <- list(
    estimate = estimate,
    fit = fit_out$fval,
    partial = adj_mat
  )
  attr(out, "value_fit") <- "SSE"  ## sum of squared errors
  
  if (test) {
    proc <-  -1
    cheapP <- FALSE
    mrTol <- 0
    seed <- -1
    model <- matrix(1,length(data_list[[1]]),1)
    # input:
    # nsample = no. of Monte Carlo samples (about 10000 is good)
    # data = data structure (cell array or general)
    # model is a nvar * k matrix specifying the linear model, default = ones(nvar,1))
    # partial = optional partial order model e.g. E={[1 2] [3 4 5]} indicates that
      # condition 1 <= condition 2 and condition 3 <= condition 4 <= condition 5
      # default = none (empty)
    # shrink is parameter to control shrinkage of covariance matrix (if input is not stats form);
      # 0 = no shrinkage; 1 = diagonal matrix; -1 = calculate optimum, default = -1
    # approx = approximation algorithm; F = no; T = yes
    test_out <- jCMRfitsx(nsample = nsample,
                          y = data_list, 
                          model = model, 
                          E = adj2list(adj_mat), 
                          shrink = shrink,
                          proc = proc, cheapP = cheapP, approximate = approx, 
                          mrTol = mrTol, seed = seed) # call java program
    test_out$fits[which(test_out$fits <= tolerance)] = 0;
    test_out$datafit[which(test_out$datafit <= tolerance)] = 0;
    ncond <- dim(test_out$pars[[1]])[2] # maybe there is a more intuitive way JT

    # output:
    # p = empirical p-value
    # datafit = observed fit of monotonic (1D) model
    # fits = nsample vector of fits of Monte Carlo samples (it is against this
    # distribution that datafit is compared to calculate p)
    
    # unpack bootstrap means
    z = array(0,dim=c(nvar,ncond,nsample))
    for (isample in 1:nsample) {
      z[,,isample] = .jevalArray(test_out$pars[[isample]],simplify=T)
    }
    a = vector("list", nvar)
    z = aperm(z,c(3,2,1))
    for (ivar in 1:nvar){
      a[[ivar]] = z[,,ivar]
    }
    out$pars = a;
    
    out$p <- test_out$p
    out$fit_diff <- test_out$datafit
    out$fit_null_dist <- test_out$fits
    attr(out, "nsample") <- nsample
    
  } else {
    out$p <- NA
    out$fit_diff <- NA
    out$fit_null_dist <- NA
    out$pars <- NA
    attr(out, "nsample") <- 0
  }
  
  
  out$shrinkage <- fit_out$shrinkage
  out$data_list <- data_list
  out$call <- cl
  
  class(out) <- "sta_cmr"
  return (out)
}

#' Monotonic Regression
#'
#' `mr` conducts monotonic regression on a data structure according to a
#' given partial order. 
#' 
#' @param  data `data.frame` containing data aggregated by participant and
#'   relevant variables in columns.
#' @param  col_value `character`. Name of column in `data` containing numerical
#'   values for analysis (i.e., responses).
#' @param col_participant `character`. Name of column in `data` containing the
#'   participant identifier.
#' @param col_dv `character`. Name of column in `data` containing the dependent
#'   variable(s) spanning the state-trace axes.
#' @param col_within `character`, optional. Name of column(s) in `data`
#'   containing the within-subjects variables.
#' @param col_between `character`, optional. Name of column(s) in `data`
#'   containing the between-subjects variables.
#' @param partial defines a partial order. Either a `character` or a named
#'   `list` of characters. See details for ways to specify a partial order.
#' @param test logical. If `TRUE` (the default) *p*-value is calculated based
#'   double-bootsrap procedure with `nsamples`. If `FALSE`, no test statistic is
#'   approximated and model is only fit.
#' @param nsample number of bootstrap samples to empirically approximate the
#'   null distribution (default is 1000, but about 10000 is probably better).
#'   Only used if `test = TRUE`.
#' @param  shrink Shrinkage parameter (see [sta_stats]). Default calculates
#'   optimum amount of shrinkage.
#' @param approx `FALSE` (the default) uses full algorithm, `TRUE` uses an
#'   approximate algorithm that should be used for large problems.
#' @param tolerance tolerance used during optimization for numerical stability
#'   (function values smaller than `tolerance` are set to 0)
#'   
#' @examples
#' data(delay)
#' 
#' # for delay data: order of factor-levels corresponds to expected partial order.
#' # Therefore, 'partial = "auto"' can be used to enforce this order.
#' mr_d1 <- mr(
#'   data = delay, 
#'   col_value = "pc", 
#'   col_participant = "participant",
#'   col_dv = "structure", 
#'   col_within = "block", 
#'   col_between = "delay", 
#'   nsample = 1e3, 
#'   partial = "auto"
#' )
#' mr_d1
#' 
#' # Alternatively, partial order can be specified symbolically:
#' mr_d2 <- mr(
#'   data = delay, 
#'   col_value = "pc", 
#'   col_participant = "participant",
#'   col_dv = "structure", 
#'   col_within = "block", 
#'   col_between = "delay", 
#'   nsample = 1e3, 
#'   partial = list(
#'     delay = "delay < `no delay`",
#'     block = "B1 < B2 < B3 < B4"
#'   )
#' )
#' mr_d2
#' 
#' # Partial order can also be specified partially symbolically:
#' mr_d3 <- mr(
#'   data = delay, 
#'   col_value = "pc", 
#'   col_participant = "participant",
#'   col_dv = "structure", 
#'   col_within = "block", 
#'   col_between = "delay", 
#'   nsample = 1e3, 
#'   partial = list(
#'     delay = "auto",
#'     block = "B1 < B2 < B3 < B4"
#'   )
#' )
#' mr_d3
#'  
#' @import rJava
#' 
#' @export
mr <- function (data, 
                col_value, col_participant, col_dv, 
                col_within, col_between, 
                partial, 
                test = TRUE,
                nsample = 1000, 
                shrink = -1, 
                approx = FALSE, 
                tolerance = 1e-4) {
  # wrapper function for staCMRx and jCMRfitsx
  # Fit and Test Multidimensional CMR
  # data is cell array of data or structured output from staSTATS 
  # partial will be transformed into partial order
  # shrink is parameter to control shrinkage of covariance matrix;
  # 0 = no shrinkage; 1 = diagonal matrix; -1 = calculate optimum
  # returns:
  # x = best fitting CMR values to y-means
  # fval = fit statistic
  # shrinkage = estimated shrinkage of covariance matrix
  # approx = F for full algorithm; T = approximate algorithm
  
  cl <- match.call()
  
  data_list <- prep_data(data = data, 
                    col_value = col_value, 
                    col_participant = col_participant, 
                    col_dv = col_dv, 
                    col_within = col_within, 
                    col_between = col_between)
  
  stats <- sta_stats(data = data, 
                     col_value = col_value, 
                     col_participant = col_participant, 
                     col_dv = col_dv, 
                     col_within = col_within, 
                     col_between = col_between)
  stats_df <- summary(stats)
  
  adj_mat <- make_adj_matrix(
    data = data,
    data_list = data_list, 
    col_within = col_within, 
    col_between = col_between,
    stats_df = stats_df,
    partial = partial
  )
  
  nvar = length(stats)
  shrinkage = matrix(0, length(stats[[1]]$shrinkage), nvar)
  for (ivar in 1:nvar) {shrinkage[,ivar] = stats[[ivar]]$shrinkage}

  # do MR for each dependent variable
  xPrime = vector("list", nvar)
  fit = matrix(0, nvar, 1)
  for (ivar in 1:nvar) {
    out = jMR (stats[[ivar]]$means, stats[[ivar]]$weights, adj2list(adj_mat))
    xPrime[[ivar]] = out$x
    fit[ivar] = out$fval
  }
  fval = sum(fit)
  if (fval < tolerance) {fval = 0} # round down
  
  for (i in 1:nvar) {xPrime[[i]]=matrix(xPrime[[i]],length(xPrime[[i]]),1)}
  fit_out = list(xPrime, fval, shrinkage)
  names(fit_out) = c("x", "fval", "shrinkage")
  
  ## prepare output from fit object
  estimate <- stats_df[,1:4]
  estimate[[1]] <- fit_out$x[[1]]
  estimate[[2]] <- fit_out$x[[2]]
  
  out <- list(
    estimate = estimate,
    fit = fit_out$fval,
    partial = adj_mat
  )
  attr(out, "value_fit") <- "SSE"  ## sum of squared errors
  
  if (test) {
    
    test_out <- jMRfits(nsample = nsample, 
                        y = data_list, E = adj2list(adj_mat),
                        shrink = shrink)
    test_out$fits[which(test_out$fits <= tolerance)] <- 0;
    # output:
    # p = empirical p-value
    # datafit = observed fit of monotonic (1D) model
    # fits = nsample vector of fits of Monte Carlo samples (it is against this
    # distribution that datafit is compared to calculate p)
    
    test_out$datafit[which(test_out$datafit <= tolerance)] = 0;
    ncond <- dim(test_out$pars[[1]])[2] # maybe there is a more intuitive way JT
    
    # unpack bootstrap means
    z = array(0,dim=c(nvar,ncond,nsample))
    for (isample in 1:nsample) {
      z[,,isample] = .jevalArray(test_out$pars[[isample]],simplify=T)
    }
    a = vector("list", nvar)
    z = aperm(z,c(3,2,1))
    for (ivar in 1:nvar){
      a[[ivar]] = z[,,ivar]
    }
    out$pars = a;
    
    out$p <- test_out$p
    out$fit_null_dist <- test_out$fits
    attr(out, "nsample") <- nsample
    
  } else {
    out$p <- NA
    out$fit_null_dist <- NA
    out$pars <- NA
    attr(out, "nsample") <- 0
  }
  
  
  out$shrinkage <- fit_out$shrinkage
  out$data_list <- data_list
  out$call <- cl
  
  class(out) <- "sta_cmr"
  return (out)
}


