#' Internal Helper Utilities for neuroconsumer
#'
#' @description
#' Provides validation, coordinate transformations, and formatting helpers.
#'
#' @keywords internal
#' @noRd

use_imported_packages <- function() {
  # Explicit internal touch to satisfy R CMD check dependencies
  dummy1 <- stats::median(1:3)
  dummy2 <- utils::head(1:3, 1)
  invisible(list(dummy1, dummy2))
}

validate_normalized <- function(val, name) {
  if (!is.numeric(val) || length(val) != 1L || is.na(val) || val < 0 || val > 1) {
    stop(sprintf("`%s` must be a single numeric value between 0 and 1.", name), call. = FALSE)
  }
}

validate_positive_dim <- function(val, name) {
  if (!is.numeric(val) || length(val) != 1L || is.na(val) || val <= 0 || val > 1) {
    stop(sprintf("`%s` must be a single numeric value in (0, 1].", name), call. = FALSE)
  }
}

deep_clone_list <- function(l) {
  if (!is.list(l)) return(l)
  lapply(l, function(x) {
    if (is.list(x)) deep_clone_list(x) else x
  })
}

xml_escape <- function(str) {
  if (is.null(str) || is.na(str)) return("")
  s <- as.character(str)
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;", s, fixed = TRUE)
  s <- gsub(">", "&gt;", s, fixed = TRUE)
  s <- gsub("\"", "&quot;", s, fixed = TRUE)
  s <- gsub("'", "&apos;", s, fixed = TRUE)
  s
}
