# Contributing

Thank you for helping improve neuroconsumer. Bug reports with a small example, new component types, export formats for eye-tracking software and ideas for the documentation are welcome.

## Running the tests

- `R CMD build . && R CMD check --as-cran neuroconsumer_*.tar.gz`
- or `devtools::check()`.

## Small changes (welcome as pull requests)

- Documentation, examples and the website.
- Compatibility fixes, as long as every test still passes unchanged.

## Changes to discuss in an issue first

- The invariant checks in `R/validation.R` and the AOI derivation in `R/aoi.R`: they are what makes the experiments trustworthy.
- Changes to the SVG output in `R/export.R`, which must stay deterministic.
- New dependencies: neuroconsumer deliberately depends only on base R.

Design notes from the first version are in [`dev/`](dev/).

Tests are never weakened or deleted to make them pass.
