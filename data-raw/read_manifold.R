options(Ncpus = parallel::detectCores()-1)
install.packages("devtools", repos = "http://144.6.252.29:8000/")
devtools::install_github("mdsumner/manifoldr")

f <- "C:\\Users\\michae_sum\\Desktop\\MEASO03.map"

con <- manifoldr::odbcConnectManifold(f)
sqlTables(con)
RODBC::sqlTables(con)
library(manifoldr)
sectors <- Drawing(f, "MEASO_Sectors_5 Table")
zones <- Drawing(f, "MEASO_Zones Table")
save(sectors, file = "sectors.Rdata")
save(zones, file = "zones.Rdata")


