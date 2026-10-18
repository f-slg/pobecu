# Homologar códigos parroquiales a las unidades del Censo 2022

El Censo 2022 y las estimaciones parroquiales de pobecu tratan cada
**cabecera cantonal** como una sola unidad (código terminado en `50`),
sin separar las parroquias urbanas. En cambio, la cartografía (por
ejemplo, el paquete geoecu) y muchos registros administrativos usan
códigos de parroquias urbanas (sufijos `01` a `49`, como las 15
parroquias urbanas de Cuenca).

## Usage

``` r
homologar_parroquia(codigo)
```

## Arguments

- codigo:

  Vector de códigos de parroquia (número o texto).

## Value

Vector de texto con códigos de 6 dígitos.

## Details

Esta función convierte esos códigos al de su cabecera cantonal para
poder agregar los datos y unirlos con la población. Los códigos de
parroquias rurales (sufijo `51` a `99`) se devuelven sin cambios, salvo
los casos especiales documentados abajo.

Casos especiales:

- `220254` (Tiputini, Aguarico): no figura como parroquia rural en el
  Censo 2022; su población está incluida en la cabecera cantonal
  `220250`.

## Examples

``` r
# Parroquias urbanas de Cuenca -> cabecera cantonal de Cuenca
homologar_parroquia(c("010101", "010115", "010150", "010151"))
#> [1] "010150" "010150" "010150" "010151"

# Agregar casos por parroquia urbana a la unidad del censo
casos <- data.frame(dpa_parroq = c("010101", "010102", "010151"),
                    casos = c(3, 5, 1))
casos$dpa_parroq <- homologar_parroquia(casos$dpa_parroq)
aggregate(casos ~ dpa_parroq, casos, sum)
#>   dpa_parroq casos
#> 1     010150     8
#> 2     010151     1
```
