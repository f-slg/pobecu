## Submission

This is the first submission of 'pobecu'.

## Test environments

* Local: Ubuntu Linux, R 4.5.2 (`R CMD check --as-cran`)
* GitHub Actions: windows-latest, macos-latest and ubuntu-latest (R release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for the reviewers

* 'geoecu' (Suggests) is the companion package with the boundaries of the
  same territorial units and is available on CRAN (version 0.4.0). All
  uses of 'geoecu' are conditional (`requireNamespace()`), and the related examples, tests and
  vignette chunks are skipped when it is not installed.

* Population tables by five-year age groups are shipped with the package
  (about 1.2 MB, xz-compressed). Single-year-of-age data (2 MB) are
  downloaded on first use from the package's GitHub release and cached with
  `tools::R_user_dir("pobecu", "cache")`. Users can also point the package to
  local copies with `pobecu_usar_carpeta()`.
* Functions that need the downloaded data fail with an informative message
  when the internet is not available. Examples that need it are wrapped in
  `@examplesIf pobecu_datos_disponibles()`, and the corresponding tests are
  skipped when the data are not available, so checks do not require internet
  access.
* The documentation is in Spanish (`Language: es`) because the package is
  aimed at users in Ecuador; the Title and Description are in English.
