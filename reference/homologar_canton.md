# Homologar códigos de cantón a las unidades del Censo 2022

Las proyecciones cantonales del INEC usan los 221 cantones del Censo
2022. La Organización Territorial del Estado del CONALI (2026), que usa
geoecu desde la versión 0.4.0, tiene 223: incluye Borbón (`0809`),
creado a partir de Eloy Alfaro (`0802`), y Sevilla Don Bosco (`1413`),
creado a partir de Morona (`1401`). Esta función convierte esos códigos
al del cantón censal que los contiene, para agregar los datos y unirlos
con la población. Los demás códigos se devuelven sin cambios.

## Usage

``` r
homologar_canton(codigo)
```

## Arguments

- codigo:

  Vector de códigos de cantón (número o texto).

## Value

Vector de texto con códigos de 4 dígitos.

## See also

[`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md)
para los códigos de parroquia.

## Examples

``` r
homologar_canton(c("0809", "1413", 1101))
#> [1] "0802" "1401" "1101"

# Agregar casos de Borbón y Eloy Alfaro antes de calcular la tasa
casos <- data.frame(dpa_canton = c("0802", "0809"), anio = 2025,
                    casos = c(7, 5))
casos$dpa_canton <- homologar_canton(casos$dpa_canton)
casos <- aggregate(casos ~ dpa_canton + anio, casos, sum)
pob_tasa(casos, "casos")
#>   dpa_canton anio casos poblacion     tasa
#> 1       0802 2025    12     52040 23.05919
```
