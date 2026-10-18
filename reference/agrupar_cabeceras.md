# Fusionar parroquias urbanas en su cabecera cantonal

Convierte una capa de parroquias con códigos DPA de parroquias urbanas
(por ejemplo,
[`geoecu::read_parroquias()`](https://rdrr.io/pkg/geoecu/man/read_dpa.html))
en las unidades del Censo 2022 que usa pobecu: las parroquias urbanas de
cada cantón se unen en un solo polígono con el código de la cabecera
cantonal (sufijo `50`), y las rurales se conservan. Los códigos se
convierten con
[`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md).

## Usage

``` r
agrupar_cabeceras(capa)
```

## Arguments

- capa:

  Un objeto `sf` con una columna `dpa_parroq` (y, si existen,
  `dpa_canton`, `canton`, `dpa_provin`, `provincia` y `area_km2`).

## Value

Un objeto `sf` con una fila por unidad censal: `dpa_parroq`, `parroquia`
(nombre del Censo 2022), `tipo` (`"cabecera"` o `"rural"`), las columnas
de cantón y provincia de la capa, `area_km2` (suma) y la geometría.

## Examples

``` r
cuenca <- geoecu::read_parroquias(canton = "Cuenca")
nrow(cuenca)                      # 15 urbanas + 21 rurales
#> [1] 36
nrow(agrupar_cabeceras(cuenca))   # 1 cabecera + 21 rurales
#> [1] 22
```
