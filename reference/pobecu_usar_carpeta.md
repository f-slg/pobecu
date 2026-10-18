# Usar datos desde una carpeta local

Indica a pobecu una carpeta que contiene `pobecu_edad_simple.rds`. Útil
para trabajar sin conexión o en servidores institucionales.

## Usage

``` r
pobecu_usar_carpeta(carpeta)
```

## Arguments

- carpeta:

  Ruta a la carpeta. Usa `NULL` para volver al comportamiento por
  defecto (caché y descarga).

## Value

La carpeta anterior, de forma invisible.

## Details

También puedes definir la variable de entorno `POBECU_CARPETA` (por
ejemplo, en tu `.Renviron`) para que la carpeta se use siempre.

## Examples

``` r
anterior <- pobecu_usar_carpeta(tempdir())
pobecu_datos_disponibles()
#> [1] TRUE
pobecu_usar_carpeta(anterior)
```
