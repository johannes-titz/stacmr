# function is INTERNAL
#' Data formats
# @rdname data_formats
# @aliases data_formats
#' 
#' @description \pkg{STACMR} accepts two kinds of data structure, **list
#'   format** and **general format**. `gen2list` transforms from the general
#'   format into the list format.
#' 
#' @param data `data.frame` or `matrix` in general format (see below).
#' @param varnames optional `list`  of the names of each within-participant
#'   condition.
#' 
#' @details 
#' 
#' \subsection{List Format}{In this format, the data are contained in a `b` x
#' `n` list where `b` is the number of between-participant conditions (groups)
#' and `n` is the number of dependent variables. Each component of the list is
#' itself an `N` x `w` matrix of observations where `N` is the number of
#' subjects (which may vary across groups and dependent variables) and `w` is
#' the number of within-participant conditions (fixed across groups and
#' dependent variables). The dependent variable may be either within-participant
#' or between-participant. This does not matter because the correlation between
#' dependent variables is assumed to be zero (although this might change in
#' future implementations).}
#' 
#' \subsection{General format}{This is a fixed column format organised as a
#' matrix in which each row corresponds to an observation and each column is
#' defined as follows:
#' 1. Participant number (for identification only, not used directly)
#' 2. Between-participant condition or group (if none, then set this value to 1)
#' 3.  Dependent variable (numbered 1, 2, and so on)
#' 4. column 4 to end: Values for each within-participant condition
#' }
#' 
#' @return `gen2list` returns a `ngroup` x `nvar` `list` in which each element
#'   is an `nsub` x `ncond` matrix of values


# @rdname data_formats
# @export
gen2list = function (data=NULL, varnames) {
# gen2cell(data)
  # R version of gen2cell.m
# converts data in "general format" to list format suitable for input to staSTATS
# general format is defined as:
  # column 1 = subject number (nsub)
  # column 2 = between-subjects condition (ngroup)
  # column 3 = dependent variable (nvar)
  # columns 4 to end = values for each within-subjects condition (ncond)
  # output is ngroup x nvar list in which each element is an nsub x ncond matrix of values
  #
  # *************************************************************************
  # written 12 September 2016
  # revised 9 March 2017 to remove missing within variables in a group
  # revised 22 August 2017 to add variable names
  # revised 28 February 2019 to repair variable names
  # 2019/05/25 added names for all elements via attributes, which take precedence
  # *************************************************************************
  #
  if (!is.null(attr(data, "names_within"))) {
    varnames <- attr(data, "names_within")
  }
  if (!missing(varnames)) {
    if (length(varnames) == length(4:ncol(data))) {
      colnames(data)[4:ncol(data)]=varnames
    }
  }
  group = data[,2]; ugroup = sort(unique(group)); ngroup = length(ugroup)
  var = data[,3]; uvar = sort(unique(var)); nvar = length(uvar)
  within = as.matrix(data[,4:ncol(data)])
  
  y = vector("list",ngroup)
  names(y) <- attr(data, "names_between")
  for (igroup in 1:ngroup) {
    temp = vector("list", nvar)
    names(temp) <-  attr(data, "names_dv")
    for (ivar in 1:nvar){
      k = which(group==ugroup[igroup] & var==uvar[ivar])
      a = as.matrix(within[k,])
      # delete any variables that all all missing
      n = colSums(is.na(a)); k=which(n==nrow(a)); if (length(k) > 0) {a = a[,-k]}
      # store in 2D list
      temp[[ivar]]=a
    }
    y[[igroup]] <- temp
  }
  attr(y, "varnames") <- attr(data, "varnames")
  return (y)
}

is_wholenumber <- function(x, tol = .Machine$double.eps^0.5)  {
  if (is.numeric(x)) all(abs(x - round(x)) < tol)
  else FALSE
  }

check_col <- function(data, col, factor_int = FALSE) {
  col_tested <- deparse(substitute(col))
  if (!all(col %in% colnames(data))) {
    not_in <- col[!(col %in% colnames(data))]
    stop(col_tested, " '",not_in,  "' not in data.", call. = FALSE)
  }
  if (factor_int) {
    fac <- vapply(col, function(x) is.factor(data[[x]]), NA)
    int <- vapply(col, function(x) is_wholenumber(data[[x]]), NA) |
      vapply(col, function(x) is.integer(data[[x]]), NA)
    if (length(col) == 1 & !(fac | int)) {
      stop(col_tested, " '", not_in,  "' is neither factor nor integer variable.", call. = FALSE)
    } else if (length(col) > 1 & all(fac)) {
      message("Combining ", length(col), " ", col_tested, " factors.")
      data[[col[1]]] <- interaction(data[col])
    } else if (length(col) > 1 & (any(int) | any(fac))) {
      stop(col_tested, " of length 1 is only supported if all columns are factors.", call. = FALSE)
    } else if (!(any(int) | any(fac))) {
      stop(col_tested, " is not of supported type (factor or integer).", call. = FALSE)
    }
    if (is.factor(data[[col[1]]]))
      attr(data, paste0("names", substr(col_tested, 4, 20))) <- levels(data[[col[1]]])
    data[[col[1]]] <- as.factor(data[[col[1]]])
  } else {
    if (length(col) > 1) {
      stop(col_tested, " needs to be of length 1 (is ", length(col), ").", call. = FALSE)
    }
  }
  data
}


prep_data <- function(data, col_value, col_participant, col_dv, 
                      col_within, col_between, return_list = TRUE) {
  ## save all variable names for later use
  varnames <- c(
    value = col_value,
    participant = paste(col_participant, collapse = ":"),
    dv = paste(col_dv, collapse = ":")
  )
  
  ## check if all columns are in data and concatenate in one, if longer than 1
  data <- check_col(data, col_value)
  data <- check_col(data, col_participant, TRUE)
  col_participant <- col_participant[1]
  data <- check_col(data, col_dv, TRUE)
  col_dv <- col_dv[1]
  
  if (missing(col_within)) {
    col_within <- "___NEWWNCOLSTACMR__"
    data[[col_within]] <- "y"
    varnames <- c(varnames, within = NULL)
  } else {
    varnames <- c(varnames, within = paste(col_within, collapse = ":"))
    data <- check_col(data, col_within, TRUE)
    col_within <- col_within[1]
  }
  
  if (missing(col_between)) {
    col_between <- "___NEWCOLSTACMR__"
    data[[col_between]] <- 1L
    varnames <- c(varnames, between = NULL)
  } else {
    varnames <- c(varnames, between = paste(col_between, collapse = ":"))
    data <- check_col(data, col_between, TRUE)
    col_between <- col_between[1]
  }
  
  ## reduce data to relevant columns
  newd <- data[,c(col_participant, col_between, col_dv, col_within, col_value)]
  ## bring in appropriate format
  d_gen <- stats::reshape(newd, v.names = col_value, 
                          timevar = col_within,
                          idvar = c(col_participant, col_between, col_dv), 
                          direction = "wide")
  attr_set <- attributes(data)[-(1:2)]
  for (i in seq_along(attr_set)) {
    attr(d_gen, names(attr_set)[i]) <- attr(data, names(attr_set)[i])
  }
  attr(d_gen, "varnames") <- varnames
  if(!return_list) return(d_gen)
  return(gen2list(d_gen))
}
