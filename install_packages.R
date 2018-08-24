# Script to install necessary packages.

pkg_list <- "https://raw.githubusercontent.com/b3-611/rpkgs/master/data/pkgs.txt"
repo = "https://cloud.r-project.org"

pkgs <- read.csv(pkg_list, header = FALSE, stringsAsFactors = FALSE)
install.packages(pkgs[, 1], dependencies = TRUE, repos = repo)
