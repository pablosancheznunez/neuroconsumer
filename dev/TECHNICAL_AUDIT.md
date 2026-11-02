# NeuroConsumer — Technical Audit

**Audit date:** 2026-11-02
**Auditor:** Antigravity Agent (primary development agent)
**Audit type:** Pre-development environment and feasibility audit
**Repository status:** Greenfield — no existing code

---

## 1. Executive summary

NeuroConsumer does not exist yet as a repository. This audit assesses the development
environment, identifies the author's conventions from existing packages, maps the
competitive landscape, and evaluates technical feasibility for the package as
specified.

**Overall readiness: ✅ READY — no blockers identified.**

The development environment has all required tools. The scientific scope is
well-differentiated from existing packages. The primary technical risk is the
SVG rendering pipeline, which requires careful design to produce deterministic,
component-addressable output from base R graphics.

---

## 2. Development environment

### 2.1 R installation

| Item | Value | Status |
|------|-------|--------|
| R version | 4.6.2 (2026-10-29 ucrt) "Diversified Portfolio" | ✅ Latest |
| Platform | x86_64-w64-mingw32/x64 (Windows) | ✅ |
| Location | `C:\Program Files\R\R-4.6.2\` | ✅ |
| Backup R | R 4.5.2 also installed | ✅ |
| Native pipe | Available (`|>` since R 4.1.0) | ✅ |

### 2.2 Build tools

| Item | Value | Status |
|------|-------|--------|
| Rtools | Rtools45 at `C:\rtools45` | ✅ |
| make | `C:\rtools45\usr\bin\make.exe` | ✅ |
| `pkgbuild::has_build_tools()` | `TRUE` | ✅ |
| Git | 2.56.0.windows.4 | ✅ |
| Git user | Pablo Sánchez-Núñez | ✅ |
| Git email | `90710802+pablosancheznunez@users.noreply.github.com` | ✅ |

### 2.3 Key development packages

| Package | Version | Purpose | Status |
|---------|---------|---------|--------|
| devtools | 2.5.2 | Package development | ✅ |
| testthat | 3.3.2 | Testing | ✅ |
| roxygen2 | 8.1.1 | Documentation | ✅ |
| usethis | 3.2.2 | Package scaffolding | ✅ |
| pkgdown | 2.2.1 | Website generation | ✅ |
| rcmdcheck | 1.4.0 | CRAN checks | ✅ |
| knitr | 1.52 | Vignettes | ✅ |
| rmarkdown | 2.32 | Report rendering | ✅ |
| pak | 0.11.1 | Package management | ✅ |
| renv | 1.3.1 | Reproducible environments | ✅ |

### 2.4 Graphics and rendering packages

| Package | Version | Relevance | Status |
|---------|---------|-----------|--------|
| grDevices (base) | 4.6.2 | SVG device, colour manipulation | ✅ Built-in |
| graphics (base) | 4.6.2 | Base plotting primitives | ✅ Built-in |
| grid (base) | 4.6.2 | Low-level grid graphics | ✅ Built-in |
| png | 0.1-9 | PNG read/write | ✅ Installed |
| jpeg | 0.1-11 | JPEG read/write | ✅ Installed |
| tiff | 0.1-12 | TIFF read/write | ✅ Installed |
| systemfonts | 1.3.2 | Font discovery | ✅ Installed |
| textshaping | 1.0.5 | Text layout | ✅ Installed |

### 2.5 Missing packages (recommended for development)

| Package | Purpose | Priority |
|---------|---------|----------|
| covr | Code coverage reporting | High |
| lintr | Static code analysis | Medium |
| styler | Code formatting | Low |
| spelling | Spell checking documentation | Medium |

### 2.6 SVG and PNG rendering verification

| Test | Result | Notes |
|------|--------|-------|
| `svg()` device | ✅ Functional | Produces valid XML/SVG output |
| `png()` device | ✅ Functional | Base raster output works |
| SVG output structure | Valid `<?xml ...>` + `<svg>` | Standard SVG 1.1 via R's built-in device |
| Coordinate control | ✅ | `plot.new()` + `rect()`/`text()` with normalised coords |
| ragg (optional) | ❌ Not installed in R 4.6.2 | Not required; base `png()` sufficient |

> **Note:** R's built-in `svg()` device produces output via Cairo-style rendering.
> For deterministic, component-addressable SVG (needed for AOI-component mapping),
> the package will likely need to generate SVG markup programmatically rather than
> relying solely on `svg()`. This is the primary technical design decision for
> Module A (Stimulus Engine). See §5.

---

## 3. Repository status

| Item | Status |
|------|--------|
| Repository directory | `C:\Users\psanc\Desktop\R\neuroconsumer\` (just created, empty) |
| DESCRIPTION | ❌ Does not exist |
| NAMESPACE | ❌ Does not exist |
| R/ directory | ❌ Does not exist |
| tests/ directory | ❌ Does not exist |
| man/ directory | ❌ Does not exist |
| vignettes/ directory | ❌ Does not exist |
| .github/workflows/ | ❌ Does not exist |
| README.md | ❌ Does not exist |
| LICENSE | ❌ Does not exist |
| Git initialised | ❌ No |
| GitHub remote | ❌ Not created |
| CI/CD | ❌ Not configured |

**Conclusion:** This is a completely greenfield project. There is no existing code to
audit against the specification. The audit therefore focuses on environment readiness,
feasibility, and risk assessment.

---

## 4. Author conventions (from existing packages)

Analysed from: `abfunnel` (0.1.0), `visualbrief` (0.1.0), `uxlearn` (0.1.0),
`ixdLab` (0.2.0).

### 4.1 Naming and style

| Convention | Pattern | Example |
|------------|---------|---------|
| Package name | Lowercase, single word | `abfunnel`, `uxlearn` |
| Function prefix | 2–3 letter abbreviation + `_` | `af_analyse`, `af_design` |
| Function names | `snake_case` | `af_plot_funnel` |
| Class names | Prefix + noun | `af_design`, `af_result` |
| Object system | S3 exclusively | `print.af_design` |
| Language | en-GB | `af_analyse` (not `af_analyze`) |

### 4.2 Package metadata

| Field | Consistent value |
|-------|-----------------|
| License | MIT + file LICENSE |
| Depends | R (>= 4.1.0) |
| Encoding | UTF-8 |
| Language | en-GB |
| LazyData | true |
| Roxygen | `list(markdown = TRUE)` |
| Config/roxygen2/version | 8.1.1 |
| Config/testthat/edition | 3 |
| VignetteBuilder | knitr |

### 4.3 Dependency philosophy

**Zero tidyverse.** All existing packages import only base/recommended packages:

- `stats`, `grDevices`, `graphics`, `utils`, `tools`
- Exception: `ixdLab` imports `shiny` and `bslib` (Shiny-specific)

### 4.4 Author identity

```r
Authors@R:
    person("Pablo", "Sánchez-Núñez",
           email = "psancheznunez@outlook.com",
           role = c("aut", "cre", "cph"),
           comment = c(ORCID = "0000-0001-7845-9506"))
