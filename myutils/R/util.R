#' Convert xlsx file into csv.
#'
#' @param xlsx An Excel file.
#' @param path Destination path.
#'
#' @return Contents of the input.
#' @export
xlsx2csv <- function(xlsx, path) {
  f <- readxl::read_xlsx(xlsx)
  readr::write_excel_csv(f, path)
}


#' Get information for packages on CRAN.
#'
#' @param pkgname Package Name
#' @param baseurl Baseurl for package info, defaults to "https://cran.r-project.org/web/packages/"
#'
#' @return Package information. (NULL if CRAN doesn't have it.)
#' @export
#'
#' @examples
#' pkg_info("tidyverse") #=> Returns information.
#' pkg_infO("R") #=> Returns NULL
#'
#' @importFrom magrittr %>%
pkg_info <- function(pkgname, baseurl = NULL) {
  if (is.null(baseurl)) {
    baseurl <- "https://cran.r-project.org/web/packages/"
  }
  pkg_url <- paste0(baseurl, pkgname)

  ret <- list()
  ret["Package Name"] <- pkgname

  result <- tryCatch({
    # Throw a HTTP Request
    h <- xml2::read_html(pkg_url)
    TRUE
  },
  error = function(e){
    # In case of 404 etc.
    FALSE
  })

  if (result) {
    ret["CRAN"] <- "YES"
  } else {
    ret["CRAN"] <- "NO"
    message(".........Not a CRAN package.... Sorry...")
    return(NULL)
  }
  # Do the following only when we get status code 200.

  # Get title
  ret["Title"] <- rvest::html_node(h, xpath = "/html/body/h2") %>% rvest::html_text()

  # Get abstract; consider the case where the package is removed from CRAN.
  abstract <- rvest::html_node(h, xpath = "/html/body/p[1]") %>% rvest::html_text()
  if (stringr::str_detect(abstract, ".*removed from the CRAN repository")) {
    message(".........Removed from the CRAN repository.... Sorry...")
    ret["CRAN"] = "REMOVED"
    return(NULL)
  }
  # Unless it's removed, do the following

  ret["Abstract"] <- abstract

  # Read details
  summary_table <-
    rvest::html_node(h, xpath = "/html/body/table[1]") %>%
    rvest::html_table() %>%
    dplyr::mutate(X1 = stringr::str_remove(X1, ":"))

  info <- summary_table[, 2, drop = FALSE]
  rownames(info) <- summary_table[, 1]
  colnames(info) <- "Value"

  # Populate the data
  ret["Version"] <- info["Version", 1]
  ret["Depends"] <- info["Depends", 1]
  ret["Imports"] <- info["Imports", 1]
  ret["Suggests"] <- info["Suggests", 1]

  ret
}
