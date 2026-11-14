# Carpeta de caché de pobecu

Los datos por edad simple se descargan la primera vez que se piden y se
guardan aquí para no volver a descargarlos. La ubicación sigue las
convenciones de cada sistema operativo
([`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)). La
primera vez que se usan en cada sesión se comprueba su huella; si el
archivo está incompleto o modificado, se descarga de nuevo. Para usar un
archivo propio, indica otra carpeta con
[`pobecu_usar_carpeta()`](https://f-slg.github.io/pobecu/reference/pobecu_usar_carpeta.md).

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
