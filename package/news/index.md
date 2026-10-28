# Changelog

## measoshapes 0.0.06

- Release “06” adds `measo_regions06` (with `_ll`, `_coastline` and
  `_ll_coastline` forms) and `measo_names06`. The boundaries are those
  of version 05. In version 06:

  - one row per region (20 rows): the WestPacific regions, split at the
    anti-meridian in 05, are one feature each
  - `name`, `label`, `sector`, `zone`, and `fill` are on the features;
    `label` is the full name, zone then sector, e.g. “Antarctic
    Atlantic”
  - `fill` is the colour of each region in the MEASO Summary for
    Policymakers (Constable et al. 2023, Figure 5): each sector has its
    own hue, light to dark from the Antarctic to the Northern zone
  - a current crs

- Version 05 is kept as it was released. Its colours have sectors
  sharing palettes (WestPacific with Atlantic, EastPacific with
  CentralIndian), and the first WPA row of `measo_names` has a fill that
  doesn’t match the second (an error, kept as released).

- Files for version 06 in ‘inst/extdata’: GeoParquet and FlatGeobuf in
  polar LAEA, longitude/latitude and EPSG:3031, GeoJSON in
  longitude/latitude, and a QGIS style. The version 05 geopackages are
  unchanged.

- Added references to the MEASO Summary for Policymakers, McCormack et
  al. (2021), and earlier MEASO documents (`citation("measoshapes")`,
  [`?measo_regions06`](https://australianantarcticdivision.github.io/measoshapes/package/reference/measo_regions06.md)).

- Known: the MEASO Summary for Policymakers describes the Northern zone
  as “no further north than 40°S”; in the Atlantic (9°W to 10°E) the
  Northern region (AON) reaches 38.3°S.

## measoshapes 0.0.05.1

- Extend the shapes southerer.

- Added colours.

## measoshapes 0.0.05

- Release “05” creates “\_coastline” versions in polar and in
  longitude/latitude. There are now dummy polygons in the north for each
  sector, for classifying data that is outside the primary regions.

## measoshapes 0.0.04

- Release “04”, renames “WestAtlantic” to “Atlantic”
