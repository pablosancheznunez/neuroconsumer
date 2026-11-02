# neuroconsumer: Controlled Visual Experimentation in Consumer Research

<!-- badges: start -->
[![R-CMD-check](https://github.com/pablosancheznunez/neuroconsumer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pablosancheznunez/neuroconsumer/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`neuroconsumer` is an R toolkit designed as a controlled visual experimentation environment for consumer research and advertising studies.

## Core Principles

- **Stimulus-First Design:** Programmatic composition of multi-component visual stimuli.
- **Declarative Manipulations:** Explicit declaration of factors, levels, and parameter transformations.
- **Experimental Invariant Verification:** Mathematical verification guaranteeing that conditions differ only in declared manipulated dimensions.
- **Deterministic Export & AOIs:** Semantic SVG/PNG rendering with automatic derivation of persistent Areas of Interest.

## Installation

```r
# Install development version from GitHub
# install.packages("remotes")
remotes::install_github("pablosancheznunez/neuroconsumer")
```

## Quick Start: 2x2 Factorial Experiment

```r
library(neuroconsumer)

# 1. Create reference stimulus
bg <- nc_component("bg", type = "background", width = 1, height = 1, properties = list(fill = "#F8FAFC"))
brand <- nc_component("brand", type = "brand", x = 0.5, y = 0.1, properties = list(text = "LUMINA"))
product <- nc_component("product", type = "product", x = 0.5, y = 0.4, width = 0.4, height = 0.3)
price <- nc_component("price", type = "price", x = 0.5, y = 0.65, properties = list(text = "$149.00"))
cta <- nc_component("cta", type = "cta", x = 0.5, y = 0.82, properties = list(text = "Buy Now", fill = "#94A3B8"))

ref_stimulus <- nc_stimulus("ad_reference", list(bg, brand, product, price, cta))
exp <- nc_experiment("display_ad_study", reference = ref_stimulus)

# 2. Declare manipulations
exp <- nc_manipulate(exp, factor = "price_pos", component = "price",
                     parameter = "y", levels = c(upper = 0.60, lower = 0.72))
exp <- nc_manipulate(exp, factor = "cta_contrast", component = "cta",
                     parameter = "properties.fill", levels = c(low = "#94A3B8", high = "#E11D48"))

# 3. Validate invariants across all 4 generated conditions
report <- nc_validate(exp)
print(report)

# 4. Extract AOIs
aois <- nc_aoi_from_components(exp$variants[[1]])
nc_aoi_to_df(aois, canvas_width = 1200, canvas_height = 900)
```

## License

MIT © Pablo Sánchez-Núñez
