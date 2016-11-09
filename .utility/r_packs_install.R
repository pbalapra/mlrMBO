library(devtools)
install_github("mlr-org/mlrMBO")


print("LIBPATHS:")
print(.libPaths())

ip = installed.packages()
ip2 = rownames(ip)
print("INSTALLED PACKAGES:")
print(ip2)

p = parse_deps(ip["mlrMBO", "Suggests"])[, "name"]

pmiss = setdiff(p, ip2)
pmiss = c(pmiss, "glmnet", "ROCR", "methods", "pander", "knitr", "stringr", "digest", "caret", "rgl", "devtools")

gh.pkgs = c("berndbischl/BBmisc", "berndbischl/parallelMap", "berndbischl/ParamHelpers", "mlr-org/mlr", "mlr-org/mlrMBO")

print("MISSING PACKAGES:")
print(pmiss)
if (length(pmiss) > 0)
  install.packages(pmiss)

update.packages(ask = FALSE)

lapply(gh.pkgs, devtools::install_github)