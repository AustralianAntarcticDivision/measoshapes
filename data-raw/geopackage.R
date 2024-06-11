library(sf)
library(dplyr)
x <- group_by(measoshapes::measo_regions05, name) |> summarize()
x <- sf::st_set_crs(x, "+proj=laea +lat_0=-90 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs")
shapes <- dplyr::inner_join(x, measoshapes::measo_names, "name")
sf::st_write(shapes, "inst/extdata/measo_regions.gpkg")

shapes_ll <- dplyr::inner_join(measoshapes::measo_regions05_ll, measoshapes::measo_names, relationship = "many-to-many")
shapes_ll <- sf::st_set_crs(shapes_ll, "EPSG:4326")
sf::st_write(shapes_ll, "inst/extdata/measo_regions_ll.gpkg")

## for Quantarctica (?)
sf::write_sf(sf::st_transform(shapes, "EPSG:3031"), "inst/extdata/measo_regions_epsg_3031.gpkg")
