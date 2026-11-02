#' Validate Experimental Invariants and Geometries
#'
#' @description
#' Performs rigorous verification that experimental variants differ only in declared
#' manipulated dimensions and preserves all invariant parameters, components, and geometries.
#'
#' @param experiment An `nc_experiment` object.
#'
#' @return An S3 object of class `nc_validation_report` containing detailed diagnostic checks.
#' @export
#'
#' @examples
#' comp <- nc_component("cta", type = "cta", x = 0.5, y = 0.8)
#' stim <- nc_stimulus("ad", list(comp))
#' exp <- nc_experiment("test", reference = stim)
#' rep <- nc_validate(exp)
#' rep$valid
nc_validate <- function(experiment) {
  if (!inherits(experiment, "nc_experiment")) {
    stop("`experiment` must be of class `nc_experiment`.", call. = FALSE)
  }

  checks <- list()
  ref_comps <- experiment$reference$components
  ref_comp_ids <- sort(names(ref_comps))

  # 1. Structural check: All variants must contain the exact same component IDs
  structural_ok <- TRUE
  unexpected_diffs <- list()

  # Identify which components and parameters are intentionally manipulated
  manip_map <- list()
  for (f_name in names(experiment$manipulations)) {
    m <- experiment$manipulations[[f_name]]
    if (!m$component %in% names(manip_map)) {
      manip_map[[m$component]] <- character(0)
    }
    manip_map[[m$component]] <- c(manip_map[[m$component]], m$parameter)
  }

  for (vid in names(experiment$variants)) {
    var_stim <- experiment$variants[[vid]]
    var_comp_ids <- sort(names(var_stim$components))

    if (!identical(ref_comp_ids, var_comp_ids)) {
      structural_ok <- FALSE
      unexpected_diffs[[paste0(vid, "_structure")]] <- "Component IDs mismatch reference stimulus."
    }

    # Parameter invariant checks
    for (cid in ref_comp_ids) {
      ref_c <- ref_comps[[cid]]
      var_c <- var_stim$components[[cid]]
      allowed_params <- manip_map[[cid]]

      # Check geometry invariance
      geom_params <- c("x", "y", "width", "height", "z_index", "visible")
      for (gp in geom_params) {
        if (!gp %in% allowed_params) {
          if (!identical(ref_c[[gp]], var_c[[gp]])) {
            unexpected_diffs[[paste0(vid, "_", cid, "_", gp)]] <- sprintf(
              "Invariant violation in condition '%s', component '%s', parameter '%s': ref=%.3f, var=%.3f",
              vid, cid, gp, as.numeric(ref_c[[gp]]), as.numeric(var_c[[gp]])
            )
          }
        }
      }

      # Check properties invariance
      ref_props <- ref_c$properties
      var_props <- var_c$properties
      for (p_key in names(ref_props)) {
        param_path <- paste0("properties.", p_key)
        if (!param_path %in% allowed_params) {
          if (!identical(ref_props[[p_key]], var_props[[p_key]])) {
            unexpected_diffs[[paste0(vid, "_", cid, "_", param_path)]] <- sprintf(
              "Invariant violation in condition '%s', component '%s', property '%s'",
              vid, cid, p_key
            )
          }
        }
      }
    }
  }

  # 2. Canvas geometry check
  canvas_ok <- TRUE
  out_of_bounds <- list()
  for (vid in names(experiment$variants)) {
    var_stim <- experiment$variants[[vid]]
    for (cid in names(var_stim$components)) {
      c_item <- var_stim$components[[cid]]
      if (c_item$x - (c_item$width / 2) < -1e-5 ||
          c_item$x + (c_item$width / 2) > 1 + 1e-5 ||
          c_item$y - (c_item$height / 2) < -1e-5 ||
          c_item$y + (c_item$height / 2) > 1 + 1e-5) {
        canvas_ok <- FALSE
        out_of_bounds[[paste0(vid, "_", cid)]] <- sprintf(
          "Component '%s' in condition '%s' exceeds normalized [0, 1] bounds.",
          cid, vid
        )
      }
    }
  }

  is_valid <- structural_ok && (length(unexpected_diffs) == 0) && canvas_ok

  structure(
    list(
      valid = is_valid,
      structural_equivalence = structural_ok,
      invariants_preserved = (length(unexpected_diffs) == 0),
      canvas_bounds_satisfied = canvas_ok,
      violations = unexpected_diffs,
      out_of_bounds = out_of_bounds,
      conditions_tested = length(experiment$variants)
    ),
    class = "nc_validation_report"
  )
}

#' @export
print.nc_validation_report <- function(x, ...) {
  if (x$valid) {
    cat("[PASS] Experimental Invariant Validation: ALL CHECKS PASSED.\n")
    cat(sprintf("  - Conditions verified: %d\n", x$conditions_tested))
    cat("  - Structural equivalence: YES\n")
    cat("  - Invariant parameters preserved: YES\n")
    cat("  - Normalized canvas bounds respected: YES\n")
  } else {
    cat("[FAIL] Experimental Invariant Validation: ISSUES DETECTED.\n")
    if (length(x$violations) > 0) {
      cat("  Violations:\n")
      for (v in x$violations) cat("    * ", v, "\n")
    }
    if (length(x$out_of_bounds) > 0) {
      cat("  Boundary errors:\n")
      for (b in x$out_of_bounds) cat("    * ", b, "\n")
    }
  }
  invisible(x)
}
