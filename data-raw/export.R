## Write the version 06 regions (one row per region name, 20 rows) to files in inst/extdata.
## These are also published on the website (site/) at stable URLs, under data/v06/.
##
##  measo_regions06.{parquet,fgb}            polar Lambert Azimuthal Equal Area (use this for areas)
##  measo_regions06_ll.{parquet,fgb,geojson} longitude/latitude
##  measo_regions06_epsg_3031.{parquet,fgb}  Antarctic Polar Stereographic, e.g. for Quantarctica
##  measo_regions06.qml                      QGIS style, fill colours by name
##
## The longitude/latitude version is defined in planar lon/lat (edges are straight in lon/lat).
## GeoJSON (RFC 7946) has the same planar interpretation: "A line between two positions is a
## straight Cartesian line".
##
## The geopackages in inst/extdata are version 05 files (written by geopackage.R), kept as they were.
library(sf)

shapes <- measoshapes::measo_regions06
shapes_ll <- measoshapes::measo_regions06_ll
## for Quantarctica (polar stereographic, not equal-area: use measo_regions06 for areas)
shapes_3031 <- st_transform(shapes, "EPSG:3031")

out <- function(x, file, driver, ...) {
  if (file.exists(file)) file.remove(file)
  st_write(x, file, driver = driver, quiet = TRUE, ...)
}
files <- c(measo_regions06 = "shapes", measo_regions06_ll = "shapes_ll",
           measo_regions06_epsg_3031 = "shapes_3031")
for (f in names(files)) {
  x <- get(files[[f]])
  out(x, file.path("inst/extdata", paste0(f, ".parquet")), "Parquet")
  ## no spatial index: it reorders the features, and 20 features don't need one
  out(x, file.path("inst/extdata", paste0(f, ".fgb")), "FlatGeobuf",
      layer_options = "SPATIAL_INDEX=NO")
}
out(shapes_ll, "inst/extdata/measo_regions06_ll.geojson", "GeoJSON",
    layer_options = c("RFC7946=YES", "WRITE_BBOX=YES"))

## QGIS style: categorized by name with the fill; T regions (no fill) are outline only.
## Colours in QML are "r,g,b,a" (QGIS reads 8-digit hex as #AARRGGBB, not #RRGGBBAA).
nms <- measoshapes::measo_names06
qml_colour <- function(x) {
  ifelse(is.na(x), "0,0,0,0", apply(col2rgb(x, alpha = TRUE), 2, paste, collapse = ","))
}
qml_symbol <- function(i, fill) {
  style <- if (fill == "0,0,0,0") "no" else "solid"
  props <- c(color = fill, style = style, outline_color = "90,90,90,255",
             outline_style = "solid", outline_width = "0.26", outline_width_unit = "MM",
             joinstyle = "bevel")
  sprintf('      <symbol type="fill" name="%d" alpha="1" clip_to_extent="1" force_rhr="0">
        <layer class="SimpleFill" enabled="1" locked="0" pass="0">
%s
          <Option type="Map">
%s
          </Option>
        </layer>
      </symbol>', i,
    paste(sprintf('          <prop k="%s" v="%s"/>', names(props), props), collapse = "\n"),
    paste(sprintf('            <Option name="%s" type="QString" value="%s"/>', names(props), props), collapse = "\n"))
}
lab <- paste0(nms$label, " (", nms$name, ")", ifelse(is.na(nms$zone), ", outside MEASO", ""))
i <- seq_len(nrow(nms)) - 1
qml <- c("<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>",
         '<qgis version="3.34.0" styleCategories="Symbology">',
         '  <renderer-v2 type="categorizedSymbol" attr="name" enableorderby="0" symbollevels="0" forceraster="0">',
         '    <categories>',
         sprintf('      <category value="%s" symbol="%d" label="%s" render="true"/>', nms$name, i, lab),
         '    </categories>',
         '    <symbols>',
         mapply(qml_symbol, i, qml_colour(nms$fill)),
         '    </symbols>',
         '  </renderer-v2>',
         '</qgis>')
writeLines(qml, "inst/extdata/measo_regions06.qml")
