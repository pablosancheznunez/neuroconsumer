#' Construct an Experimental Visual Stimulus
#'
#' @description
#' Creates a composite visual stimulus containing multiple components positioned
#' in normalized coordinates on a defined canvas.
#'
#' @param id A unique character string identifier for the stimulus.
#' @param components A list of `nc_component` objects.
#' @param width Canvas width in pixels. Default is 1200.
#' @param height Canvas height in pixels. Default is 900.
#' @param background_color Canvas background fill colour. Default is "#FFFFFF".
#'
#' @return An S3 object of class `nc_stimulus`.
#' @export
#'
#' @examples
#' comp1 <- nc_component("bg", type = "background", width = 1, height = 1)
#' comp2 <- nc_component("title", type = "headline", x = 0.5, y = 0.2,
#'                       properties = list(text = "Hello World"))
#' stim <- nc_stimulus("stim_01", components = list(comp1, comp2))
nc_stimulus <- function(id,
                        components = list(),
                        width = 1200,
                        height = 900,
                        background_color = "#FFFFFF") {
  if (!is.character(id) || length(id) != 1L || nchar(id) == 0) {
    stop("`id` must be a non-empty character string.", call. = FALSE)
  }
  if (!is.numeric(width) || width <= 0) {
    stop("`width` must be a positive number.", call. = FALSE)
  }
  if (!is.numeric(height) || height <= 0) {
    stop("`height` must be a positive number.", call. = FALSE)
  }
  if (!is.list(components)) {
    stop("`components` must be a list of `nc_component` objects.", call. = FALSE)
  }

  comp_dict <- list()
  if (length(components) > 0) {
    for (i in seq_along(components)) {
      c_item <- components[[i]]
      if (!inherits(c_item, "nc_component")) {
        stop(sprintf("Item %d in `components` is not an `nc_component`.", i), call. = FALSE)
      }
      if (c_item$id %in% names(comp_dict)) {
        stop(sprintf("Duplicate component id detected: '%s'.", c_item$id), call. = FALSE)
      }
      comp_dict[[c_item$id]] <- c_item
    }
  }

  structure(
    list(
      id = as.character(id),
      canvas = list(
        width = as.integer(width),
        height = as.integer(height),
        background_color = as.character(background_color)
      ),
      components = comp_dict
    ),
    class = "nc_stimulus"
  )
}

#' Add or Replace a Component in a Stimulus
#'
#' @param stimulus An `nc_stimulus` object.
#' @param component An `nc_component` object to add or update.
#'
#' @return An updated `nc_stimulus` object.
#' @export
#'
#' @examples
#' stim <- nc_stimulus("ad")
#' comp <- nc_component("brand", type = "brand", x = 0.5, y = 0.1)
#' stim <- nc_add_component(stim, comp)
nc_add_component <- function(stimulus, component) {
  if (!inherits(stimulus, "nc_stimulus")) {
    stop("`stimulus` must be of class `nc_stimulus`.", call. = FALSE)
  }
  if (!inherits(component, "nc_component")) {
    stop("`component` must be of class `nc_component`.", call. = FALSE)
  }
  stimulus$components[[component$id]] <- component
  stimulus
}

#' @export
print.nc_stimulus <- function(x, ...) {
  cat("<nc_stimulus: ", x$id, ">\n", sep = "")
  cat(sprintf("  Canvas: %d x %d px (bg: %s)\n", x$canvas$width, x$canvas$height, x$canvas$background_color))
  cat(sprintf("  Components (%d):\n", length(x$components)))
  for (cid in names(x$components)) {
    c_item <- x$components[[cid]]
    cat(sprintf("    - %s [%s] at (%.2f, %.2f) z=%d\n", c_item$id, c_item$type, c_item$x, c_item$y, c_item$z_index))
  }
  invisible(x)
}
