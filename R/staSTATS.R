#' Statistics for state-Trace Analysis
#' 
#' Calculates statistics for state trace analysis. This function is mainly for
#' internal use, but the `print` and `summary` method for the returned objects
#' of class `sta_stats` also provide a convenient overview of the data point of
#' the state-trace analysis.
#' 
#' @param shrink numeric indicating amount of shrinkage to apply to the
#'   estimated covariance matrix. Generally, the covariance matrix needs to be
#'   shrunk during the bootstrap cycle to avoid ill-conditioning. If `shrink =
#'   0` then no shrinkage is applied. If `shrink = 1` then maximum shrinkage is
#'   applied. This means that the covariance matrix is diagonalized with all
#'   off-diagonal entries set to zero. If `shrink < 0` (the default) then an
#'   optimal shrinkage value is estimated for each within-participant block and
#'   applied according to an algorithm developed by Ledoit and Wolf (2004).
#' @param warning if warning is `TRUE` then a warning is thrown if `NA`s are detected.
#'   Default is `FALSE`.
#'   
#' @return A `list` of `list`s with additional class `sta_stats`. The length of
#'   the outer `lists` corresponds to the number of `dv`s in the data (i.e.,
#'   each slot corresponds to one `dv` and is named accordingly). Each of the
#'   inner lists contains the following slots:
#'   -  `means`: vector of means across all conditions. Names of the vector
#'   correspond to the within-participants conditions.
#'   - `n`:  matrix  of number of observations (subjects) in each
#'   within-participant block
#'   - `cov`: the covariance matrix  (for information only)
#'   - `regcov`: adjusted covariance matrix following application of shrinkage
#'   - `shrinkage`: a vector of length `b` (where `b` is the number of levels of
#'   the between-participant independent variable) containing the specified or
#'   estimated shrinkage values.
#'   - `weights`: matrix of weights defined as: `n * solve(regcov)`.
#'   - `lm`: matrix  of Loftus-Masson within-participant standard errors
#'   (potentially used by the plotting function)
#'   - `nanflag`: count of missing values (`NA`s) per group?between-subjects
#'   condition.
#'   - `bad`: If not 0, indicates problems with the covariance matrix.
#'   - `conditions`: mapping of means to between-subjects conditions
#'   (`character` vector).
#'   
#'  The `summary` method returns a `data.frame` giving means, conditions, and
#'  mean N. The `print` method prints this `data.frame` with specified `digits`.
#' 
#' @references Ledoit, O. & Wolf, M. (2004). Honey, I shrunk the sample
#'   covariance matrix. *The Journal of Portfolio Management*, 30(4), 110-119.
#' 
#' @inheritParams cmr
#' 
#' @examples
#' data(delay)
#' 
#' stats <- sta_stats(
#'   data = delay, 
#'   col_value = "pc", 
#'   col_participant = "participant",
#'   col_dv = "structure", 
#'   col_within = "block", 
#'   col_between = "delay"
#' )
#' stats
#' str(stats)
#' summary(stats)
#' 
#' 
#' @export
sta_stats <- function(data, 
                     col_value, col_participant, col_dv, col_within, 
                     col_between, 
                     shrink=-1, warning=FALSE) {
    y <- prep_data(data = data, 
                 col_value = col_value, 
                 col_participant = col_participant, 
                 col_dv = col_dv, 
                 col_within = col_within, 
                 col_between = col_between, 
                 return_list = FALSE)
    staSTATS(
      data = y,
      shrink = shrink,
      varnames = attr(y, "names_within"),
      warning = warning
    )
}


