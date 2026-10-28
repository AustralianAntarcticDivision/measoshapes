## shared setup for executed chunks: files as published, package data from the repo
suppressPackageStartupMessages(library(sf))
dd <- "data/v06"
base_url <- "https://australianantarcticdivision.github.io/measoshapes/data/v06"
for (f in list.files("../data", full.names = TRUE)) load(f)
