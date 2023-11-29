library(sf)
shapes <- dplyr::inner_join(measoshapes::measo_regions05, measoshapes::measo_names)
sf::st_write(shapes, "inst/extdata/measo_regions.gpkg")
shapes_ll <- dplyr::inner_join(measoshapes::measo_regions05_ll, measoshapes::measo_names)
sf::st_write(shapes_ll, "inst/extdata/measo_regions_ll.gpkg")

## for Quantarctica (?)
sf::write_sf(sf::st_transform(measoshapes::measo_regions05, "EPSG:3031"), "inst/extdata/measo_regions_epsg_3031.gpkg")
