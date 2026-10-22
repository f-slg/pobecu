# Buscar en el catálogo de pobecu

Busca por nombre (sin importar tildes ni mayúsculas) o por código en el
catálogo [dpa_pob](https://f-slg.github.io/pobecu/reference/dpa_pob.md).

## Usage

``` r
buscar_pob(texto, nivel = c("parroquia", "canton", "provincia"))
```

## Arguments

- texto:

  Texto a buscar: parte de un nombre o un código.

- nivel:

  Nivel en el que buscar: `"parroquia"`, `"canton"` o `"provincia"`.

## Value

Un `data.frame` con las coincidencias en el nivel indicado.

## Examples

``` r
buscar_pob("arenal")
#>   dpa_parroq parroquia            tipo dpa_canton  canton dpa_provin provincia
#> 1     111052 El Arenal parroquia rural       1110 Puyango         11      Loja
buscar_pob("puyango", nivel = "canton")
#>   dpa_canton  canton dpa_provin provincia
#> 1       1110 Puyango         11      Loja
buscar_pob("11", nivel = "provincia")
#>   dpa_provin provincia
#> 1         11      Loja
```
