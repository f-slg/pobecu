# ¿Están disponibles los datos por edad simple sin descargar?

Los grupos quinquenales vienen dentro del paquete; las edades simples (0
a 100 y más) se descargan la primera vez que se piden con
`poblacion(edad = "simple")` u otros cortes de edad que no son múltiplos
de 5. Esta función indica si ya están en la carpeta local o en la caché.

## Usage

``` r
pobecu_datos_disponibles()
```

## Value

`TRUE` o `FALSE`.

## Examples

``` r
pobecu_datos_disponibles()
#> [1] TRUE
```