staSTATS <- function(data, shrink=-1, varnames, warning=FALSE) {
  ## Calculates statistics for state trace analysis
  ##
  ## Args:
  ##   data: A list of lists containing nsub x ncond matrices
  ##   varnames: An optional list of names of within-participant conditions
  ##   shrink: 0=no shrinkage of covariance; 1=maximal shrinkage; -1=estimated optimal shrinkage
  ##   if warning is set then a warning message is printed if NAs are detected
  ##
  ## Returns a list with the following items:
  ##   means: Observed means
  ##   n: Number of subjects
  ##   cov: Observed covariance matrix
  ##   recov: Regularized (shrinked) covariance matrix 
  ##   weights: Weight matrix for monotonic regression
  ##   lm: Loftus-Masson within subjects variance
  ##   shrinkage: shrinkage parameter (estimated or returned)
  ##   nanflag: count of missing values (NAs)
  
  #if (missing(shrink)) {shrink = -1}
  #if (missing(warning)) {warning = 0}
  
  y <- data
  if (is(y, "data.frame")) {
    y = gen2list(y, varnames)
  } # convert from general to list format if req'd
  ngroup = length(y); nvar = length(y[[1]])
  
  output = vector("list", nvar)
  
  if ('means' %in% names(y[[1]])) {
    output = y # already in stats form
  } else {
    for(ivar in 1:nvar) {
      i.means = numeric()
      i.n = matrix(0,0,0)
      i.cov = matrix(0,0,0)
      i.regcov = matrix(0,0,0)
      i.shrinkage = numeric()
      i.weights = matrix(0,0,0)
      i.lm = matrix(0,0,0)
      i.bad = matrix(0,0,0)
      i.nanflag = matrix(0,0,0)
      for (igroup in 1:ngroup) {
        y.i <- as.matrix(y[[igroup]][[ivar]])
 #       y.i <- y.i[complete.cases(y.i), ] ## delete rows with NAs
        g.nanflag <- sum(is.na(y.i))
        g.means <- colMeans(y.i,na.rm=TRUE)
        a=y.i; a[is.na(y.i)]=0; a[!is.na(y.i)]=1; g.n=t(a)%*%a; a=g.n-1; a[a<0]=0; # no. of observations
        g.cov <- cov(y.i,use='pairwise.complete.obs')*a/g.n; g.cov[is.na(g.cov)]=0 # adjusted covariance
        
        eigcov <- eigen(g.cov)
        if ((kappa(g.cov,2) < 1e6) && (min(eigcov$values) > 0))
          {s <- shrinkDiag(y.i, shrink); g.bad <- 0}
       else
          {s <- shrinkDiag(y.i, 1); g.bad <- 1} # diagonalize ill-conditioned matrix
        g.regcov <- s$sigma; g.shrinkage = s$shrinkage
        eigRegcov <- eigen(g.regcov) # check if positive definite
        if ((kappa(g.regcov,2) > 1e6) ||(min(eigRegcov$values) <= 0))
        {g.regcov <- sum(eigRegcov$values)*diag(nrow(g.regcov))/nrow(g.regcov); g.bad <- 2}
        
        Nmin <- g.n; Nmin[which(diag(nrow(g.regcov)) > g.n)] <- 1;
        g.weights <- Nmin*solve(g.regcov)
        if (length(g.regcov)==1) {g.lm=g.regcov} else {g.lm = LoftusMasson (y.i)}
        
        # add to vectors and matrices
        i.means = c(i.means, g.means)
        i.n = magic::adiag(i.n, g.n) # requires "magic" package
        i.cov = magic::adiag(i.cov, g.cov)
        i.regcov = magic::adiag(i.regcov, g.regcov)
        i.shrinkage = c(i.shrinkage, g.shrinkage)
        i.weights = magic::adiag(i.weights, g.weights)
        i.lm = magic::adiag(i.lm, g.lm)
        i.bad = c(i.bad, g.bad)
        i.nanflag = c(i.nanflag, g.nanflag)
      }
      ## preassign length of names vector (should be done for others as well)
      i.lengths <- vapply(y, function(x) ncol(x[[ivar]]), 0)
      i.names <- rep(
        if (!is.null(attr(data, "names_between"))) attr(data, "names_between") 
            else rep("1", ngroup),
            i.lengths)
      names(i.names) <- names(i.means)
      # add to list
      out = list(i.means, i.n, i.cov, i.regcov, i.shrinkage, 
                 i.weights, i.lm, i.nanflag, i.bad, i.names)
      output[[ivar]] = out
      names(output[[ivar]]) = c("means", "n", "cov", "regcov", "shrinkage", 
                                "weights", "lm", "nanflag", "bad", "conditions")
      
      if (sum(i.nanflag > 0) && (warning))
        {warning(sum(i.nanflag), ' detected for variable',ivar)}
      if (sum(i.bad > 0) && (warning))
        {warning('Bad covariance matrix detected for variable',ivar, '. Type = ', i.bad)}
    }
    if(!is.null(attr(data, "names_dv"))) {
      names(output) <- make.names(attr(data, "names_dv"), unique = TRUE)
    }
  }
  attr(output, "varnames") <- attr(y, "varnames")
  class(output) <- "sta_stats"
  return(output)
}

#' @export
summary.sta_stats <- function(object, ...) {
  
  ns <- lapply(object, function(y) apply(y$n, 2, function(x) mean(x[x!=0])))
  ns <- as.data.frame(do.call("cbind", ns))
  colnames(ns) <- paste0("N_", colnames(ns))
  out <- as.data.frame(do.call("cbind", lapply(object, `[[`, i = "means")))
  out$within <- names(object[[1]][["conditions"]])
  out$between <- object[[1]][["conditions"]]
  out <- cbind(out, ns)
  rownames(out) <- NULL
  out
  
}

#' @export
print.sta_stats <- function(x, digits = 3, ...) {
  
  # se <- as.data.frame(do.call("cbind", lapply(x, function(x) diag(x[["lm"]]))))
  # 
  # mypaste <- function(x, y) paste0(format(x, digits = digits), " (", 
  #        format(x-y, digits = digits), ", ", format(x+y, digits = digits), ")")
  # out <- as.data.frame(mapply(mypaste, means, se), stringsAsFactors = FALSE)

  print(summary(x), digits = digits)
}
