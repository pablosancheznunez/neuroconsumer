#' Export Experimental Stimuli to SVG and PNG
#'
#' @description
#' Renders an `nc_stimulus` deterministically to SVG markup or raster PNG format.
#' All components are tagged with semantic XML attributes (`id`, `data-component-type`,
#' `data-z-index`) enabling direct linkage with Areas of Interest.
#'
#' @param stimulus An `nc_stimulus` object.
#'
#' @return Invisibly returns the SVG character string.
#' @export
#'
#' @examples
#' comp <- nc_component("hero", type = "headline", x = 0.5, y = 0.5,
#'                      properties = list(text = "Sample Title", fill = "#3B82F6", color = "#FFFFFF"))
#' stim <- nc_stimulus("sample", list(comp))
#' svg_txt <- nc_render_svg(stim)
nc_render_svg <- function(stimulus) {
  if (!inherits(stimulus, "nc_stimulus")) {
    stop("`stimulus` must be of class `nc_stimulus`.", call. = FALSE)
  }

  w <- stimulus$canvas$width
  h <- stimulus$canvas$height
  bg <- stimulus$canvas$background_color

  lines <- c(
    sprintf('<?xml version="1.0" encoding="UTF-8"?>'),
    sprintf('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">', w, h, w, h),
    sprintf('  <!-- NeuroConsumer Stimulus: %s -->', xml_escape(stimulus$id)),
    sprintf('  <rect width="100%%" height="100%%" fill="%s"/>', xml_escape(bg))
  )

  # Sort components by z_index
  comps <- stimulus$components
  if (length(comps) > 0) {
    z_vals <- vapply(comps, function(c_item) c_item$z_index, integer(1))
    comps <- comps[order(z_vals)]

    for (c_item in comps) {
      if (!c_item$visible) next
      # Calculate absolute pixel coordinates from normalized centre coordinates
      cx <- c_item$x * w
      cy <- c_item$y * h
      cw <- c_item$width * w
      ch <- c_item$height * h
      top_left_x <- cx - (cw / 2)
      top_left_y <- cy - (ch / 2)

      p <- c_item$properties
      fill_col <- if (!is.null(p$fill)) p$fill else "none"
      stroke_col <- if (!is.null(p$stroke)) p$stroke else "none"
      stroke_w <- if (!is.null(p$stroke_width)) p$stroke_width else 0
      rx <- if (!is.null(p$border_radius)) p$border_radius else 0
      txt_col <- if (!is.null(p$color)) p$color else "#000000"
      font_sz <- if (!is.null(p$font_size)) p$font_size else 20
      font_fam <- if (!is.null(p$font_family)) p$font_family else "sans-serif"
      font_wt <- if (!is.null(p$font_weight)) p$font_weight else "normal"

      lines <- c(lines, sprintf(
        '  <g id="nc-comp-%s" data-component-type="%s" data-z-index="%d">',
        xml_escape(c_item$id), xml_escape(c_item$type), c_item$z_index
      ))

      # Draw box if background/fill is present or required
      if (fill_col != "none" || stroke_col != "none") {
        lines <- c(lines, sprintf(
          '    <rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" rx="%.1f" fill="%s" stroke="%s" stroke-width="%.1f"/>',
          top_left_x, top_left_y, cw, ch, rx, xml_escape(fill_col), xml_escape(stroke_col), stroke_w
        ))
      }

      # Draw text if text property exists
      if (!is.null(p$text) && nchar(p$text) > 0) {
        # Place text at centre of component
        lines <- c(lines, sprintf(
          '    <text x="%.2f" y="%.2f" text-anchor="middle" dominant-baseline="middle" fill="%s" font-family="%s" font-size="%.1f" font-weight="%s">%s</text>',
          cx, cy, xml_escape(txt_col), xml_escape(font_fam), font_sz, xml_escape(font_wt), xml_escape(p$text)
        ))
      }

      lines <- c(lines, '  </g>')
    }
  }

  lines <- c(lines, '</svg>')
  paste(lines, collapse = "\n")
}

#' Export Stimulus to Disk
#'
#' @param stimulus An `nc_stimulus` object.
#' @param file Destination file path.
#' @param format Target format ("svg" or "png"). Defaults to format deduced from file extension.
#'
#' @return The normalized file path, invisibly.
#' @export
#'
#' @examples
#' comp <- nc_component("hero", type = "headline", x = 0.5, y = 0.5)
#' stim <- nc_stimulus("sample", list(comp))
#' out_f <- file.path(tempdir(), "test.svg")
#' nc_export(stim, out_f)
nc_export <- function(stimulus, file, format = NULL) {
  if (is.null(format)) {
    if (grepl("\\.png$", file, ignore.case = TRUE)) format <- "png"
    else format <- "svg"
  }
  format <- tolower(format)

  svg_content <- nc_render_svg(stimulus)

  if (format == "svg") {
    writeLines(svg_content, file, useBytes = TRUE)
  } else if (format == "png") {
    if (requireNamespace("rsvg", quietly = TRUE)) {
      rsvg::rsvg_png(charToRaw(svg_content), file = file)
    } else {
      # Fallback to standard base graphics png
      w <- stimulus$canvas$width
      h <- stimulus$canvas$height
      grDevices::png(file, width = w, height = h)
      graphics::par(mar = c(0, 0, 0, 0))
      graphics::plot.new()
      # Base R preview
      graphics::rect(0, 0, 1, 1, col = stimulus$canvas$background_color, border = NA)
      for (c_item in stimulus$components) {
        if (!c_item$visible) next
        cx <- c_item$x
        cy <- 1 - c_item$y # flip y for graphics
        cw <- c_item$width
        ch <- c_item$height
        fill <- if (!is.null(c_item$properties$fill) && c_item$properties$fill != "none") c_item$properties$fill else NA
        graphics::rect(cx - cw/2, cy - ch/2, cx + cw/2, cy + ch/2, col = fill, border = NA)
        if (!is.null(c_item$properties$text)) {
          col <- if (!is.null(c_item$properties$color)) c_item$properties$color else "black"
          graphics::text(cx, cy, labels = c_item$properties$text, col = col)
        }
      }
      grDevices::dev.off()
    }
  } else {
    stop("Unsupported export format: ", format, call. = FALSE)
  }

  invisible(normalizePath(file, mustWork = FALSE))
}
