minlat <- -80
sectors_ll <- tibble::tribble(~lon, ~lat, ~zone,
                 -125, minlat,  1,
                 -125, -35,  1,

                 -70, minlat, 2,
                 -64.5, -66, 2,
                 -60, -64, 2,
                 -55.054477039271191, -63.260598133971456, 2,
                 -63.799776827053591, -54.721070105901589, 2,

               30, minlat, 3,
               30, -35, 3,

                 115, minlat, 4,
                 115, -35, 4,

                 158, minlat, 5,
                 158, -75,    5,
                 170, -71.60, 5,
                 170, -47.50, 5
                 )

library(spbabel)
library(dplyr)
library(sf)
sectors <- sectors_ll %>%
  transmute(lon, lat, x_ = lon, y_ = lat, branch_ = zone, object_ = zone, order_ = row_number()) %>%
  sp(crs = "+init=epsg:4326")
sectors <- sf::st_as_sf(sectors)
#file.copy("../measo-access/shapes/zones.Rdata", "data-raw/zones.Rdata")
load("data-raw/zones.Rdata")

#plot(sectors)
#plot(zones, add = TRUE)
#maps::map(add = TRUE)
domain <- st_cast(spex::polygonize(raster::raster(raster::extent(-180, 180, minlat, -30), nrows = 1,
                                                  ncols = 1,
                                                  crs = st_crs(sectors)$proj4string)), "LINESTRING")

lns <- st_sf(geometry = c(st_geometry(sectors),
                          st_geometry(domain),
                          st_geometry(zones)), crs = 4326)

measo_regions03g <- st_cast(st_polygonize(st_union(lns)))
## drop degenerate regions
measo_regions03g <- measo_regions03g[st_area(st_set_crs(measo_regions03g, NA)) > 1]


measo_regions04 <- st_sf(geometry = measo_regions03g)
#st_coordinates(st_centroid(measo_regions03))[,2]
plot(measo_regions04[st_coordinates(st_centroid(measo_regions04))[,2] < -38, ],
     col = sample(rainbow(nrow(measo_regions04)-1)))




## order by longitude, then latitude of bottom left corner
ord <- spbabel::sptable(measo_regions04) %>%
  group_by(object_) %>%
  arrange(x_, y_) %>% slice(1) %>% ungroup() %>% arrange(x_, y_) %>% pull(object_)

measo_regions04 <- measo_regions04[ord, ]

measo_regions04$name <- c("WPA", "WPS", "WPN",
                          NA, ## northern background,
                          "EPA", "EPS", "EPN",
                          "AOA", "AOS", "AON",

                          "CIA", "CIS", "CIN",
                          "EIA", "EIS", "EIN",
                          "WPA", "WPS", "WPN")
measo_regions04$a <- NULL
measo_regions04_ll <- measo_regions04
plot(st_geometry(measo_regions04), reset = FALSE,
     col = rainbow(length(unique(measo_regions04$name)),
                   alpha = 0.4)[factor(measo_regions04$name)], border  = NA)
text(st_coordinates(st_centroid(measo_regions04)),
     lab = measo_regions04$name)
sp::plot(orsifronts::orsifronts, add = TRUE)


## zones polar
measo_regions04 <- sf::st_transform(sf::st_set_crs(sf::st_segmentize(sf::st_set_crs(measo_regions04_ll, NA), 0.2), 4326),
                          "+proj=laea +lat_0=-90 +lon_0=0 +datum=WGS84")


zz <- c("Antarctic", "Subantarctic", "Northern")
sec <- c("WestPacific", "EastPacific", "Atlantic",
         "CentralIndian", "EastIndian", "WestPacific")
measo_names <- tibble::tibble(name = measo_regions04$name,
                              sector = c(rep(sec[1], 3), NA,
                                         rep(sec[-1], each =  3)),
                              zone = c(zz,
                                       NA,
                                       rep(zz, 5)))
usethis::use_data(measo_names, overwrite = TRUE)
usethis::use_data(measo_regions04_ll)
usethis::use_data(measo_regions04)


