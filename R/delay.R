#' Experiment 1 of Dunn, Newell, & Kalish (2012)
#' 
#' @format ## `delay`
#' 
#' Data from 130 `participant`s with two between-participants factors (`delay`
#' and `structure`) with two levels each and one within-participants factor
#' (`block`) with four levels. The dependent variable is proportion correct
#' `pc`.
#'
#' Participants in this study completed one of two category-learning tasks
#' defined according to the category `structure` that participants learned. For
#' the rule-based (RB) group, the category structure was defined by a simple
#' rule. For the information-integration (II) group, the category structure was
#' more complex and could not be defined by a simple rule.
#'
#' The experiment consisted of four 80-trial `block`s for each participant.
#' Within each block, all 80 stimuli were presented in a random order (with
#' different orders for each participant). Participants were told to learn which
#' of four categories (labeled, 1, 2, 3, and 4) each stimulus belonged to. On
#' each trial, a stimulus was presented, and participants terminated the display
#' by pressing one of the keys labeled 1-4 on the computer keyboard
#' corresponding to Categories 1-4, respectively. Following the response, a mask
#' appeared. The length with which the mask was shown defined the `delay`
#' condition. Either 0.5-s (No Delay condition) or 5-s (Delay condition).
#'
#' Following presentation of the mask, feedback appeared on the computer screen
#' for 0.75 s. If the response was correct, the word "Correct" was presented;
#' otherwise, the word "Incorrect" was presented.  Following presentation of
#' feedback, a blank screen followed the duration of which was again defined the
#' `delay` condition. The screen was blank for either 5 s (No Delay condition)
#' or 0.5 s (Delay condition) before the next trial commenced. The sequence and
#' timing of these events were same as those used by Maddox and Ing (2005).
#' 
#' \describe{
#'   \item{participant}{id}
#'   \item{delay}{delay condition (delay or no delay)}
#'   \item{strucutre}{rule-based or information-integration}
#'   \item{block}{block number}
#'   \item{pc}{percent correct}
#' }
#'
#' @source Dunn, J. C., Newell, B. R., & Kalish, M. L. (2012). The effect of
#'   feedback delay and feedback type on perceptual category learning: The
#'   limits of multiple systems. \emph{Journal of Experimental Psychology:
#'   Learning, Memory, and Cognition}, 38(4), 840-859.
#'   \doi{10.1037/a0027867}
#'   
#' @references Maddox, W. T., & Ing, A. D. (2005). Delayed Feedback Disrupts the
#'   Procedural-Learning System but Not the Hypothesis-Testing System in
#'   Perceptual Category Learning. *Journal of Experimental Psychology: Learning,
#'   Memory, and Cognition*, 31(1), 100-107.
#'   \doi{10.1037/0278-7393.31.1.100}
"delay"
