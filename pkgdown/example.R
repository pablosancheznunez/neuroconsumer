# Builds the example stimulus pack published at /example/ on the website:
# the 2 x 2 experiment from the gallery article, exported as SVG and PNG,
# with its design table, AOI table and invariant check.
library(neuroconsumer)

out <- "_site/example"
dir.create(out, recursive = TRUE, showWarnings = FALSE)

bg <- nc_component("bg", type = "background", width = 1, height = 1,
                   properties = list(fill = "#F8FAFC"))
brand <- nc_component("brand", type = "brand", x = 0.5, y = 0.1, width = 0.3, height = 0.08,
                      properties = list(text = "LUMINA", color = "#1E293B", font_size = 44,
                                        font_weight = "bold", font_family = "Georgia, serif"))
product <- nc_component("product", type = "product", x = 0.5, y = 0.38, width = 0.4, height = 0.34,
                        properties = list(fill = "#CBD5E1", border_radius = 18,
                                          text = "product image", color = "#475569"))
price <- nc_component("price", type = "price", x = 0.5, y = 0.65, width = 0.24, height = 0.08,
                      properties = list(text = "$149.00", color = "#0F172A", font_size = 40,
                                        font_weight = "bold"))
cta <- nc_component("cta", type = "cta", x = 0.5, y = 0.84, width = 0.28, height = 0.1,
                    properties = list(text = "Buy now", fill = "#94A3B8", color = "#FFFFFF",
                                      border_radius = 12, font_size = 34))

exp <- nc_experiment("display_ad_study", title = "Price position x CTA contrast",
                     reference = nc_stimulus("ad_reference", list(bg, brand, product, price, cta)))
exp <- nc_manipulate(exp, factor = "price_pos", component = "price",
                     parameter = "y", levels = c(upper = 0.60, lower = 0.72))
exp <- nc_manipulate(exp, factor = "cta_contrast", component = "cta",
                     parameter = "properties.fill", levels = c(low = "#94A3B8", high = "#E11D48"))

design <- nc_design(exp)
utils::write.csv(design, file.path(out, "design.csv"), row.names = FALSE)

aois <- do.call(rbind, lapply(names(exp$variants), function(cond) {
  s <- exp$variants[[cond]]
  df <- nc_aoi_to_df(nc_aoi_from_components(s), s$canvas$width, s$canvas$height)
  cbind(condition_id = cond, df)
}))
utils::write.csv(aois, file.path(out, "aois.csv"), row.names = FALSE)

cards <- vapply(names(exp$variants), function(cond) {
  s <- exp$variants[[cond]]
  nc_export(s, file.path(out, paste0(cond, ".svg")))
  nc_export(s, file.path(out, paste0(cond, ".png")))
  row <- design[design$condition_id == cond, ]
  sprintf(paste0(
    '<figure><a href="%1$s.png"><img src="%1$s.svg" alt="Condition %1$s: price %2$s, CTA contrast %3$s"></a>',
    '<figcaption><code>%1$s</code><br>price: %2$s &middot; CTA contrast: %3$s<br>',
    '<a href="%1$s.svg">SVG</a> &middot; <a href="%1$s.png">PNG</a></figcaption></figure>'),
    cond, row$price_pos, row$cta_contrast)
}, character(1))

status <- paste(utils::capture.output(print(nc_validate(exp))), collapse = "\n")

html <- c(
  '<!doctype html><html lang="en"><head><meta charset="utf-8">',
  '<meta name="viewport" content="width=device-width, initial-scale=1">',
  '<title>neuroconsumer example stimulus pack</title>',
  '<link rel="icon" href="../favicon.svg" type="image/svg+xml">',
  '<style>',
  ':root{--ink:#182c56;--muted:#5a6782;--bg:#f5f7fb;--card:#fff;--line:#d9e0ee;--link:#2f5fc4}',
  '@media (prefers-color-scheme:dark){:root{--ink:#e6ebf5;--muted:#a9b4cc;--bg:#111827;--card:#1b2436;--line:#2c3854;--link:#8fb0f5}}',
  'body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.55 system-ui,sans-serif}',
  'main{max-width:1100px;margin:0 auto;padding:32px 16px}',
  'h1{font-family:Georgia,serif;font-weight:normal;margin:0 0 8px}p,li{color:var(--muted)}',
  '.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:16px;margin:24px 0}',
  'figure{margin:0;background:var(--card);border:1px solid var(--line);border-radius:10px;padding:12px}',
  'figure img{width:100%;height:auto;border-radius:6px;display:block}',
  'figcaption{font-size:14px;color:var(--muted);margin-top:8px}code{font-size:13px}',
  'pre{background:var(--card);border:1px solid var(--line);border-radius:8px;padding:12px;overflow-x:auto}',
  'a{color:var(--link)}',
  '</style></head><body><main>',
  '<p><a href="../">neuroconsumer</a> / example</p>',
  '<h1>Example stimulus pack</h1>',
  paste('<p>A 2 &times; 2 display-ad experiment (price position &times; call-to-action contrast)',
        'built, validated and exported with neuroconsumer. All four conditions come from one',
        'reference stimulus and differ only in the two declared factors. The brand is fictitious.</p>'),
  '<div class="grid">', cards, '</div>',
  '<h2>Downloads</h2>',
  '<ul><li><a href="design.csv">design.csv</a>: the factorial design, one row per condition</li>',
  '<li><a href="aois.csv">aois.csv</a>: Areas of Interest for every condition, in normalised and pixel coordinates, ready to import into eye-tracking software</li></ul>',
  '<h2>Invariant check</h2>',
  paste0('<pre>', status, '</pre>'),
  '<p>How it is built: <a href="../articles/stimulus-gallery.html">gallery article</a> &middot; <a href="https://github.com/pablosancheznunez/neuroconsumer/blob/main/pkgdown/example.R">source script</a></p>',
  '</main></body></html>'
)
writeLines(html, file.path(out, "index.html"), useBytes = TRUE)
