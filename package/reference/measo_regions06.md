# MEASO regions, version 06

The MEASO assessment areas: five sectors (Atlantic, Central Indian, East
Indian, West Pacific, East Pacific), each with three zones (Antarctic,
Subantarctic, Northern), and a temperate (T) region north of each sector
that is outside MEASO. One row per region (20 rows).

## Details

The boundaries are those of version 05. In version 06 the anti-meridian
split of WestPacific is dissolved (one feature per name), the regions
carry their attributes, and `fill` is the colour of each region in the
MEASO Summary for Policymakers (Figure 5).

- `measo_regions06` polar Lambert Azimuthal Equal Area (use this for
  areas)

- `measo_regions06_ll` longitude/latitude: boundaries are straight lines
  in longitude/latitude (along parallels and meridians), WestPacific is
  a MULTIPOLYGON either side of the anti-meridian

- `measo_regions06_coastline`, `measo_regions06_ll_coastline` with the
  Antarctic continent cut out

- `measo_names06` the attributes alone, a key by `name`

Columns:

- `name` code, sector then zone, e.g. "AOA"

- `label` full name, zone then sector, e.g. "Antarctic Atlantic"

- `sector` e.g. "CentralIndian"

- `zone` "Antarctic", "Subantarctic", "Northern", or `NA` for the
  temperate regions

- `fill` colour as "#RRGGBB", `NA` for the temperate regions

## References

Constable, A.J., J. Melbourne-Thomas, M.M.C. Muelbert, S. McCormack, M.
Brasier, J.A. Caccavo, R.D. Cavanagh, S.M. Grant, H.J. Griffiths, J.
Gutt, S.F. Henley, J. Höfer, A.B. Hollowed, N.M. Johnston, S.A. Morley,
E.J. Murphy, M.H. Pinkerton, I.R. Schloss, K.M. Swadling, A.P. Van de
Putte (2023) Marine Ecosystem Assessment for the Southern Ocean: Summary
for Policymakers. Integrated Climate and Ecosystem Dynamics in the
Southern Ocean, Scientific Committee on Antarctic Research, Scientific
Committee on Oceanic Research, Integrated Marine Biosphere Research.
[doi:10.5281/zenodo.8359585](https://doi.org/10.5281/zenodo.8359585) .
See Figure 5, "MEASO assessment areas".

McCormack, S.A., J. Melbourne-Thomas, R. Trebilco, J.L. Blanchard, B.
Raymond, A. Constable (2021) Decades of dietary data demonstrate
regional food web structures in the Southern Ocean. Ecology and
Evolution 11(1): 227–241.
[doi:10.1002/ece3.7017](https://doi.org/10.1002/ece3.7017)

Earlier MEASO documents, from the time of versions 03 to 05 of the
regions:

Brasier, M.J., A. Constable, J. Melbourne-Thomas, R. Trebilco, H.
Griffiths, A. Van de Putte, M. Sumner (2019) Observations and models to
support the first Marine Ecosystem Assessment for the Southern Ocean
(MEASO). Journal of Marine Systems 197: 103182.
[doi:10.1016/j.jmarsys.2019.05.008](https://doi.org/10.1016/j.jmarsys.2019.05.008)

Constable, A., J. Melbourne-Thomas, R. Trebilco, M. Brasier (2018)
Marine Ecosystem Assessment for the Southern Ocean (MEASO). SC-CCAMLR
2018 Background Paper, SC-CAMLR-XXXVII/BG/22.

Constable, A., J. Melbourne-Thomas, R. Trebilco, M. Sumner, M. Brasier
(2018) The role of models in facilitating the first Marine Ecosystem
Assessment for the Southern Ocean (MEASO). Australian Coastal and Oceans
Modelling and Observations meeting, Canberra, October 2018.

## Examples

``` r
x <- measo_regions06_coastline
plot(sf::st_geometry(x), col = x$fill)
```
