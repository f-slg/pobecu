# Catálogo de parroquias, cantones y provincias de pobecu

Una fila por parroquia del Censo 2022, con sus códigos DPA, nombres
oficiales del INEC, la población censal 2010 y 2022 y el método usado en
la estimación parroquial.

## Usage

``` r
dpa_pob
```

## Format

Un `data.frame` con 1042 filas y 10 columnas:

- dpa_parroq:

  Código DPA de la parroquia (6 dígitos, texto). Las cabeceras
  cantonales terminan en `50`.

- parroquia:

  Nombre de la parroquia según el Censo 2022.

- tipo:

  `"cabecera cantonal"` (incluye las parroquias urbanas) o
  `"parroquia rural"`, con los mismos valores que geoecu.

- dpa_canton, canton:

  Código y nombre del cantón.

- dpa_provin, provincia:

  Código y nombre de la provincia.

- metodo:

  Método de la estimación parroquial: `"logistica"`,
  `"participacion_constante"` (cantones con parroquias creadas después
  de 2010) o `"parroquia_unica"` (cantones de una sola parroquia).

- censo_2010, censo_2022:

  Población empadronada en los censos 2010 (en los límites de 2022; `NA`
  para parroquias creadas después de 2010) y 2022.

## Source

INEC, VIII Censo de Población y VII de Vivienda 2022, tablas 2.1 y 5.2
de *Estructura poblacional*. Los códigos de las parroquias rurales se
asignaron por nombre a partir de la División Político-Administrativa
oficial.

## Details

Los cantones y parroquias creados después del censo (por ejemplo, el
cantón Borbón o la parroquia Sosote) no tienen fila propia: su población
está incluida en la unidad censal que los contenía. Ver
[`homologar_canton()`](https://f-slg.github.io/pobecu/reference/homologar_canton.md)
y
[`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md).

## Examples

``` r
head(dpa_pob)
#>   dpa_parroq  parroquia              tipo dpa_canton canton dpa_provin
#> 1     010150     Cuenca cabecera cantonal       0101 Cuenca         01
#> 2     010151      Baños   parroquia rural       0101 Cuenca         01
#> 3     010152      Cumbe   parroquia rural       0101 Cuenca         01
#> 4     010153    Chaucha   parroquia rural       0101 Cuenca         01
#> 5     010154      Checa   parroquia rural       0101 Cuenca         01
#> 6     010155 Chiquintad   parroquia rural       0101 Cuenca         01
#>   provincia    metodo censo_2010 censo_2022
#> 1     Azuay logistica     334015     361524
#> 2     Azuay logistica      16962      21797
#> 3     Azuay logistica       5501       6455
#> 4     Azuay logistica       1296       1721
#> 5     Azuay logistica       2736       3204
#> 6     Azuay logistica       4788       5738
table(dpa_pob$provincia, dpa_pob$tipo)
#>                                 
#>                                  cabecera cantonal parroquia rural
#>   Azuay                                         15              61
#>   Bolívar                                        7              19
#>   Carchi                                         6              26
#>   Cañar                                          7              26
#>   Chimborazo                                    10              45
#>   Cotopaxi                                       7              33
#>   El Oro                                        14              50
#>   Esmeraldas                                     7              57
#>   Galápagos                                      3               5
#>   Guayas                                        25              29
#>   Imbabura                                       6              36
#>   Loja                                          16              78
#>   Los Ríos                                      13              17
#>   Manabí                                        22              55
#>   Morona Santiago                               12              46
#>   Napo                                           5              20
#>   Orellana                                       4              28
#>   Pastaza                                        4              17
#>   Pichincha                                      8              53
#>   Santa Elena                                    3               8
#>   Santo Domingo De Los Tsáchilas                 2              10
#>   Sucumbíos                                      7              29
#>   Tungurahua                                     9              44
#>   Zamora Chinchipe                               9              29
```
