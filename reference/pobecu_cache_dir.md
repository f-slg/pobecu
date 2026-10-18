# Carpeta de caché de pobecu

Los datos por edad simple se descargan la primera vez que se piden y se
guardan aquí para no volver a descargarlos. La ubicación sigue las
convenciones de cada sistema operativo
([`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)).

## Usage

``` r
pobecu_cache_dir()
```

## Value

Ruta de la carpeta de caché (texto).

## Examples

``` r
pobecu_cache_dir()
#> [1] "/home/runner/.cache/R/pobecu/datos-v0.1.0"
```
