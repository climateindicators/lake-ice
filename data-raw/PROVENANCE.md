# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-lake-ice/index.html>  \
  sha256 `7bd432fa48d9d79aa01a3307c5e8e72bc4f0ff03b3ccb631e82c17525a696237`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-06/lake-ice_documentation.pdf>

## Figure data

- `lake-ice_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2021-04/lake-ice_fig-1.csv>  \
  sha256 `07ca0c4d933fa86f2b7fbb92837a76808a33a8b1ac0e0af31ee34a6bdaabf1b6`  \
  encoding UTF-8, 171 data rows, columns: `Year`, `Detroit Lake`, `Lake George`, `Lake Mendota`, `Lake Monona`, `Mirror Lake`, `Otsego Lake`, `Shell Lake`, `Lake Superior at Bayfield`, `Geneva Lake`  \
  title: Figure 1. Date of First Freeze for Selected U.S. Lakes, 1850-2019  \
  data source: Various organizations; web update: April 2021; units: days from January 1

- `lake-ice_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2021-04/lake-ice_fig-2.csv>  \
  sha256 `2e94ba491fe6b55c8f12f9694ba7a93dd2bba0256e00734d164670fcab32c284`  \
  encoding UTF-8, 180 data rows, columns: `Year`, `Detroit Lake`, `Lake George`, `Lake Mendota`, `Lake Monona`, `Mirror Lake`, `Otsego Lake`, `Shell Lake`, `Superior at Bayfield`, `Geneva Lake`, `Lake Osakis`, `Damariscotta Lake`, `Cobbosseecontee Lake`, `Sebago Lake`, `Moosehead Lake`  \
  title: Figure 2. Date of Ice Thaw for Selected U.S. Lakes, 1840-2019  \
  data source: Various organizations; web update: April 2021; units: days from January 1

- `lake-ice_fig-3.csv`  \
  <https://19january2025snapshot.epa.gov/sites/default/files/2021-04/lake-ice_fig-3.csv>  \
  sha256 `a2984b0acc1d55a7bc7bf346782fa5271ce6f23670e8da3e6ba92bfcb60e4422`  \
  encoding UTF-8, 14 data rows, columns: `Lake name`, `Lat`, `Long`, `Change in ice thaw date`  \
  title: Figure 3. Change in Ice Thaw Dates for Selected U.S. Lakes, 1905-2019  \
  data source: Various organizations; web update: April 2021; units: days change from 1905 to 2019
