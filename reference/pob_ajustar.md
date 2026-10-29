# Ajustar un modelo territorial de población para 1900-2100

Ajusta tendencias locales lineales mediante máxima verosimilitud y
filtro de Kalman: logaritmo del total nacional y coordenadas log-ratio
centradas de las participaciones de cada territorio en su padre. La
extrapolación amortigua la pendiente y la distribución descendente
conserva los totales.

## Usage

``` r
pob_ajustar(
  entrenamiento = NULL,
  ventana = 20,
  phi_total = 0.98,
  phi_partes = 0.95
)
```

## Arguments

- entrenamiento:

  Años de las tablas publicados que se pueden utilizar. NULL usa todos.
  Deben quedar al menos ocho años consecutivos por nivel.

- ventana:

  Máximo de años utilizados en cada extremo, al menos ocho.

- phi_total:

  Amortiguación anual de la pendiente nacional, en (0,1\].

- phi_partes:

  Amortiguación de las participaciones, en (0,1\].

## Value

Objeto `pob_modelo` con datos de referencia, modelos en ambos sentidos
temporales, parámetros y tabla `diagnosticos` de cada ajuste.

## Details

Se incluyen proyecciones publicadas en el entrenamiento por defecto. Se
condiciona a esas trayectorias; no se ajustan fecundidad, mortalidad ni
migración por cohortes. Las unidades son las de referencia del Censo
2022, incluso para años en los que no existían administrativamente. La
retrospectiva ajusta el modelo a la serie invertida: no es un suavizador
histórico ni evidencia censal del siglo XX. Consulte la metodología del
README antes de interpretar horizontes lejanos.

## Examples

``` r
# \donttest{
modelo <- pob_ajustar()
#> Nota: las cifras parroquiales son una estimación de pobecu a partir de las proyecciones cantonales del INEC; no son cifras oficiales. Ver ?pob_parroquias. (Este aviso se muestra una vez por sesión.)
#> Warning: 12 ajustes usan respaldo lineal; consulte $diagnosticos.
head(modelo$diagnosticos)
#>   codigo padre     nivel sentido entrenamiento_desde entrenamiento_hasta  n
#> 1     EC  <NA>  nacional   retro                1950                1969 20
#> 2     EC  <NA>  nacional     pro                2031                2050 20
#> 3     01    EC provincia   retro                1990                2009 20
#> 4     01    EC provincia     pro                2016                2035 20
#> 5     02    EC provincia   retro                1990                2009 20
#> 6     02    EC provincia     pro                2016                2035 20
#>                           metodo convergencia    pendiente var_nivel
#> 1       StructTS_tendencia_local            0 -0.025541233         0
#> 2       StructTS_tendencia_local            0  0.003842644         0
#> 3       StructTS_tendencia_local            0  0.007417301         0
#> 4       StructTS_tendencia_local            0 -0.002033895         0
#> 5 StructTS_sin_ruido_observacion            0  0.012997541         0
#> 6       StructTS_tendencia_local            0 -0.002758758         0
#>   var_pendiente var_observacion
#> 1  4.349116e-05               0
#> 2  2.954892e-06               0
#> 3  1.044394e-06               0
#> 4  2.082802e-06               0
#> 5  7.349575e-06               0
#> 6  1.271848e-05               0
#>                                                                                                advertencia
#> 1                                                                                                         
#> 2                                                                                                         
#> 3                                                                                                         
#> 4                                                                                                         
#> 5 possible convergence problem: 'optim' gave code = 52 and message ‘ERROR: ABNORMAL_TERMINATION_IN_LNSRCH’
#> 6                                                                                                         
# }
```
