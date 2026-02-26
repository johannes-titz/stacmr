
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stacmr

<!-- badges: start -->

[![R-CMD-check](https://github.com/monotonicity/stacmr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/monotonicity/stacmr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/monotonicity/stacmr/graph/badge.svg)](https://app.codecov.io/gh/monotonicity/stacmr)
<!-- badges: end -->

The goal of `stacmr` is to provide functionality for state-trace
analysis via conjoint monotonic regression. The main function for this
is `cmr()`. In addition, it provides functionality for fitting monotonic
regression models with function `mr()`.

## Installation

You can install the released version of stacmr from
[CRAN](https://CRAN.R-project.org) with:

``` r
## NOT YET AVAILABLE FROM CRAN
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("monotonicity/stacmr")
```

## Example

This is a basic example.

``` r
library(stacmr)
## load data from Exp. 1 of Dunn, Newell, & Kalish (2012)
data(delay)
str(delay, width = 78, strict.width = "cut")
#> 'data.frame':    520 obs. of  5 variables:
#>  $ participant: Factor w/ 130 levels "1","2","3","4",..: 1 2 3 4 5 6 7 8 9 1..
#>  $ delay      : Factor w/ 2 levels "delay","no delay": 1 2 2 1 1 2 2 1 1 1 ...
#>  $ structure  : Factor w/ 2 levels "rule-based","information-integration": 1..
#>  $ block      : Factor w/ 4 levels "B1","B2","B3",..: 1 1 1 1 1 1 1 1 1 1 ...
#>  $ pc         : num  0.338 0.287 0.525 0.35 0.237 ...

stats <- sta_stats(
  data = delay, 
  col_value = "pc", 
  col_participant = "participant",
  col_dv = "structure", 
  col_within = "block", 
  col_between = "delay"
)
stats
#>   rule.based information.integration within  between N_rule.based
#> 1      0.344                   0.284     B1    delay           34
#> 2      0.443                   0.303     B2    delay           34
#> 3      0.508                   0.318     B3    delay           34
#> 4      0.517                   0.310     B4    delay           34
#> 5      0.368                   0.331     B1 no delay           34
#> 6      0.468                   0.455     B2 no delay           34
#> 7      0.576                   0.535     B3 no delay           34
#> 8      0.612                   0.549     B4 no delay           34
#>   N_information.integration
#> 1                        32
#> 2                        32
#> 3                        32
#> 4                        32
#> 5                        30
#> 6                        30
#> 7                        30
#> 8                        30


### cmr() fits conjoint monotonic regression for state-trace analysis
## Fit and test CMR State-Trace Analysis Model
st_d1 <- cmr(
  data = delay, 
  col_value = "pc", 
  col_participant = "participant",
  col_dv = "structure", 
  col_within = "block", 
  col_between = "delay", 
  nsample = 1e4
)
st_d1  ## basic information about conjoint-monotonic model
#> 
#> CMR fit to 8 data points with call:
#> cmr(data = delay, col_value = "pc", col_participant = "participant", 
#>     col_dv = "structure", col_within = "block", col_between = "delay", 
#>     nsample = 10000)
#> 
#> DVs: rule-based & information-integration 
#> Within: block 
#> Between: delay 
#> 
#> Fit value (SSE): 1.653
#> Fit difference to MR model (SSE): 1.653
#> p-value (based on 10000 samples): 0.3453

summary(st_d1)  ## basic information plus estimated cell means
#> 
#> CMR fit to 8 data points with call:
#> cmr(data = delay, col_value = "pc", col_participant = "participant", 
#>     col_dv = "structure", col_within = "block", col_between = "delay", 
#>     nsample = 10000)
#> 
#> Fit value (SSE): 1.653
#> Fit difference to MR model (SSE): 1.653
#> p-value (based on 10000 samples): 0.3453 
#> 
#> Estimated cell means:
#>   rule.based information.integration within  between
#> 1     0.3352                  0.2861     B1    delay
#> 2     0.4199                  0.3149     B2    delay
#> 3     0.4834                  0.3256     B3    delay
#> 4     0.4834                  0.3178     B4    delay
#> 5     0.3751                  0.3149     B1 no delay
#> 6     0.4834                  0.4357     B2 no delay
#> 7     0.5885                  0.5165     B3 no delay
#> 8     0.6252                  0.5316     B4 no delay

### cmr() also accepts partial order. 
## CMR model is tested against MR model with partial order 
st_d3 <- cmr(
  data = delay, 
  col_value = "pc", 
  col_participant = "participant",
  col_dv = "structure", 
  col_within = "block", 
  col_between = "delay", 
  partial = "auto"
)
st_d3
#> 
#> CMR fit to 8 data points with call:
#> cmr(data = delay, col_value = "pc", col_participant = "participant", 
#>     col_dv = "structure", col_within = "block", col_between = "delay", 
#>     partial = "auto")
#> 
#> DVs: rule-based & information-integration 
#> Within: block 
#> Between: delay 
#> 
#> Fit value (SSE): 1.749
#> Fit difference to MR model (SSE): 1.577
#> p-value (based on 1000 samples): 0.159
summary(st_d3)
#> 
#> CMR fit to 8 data points with call:
#> cmr(data = delay, col_value = "pc", col_participant = "participant", 
#>     col_dv = "structure", col_within = "block", col_between = "delay", 
#>     partial = "auto")
#> 
#> Fit value (SSE): 1.749
#> Fit difference to MR model (SSE): 1.577
#> p-value (based on 1000 samples): 0.159 
#> 
#> Estimated cell means:
#>   rule.based information.integration within  between
#> 1     0.3353                  0.2856     B1    delay
#> 2     0.4186                  0.3150     B2    delay
#> 3     0.4806                  0.3227     B3    delay
#> 4     0.4850                  0.3227     B4    delay
#> 5     0.3759                  0.3150     B1 no delay
#> 6     0.4850                  0.4358     B2 no delay
#> 7     0.5898                  0.5167     B3 no delay
#> 8     0.6265                  0.5318     B4 no delay
```

## Changes to upstream JT

- singmann changes are starting on may 24, 2019
- kalish repo last change before that is on february 28, 2019
- kalish repo had changes made after may 24, 2019

The only file that was massively chaned is gen2list.R, which is
basically a rewrite.

Otherwise we can just take the upstream files. As far as I can see, the
cahnges were cosmetic, mainly returning more information in the output
(e.g. bootstrap means), although one change appears to be a bug fix,
where nCond is changed from length(y\[\[1\]\]\[\[1\]\] to
length(y\[\[1\]\]\[\[1\]\]\[1,\])), but that seems to be for
list-inputs, not for data-frames.

what is missing in stacmr is staCMRFIT.R (testing the difference between
fits of monotonic model and partial order model) and staMRFIT.R (testing
the fit of a partial order), which are replaced by cmr and mr,
respectively in continuous_state-trace.R. So changes in staCMRFIT.R and
staMRFIT.R must be tracked carefully. The changes to date included
adding `pars` to the output, that’s it.

## todos JT

apper for binomial data. This is currently in the dunn & kalish format
in the files that include BN.

in the upstream code pars argument is missing in jMRfits.R -\> this is
is definitely an issue that should be filed in STA

we need to think about maintaining the code…is it better to rely on
upstream R wrappers or on own R wrappers? if there are any changes to
upstream code, it might be a mess to integrate them, then again the
original wrappers are not ideal anyway.

can we get this on cran with java binaries? or building on cran with
maven?
