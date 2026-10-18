# Mapa con población: capas de geoecu unidas a pobecu

Devuelve la capa geográfica del nivel indicado (del paquete
[geoecu](https://github.com/f-slg/geoecu)) con la población de pobecu ya
unida, lista para mapear. Ambos paquetes usan los mismos códigos DPA,
así que no hace falta preparar nada.

## Usage

``` r
pob_mapa(
  nivel = c("canton", "provincia", "parroquia"),
  anio = NULL,
  provincia = NULL,
  canton = NULL,
  sexo = FALSE,
  area = FALSE,
  edad = NULL,
  resolucion = c("baja", "alta"),
  crs = 4326
)
```

## Arguments

- nivel:

  `"canton"` (por defecto), `"provincia"` o `"parroquia"`.

- anio:

  Año o años. Por defecto, el año en curso si está disponible; si no, el
  último año disponible.

- provincia:

  Provincias a incluir, por nombre (sin importar tildes ni mayúsculas) o
  código: `"Loja"`, `"11"` o `11`. `NULL` incluye todo el país.

- canton:

  Cantones a incluir (niveles `"canton"` y `"parroquia"`), por nombre o
  código. Si un nombre se repite en varias provincias (por ejemplo,
  Bolívar u Olmedo), usa el código o indica también `provincia`.

- sexo:

  Si es `TRUE`, desagrega por sexo al nacer (`"hombre"`, `"mujer"`).

- area:

  Si es `TRUE`, desagrega por área de residencia (`"urbana"`,
  `"rural"`). Solo para los niveles nacional, provincial y cantonal, y
  para los años 2010-2035.

- edad:

  Desagregación por edad:

  - `NULL` (por defecto): sin desagregar.

  - `"quinquenal"`: grupos de 5 años (`"0-4"`, ..., `"100+"`; en el
    nivel parroquial el último grupo es `"85+"`).

  - `"simple"`: años cumplidos, de 0 a 100 (100 = 100 y más).

  - `"etapas"`: etapas de vida del INEC (0-11, 12-17, 18-29, 30-64,
    65+).

  - Un vector numérico con las edades de inicio de cada grupo, por
    ejemplo `c(0, 1, 5, 15, 65)` para 0, 1-4, 5-14, 15-64 y 65+.

  Los grupos quinquenales (y los cortes múltiplos de 5) vienen dentro
  del paquete. Las edades simples, las etapas y los demás cortes usan
  datos que se descargan la primera vez (ver
  [`pobecu_datos_disponibles()`](https://f-slg.github.io/pobecu/reference/pobecu_datos_disponibles.md))
  y no están disponibles para parroquias.

- resolucion, crs:

  Resolución y sistema de coordenadas de la capa, como en
  [`geoecu::read_cantones()`](https://rdrr.io/pkg/geoecu/man/read_dpa.html).

## Value

Un objeto `sf` con las columnas de la capa, las de
[`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md)
(`anio`, `poblacion` y las desagregaciones pedidas) y `densidad`
(habitantes por km²). Con varios años o desagregaciones, cada polígono
se repite una vez por combinación (útil para
[`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)).

## Details

En el nivel parroquial las parroquias urbanas de geoecu se fusionan en
su cabecera cantonal con
[`agrupar_cabeceras()`](https://f-slg.github.io/pobecu/reference/agrupar_cabeceras.md),
porque esa es la unidad del Censo 2022 y de la estimación parroquial.

## See also

[`agrupar_cabeceras()`](https://f-slg.github.io/pobecu/reference/agrupar_cabeceras.md),
[`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md).

## Examples

``` r
m <- pob_mapa("canton", anio = 2025, provincia = "Loja")
plot(m["densidad"], logz = TRUE)


# Parroquias de Cuenca: las 15 urbanas se fusionan en la cabecera
pob_mapa("parroquia", anio = 2030, canton = "Cuenca")
#> Nota: las cifras parroquiales son una estimación de pobecu a partir de las proyecciones cantonales del INEC; no son cifras oficiales. Ver ?pob_parroquias. (Este aviso se muestra una vez por sesión.)
#> Simple feature collection with 22 features and 11 fields
#> Geometry type: GEOMETRY
#> Dimension:     XY
#> Bounding box:  xmin: -79.67032 ymin: -3.17256 xmax: -78.84732 ymax: -2.5169
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>    dpa_parroq                parroquia     tipo dpa_canton canton dpa_provin
#> 1      010150                   Cuenca cabecera       0101 CUENCA         01
#> 2      010151                    Baños    rural       0101 CUENCA         01
#> 3      010152                    Cumbe    rural       0101 CUENCA         01
#> 4      010153                  Chaucha    rural       0101 CUENCA         01
#> 5      010154                    Checa    rural       0101 CUENCA         01
#> 6      010155               Chiquintad    rural       0101 CUENCA         01
#> 7      010156                   Llacao    rural       0101 CUENCA         01
#> 8      010157                Molleturo    rural       0101 CUENCA         01
#> 9      010158                    Nulti    rural       0101 CUENCA         01
#> 10     010159 Octavio Cordero Palacios    rural       0101 CUENCA         01
#>    provincia area_km2 anio poblacion                       geometry    densidad
#> 1      AZUAY   71.625 2030    368885 POLYGON ((-79.02874 -2.876,... 5150.226876
#> 2      AZUAY  251.445 2030     24962 MULTIPOLYGON (((-79.04957 -...   99.274195
#> 3      AZUAY   75.132 2030      6978 MULTIPOLYGON (((-78.97793 -...   92.876537
#> 4      AZUAY  379.992 2030      2010 MULTIPOLYGON (((-79.29187 -...    5.289585
#> 5      AZUAY  110.859 2030      3464 MULTIPOLYGON (((-78.98794 -...   31.246899
#> 6      AZUAY   93.446 2030      6283 MULTIPOLYGON (((-79.12004 -...   67.236693
#> 7      AZUAY   15.962 2030      9021 MULTIPOLYGON (((-78.91612 -...  565.154743
#> 8      AZUAY  983.773 2030      6594 MULTIPOLYGON (((-79.2892 -2...    6.702766
#> 9      AZUAY   27.041 2030      8633 MULTIPOLYGON (((-78.89031 -...  319.255945
#> 10     AZUAY   20.878 2030      2640 MULTIPOLYGON (((-78.97988 -...  126.448894
```
