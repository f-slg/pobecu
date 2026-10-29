# Unir la población con una tabla propia

Agrega a tu tabla (por ejemplo, casos por cantón y año) una columna con
la población correspondiente, usando el código DPA y, si existe, el año.
Los códigos se limpian con
[`formatear_codigo()`](https://f-slg.github.io/pobecu/reference/formatear_codigo.md),
así que funcionan aunque vengan de Excel sin ceros a la izquierda.

## Usage

``` r
pob_unir(
  datos,
  nivel = c("canton", "provincia", "parroquia"),
  codigo = NULL,
  anio = NULL,
  sexo = FALSE,
  edad = NULL
)
```

## Arguments

- datos:

  Un `data.frame` con una columna de códigos DPA.

- nivel:

  `"canton"` (por defecto), `"provincia"` o `"parroquia"`.

- codigo:

  Nombre de la columna de `datos` con el código DPA. Por defecto se usa
  `dpa_provin`, `dpa_canton` o `dpa_parroq` según el nivel.

- anio:

  Nombre de la columna de `datos` con el año, o un año fijo (número)
  para toda la tabla. Por defecto se usa la columna `anio` si existe.
  Acepta columnas numéricas, de texto o factor con años enteros.

- sexo, edad:

  Desagregación de la población, como en
  [`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md).
  Si la usas, `datos` debe tener columnas `sexo` (`"hombre"`/`"mujer"`)
  y/o `edad` con los mismos valores que devuelve
  [`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md).

## Value

`datos` con una columna adicional `poblacion`. Las filas sin
coincidencia quedan con `NA` y se avisa con una advertencia.

## Examples

``` r
casos <- data.frame(dpa_canton = c(1101, 1102, 701), anio = 2024,
                    casos = c(120, 8, 40))
pob_unir(casos)
#>   dpa_canton anio casos poblacion
#> 1       1101 2024   120    257110
#> 2       1102 2024     8     26544
#> 3        701 2024    40    321196

# Por sexo
casos_sexo <- data.frame(dpa_provin = "11", anio = 2025,
                         sexo = c("hombre", "mujer"), casos = c(10, 14))
pob_unir(casos_sexo, nivel = "provincia", sexo = TRUE)
#>   dpa_provin anio   sexo casos poblacion
#> 1         11 2025 hombre    10    243527
#> 2         11 2025  mujer    14    254930
```
