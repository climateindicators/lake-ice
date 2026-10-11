# Build tidy long-format data for the Lake Ice indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Generated as a stub by the build-indicator skill. Each figure below has a
# `todo_reshape()` call standing where its reshape belongs. Replace that line,
# then delete the todo_reshape() helper once no call to it remains.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# EPA spells the same lake differently from file to file ("Superior at Bayfield",
# "Geneva", "Osakis"). Every figure's lake column is mapped onto one canonical
# name here so the three outputs join on `lake`. Names are matched exactly; an
# unlisted spelling stops the build rather than passing through.
LAKES <- c(
  "Detroit Lake"              = "Detroit Lake",
  "Lake George"               = "Lake George",
  "Lake Mendota"              = "Lake Mendota",
  "Lake Monona"               = "Lake Monona",
  "Mirror Lake"               = "Mirror Lake",
  "Otsego Lake"               = "Otsego Lake",
  "Shell Lake"                = "Shell Lake",
  "Lake Superior at Bayfield" = "Lake Superior at Bayfield",
  "Superior at Bayfield"      = "Lake Superior at Bayfield",
  "Geneva Lake"               = "Geneva Lake",
  "Geneva"                    = "Geneva Lake",
  "Lake Osakis"               = "Lake Osakis",
  "Osakis"                    = "Lake Osakis",
  "Damariscotta Lake"         = "Damariscotta Lake",
  "Damariscotta"              = "Damariscotta Lake",
  "Cobbosseecontee Lake"      = "Cobbosseecontee Lake",
  "Cobbosseecontee"           = "Cobbosseecontee Lake",
  "Sebago Lake"               = "Sebago Lake",
  "Sebago"                    = "Sebago Lake",
  "Moosehead Lake"            = "Moosehead Lake",
  "Moosehead"                 = "Moosehead Lake"
)

canonical_lake <- function(x, what) {
  bad <- setdiff(x, names(LAKES))
  if (length(bad)) {
    stop("Unknown lake name(s) in ", what, ": ", paste(sQuote(bad), collapse = ", "),
         "\nAdd the spelling to LAKES in R/build_data.R.", call. = FALSE)
  }
  unname(LAKES[x])
}

# Year x lake wide table to one row per populated (year, lake) cell, rows in
# source order (year, then column order). Blank cells are years with no record.
pivot_lakes <- function(df, lake_cols, what) {
  df |>
    tidyr::pivot_longer(dplyr::all_of(lake_cols), names_to = "lake", values_to = "value") |>
    filter(value != "") |>
    transmute(year = Year, lake = canonical_lake(lake, what), value)
}

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Lake Ice",
  slug                    = "lake-ice",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-lake-ice/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-06/lake-ice_documentation.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Date of First Freeze for Selected U.S. Lakes, 1850-2019 ----

f1_path <- file.path(raw_dir, "lake-ice_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

f1_lakes <- c("Detroit Lake", "Lake George", "Lake Mendota", "Lake Monona", "Mirror Lake", "Otsego Lake", "Shell Lake", "Lake Superior at Bayfield", "Geneva Lake")
assert_headers(f1_raw, id_cols = "Year", expected_headers = f1_lakes, what = "lake-ice_fig-1.csv")

# Units: days from January 1 (negative = before January 1). Values as character
# so the 10-digit source values survive byte for byte.
f1 <- pivot_lakes(f1_raw, f1_lakes, "lake-ice_fig-1.csv")
assert_conservation(f1_raw, f1_lakes, nrow(f1), "lake-ice_fig-1.csv")

write_csv_stable(f1, file.path(out_dir, "lake_ice_freeze_dates.csv"))

# ---- Figure 2: Date of Ice Thaw for Selected U.S. Lakes, 1840-2019 ----

f2_path <- file.path(raw_dir, "lake-ice_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

f2_lakes <- c("Detroit Lake", "Lake George", "Lake Mendota", "Lake Monona", "Mirror Lake", "Otsego Lake", "Shell Lake", "Superior at Bayfield", "Geneva Lake", "Lake Osakis", "Damariscotta Lake", "Cobbosseecontee Lake", "Sebago Lake", "Moosehead Lake")
assert_headers(f2_raw, id_cols = "Year", expected_headers = f2_lakes, what = "lake-ice_fig-2.csv")

# Units: days from January 1.
f2 <- pivot_lakes(f2_raw, f2_lakes, "lake-ice_fig-2.csv")
assert_conservation(f2_raw, f2_lakes, nrow(f2), "lake-ice_fig-2.csv")

write_csv_stable(f2, file.path(out_dir, "lake_ice_thaw_dates.csv"))

# ---- Figure 3: Change in Ice Thaw Dates for Selected U.S. Lakes, 1905-2019 ----

f3_path <- file.path(raw_dir, "lake-ice_fig-3.csv")
f3_meta <- read_epa_preamble(f3_path)
f3_raw  <- read_epa_csv(f3_path)

assert_headers(
  f3_raw,
  id_cols          = c("Lake name", "Lat", "Long"),
  expected_headers = "Change in ice thaw date",
  what             = "lake-ice_fig-3.csv"
)

# Already one row per lake, so no pivot. Units: days change from 1905 to 2019
# (negative = thaw now comes earlier).
f3 <- f3_raw |>
  transmute(
    lake      = canonical_lake(`Lake name`, "lake-ice_fig-3.csv"),
    latitude  = Lat,
    longitude = Long,
    value     = `Change in ice thaw date`
  )

write_csv_stable(f3, file.path(out_dir, "lake_ice_thaw_change.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

# One entry per output column, in order, filled from the data frame itself so it
# cannot drift.
describe <- function(df, value_desc) {
  docs <- list(
    year      = c("integer", "Year."),
    lake      = c("string", "Lake name, normalised to one spelling across all three files."),
    latitude  = c("number", "Latitude of the lake in decimal degrees (north positive)."),
    longitude = c("number", "Longitude of the lake in decimal degrees (west negative)."),
    value     = c("number", value_desc)
  )
  lapply(names(df), function(nm) col(nm, docs[[nm]][1], docs[[nm]][2]))
}

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "lake_ice_freeze_dates.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "lake-ice_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(f1, "Date of first freeze, in days from January 1 (negative = before January 1), as published by EPA.")
    ),
    list(
      file            = "lake_ice_thaw_dates.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "lake-ice_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = describe(f2, "Date of ice thaw, in days from January 1, as published by EPA.")
    ),
    list(
      file            = "lake_ice_thaw_change.csv",
      figure          = "Figure 3",
      figure_title    = f3_meta$title,
      source_file     = "lake-ice_fig-3.csv",
      source_sha256   = file_sha256(f3_path),
      source_encoding = "UTF-8",
      data_source     = f3_meta$data_source,
      web_update      = f3_meta$web_update,
      unit            = f3_meta$units,
      rows            = nrow(f3),
      columns         = describe(f3, "Change in ice thaw date from 1905 to 2019, in days (negative = earlier thaw).")
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
