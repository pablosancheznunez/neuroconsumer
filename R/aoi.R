#' Define and Extract Areas of Interest (AOIs)
#'
#' @description
#' Defines Areas of Interest (AOIs) for eye-tracking experiments and visual analysis.
#' Can automatically extract precise bounding boxes from `nc_component` objects with
#' persistent component IDs across experimental conditions.
#'
#' @param id Unique identifier for the AOI.
#' @param component_id Identifier of the associated visual component.
#' @param xmin Minimum horizontal coordinate `[0, 1]`.
#' @param ymin Minimum vertical coordinate `[0, 1]`.
#' @param xmax Maximum horizontal coordinate `[0, 1]`.
#' @param ymax Maximum vertical coordinate `[0, 1]`.
#' @param label Optional descriptive label.
#'
#' @return An S3 object of class `nc_aoi`.
#' @export
#'
#' @examples
#' aoi <- nc_aoi("aoi_logo", component_id = "logo",
#'               xmin = 0.4, ymin = 0.1, xmax = 0.6, ymax = 0.2)
nc_aoi <- function(id,
                   component_id = id,
                   xmin,
                   ymin,
                   xmax,
                   ymax,
                   label = id) {
  validate_normalized(xmin, "xmin")
  validate_normalized(ymin, "ymin")
  validate_normalized(xmax, "xmax")
  validate_normalized(ymax, "ymax")

  if (xmax <= xmin) {
    stop("`xmax` must be strictly greater than `xmin`.", call. = FALSE)
  }
  if (ymax <= ymin) {
    stop("`ymax` must be strictly greater than `ymin`.", call. = FALSE)
  }

  structure(
    list(
      id = as.character(id),
      component_id = as.character(component_id),
      label = as.character(label),
      geometry = list(
        xmin = as.numeric(xmin),
        ymin = as.numeric(ymin),
        xmax = as.numeric(xmax),
        ymax = as.numeric(ymax)
      )
    ),
    class = "nc_aoi"
  )
}

#' Extract AOIs from Stimulus Components
#'
#' @description
#' Computes exact bounding box AOIs for every visible component in an `nc_stimulus`,
#' optionally expanding boundaries by a padding margin.
#'
#' @param stimulus An `nc_stimulus` object.
#' @param padding Numeric fraction added to each side in normalized coordinates. Default is 0.
#'
#' @return A list of `nc_aoi` objects, of class `nc_aoi_set`.
#' @export
#'
#' @examples
#' comp <- nc_component("cta", type = "cta", x = 0.5, y = 0.8, width = 0.2, height = 0.1)
#' stim <- nc_stimulus("ad", list(comp))
#' aois <- nc_aoi_from_components(stim)
nc_aoi_from_components <- function(stimulus, padding = 0) {
  if (!inherits(stimulus, "nc_stimulus")) {
    stop("`stimulus` must be of class `nc_stimulus`.", call. = FALSE)
  }
  if (!is.numeric(padding) || padding < 0) {
    stop("`padding` must be a non-negative numeric value.", call. = FALSE)
  }

  aois <- list()
  for (cid in names(stimulus$components)) {
    comp <- stimulus$components[[cid]]
    if (!comp$visible || comp$type == "background") next

    xmin <- max(0, comp$x - (comp$width / 2) - padding)
    xmax <- min(1, comp$x + (comp$width / 2) + padding)
    ymin <- max(0, comp$y - (comp$height / 2) - padding)
    ymax <- min(1, comp$y + (comp$height / 2) + padding)

    aoi_id <- paste0("aoi_", comp$id)
    aois[[aoi_id]] <- nc_aoi(
      id = aoi_id,
      component_id = comp$id,
      xmin = xmin,
      ymin = ymin,
      xmax = xmax,
      ymax = ymax,
      label = paste0(comp$type, ": ", comp$id)
    )
  }

  structure(aois, class = "nc_aoi_set")
}

#' Convert AOIs to a Data Frame
#'
#' @param aois An `nc_aoi_set` or list of `nc_aoi` objects.
#' @param canvas_width Optional canvas width in pixels for pixel coordinates.
#' @param canvas_height Optional canvas height in pixels for pixel coordinates.
#'
#' @return A `data.frame` containing AOI identifiers and coordinate boundaries.
#' @export
#'
#' @examples
#' comp <- nc_component("cta", type = "cta", x = 0.5, y = 0.8, width = 0.2, height = 0.1)
#' stim <- nc_stimulus("ad", list(comp))
#' aois <- nc_aoi_from_components(stim)
#' df <- nc_aoi_to_df(aois, 1200, 900)
nc_aoi_to_df <- function(aois, canvas_width = NULL, canvas_height = NULL) {
  if (length(aois) == 0) {
    return(data.frame(
      id = character(0),
      component_id = character(0),
      label = character(0),
      xmin = numeric(0),
      ymin = numeric(0),
      xmax = numeric(0),
      ymax = numeric(0),
      stringsAsFactors = FALSE
    ))
  }

  rows <- lapply(aois, function(a) {
    data.frame(
      id = a$id,
      component_id = a$component_id,
      label = a$label,
      xmin = a$geometry$xmin,
      ymin = a$geometry$ymin,
      xmax = a$geometry$xmax,
      ymax = a$geometry$ymax,
      stringsAsFactors = FALSE
    )
  })

  df <- do.call(rbind, rows)
  rownames(df) <- NULL

  if (!is.null(canvas_width) && !is.null(canvas_height)) {
    df$px_xmin <- round(df$xmin * canvas_width)
    df$px_xmax <- round(df$xmax * canvas_width)
    df$px_ymin <- round(df$ymin * canvas_height)
    df$px_ymax <- round(df$ymax * canvas_height)
    df$px_width <- df$px_xmax - df$px_xmin
    df$px_height <- df$px_ymax - df$px_ymin
  }

  df
}

#' @export
print.nc_aoi_set <- function(x, ...) {
  cat("<nc_aoi_set: ", length(x), " AOIs>\n", sep = "")
  for (a in x) {
    cat(sprintf("  - %s (comp: %s): x=[%.3f, %.3f], y=[%.3f, %.3f]\n",
                a$id, a$component_id,
                a$geometry$xmin, a$geometry$xmax,
                a$geometry$ymin, a$geometry$ymax))
  }
  invisible(x)
}
