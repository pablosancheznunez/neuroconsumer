#' Declarative Experimental Manipulations
#'
#' @description
#' Defines factors, levels, and corresponding parameter transformations for visual stimuli.
#' Allows programmatic generation of condition variants while explicitly tracking
#' manipulated parameters versus invariants.
#'
#' @param experiment An `nc_experiment` object.
#' @param factor Name of the experimental factor (character string).
#' @param component Target component id to manipulate.
#' @param parameter Parameter path to modify (e.g. "x", "y", "width", "height", "properties.fill").
#' @param levels Named vector or list mapping level names to parameter values.
#'
#' @return An updated `nc_experiment` object.
#' @export
#'
#' @examples
#' comp <- nc_component("price", type = "price", x = 0.5, y = 0.8)
#' stim <- nc_stimulus("ad_ref", list(comp))
#' exp <- nc_experiment("pricing_study", reference = stim)
#' exp <- nc_manipulate(exp, factor = "price_pos", component = "price",
#'                      parameter = "y", levels = c(upper = 0.55, lower = 0.82))
nc_manipulate <- function(experiment, factor, component, parameter, levels) {
  if (!inherits(experiment, "nc_experiment")) {
    stop("`experiment` must be of class `nc_experiment`.", call. = FALSE)
  }
  if (!is.character(factor) || length(factor) != 1L || nchar(factor) == 0) {
    stop("`factor` must be a non-empty character string.", call. = FALSE)
  }
  if (!is.character(component) || length(component) != 1L) {
    stop("`component` must be a character string.", call. = FALSE)
  }
  if (!is.character(parameter) || length(parameter) != 1L) {
    stop("`parameter` must be a character string.", call. = FALSE)
  }
  if (is.null(names(levels)) || any(names(levels) == "")) {
    stop("`levels` must be a named vector or list (e.g. c(upper = 0.5, lower = 0.8)).", call. = FALSE)
  }

  manip <- list(
    factor = as.character(factor),
    component = as.character(component),
    parameter = as.character(parameter),
    levels = as.list(levels)
  )

  experiment$manipulations[[factor]] <- manip
  experiment <- nc_build_variants(experiment)
  experiment
}

#' Generate Experimental Variants from Manipulations
#'
#' @description
#' Evaluates all declared manipulations as a factorial design and constructs
#' distinct `nc_stimulus` variants corresponding to each condition.
#'
#' @param experiment An `nc_experiment` object.
#'
#' @return An `nc_experiment` object with updated conditions and stimulus variants.
#' @export
nc_build_variants <- function(experiment) {
  if (!inherits(experiment, "nc_experiment")) {
    stop("`experiment` must be of class `nc_experiment`.", call. = FALSE)
  }

  if (length(experiment$manipulations) == 0) {
    experiment$design <- data.frame(condition_id = "ref", stringsAsFactors = FALSE)
    experiment$variants <- list(ref = experiment$reference)
    return(experiment)
  }

  # Build grid of factors
  factor_levels <- lapply(experiment$manipulations, function(m) names(m$levels))
  grid <- expand.grid(factor_levels, stringsAsFactors = FALSE)
  grid$condition_id <- apply(grid, 1, function(row) {
    paste(names(grid), row, sep = "_", collapse = "__")
  })
  # Reorder columns so condition_id is first
  cols <- c("condition_id", setdiff(names(grid), "condition_id"))
  grid <- grid[, cols, drop = FALSE]

  variants <- list()
  for (i in seq_len(nrow(grid))) {
    cond_id <- grid$condition_id[i]
    var_stim <- deep_clone_list(experiment$reference)
    class(var_stim) <- class(experiment$reference)
    for (cid in names(var_stim$components)) {
      class(var_stim$components[[cid]]) <- "nc_component"
    }
    var_stim$id <- cond_id

    # Apply manipulations
    for (f_name in names(experiment$manipulations)) {
      m <- experiment$manipulations[[f_name]]
      lvl_name <- grid[i, f_name]
      val <- m$levels[[lvl_name]]

      if (!m$component %in% names(var_stim$components)) {
        stop(sprintf("Target component '%s' not found in stimulus.", m$component), call. = FALSE)
      }

      target <- var_stim$components[[m$component]]
      if (startsWith(m$parameter, "properties.")) {
        prop_key <- sub("^properties\\.", "", m$parameter)
        target$properties[[prop_key]] <- val
      } else {
        target[[m$parameter]] <- val
      }
      var_stim$components[[m$component]] <- target
    }

    variants[[cond_id]] <- var_stim
  }

  experiment$design <- grid
  experiment$variants <- variants
  experiment
}
