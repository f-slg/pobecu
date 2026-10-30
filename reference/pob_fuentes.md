# Fuentes y versión de los datos

Muestra de dónde provienen los datos de pobecu, qué periodo cubre cada
nivel y qué cifras son oficiales del INEC y cuáles son estimaciones del
paquete.

## Usage

``` r
pob_fuentes()
```

## Value

Un `data.frame` de clase `pob_fuentes` con una fila por nivel. Al
imprimirlo se muestran también la versión de los datos y las fuentes.

## Examples

``` r
pob_fuentes()
#> pobecu 0.2.0.9000 · datos datos-v0.1.0
#> Estimaciones hasta 2022 y proyecciones desde 2023, al 30 de junio de cada año.
#> 
#>      nivel   periodo      area        edad              tipo
#>   nacional 1950-2050 2010-2035      0-100+           oficial
#>  provincia 1990-2035 2010-2035      0-100+           oficial
#>     canton 2010-2035 2010-2035      0-100+           oficial
#>  parroquia 2010-2035        no 0-4 ... 85+ estimación pobecu
#> 
#> Fuentes:
#> * INEC, Estimaciones y Proyecciones de Población, Revisión 2024 (actualización con áreas, 2025).
#>   https://www.ecuadorencifras.gob.ec/proyecciones-poblacionales/
#> * INEC, VIII Censo de Población y VII de Vivienda 2022.
#>   https://www.censoecuador.gob.ec/resultados-censo/
#> Las cifras parroquiales no son oficiales: ver ?pob_parroquias.
```
