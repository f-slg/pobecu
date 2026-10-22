# Convertir una capa de geoecu a las unidades del Censo 2022

Fusiona los polígonos de una capa de cantones o parroquias (por ejemplo,
[`geoecu::read_cantones()`](https://f-slg.github.io/geoecu/reference/read_dpa.html)
o
[`geoecu::read_parroquias()`](https://f-slg.github.io/geoecu/reference/read_dpa.html))
en las unidades del Censo 2022 que usa pobecu, para unirla con la
población sin perder ni repetir territorio. Los códigos se convierten
con
[`homologar_canton()`](https://f-slg.github.io/pobecu/reference/homologar_canton.md)
o
[`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md)
y los polígonos con el mismo código se unen:

## Usage

``` r
agrupar_unidades(capa)

agrupar_cabeceras(capa)
```

## Arguments

- capa:

  Un objeto `sf` con una columna `dpa_parroq` (parroquias) o
  `dpa_canton` (cantones). Si existen, se usan también `tipo` y
  `area_km2`.

## Value

Un objeto `sf` con una fila por unidad del censo: el código, los nombres
de pobecu (de la parroquia, el cantón y la provincia, según el nivel),
`tipo` (`"cabecera cantonal"` o `"parroquia rural"` en el nivel
parroquial; el de la capa en el cantonal), `area_km2` (suma) y la
geometría.

## Details

- Con geoecu 0.4.0 y posteriores (CONALI 2026): los cantones Borbón y
  Sevilla Don Bosco vuelven a Eloy Alfaro y Morona, y las parroquias
  creadas después del censo (Sosote, Shuar Pastaza, Juan Montalvo, La
  Magdalena, La Primavera y Miss Ecuador) se unen a la parroquia censal
  que las contenía.

- Con geoecu 0.3.0 y anteriores: las parroquias urbanas de cada cantón
  se unen en su cabecera cantonal (por ejemplo, las 15 de Cuenca).

Las unidades que no existen en pobecu, como las zonas en estudio, se
conservan con sus datos originales. `agrupar_cabeceras()` es el nombre
anterior de esta función y se mantiene por compatibilidad.

## Examples

``` r
esmeraldas <- geoecu::read_cantones(provincia = "Esmeraldas")
nrow(esmeraldas)                    # con Borbón
#> [1] 8
nrow(agrupar_unidades(esmeraldas))  # Borbón dentro de Eloy Alfaro
#> [1] 7
```
