## Submission

This is a patch release of 'pobecu' (0.3.0 -> 0.3.1). It fixes recovery
from a corrupted download cache for single-year-of-age population data,
validates malformed geographic codes and filters, and improves diagnostics
for rows that cannot be matched to a population denominator. See NEWS.md.
The population data (data release 'datos-v0.1.0') and statistical methods
are unchanged.

## Reason for the early update

We apologise for requesting another update only one week after 0.3.0
(published 2026-11-07), despite stating in that submission that we did not
plan another update in the coming months. We are requesting an exception
for the following reproducible reliability defects.

In 0.3.0, a truncated single-year-of-age data file is treated as available
and reused on every call. Age-specific population queries then fail with
an uninformative readRDS error until the user manually clears the cache.
Version 0.3.1 verifies the official file's checksum on download and first
use in each session, saves completed downloads via a temporary file, and
redownloads a damaged cache. It also rejects malformed codes instead of
padding them into impossible codes, and identifies why population joins
fail (code, year, sex or age).

The intended application is the extraction of population denominators for
epidemiological rates, including surveillance of waterborne diseases.
Ecuador is under a national red alert for El Nino, declared on 29 August
2026 (SNGR Resolution 238-2026). PAHO's 2026-2027 public health situation
analysis identifies increased risks of waterborne and foodborne diseases
among the possible consequences of the event. In this context, these
fixes improve the reliability of age-specific denominator extraction and
help users detect unmatched records before calculating rates.

We have not identified incorrect population figures in 0.3.0; the changes
address access to the data, input validation and diagnostics. We
understand that the epidemiological context does not by itself establish
urgency, and will respect CRAN's decision if this update should wait.

Official sources for the context:
* https://www.gestionderiesgos.gob.ec/sitrep-eventos-de-lluvias-por-alerta-roja/
* https://www.paho.org/es/documentos/analisis-situacion-salud-publica-nino-americas-2026-2027-24-junio-2026

## Test environments

* Local Ubuntu 26.04.1 LTS, R 4.5.2: R CMD check --as-cran on the built
  source tarball, including --run-donttest examples and the PDF manual.
* GitHub Actions: Windows, macOS and Ubuntu (R release), Ubuntu (R-devel).
* Local tests with geoecu 0.4.2 and the published data available:
  224 expectations, 0 failures, 0 errors, 0 skips.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for the reviewers

* 'geoecu' (Suggests, >= 0.4.1) is the companion package for geographic
  boundaries. Version 0.4.2 is available on CRAN. All uses are conditional
  on it being installed; map examples and tests also require the layers
  to be available locally.
* Single-year-of-age data are downloaded on first use from the package's
  GitHub data release and cached with tools::R_user_dir("pobecu", "cache").
  Examples needing those data use @examplesIf pobecu_datos_disponibles(),
  and corresponding tests skip when the data are unavailable.
* The cache unit tests use temporary directories and local file://
  sources. A separate end-to-end repair test accesses the published data
  and is skipped on CRAN. Checks do not require downloading the data.
* The examples of pob_ajustar() and pob_estimar() use \donttest{} because
  fitting the model is comparatively expensive.
* Documentation is in Spanish (Language: es); Title and Description are
  in English. DOI and ORCID metadata are included in this release.
