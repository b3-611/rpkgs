# Script to list relevant information from package webpages.

library("tidyverse")
library("readxl")
library("rvest")

devtools::load_all("myutils")

# Read required package list.
pkgs <- read_csv("data/pkgs.txt", col_names = "Package Name")

# *** For test purpose ***
# pkgs <- head(pkgs, 10)


pkgs <- pkgs %>% 
  mutate(Title = NA, CRAN = NA, Abstract = NA, Version = NA, 
         Depends = NA, Imports = NA, Suggests = NA)

n <- nrow(pkgs)

for (i in seq_len(n))  {
  # Package Name
  pkg <- pkgs$`Package Name`[i]
  message("[", i, "/", n, "]  ", pkg)

  # Fetch Information
  data <- tryCatch({
      res <- pkg_info(pkg)
      list(res = res, status = "OK")
    },
    warning = function(e) {
      status = if (str_detect("removed", e)) "REMOVED" else "MISSING"
      list(res = NULL, status = status)
    }
  )
  
  pkgs$CRAN[i] <- data$status
  
  if (is.null(data$res)) {
    #Sys.sleep(2)
    next()
  }

  # Make a list
  pkgs$Title[i] <- data$res$Title
  pkgs$Abstract[i] <- data$res$Abstract
  pkgs$Version[i] <- data$res$Version
  pkgs$Depends[i] <- data$res$Depends
  pkgs$Imports[i] <- data$res$Imports
  pkgs$Suggests[i] <- data$res$Suggests
}

# Write out the result
write_excel_csv(pkgs, "out/packages.csv")

