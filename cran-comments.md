## Resubmission

This is a resubmission of a new package. The automatic pre-tests of the first submission reported:

* Two WARNINGs because the vignette had not been built into the tarball. The tarball is now built with the vignette (`inst/doc` is present).
* A NOTE for the package website URL, which was not yet online. It is now live: <https://pablosancheznunez.com/neuroconsumer/>.
* Possibly misspelled words in DESCRIPTION ("AOIs", "invariants"). The sentence has been reworded without them.

## Test environments

* GitHub Actions: Ubuntu (R devel, release, oldrel-1), macOS (release), Windows (release).
* Local: Windows 11 x64, R 4.6.2 ucrt.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for CRAN

* neuroconsumer is a controlled visual experimentation environment for consumer research.
* Generates vector stimuli (SVG) and raster previews (PNG) deterministically using base R graphics and grDevices.
* No external network calls, telemetry, or remote services are used.
