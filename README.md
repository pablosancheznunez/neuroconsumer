# neuroconsumer <img src="man/figures/logo.png" align="right" height="139" alt="neuroconsumer logo" />

<!-- badges: start -->
[![CI](https://github.com/pablosancheznunez/neuroconsumer/actions/workflows/ci.yml/badge.svg)](https://github.com/pablosancheznunez/neuroconsumer/actions/workflows/ci.yml)
[![Website](https://img.shields.io/badge/docs-pkgdown-24407a)](https://pablosancheznunez.com/neuroconsumer/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
<!-- badges: end -->

**Controlled visual experimentation in consumer research.**

neuroconsumer builds the visual stimuli for advertising and consumer-research experiments (eye tracking, attention, preference or choice studies) from code, so that every condition is reproducible and documented. You describe a reference stimulus once, declare which elements change and how, and the package:

- generates every condition of the factorial design from that reference;
- **verifies that conditions differ only in the declared dimensions**, so an unintended change in colour, size or position cannot slip into the experiment;
- renders each condition to deterministic SVG and PNG, with every element tagged by its identifier;
- derives Areas of Interest (AOIs) from the components, with identifiers that stay the same in every condition, ready to import into eye-tracking software.

It prepares and documents stimuli; it does not collect or analyse gaze or response data.

**Website:** <https://pablosancheznunez.com/neuroconsumer/> · **Example stimulus pack:** <https://pablosancheznunez.com/neuroconsumer/example/>

## Installation

```r
# install.packages("remotes")
remotes::install_github("pablosancheznunez/neuroconsumer")
```

neuroconsumer depends only on base R. Install [rsvg](https://cran.r-project.org/package=rsvg) for high-fidelity PNG output.

## Example: a 2 x 2 display-ad experiment

```r
library(neuroconsumer)

# 1. Reference stimulus: named components in normalised coordinates (0-1)
bg      <- nc_component("bg", type = "background", width = 1, height = 1,
                        properties = list(fill = "#F8FAFC"))
brand   <- nc_component("brand", type = "brand", x = 0.5, y = 0.1,
                        properties = list(text = "LUMINA"))
product <- nc_component("product", type = "product", x = 0.5, y = 0.4,
                        width = 0.4, height = 0.3)
price   <- nc_component("price", type = "price", x = 0.5, y = 0.65,
                        properties = list(text = "$149.00"))
cta     <- nc_component("cta", type = "cta", x = 0.5, y = 0.82,
                        properties = list(text = "Buy now", fill = "#94A3B8"))

exp <- nc_experiment("display_ad_study",
                     reference = nc_stimulus("ad_reference", list(bg, brand, product, price, cta)))

# 2. Declare the manipulations: price position x call-to-action contrast
exp <- nc_manipulate(exp, factor = "price_pos", component = "price",
                     parameter = "y", levels = c(upper = 0.60, lower = 0.72))
exp <- nc_manipulate(exp, factor = "cta_contrast", component = "cta",
                     parameter = "properties.fill", levels = c(low = "#94A3B8", high = "#E11D48"))
nc_design(exp)

# 3. Verify that the four conditions differ only where declared
nc_validate(exp)
#> [PASS] Experimental Invariant Validation: ALL CHECKS PASSED.

# 4. AOIs in pixels, and the stimuli as SVG/PNG
nc_aoi_to_df(nc_aoi_from_components(exp$variants[[1]]), canvas_width = 1200, canvas_height = 900)
nc_export(exp$variants[[1]], "condition_1.svg")
```

See the [gallery article](https://pablosancheznunez.com/neuroconsumer/articles/stimulus-gallery.html) for the rendered conditions with their AOIs.

## Main functions

| Step | Functions |
|---|---|
| Build stimuli | `nc_component()`, `nc_stimulus()`, `nc_add_component()` |
| Design | `nc_experiment()`, `nc_manipulate()`, `nc_build_variants()`, `nc_design()` |
| Verify | `nc_validate()` |
| Areas of Interest | `nc_aoi()`, `nc_aoi_from_components()`, `nc_aoi_to_df()` |
| Export | `nc_render_svg()`, `nc_export()` |

## Citation

If you use neuroconsumer in your research, please cite it; `citation("neuroconsumer")` gives the reference, and [CITATION.cff](CITATION.cff) is read by GitHub's "Cite this repository" button.

## Contributing

Bug reports and suggestions are welcome in the [issues](https://github.com/pablosancheznunez/neuroconsumer/issues). See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT © Pablo Sánchez-Núñez
