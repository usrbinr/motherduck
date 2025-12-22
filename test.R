library(devtools)

document()

pkgdown::build_site()
check(remote=TRUE,manual=TRUE)