```

### 4.5 Web presence

| Item | Pattern |
|------|---------|
| GitHub | `https://github.com/pablosancheznunez/{package}` |
| pkgdown site | `https://pablosancheznunez.com/{package}/` |
| Bug reports | `https://github.com/pablosancheznunez/{package}/issues` |

### 4.6 CI/CD gap

**None of the author's existing packages have GitHub Actions configured.**
This is a gap that should be addressed from day one with NeuroConsumer.

---

## 5. Technical feasibility assessment

### 5.1 SVG rendering strategy

The specification requires deterministic, component-addressable SVG output where
each visual component (product, brand, headline, price, CTA, etc.) is identifiable
in the output file and mappable to AOIs.

**Option A: R's built-in `svg()` device**

- ✅ No external dependency
- ❌ Output is a monolithic rendering; individual components are not tagged with semantic IDs
- ❌ No control over SVG element attributes (e.g., `id`, `class`, `data-component`)
- ❌ Coordinate mapping from normalised to SVG coordinates requires reverse engineering

**Option B: Programmatic SVG generation (recommended)**

- ✅ Full control over SVG structure, element IDs, and attributes
- ✅ Each component maps directly to an SVG group (`<g id="component_price">`)
- ✅ AOIs can be embedded as transparent overlay rectangles
- ✅ Deterministic: same inputs always produce identical SVG text
- ✅ No dependency beyond base R string operations
- ❌ Requires implementing text measurement (font metrics) or accepting simplified text layout
- ❌ Typography quality depends on viewer, not R's graphics engine

