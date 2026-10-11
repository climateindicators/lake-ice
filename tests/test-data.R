# Regression checks on the generated data for the Lake Ice indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 3 dataset(s)", length(meta$datasets) == 3L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pinned from EPA's April 2021 web update. A legitimate data update fails here
# and says exactly what changed. Values compare as strings to pin source precision.
row_is <- function(df, i, ...) identical(unlist(df[i, ], use.names = FALSE), c(...))
extreme <- function(df, f) df$value[f(as.numeric(df$value))]

fr <- rd("lake_ice_freeze_dates.csv")
check("freeze dates: 1259 rows", nrow(fr) == 1259L)
check("freeze dates: 9 lakes", length(unique(fr$lake)) == 9L)
check("freeze dates: first row 1849 Otsego Lake 13", row_is(fr, 1, "1849", "Otsego Lake", "13"))
check("freeze dates: last row 2019 Mirror Lake -21.2", row_is(fr, nrow(fr), "2019", "Mirror Lake", "-21.2"))
check("freeze dates: min -47.28571429", identical(extreme(fr, which.min), "-47.28571429"))
check("freeze dates: max 31.66666667", identical(extreme(fr, which.max), "31.66666667"))

th <- rd("lake_ice_thaw_dates.csv")
check("thaw dates: 2154 rows", nrow(th) == 2154L)
check("thaw dates: 14 lakes", length(unique(th$lake)) == 14L)
check("thaw dates: first row 1840 Damariscotta Lake 110.6666667", row_is(th, 1, "1840", "Damariscotta Lake", "110.6666667"))
check("thaw dates: last row 2019 Moosehead Lake 123.4", row_is(th, nrow(th), "2019", "Moosehead Lake", "123.4"))
check("thaw dates: min 73.55555556", identical(extreme(th, which.min), "73.55555556"))
check("thaw dates: max 138.2222222", identical(extreme(th, which.max), "138.2222222"))

ch <- rd("lake_ice_thaw_change.csv")
check("thaw change: 14 rows", nrow(ch) == 14L)
check("thaw change: first row Detroit Lake", row_is(ch, 1, "Detroit Lake", "46.7833", "-95.9333", "0"))
check("thaw change: last row Moosehead Lake", row_is(ch, nrow(ch), "Moosehead Lake", "45.6408", "-69.6658", "-5.181818182"))
check("thaw change: min -24.42857143 (Lake Superior at Bayfield)",
      identical(extreme(ch, which.min), "-24.42857143") && ch$lake[which.min(as.numeric(ch$value))] == "Lake Superior at Bayfield")
check("thaw change: max 0", identical(extreme(ch, which.max), "0"))

cat("\nCross-figure\n")
check("every lake name is one of the 14 thaw-date lakes",
      all(c(fr$lake, ch$lake) %in% unique(th$lake)) && setequal(ch$lake, th$lake))

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
