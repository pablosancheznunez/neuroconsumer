test_that("nc_component constructors and validators work", {
  comp <- nc_component(
    id = "btn",
    type = "cta",
    x = 0.5,
    y = 0.8,
    width = 0.3,
    height = 0.1,
    properties = list(text = "Click Me", fill = "#E11D48")
  )

  expect_s3_class(comp, "nc_component")
  expect_equal(comp$id, "btn")
  expect_equal(comp$type, "cta")
  expect_equal(comp$properties$text, "Click Me")

  # Validation errors
  expect_error(nc_component("", "cta"))
  expect_error(nc_component("c", "cta", x = 1.5))
  expect_error(nc_component("c", "cta", width = -0.1))
})

test_that("nc_stimulus manages components deterministically", {
  c1 <- nc_component("bg", type = "background", width = 1, height = 1)
  c2 <- nc_component("title", type = "headline", x = 0.5, y = 0.2)
  stim <- nc_stimulus("ad1", list(c1, c2))

  expect_s3_class(stim, "nc_stimulus")
  expect_equal(length(stim$components), 2)
  expect_error(nc_stimulus("dup", list(c1, c1))) # Duplicate ID prevention

  # Add component
  c3 <- nc_component("cta", type = "cta", x = 0.5, y = 0.8)
  stim2 <- nc_add_component(stim, c3)
  expect_equal(length(stim2$components), 3)
})

test_that("nc_aoi extracts bounding boxes accurately", {
  comp <- nc_component("price", type = "price", x = 0.5, y = 0.6, width = 0.2, height = 0.1)
  stim <- nc_stimulus("ad", list(comp))
  aois <- nc_aoi_from_components(stim)

  expect_s3_class(aois, "nc_aoi_set")
  expect_equal(length(aois), 1)

  df <- nc_aoi_to_df(aois, canvas_width = 1000, canvas_height = 800)
  expect_equal(df$xmin[1], 0.4)
  expect_equal(df$xmax[1], 0.6)
  expect_equal(df$ymin[1], 0.55)
  expect_equal(df$ymax[1], 0.65)
  expect_equal(df$px_width[1], 200)
  expect_equal(df$px_height[1], 80)
})

test_that("Mandatory 2x2 Demonstration Experiment runs with Invariant Verification", {
  # Components
  bg <- nc_component("bg", type = "background", width = 1, height = 1, properties = list(fill = "#F8FAFC"))
  brand <- nc_component("brand", type = "brand", x = 0.5, y = 0.1, width = 0.3, height = 0.05,
                        properties = list(text = "LUMINA", color = "#0F172A"))
  headline <- nc_component("headline", type = "headline", x = 0.5, y = 0.22, width = 0.7, height = 0.08,
                           properties = list(text = "Engineered for Clarity", color = "#334155"))
  product <- nc_component("product", type = "product", x = 0.5, y = 0.42, width = 0.4, height = 0.25,
                          properties = list(fill = "#E2E8F0", stroke = "#94A3B8"))
  price <- nc_component("price", type = "price", x = 0.5, y = 0.65, width = 0.25, height = 0.06,
                        properties = list(text = "$149.00", fill = "#1E293B", color = "#FFFFFF"))
  cta <- nc_component("cta", type = "cta", x = 0.5, y = 0.82, width = 0.32, height = 0.08,
                      properties = list(text = "Order Now", fill = "#94A3B8", color = "#FFFFFF"))

  ref_stim <- nc_stimulus("reference", list(bg, brand, headline, product, price, cta))
  exp <- nc_experiment("ad_2x2", title = "Price Position x CTA Contrast", reference = ref_stim)

  # Factor A: Price position (upper vs lower)
  exp <- nc_manipulate(exp, factor = "price_pos", component = "price",
                       parameter = "y", levels = c(upper = 0.60, lower = 0.72))

  # Factor B: CTA contrast (low vs high)
  exp <- nc_manipulate(exp, factor = "cta_contrast", component = "cta",
                       parameter = "properties.fill",
                       levels = c(low = "#94A3B8", high = "#E11D48"))

  # 2x2 factorial produces 4 conditions
  expect_equal(length(exp$variants), 4)

  # Invariant validation
  rep <- nc_validate(exp)
  expect_true(rep$valid)
  expect_true(rep$structural_equivalence)
  expect_true(rep$invariants_preserved)

  # Export SVG verification
  for (v_stim in exp$variants) {
    svg_str <- nc_render_svg(v_stim)
    expect_true(grepl("<svg", svg_str))
    expect_true(grepl("id=\"nc-comp-price\"", svg_str))
    expect_true(grepl("id=\"nc-comp-cta\"", svg_str))
  }
})