**Recommendation:** Use programmatic SVG generation (Option B) for the stimulus engine.
Use R's `svg()` or `png()` device only for preview rendering via `nc_preview()`.
This gives the package full control over component identifiers, AOI geometry,
and deterministic output.

### 5.2 PNG export strategy

PNG export can be achieved by:

1. **From SVG**: Render the programmatic SVG to PNG via `rsvg::rsvg_png()` (rsvg 2.7.0 is installed ✅)
2. **Direct**: Use base R `png()` device with grid graphics for a separate rendering path
3. **Hybrid**: Generate SVG first, then convert to PNG (recommended for consistency)

**Recommendation:** Generate SVG as the canonical output, then convert to PNG via `rsvg`.
This ensures pixel-identical correspondence between SVG and PNG versions.

### 5.3 Normalised coordinate system

The specification calls for a normalised coordinate system. R's `grid` package
supports arbitrary viewports with normalised (0–1) or absolute coordinates.
This maps naturally to the requirement.

**Feasibility: ✅ Straightforward with base R `grid` or manual coordinate transforms.**

### 5.4 Factorial design generation

Generating factorial conditions from declared factors is straightforward with
`expand.grid()` (base R). No external dependency needed.

**Feasibility: ✅ Trivial in base R.**

### 5.5 Experimental invariant validation

Comparing parameter sets across variants to detect expected vs. unexpected
differences is fundamentally a set-comparison operation on named lists.

**Feasibility: ✅ Straightforward with base R list comparison operations.**

### 5.6 Provenance and reproducibility

Capturing R session info, random seeds, timestamps, and package versions is
supported by `sessionInfo()`, `Sys.time()`, `.Random.seed`, and `packageVersion()`.

**Feasibility: ✅ Fully supported in base R.**

---

## 6. Competitive landscape positioning

### 6.1 Adjacent packages

| Package | Domain | Overlap with NeuroConsumer |
|---------|--------|--------------------------|
| `eyeprocess` | Multimodal process-data analysis | None — analyses collected data, does not create stimuli |
| `imagefluency` | Visual feature measurement | Minimal — measures image properties; NC creates controlled stimuli |
| `rcicr` | Reverse-correlation image classification | None — different paradigm entirely |
| `eyetools` | Eye-tracking data analysis | None — analyses gaze data, does not manage stimuli |
| `kollaR` | Eye-tracking data analysis | None — post-collection analysis |
| `cbcTools` | Choice-based conjoint design | Partial — designs choice experiments, but for attribute profiles not visual stimuli |
| `conjoint` | Conjoint analysis | Partial — statistical analysis of conjoint data |
| `stimupy` (Python) | Visual stimulus generation | Moderate — generates visual patterns, but for psychophysics not advertising |

### 6.2 Gap analysis

**No existing R package provides:**

1. ✅ Programmatic construction of multi-component visual advertising stimuli
2. ✅ Declarative experimental manipulations on visual stimulus parameters
3. ✅ Automatic AOI generation from visual components with stable identifiers
4. ✅ Invariant validation across experimental variants
5. ✅ Deterministic SVG/PNG export with component-level addressability
6. ✅ Integrated experiment documentation and provenance

**NeuroConsumer occupies a genuinely unserved niche.** The closest tools are either
in a different language (stimupy), in a different domain (cbcTools), or address
a different stage of the research pipeline (eyetools, imagefluency).

---

## 7. Risk assessment

