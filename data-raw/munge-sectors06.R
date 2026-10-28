## Version 06 of the MEASO regions, built from the shipped version 05 data.
##
## The boundaries are those of version 05 (munge-sectors05.R, which depends on packages no longer
## readily available: spbabel, spex, sfdct, raadtools, ...). Version 05 is left exactly as released.
## Changes in 06:
##
##  * one row per region name (20 rows): WestPacific, split at the anti-meridian in 05 (WPA, WPS,
##    WPN and WPT each appear twice), is dissolved to a single feature per name
##  * attributes on the features: name, label, sector, zone, fill
##  * label is the full name, zone then sector, e.g. "Antarctic Atlantic" for AOA
##  * fill is the colour of each region in the MEASO Summary for Policymakers (Constable et al. 2023,
##    Figure 5, "MEASO assessment areas", adapted from McCormack et al. 2021): each sector has its own
##    hue, light to dark from the Antarctic to the Northern zone. The published figure is CMYK; these
##    are its sRGB rendering. The T (temperate) regions are outside MEASO and have no fill.
##  * a current crs (05 carries old-style sf crs objects)
##
## The longitude/latitude versions are defined in planar lon/lat (edges are straight in lon/lat,
## i.e. along parallels and meridians). In that plane the two WP pieces are at x = -180 and x = 180
## and don't touch, so they are combined as a MULTIPOLYGON, not unioned. The polar (LAEA) versions
## are unioned: there the two pieces share their edge along the anti-meridian.
library(sf)
library(dplyr)

laea <- "+proj=laea +lat_0=-90 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
recrs <- function(x, crs) {
  g <- st_geometry(x)
  attr(g, "crs") <- st_crs(crs)
  st_geometry(x) <- g
  x
}

## sectors in the order of the MEASO Summary for Policymakers, zones south to north
sectors <- c(Atlantic = "Atlantic", CentralIndian = "Central Indian", EastIndian = "East Indian",
             WestPacific = "West Pacific", EastPacific = "East Pacific")
zones <- c(Antarctic = "A", Subantarctic = "S", Northern = "N")
codes <- c(Atlantic = "AO", CentralIndian = "CI", EastIndian = "EI",
           WestPacific = "WP", EastPacific = "EP")

fills <- tibble::tribble(
  ~sector,          ~Antarctic, ~Subantarctic, ~Northern,
  "Atlantic",       "#F9BDBC",  "#F27071",     "#E11F26",
  "CentralIndian",  "#F9D7C2",  "#F4B187",     "#EC8444",
  "EastIndian",     "#D1D3EA",  "#B0B4D9",     "#878DC5",
  "WestPacific",    "#E0B8D6",  "#C579B2",     "#843A75",
  "EastPacific",    "#9FC5C7",  "#609FA0",     "#4B7E7F"
)

measo_names06 <- bind_rows(
  lapply(names(sectors), function(s) {
    f <- unlist(fills[fills$sector == s, names(zones)])
    tibble::tibble(name = paste0(codes[[s]], c(zones, "T")),
                   label = paste(c(names(zones), "Temperate"), sectors[[s]]),
                   sector = s,
                   zone = c(names(zones), NA),
                   fill = c(f, NA))
  })
)
## same names, sectors and zones as 05
old <- distinct(measoshapes::measo_names, name, sector, zone)
stopifnot(nrow(measo_names06) == 20,
          setequal(measo_names06$name, old$name),
          identical(arrange(old, name)$sector, arrange(measo_names06, name)$sector),
          identical(arrange(old, name)$zone, arrange(measo_names06, name)$zone))

dissolve <- function(x, crs, union = TRUE) {
  x <- summarize(group_by(recrs(x, crs), name), do_union = union)
  st_as_sf(inner_join(measo_names06, x, "name"))  ## keeps measo_names06 order
}
measo_regions06 <- dissolve(measoshapes::measo_regions05, laea)
measo_regions06_coastline <- dissolve(measoshapes::measo_regions05_coastline, laea)
measo_regions06_ll <- dissolve(measoshapes::measo_regions05_ll, "EPSG:4326", union = FALSE)
measo_regions06_ll_coastline <- dissolve(measoshapes::measo_regions05_ll_coastline, "EPSG:4326",
                                         union = FALSE)

planar <- function(x) st_set_crs(x, NA)
for (x in list(measo_regions06, measo_regions06_coastline,
               planar(measo_regions06_ll), planar(measo_regions06_ll_coastline))) {
  stopifnot(nrow(x) == 20, all(st_is_valid(x)), identical(x$name, measo_names06$name))
}
## dissolving doesn't change the total area (LAEA is equal-area; lon/lat in planar square degrees)
stopifnot(isTRUE(all.equal(sum(st_area(measo_regions06)), sum(st_area(measoshapes::measo_regions05)))),
          isTRUE(all.equal(sum(st_area(planar(measo_regions06_ll))),
                    sum(st_area(planar(measoshapes::measo_regions05_ll))))))

usethis::use_data(measo_names06, measo_regions06, measo_regions06_coastline,
                  measo_regions06_ll, measo_regions06_ll_coastline, overwrite = TRUE)
