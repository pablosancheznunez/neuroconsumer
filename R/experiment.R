#' Create an Experimental Container
#'
#' @description
#' The central container for controlled visual experimentation in consumer research.
#' Holds the reference stimulus, declared manipulations, factorial design matrix,
#' generated variants, AOIs, and validation reports.
#'
#' @param id A unique character string identifier for the experiment.
#' @param title A human-readable title.
#' @param reference An `nc_stimulus` object acting as the baseline reference layout.
#'
#' @return An S3 object of class `nc_experiment`.
#' @export
#'
#' @examples
#' comp <- nc_component("hero", type = "product", x = 0.5, y = 0.5)
#' stim <- nc_stimulus("base_ad", list(comp))
#' exp <- nc_experiment("ad_study_01", title = "Price Display Study", reference = stim)
nc_experiment <- function(id, title = id, reference = NULL) {
  if (!is.character(id) || length(id) != 1L || nchar(id) == 0) {
    stop("`id` must be a non-empty character string.", call. = FALSE)
  }

  if (is.null(reference)) {
    reference <- nc_stimulus("reference_stimulus")
  } else if (!inherits(reference, "nc_stimulus")) {
    stop("`reference` must be of class `nc_stimulus`.", call. = FALSE)
  }

  structure(
    list(
      id = as.character(id),
      title = as.character(title),
      reference = reference,
      manipulations = list(),
      design = data.frame(condition_id = "ref", stringsAsFactors = FALSE),
      variants = list(ref = reference),
      metadata = list(
        created_at = as.character(Sys.time()),
        r_version = R.version.string
      )
    ),
    class = "nc_experiment"
  )
}

#' Summarize Design Conditions in an Experiment
#'
#' @param experiment An `nc_experiment` object.
#'
#' @return A `data.frame` of experimental conditions and factor levels.
#' @export
#'
#' @examples
#' comp <- nc_component("cta", type = "cta", x = 0.5, y = 0.8)
#' stim <- nc_stimulus("ad", list(comp))
#' exp <- nc_experiment("test", reference = stim)
#' nc_design(exp)
nc_design <- function(experiment) {
  if (!inherits(experiment, "nc_experiment")) {
    stop("`experiment` must be of class `nc_experiment`.", call. = FALSE)
  }
  experiment$design
}

#' @export
print.nc_experiment <- function(x, ...) {
  cat("<nc_experiment: ", x$id, " (", x$title, ")>\n", sep = "")
  cat(sprintf("  Reference components: %d\n", length(x$reference$components)))
  cat(sprintf("  Manipulations (%d factors declared):\n", length(x$manipulations)))
  for (f in names(x$manipulations)) {
    m <- x$manipulations[[f]]
    cat(sprintf("    - %s: component '%s' -> %s [%s]\n",
                f, m$component, m$parameter, paste(names(m$levels), collapse = ", ")))
  }
  cat(sprintf("  Generated variants: %d conditions\n", length(x$variants)))
  invisible(x)
}