### 7.1 Technical risks

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| SVG text measurement without font metrics | Medium | High | Accept approximate positioning; document limitation; optionally use `systemfonts` for precise metrics |
| Cross-platform SVG rendering inconsistencies | Low | Medium | Test on Windows, macOS, Linux; document viewer requirements |
| `rsvg` dependency for PNG conversion | Low | Low | Already installed; widely available on CRAN; fallback to base `png()` possible |
| Complexity of programmatic SVG generation | Medium | Medium | Keep SVG subset minimal (rect, text, image, group); build incrementally |
| CRAN compliance with SVG string generation | Low | Low | No external system calls needed; pure R string operations |
| Test reproducibility across platforms | Medium | Medium | Use `withr::with_seed()` for randomisation; normalise line endings |

### 7.2 Scope risks

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Scope creep into eye-tracking/EEG/physiological signals | High | Medium | Specification explicitly prohibits this in v1; enforce in code review |
| Over-engineering the S3 class hierarchy | Medium | Medium | Start minimal; add complexity only when demonstrated necessary |
| Premature optimisation of rendering pipeline | Low | Medium | Profile only after the demo experiment runs |

### 7.3 Process risks

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| No CI/CD precedent in author's workflow | Medium | High | Establish GitHub Actions from Phase 0 |
| Missing code coverage tooling (covr) | Low | High | Install covr early |
| Single-developer bus factor | Medium | — | Comprehensive documentation and tests |

---

## 8. Recommendations

### 8.1 Pre-development actions (before Stage 2)

1. **Install `covr`** for code coverage reporting.
2. **Install `lintr`** for static analysis in CI.
3. **Create GitHub repository** and configure branch protection.
4. **Set up GitHub Actions** using `r-lib/actions` for R-CMD-check on ubuntu-latest, windows-latest, macOS-latest.
5. **Review and approve** ARCHITECTURE.md and DEVELOPMENT_ROADMAP.md.

### 8.2 Design decisions requiring early resolution

1. **SVG generation approach:** Programmatic (recommended) vs. device-based.
2. **PNG conversion dependency:** `rsvg` as Suggests (recommended) vs. base `png()` only.
3. **Font handling:** Accept simplified text metrics vs. depend on `systemfonts`.
4. **Minimum R version:** R >= 4.1.0 (for native pipe `|>`; consistent with author convention).
5. **Function prefix:** `nc_` (consistent with `neuroconsumer`, concise, available).

### 8.3 Proposed dependency budget

**Imports (base/recommended only):**

- `grDevices` — colour manipulation, device handling
- `graphics` — base plotting (for `nc_preview()`)
- `grid` — viewport/coordinate system
- `stats` — basic statistics for validation summaries
- `utils` — general utilities

**Suggests:**

- `testthat` (>= 3.0.0) — testing
- `knitr` — vignettes
- `rmarkdown` — reports and vignettes
- `rsvg` — SVG-to-PNG conversion
- `png` — PNG file I/O for pixel comparison
- `covr` — code coverage (CI only)

**Not imported:**

- No tidyverse packages
- No ggplot2
- No data.table
- No external web services

---

## 9. Feasibility conclusion

> **Can NeuroConsumer become a technically robust and scientifically differentiated
> R package for controlled visual experimentation in consumer research?**

**Yes.** The evidence supports this conclusion:

1. **Technical feasibility is confirmed.** All required rendering primitives (SVG, PNG),
   coordinate systems, factorial design generation, and validation operations are
   achievable with base R and minimal dependencies.

2. **The niche is genuinely unserved.** No existing R package integrates programmatic
   stimulus construction, declarative manipulations, AOI management, invariant
   validation, and deterministic export in a single coherent workflow.

3. **The development environment is complete.** R 4.6.2, Rtools45, and all required
   development packages are installed and functional.

4. **The author's conventions are well-established** and provide a strong foundation
   for consistent package design.

5. **The specification is well-scoped.** Restricting v1 to static digital advertising
   stimuli is a tractable first release that demonstrates the full pipeline without
   excessive complexity.

**Primary technical challenge:** Designing the programmatic SVG generation module
to produce clean, component-addressable, deterministic output with acceptable text
layout quality. This is solvable but requires careful design in Stage 2.

**Recommendation:** Proceed to Architecture and Roadmap review, then Stage 2
implementation upon approval.

---

*Audit generated by Antigravity Agent. Last updated: 2026-11-02T16:26+01:00.*
