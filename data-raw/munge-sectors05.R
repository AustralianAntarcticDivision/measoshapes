minlat <- -80
maxlat <- -30
sectors_ll <- tibble::tribble(~lon, ~lat, ~zone,
                 -125, minlat,  1,
                 -125, maxlat,  1,

                 -70, minlat, 2,
                 -64.5, -66, 2,
                 -60, -64, 2,
                 -55.054477039271191, -63.260598133971456, 2,
                 -63.799776827053591, -54.721070105901589, 2,
                 -63.799776827053591, maxlat,2,

               30, minlat, 3,
               30, maxlat, 3,

                 115, minlat, 4,
                 115, maxlat, 4,

                 158, minlat, 5,
                 158, -75,    5,
                 170, -71.60, 5,
                 170, -47.50, 5,
                 170, maxlat, 5,
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
zones <- rbind(zones,
    st_sf(ID = 0, front = NA_character_,
          geometry = st_sfc(st_linestring(cbind(c(-180, 180), maxlat)))))
#plot(sectors)
#plot(zones, add = TRUE)
#maps::map(add = TRUE)
domain <- st_cast(spex::polygonize(raster::raster(raster::extent(-180, 180, minlat, -30), nrows = 1,
                                                  ncols = 1,
                                                  crs = st_crs(sectors)$proj4string)), "LINESTRING")

lns <- st_sf(geometry = c(st_geometry(sectors),
                          st_geometry(domain),
                          st_geometry(zones)), crs = 4326)

gg <- st_cast(st_polygonize(st_union(lns)))
## drop degenerate regions
gg <- gg[st_area(st_set_crs(gg, NA)) > 1]


measo_regions05 <- st_sf(geometry = gg)
plot(measo_regions05, col = sample(viridis::viridis(30)))



## order by longitude, then latitude of bottom left corner
ord <- spbabel::sptable(measo_regions05) %>%
  group_by(object_) %>%
  arrange(x_, y_) %>% slice(1) %>% ungroup() %>% arrange(x_, y_) %>% pull(object_)

measo_regions05 <- measo_regions05[ord, ]
plot(measo_regions05, col = viridis::viridis(25))
measo_regions05$name <- c("WPA", "WPS", "WPN",
                          NA, ## northern background,
                          "EPA", "EPS", "EPN",
                          NA,
                          "AOA", NA, "AOS",
                          "AON",
                          "CIA", "CIS", "CIN",
                          NA,
                          "EIA", "EIS", "EIN",
                          NA,
                          "WPA", "WPS", "WPN",
                          NA)
measo_regions05$a <- NULL
measo_regions05_ll <- measo_regions05
plot(st_geometry(measo_regions05), reset = FALSE,
     col = rainbow(length(unique(measo_regions05$name)),
                   alpha = 0.4)[factor(measo_regions05$name)], border  = NA)
text(st_coordinates(st_centroid(measo_regions05)),
lab = measo_regions05$name)
#   lab = 1:24)




sp::plot(orsifronts::orsifronts, add = TRUE)


## zones polar
measo_regions05 <- sf::st_transform(sf::st_set_crs(sf::st_segmentize(sf::st_set_crs(measo_regions05_ll, NA), 0.2), 4326),
                          "+proj=laea +lat_0=-90 +lon_0=0 +datum=WGS84")


zz <- c("Antarctic", "Subantarctic", "Northern", NA,
        "Antarctic", "Subantarctic", "Northern", NA,
        "Antarctic", NA, "Subantarctic", "Northern",
        "Antarctic", "Subantarctic", "Northern", NA,
        "Antarctic", "Subantarctic", "Northern", NA,
        "Antarctic", "Subantarctic", "Northern", NA)
sec <- c("WestPacific", "EastPacific", "Atlantic",
         "CentralIndian", "EastIndian", "WestPacific")
measo_names <- tibble::tibble(name = measo_regions05$name,
                              sector = rep(sec, each = 4),
                              zone = zz)
usethis::use_data(measo_names, overwrite = TRUE)
usethis::use_data(measo_regions05_ll)
usethis::use_data(measo_regions05)


