
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stacmr

<!-- badges: start -->

[![R-CMD-check](https://github.com/johannes-titz/stacmr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/johannes-titz/stacmr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/johannes-titz/stacmr/graph/badge.svg)](https://app.codecov.io/gh/johannes-titz/stacmr)
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
#>  $ delay      : Factor w/ 2 levels "no delay","delay": 2 1 1 2 2 1 1 2 2 2 ...
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
#> 1      0.368                   0.331     B1 no delay           34
#> 2      0.468                   0.455     B2 no delay           34
#> 3      0.576                   0.535     B3 no delay           34
#> 4      0.612                   0.549     B4 no delay           34
#> 5      0.344                   0.284     B1    delay           34
#> 6      0.443                   0.303     B2    delay           34
#> 7      0.508                   0.318     B3    delay           34
#> 8      0.517                   0.310     B4    delay           34
#>   N_information.integration
#> 1                        30
#> 2                        30
#> 3                        30
#> 4                        30
#> 5                        32
#> 6                        32
#> 7                        32
#> 8                        32


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
#> p-value (based on 10000 samples): 0.3433

summary(st_d1)  ## basic information plus estimated cell means
#> 
#> CMR fit to 8 data points with call:
#> cmr(data = delay, col_value = "pc", col_participant = "participant", 
#>     col_dv = "structure", col_within = "block", col_between = "delay", 
#>     nsample = 10000)
#> 
#> Fit value (SSE): 1.653
#> Fit difference to MR model (SSE): 1.653
#> p-value (based on 10000 samples): 0.3433 
#> 
#> Estimated cell means:
#>   rule.based information.integration within  between
#> 1     0.3751                  0.3149     B1 no delay
#> 2     0.4834                  0.4357     B2 no delay
#> 3     0.5885                  0.5165     B3 no delay
#> 4     0.6252                  0.5316     B4 no delay
#> 5     0.3352                  0.2861     B1    delay
#> 6     0.4199                  0.3149     B2    delay
#> 7     0.4834                  0.3256     B3    delay
#> 8     0.4834                  0.3178     B4    delay

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
#> Fit value (SSE): 31.66
#> Fit difference to MR model (SSE): 0
#> p-value (based on 1000 samples): 0.994
summary(st_d3)
#> 
#> CMR fit to 8 data points with call:
#> cmr(data = delay, col_value = "pc", col_participant = "participant", 
#>     col_dv = "structure", col_within = "block", col_between = "delay", 
#>     partial = "auto")
#> 
#> Fit value (SSE): 31.66
#> Fit difference to MR model (SSE): 0
#> p-value (based on 1000 samples): 0.994 
#> 
#> Estimated cell means:
#>   rule.based information.integration within  between
#> 1     0.3561                  0.2620     B1 no delay
#> 2     0.4427                  0.3347     B2 no delay
#> 3     0.5457                  0.3654     B3 no delay
#> 4     0.5708                  0.3663     B4 no delay
#> 5     0.3600                  0.2926     B1    delay
#> 6     0.4853                  0.3347     B2    delay
#> 7     0.5546                  0.3654     B3    delay
#> 8     0.5708                  0.3663     B4    delay
```

## Changes to upstream JT

- singmann changes are starting on may 24, 2019
- kalish repo last change before that is on february 28, 2019
- kalish repo had changes made after may 24, 2019

The only file that was massively changed is gen2list.R, which is
basically a rewrite.

Otherwise we can just take the upstream files. As far as I can see, the
changes were cosmetic, mainly returning more information in the output
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

Add wrapper for binomial data. This is currently in the dunn & kalish
format in the files that include BN.

Is it better to rely on upstream R wrappers or on own R wrappers? if
there are any changes to upstream code, it might be a mess to integrate
them, then again the original wrappers are not ideal anyway.

Can we get this on cran with java binaries? In general that seems
possible, we now include a dockerfile that can build the jar from
source; as far as I can see there is no non-free libs included.
