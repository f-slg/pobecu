# Población nacional, provincial y cantonal del INEC

Estimaciones (1950-2022) y proyecciones (2023 en adelante) oficiales de
población del Instituto Nacional de Estadística y Censos (INEC),
Revisión 2024, por año, área de residencia, sexo al nacer y grupos
quinquenales de edad. Las cifras corresponden al 30 de junio de cada
año.

## Usage

``` r
pob_nacional

pob_provincias

pob_cantones
```

## Format

`data.frame` en formato largo con las columnas:

- dpa_provin, dpa_canton:

  Código DPA (factor; solo en `pob_provincias` y `pob_cantones`).

- anio:

  Año (entero).

- area:

  `"total"`, `"urbana"` o `"rural"` (factor).

- sexo:

  `"hombre"` o `"mujer"` (factor).

- grupo_edad:

  Grupo quinquenal: `"0-4"`, `"5-9"`, ..., `"95-99"`, `"100+"` (factor
  ordenado por edad).

- poblacion:

  Número de personas (entero).

An object of class `data.frame` with 5334 rows and 5 columns.

An object of class `data.frame` with 72576 rows and 6 columns.

An object of class `data.frame` with 482664 rows and 6 columns.

## Source

INEC, *Estimaciones y Proyecciones de Población, Revisión 2024*
(tabulados con áreas de residencia, 2025),
<https://www.ecuadorencifras.gob.ec/proyecciones-poblacionales/>. Ver
`data-raw/` en el repositorio para el procesamiento completo.

## Details

Para consultarlas de forma cómoda (filtrar, agregar, cambiar los grupos
de edad o agregar nombres) usa
[`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md).

- Periodos: nacional 1950-2050, provincial 1990-2035, cantonal
  2010-2035.

- Área: en 2010-2035 cada combinación aparece dos veces, `"urbana"` y
  `"rural"`, que suman el total. Fuera de ese periodo (solo nacional y
  provincial) hay una sola fila con `area = "total"`. Según el INEC, la
  población por área es una estimación derivada de las proyecciones
  cantonales.

- Método del INEC: componentes demográficos por cohortes para los
  niveles nacional y provincial; extrapolación logística de la
  participación de cada cantón en su provincia para el nivel cantonal.

- Los tres niveles son coherentes entre sí: la suma de los cantones de
  una provincia es igual a la provincia, y la suma de las provincias es
  igual al total nacional.

## Examples

``` r
head(pob_cantones)
#>   dpa_canton anio  area   sexo grupo_edad poblacion
#> 1       0101 2010 rural hombre        0-4      9973
#> 2       0101 2010 rural hombre        5-9      9597
#> 3       0101 2010 rural hombre      10-14      9867
#> 4       0101 2010 rural hombre      15-19      9528
#> 5       0101 2010 rural hombre      20-24      8346
#> 6       0101 2010 rural hombre      25-29      7094
# Población nacional por año
tapply(pob_nacional$poblacion, pob_nacional$anio, sum)[c("1950", "2025", "2050")]
#>     1950     2025     2050 
#>  3536810 18103660 21141923 
```
