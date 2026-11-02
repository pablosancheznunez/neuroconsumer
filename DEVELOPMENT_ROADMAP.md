# NeuroConsumer — Development Roadmap

**Package:** `neuroconsumer`  
**Target Release:** 0.1.0  
**Status:** Stage 1 Planned  
**Date:** 2026-11-02  

---

## Roadmap Overview

```
[ Stage 1: Technical Audit & Architecture ]  <== CURRENT (Completed)
                     |
                     v
[ Stage 2: Core Prototype & 2x2 Demonstration ]
  - Stimulus & Component Engine
  - Declarative Manipulations
  - Automatic AOI Derivation
  - Invariant Verification Engine
  - Deterministic SVG/PNG Export
  - Demonstration Experiment (Price Position x CTA Contrast)
                     |
                     v
[ Stage 3: Verification, Robustness & Edge Cases ]
  - Complete unit test suite (testthat 3)
  - Geometric intersection & boundary validation
  - Eye-tracker export formats (Tobii, Gazepoint, generic)
  - Provenance & checksum manifest generation
                     |
                     v
[ Stage 4: Package Infrastructure & CI ]
  - GitHub Actions (Ubuntu, Windows, macOS R-CMD-check)
  - Documentation (roxygen2 with markdown)
  - Vignettes (2x2 Factorial Guide, Methodological Limits)
  - pkgdown website generation
                     |
                     v
[ Stage 5: CRAN Readiness Review ]
  - R CMD check --as-cran with 0 errors, 0 warnings, 0 notes
  - User review & approval before any public submission
```

---

## Stage Breakdown

### Stage 1: Technical Audit and Design (Current)
- [x] Environment inspection (R 4.6.2, Rtools45, Git 2.56, installed packages).
- [x] Competitive landscape review (`eyeprocess`, `imagefluency`, `rcicr`, `eyetools`, `stimupy`, etc.).
- [x] Author convention alignment (base R imports, `nc_` prefix, S3 classes, en-GB).
- [x] Deliver `TECHNICAL_AUDIT.md`.
- [x] Deliver `ARCHITECTURE.md`.
- [x] Deliver `DEVELOPMENT_ROADMAP.md`.
- [ ] Present audit to researcher and obtain approval to begin implementation.

### Stage 2: Core Prototype & 2x2 Factorial Demonstration
**Target Deliverables:**
1. Package scaffold:
   - `DESCRIPTION`, `NAMESPACE`, `.Rbuildignore`, `.gitignore`, `LICENSE`, `LICENSE.md`.
2. Core constructors:
   - `nc_component()`: Primitive component types (product, brand, headline, text, price, cta, background).
   - `nc_stimulus()`: Composition container with normalized coordinates `[0, 1]`.
   - `nc_experiment()`: Experiment-level container.
3. Declarative manipulation:
   - `nc_manipulate()`: Factor and level definitions binding to component parameters.
   - Factorial expansion producing conditioned variants.
4. AOI derivation:
   - `nc_aoi_from_components()`: Automated calculation of bounding boxes with consistent IDs.
5. Invariant validation:
   - `nc_validate()`: Structural & parameter diff verification (detects unmanipulated property changes).
6. Deterministic renderer:
   - `nc_export_svg()` / `nc_export_png()`: Outputting clean SVG XML and raster images.
7. Demonstration experiment:
   - 2x2 Factorial: **Price position** (upper vs. lower) x **CTA contrast** (low vs. high).
   - Fully runnable from a clean R session.

### Stage 3: Quality, Robustness & Edge Cases
**Target Deliverables:**
1. Comprehensive test suite (`tests/testthat/`):
   - Geometry tests (out of bounds, zero/negative dimensions).
   - Overlap detection tests (intersection calculation).
   - Invariant failure detection (verifying that unauthorized property shifts throw errors).
   - Deterministic SVG string hashing tests.
2. Formatted exports:
   - Export AOI coordinates formatted for Tobii Studio/Lab, Gazepoint, and generic CSV.
3. Provenance manifest:
   - `nc_manifest()` creating an immutable record of checksums, seeds, and session information.

### Stage 4: Documentation & CI/CD
**Target Deliverables:**
1. Automated CI:
   - `.github/workflows/R-CMD-check.yaml` running across Linux, macOS, Windows.
2. Vignettes:
   - `vignettes/advertising-experiment.Rmd`: End-to-end tutorial using the demonstration experiment.
   - `vignettes/methodological-limits.Rmd`: Rigorous distinction between technical validation vs. psychological/perceptual claims.
3. Reference documentation:
   - Complete roxygen2 tags with executable examples for all public functions.

### Stage 5: CRAN Readiness & Review
**Target Deliverables:**
1. `rcmdcheck::rcmdcheck(args = "--as-cran")` clean execution.
2. Verification of zero tidyverse imports and strict base R compatibility.
3. Submission proposal presented to author for explicit authorization.

---

## Acceptance Criteria for Stage 2 Approval
1. The 2x2 demonstration experiment generates 4 variants from 1 reference stimulus.
2. `nc_validate()` passes on valid designs and flags introduced unexpected variance.
3. All exported SVGs are valid XML with clean component-level identifiers.
4. Unit tests execute and pass via `devtools::test()`.
