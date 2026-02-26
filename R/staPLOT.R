#' State-Trace Plot for Continuous Data
#'
#' Generates a state-trace plot for continuous data.
#' 
#' @param data Name of the data set and is the one required argument. It may be
#'   in either general or list format, or in summary statistics form (i.e., the
#'   output of staSTATS).
#' @param vars ...?
#' @param groups \code{list} identifying the conditions to be distinguished in
#'   the plot with different markers.
#' @param  grouplabels \code{list} consisting of the labels for the groups
#'   defined by groups to appear in the legend.
#' @param  axislabels \code{list} that defines the labels on the x-axis and
#'   y-axis, respectively.
#' @param xlim,ylim vector of axes limits.
#' @param  pred \code{list} of predicted values for each condition. Typically,
#'   this is the best-fitting values returned by \code{\link{mr}} or
#'   \code{\link{cmr}}.
#' @param  palette identifies a color palette (see
#'   \code{\link[ggplot2]{scale_colour_brewer}}) for plotting points.
#'   
staPLOT <- function (data, vars=c(1,2), groups=NULL, grouplabels=NULL, 
                     axislabels=c("DV1","DV2"),
                     xlim=NULL, ylim=NULL, pred=NULL, palette="Set1") 
{
  # function staPLOT (data, vars=c(1,2), groups=NULL, grouplabels=NULL, axislabels=c("DV1","DV2"),
  # xlim=NULL, ylim=NULL, pred=NULL, palette="Set1")
  # generates state-trace plot
  # get stats from data (depending on its form)
  shrink = -1;
  if (is(data,"data.frame")) {
    y = gen2list (data) # convert from general format
    ys = staSTATS (y, shrink) # get stats
  } 
  if (is(data,"list")) {
    if (is.null(data[[1]]$means)) {ys = staSTATS(data, shrink) # in list form, get stats
    } else {ys = data} # already in stats form
  }
  
  nvar = length(ys)
  if (is.null(groups)) {g = rep(1,length(ys[[1]]$means))}
  if (is.list(groups)) # convert list to vector of group id's
  {g=rep(1,length(ys[[1]]$means)); k=0;
  for (i in 1:length(groups)) {
    for (j in 1:length(groups[[i]])) {g[groups[[i]][j]]=i}
  }
  }
  groups=g;
  
  if (is.null(grouplabels)) {
    grouplabels=rep(1,length(groups));
    for (i in 1:length(groups)) {grouplabels[i]=paste("Condition ",toString(groups[i]))}
  } else {
    g = rep(1,length(groups));
    for (i in 1:length(groups)) {g[i]=grouplabels[[groups[i]]]};
    grouplabels=g;
  }
  
  # calculate model
  if (!is.null(pred)) {
    ix = vars[1]; iy = vars[2]; 
    x = pred[[ix]]; y = pred[[iy]]
    i = tiesort(x,y); x = i$x; y = i$y;
    model = data.frame(x,y)
  } else {model=NULL}
  
  # calculate data
  ix = vars[1]; iy = vars[2]; x = ys[[ix]]$means; y = ys[[iy]]$means
  if (length(ys[[ix]]$n) > 1)
  {cx = sqrt(diag(ys[[ix]]$cov)/diag(ys[[ix]]$n)) # between subjects
  cy = sqrt(diag(ys[[iy]]$cov)/diag(ys[[iy]]$n))} else 
  {cx = sqrt(diag(ys[[ix]]$lm)/ys[[ix]]$n) # within subjects
  cy = sqrt(diag(ys[[iy]]$lm)/ys[[iy]]$n)}
  
  # plot
  df = data.frame(x,y)
  p=ggplot2::ggplot(data=df, ggplot2::aes(x=x, y=y)) + 
    ggplot2::geom_errorbar(mapping = ggplot2::aes(ymin = y-cy, ymax = y+cy), 
                           color="black") + 
    ggplot2::geom_errorbarh(mapping = ggplot2::aes(xmin = x-cx, xmax = x+cx), 
                            color="black") +
    ggplot2::geom_point(mapping = ggplot2::aes(fill=as.factor(grouplabels)), 
                        color="black",size=5, shape=21)
  if (!is.null(model)) {
    p = p + 
      ggplot2::geom_line(data=model, 
                         mapping = ggplot2::aes(x=x,y=y), 
                         color="black", linetype="dashed") + 
      ggplot2::geom_point(data=model, 
                          mapping = ggplot2::aes(x=x,y=y), 
                          fill="white",color="black",size=2, shape=22)
  }
  p = p + 
    ggplot2::labs(x = axislabels[[1]], y = axislabels[[2]]) + 
    ggplot2::scale_fill_brewer(palette=palette)
  p = p + 
    ggplot2::coord_fixed(ratio=1)
  if (!is.null(xlim)) {p = p + ggplot2::xlim(xlim[1],xlim[2])}
  if (!is.null(ylim)) {p = p + ggplot2::ylim(ylim[1],ylim[2])}
  #p = p + scale_fill_discrete(name = "New Legend Title")
  
  ## HS: deactivated setting theme internally, that seems rather bad style
  ## TODO: make theme_stacmr() function that sets these.
  # p = p + ggplot2::theme(panel.background=element_blank(),
  #               axis.text.x=element_text(colour="black",size=12),
  #               axis.text.y=element_text(colour="black",size=12),
  #               axis.line=element_line(colour="black"),
  #               legend.title = element_blank(),
  #               legend.background = element_rect(color = "black", size = .5, linetype = "solid"),
  #               legend.key = element_rect(colour = NA, fill = NA),
  #               legend.position = c(.2,.9)
  #               )
  
  plot(p)
  return(p)
}