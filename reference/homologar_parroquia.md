# Homologar códigos parroquiales a las unidades del Censo 2022

El Censo 2022 y las estimaciones parroquiales de pobecu usan las
parroquias vigentes en el censo: cada **cabecera cantonal** es una sola
unidad (código terminado en `50`), sin separar las parroquias urbanas.
Otras fuentes usan códigos que no existen en el censo:

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

- **Parroquias urbanas** (sufijos `01` a `49`, como las 15 de Cuenca),
  que aparecen en muchos registros administrativos y en geoecu 0.3.0 y
  anteriores. Se convierten al código de su cabecera cantonal.

- **Códigos de la Organización Territorial del Estado del CONALI
  (2026)**, que usa geoecu desde la versión 0.4.0: las parroquias de los
  cantones creados después del censo (Borbón, antes en Eloy Alfaro, y
  Sevilla Don Bosco, antes en Morona) y Bella Vista (Santa Cruz)
  recuperan su código del censo, y las parroquias creadas después del
  censo (Sosote, Shuar Pastaza, Juan Montalvo, La Magdalena, La
  Primavera y Miss Ecuador) se convierten al de la parroquia censal que
  las contenía.

Así se pueden agregar los datos y unirlos con la población. Los demás
códigos se devuelven sin cambios.

Casos especiales:

- `220254` (Tiputini, Aguarico): no figura como parroquia rural en el
  Censo 2022; su población está incluida en la cabecera cantonal
  `220250`.

- La Magdalena (`210456`) se formó con territorio de Shushufindi,
  Limoncocha y San Roque; se asigna a Shushufindi (`210450`), de donde
  salió la mayor parte.

- Las zonas en estudio de geoecu (`139090`, `140190`, `900651`) no
  tienen población en pobecu y se devuelven sin cambios.

## See also

[`homologar_canton()`](https://f-slg.github.io/pobecu/reference/homologar_canton.md)
para los códigos de cantón.

## Examples

``` r
# Parroquias urbanas de Cuenca -> cabecera cantonal de Cuenca
homologar_parroquia(c("010101", "010115", "010150", "010151"))
#> [1] "010150" "010150" "010150" "010151"

# Códigos de geoecu >= 0.4.0 (CONALI 2026): cabecera de Borbón y Sosote
homologar_parroquia(c("080950", "131251"))
#> [1] "080253" "131250"

# Agregar casos por parroquia urbana a la unidad del censo
casos <- data.frame(dpa_parroq = c("010101", "010102", "010151"),
                    casos = c(3, 5, 1))
casos$dpa_parroq <- homologar_parroquia(casos$dpa_parroq)
aggregate(casos ~ dpa_parroq, casos, sum)
#>   dpa_parroq casos
#> 1     010150     8
#> 2     010151     1
```
