#' Create an Experimental Visual Component
#'
#' @description
#' Constructs an experimental visual component with normalized canvas coordinates `[0, 1]`.
#'
#' @param id A unique character string identifier for the component.
#' @param type A character string denoting component type: "product", "brand",
#'   "headline", "text", "price", "cta", "background", or "shape".
#' @param x Horizontal centre position in normalized coordinates `[0, 1]`.
#' @param y Vertical centre position in normalized coordinates `[0, 1]`.
#' @param width Width in normalized coordinates `(0, 1]`.
#' @param height Height in normalized coordinates `(0, 1]`.
#' @param z_index Integer indicating rendering layer order (lowest rendered first).
#' @param visible Logical indicating visibility. Default is `TRUE`.
#' @param properties Named list of component-specific visual attributes (e.g. text,
#'   fill, color, font_size, font_family, font_weight, border_radius).
#'
#' @return An S3 object of class `nc_component`.
#' @export
#'
#' @examples
#' comp <- nc_component(
#'   id = "cta_button",
#'   type = "cta",
#'   x = 0.5,
#'   y = 0.85,
#'   width = 0.3,
#'   height = 0.08,
#'   properties = list(text = "Buy Now", fill = "#E11D48", color = "#FFFFFF")
#' )
nc_component <- function(id,
                         type = c("product", "brand", "headline", "text", "price", "cta", "background", "shape"),
                         x = 0.5,
                         y = 0.5,
                         width = 0.2,
                         height = 0.1,
                         z_index = 1L,
                         visible = TRUE,
                         properties = list()) {
  if (!is.character(id) || length(id) != 1L || nchar(id) == 0) {
    stop("`id` must be a non-empty character string.", call. = FALSE)
  }
  type <- match.arg(type)
  validate_normalized(x, "x")
  validate_normalized(y, "y")
  validate_positive_dim(width, "width")
  validate_positive_dim(height, "height")

  if (!is.numeric(z_index) || length(z_index) != 1L) {
    stop("`z_index` must be an integer.", call. = FALSE)
  }
  if (!is.logical(visible) || length(visible) != 1L) {
    stop("`visible` must be a logical value.", call. = FALSE)
  }
  if (!is.list(properties)) {
    stop("`properties` must be a named list.", call. = FALSE)
  }

  structure(
    list(
      id = as.character(id),
      type = type,
      x = as.numeric(x),
      y = as.numeric(y),
      width = as.numeric(width),
      height = as.numeric(height),
      z_index = as.integer(z_index),
      visible = as.logical(visible),
      properties = properties
    ),
    class = "nc_component"
  )
}

#' @export
print.nc_component <- function(x, ...) {
  cat("<nc_component: ", x$id, " [", x$type, "]>\n", sep = "")
  cat(sprintf("  Position (x, y): (%.3f, %.3f)\n", x$x, x$y))
  cat(sprintf("  Dimension (w, h): (%.3f, %.3f)\n", x$width, x$height))
  cat(sprintf("  Layer (z-index): %d | Visible: %s\n", x$z_index, x$visible))
  if (length(x$properties) > 0) {
    cat("  Properties:\n")
    for (p in names(x$properties)) {
      cat(sprintf("    - %s: %s\n", p, as.character(x$properties[[p]])))
    }
  }
  invisible(x)
}
