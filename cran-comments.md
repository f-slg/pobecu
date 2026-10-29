## Submission

This is an update of 'pobecu' (0.2.0 -> 0.3.0). It adds the functions
`pob_ajustar()` and `pob_estimar()` (territorial population scenarios for
1900-2100), stricter input validation in `pob_unir()` and `pob_tasa()`, and a
`print()` method for `pob_fuentes()`. See NEWS.md for details.

## Test environments

* Local: Ubuntu Linux, R 4.5.2 (`R CMD check --as-cran`)
* GitHub Actions: windows-latest, macos-latest and ubuntu-latest (R release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for the reviewers

* 'geoecu' (Suggests, >= 0.4.1) is the companion package with the boundaries
  of the same territorial units and is available on CRAN. All uses of
  'geoecu' are conditional (`requireNamespace()`), and the related examples,
  tests and vignette chunks are skipped when it is not installed.
* Single-year-of-age data are downloaded on first use from the package's
  GitHub release and cached with `tools::R_user_dir("pobecu", "cache")`.
  Examples that need them are wrapped in `@examplesIf
  pobecu_datos_disponibles()` and the corresponding tests are skipped when
  the data are not available, so checks do not require internet access.
* The examples of `pob_ajustar()` and `pob_estimar()` are in `\donttest{}`
  because fitting the model takes about 8 seconds.
* The documentation is in Spanish (`Language: es`); the Title and
  Description are in English.
