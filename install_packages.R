# Script to install necessary packages.

csv <- "extdata/pkgs.txt"
repo = "https://cloud.r-project.org"

pkgs <- read.csv(pkg_list, header = FALSE, stringsAsFactors = FALSE)
install.packages(pkgs, dependencies = TRUE, repos = repo)
