# Calcular tasas con la población de pobecu

Une la población con
[`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md) y
calcula una tasa por cada `por` habitantes (por defecto, por 100 000).

## Usage

``` r
pob_tasa(
  datos,
  casos,
  nivel = c("canton", "provincia", "parroquia"),
  por = 1e+05,
  ...
)
```

## Arguments

- datos:

  Un `data.frame` con una columna de códigos DPA.

- casos:

  Nombre de la columna de `datos` con el numerador (casos, defunciones,
  nacimientos, etc.).

- nivel:

  `"canton"` (por defecto), `"provincia"` o `"parroquia"`.

- por:

  Base de la tasa. Por defecto 100 000 habitantes.

- ...:

  Otros argumentos para
  [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md)
  (`codigo`, `anio`, `sexo`, `edad`).

## Value

`datos` con las columnas `poblacion` y `tasa`.

## Examples

``` r
casos <- data.frame(dpa_provin = c("01", "11", "17"), anio = 2024,
                    casos = c(35, 52, 210))
pob_tasa(casos, "casos", nivel = "provincia")
#>   dpa_provin anio casos poblacion      tasa
#> 1         01 2024    35    831220  4.210678
#> 2         11 2024    52    497438 10.453564
#> 3         17 2024   210   3272265  6.417573
```
