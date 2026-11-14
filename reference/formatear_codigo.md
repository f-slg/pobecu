# Formatear códigos DPA

Devuelve códigos DPA como texto con el número correcto de dígitos,
recuperando los ceros a la izquierda que se pierden cuando un código se
guarda como número en Excel (por ejemplo, `701` en lugar de `"0701"`).

## Usage

``` r
formatear_codigo(x, nivel = c("parroquia", "canton", "provincia"))
```

## Arguments

- x:

  Vector de códigos (número o texto).

- nivel:

  `"provincia"` (2 dígitos), `"canton"` (4) o `"parroquia"` (6).

## Value

Vector de texto. Los valores que no son códigos válidos se devuelven
como `NA` con una advertencia: los que tienen letras o más dígitos que
el nivel, y los que al completarse empezarían por `"00"` (no existe esa
provincia; suele ser un código de otro nivel, como `"01"` usado como
cantón).

## Examples

``` r
formatear_codigo(c(1, 11, "7"), "provincia")
#> [1] "01" "11" "07"
formatear_codigo(c(701, 1101), "canton")
#> [1] "0701" "1101"
formatear_codigo(110150, "parroquia")
#> [1] "110150"
```
