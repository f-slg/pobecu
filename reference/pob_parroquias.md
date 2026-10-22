# Población parroquial estimada, 2010-2035

Estimación de la población de las 1042 parroquias del Censo 2022 (221
cabeceras cantonales y 821 parroquias rurales) por año, sexo al nacer y
grupos quinquenales de edad. **No es una cifra oficial**: el INEC no
publica proyecciones parroquiales. pobecu la construye a partir de la
proyección oficial de cada cantón, de modo que la suma de las parroquias
de un cantón es exactamente igual a la cifra oficial del INEC para ese
cantón, año, sexo y grupo de edad.

## Usage

``` r
pob_parroquias
```

## Format

`data.frame` con las columnas `dpa_parroq` (factor), `anio`, `area`
(siempre `"total"`), `sexo`, `grupo_edad` (`"0-4"`, ..., `"80-84"`,
`"85+"`) y `poblacion`.

## Source

Elaboración propia a partir de INEC, *Estimaciones y Proyecciones de
Población, Revisión 2024*, y del VIII Censo de Población y VII de
Vivienda 2022 (tabulados de estructura poblacional),
<https://www.censoecuador.gob.ec/resultados-censo/>.

## Details

**Unidades.** Son las parroquias del Censo 2022. Cada cabecera cantonal
(código terminado en `50`) es una sola unidad que incluye a todas las
parroquias urbanas del cantón. Para unir datos que usan códigos de
parroquias urbanas o de la Organización Territorial del Estado del
CONALI (2026), como las capas de geoecu 0.4.0 y posteriores,
conviértelos con
[`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md).

**Método.**

1.  *Participación en el cantón.* Se calcula la proporción de la
    población del cantón que vive en cada parroquia en los censos 2010 y
    2022, y se interpola y extrapola con una función logística (lineal
    en la escala logit), el mismo método que usa el INEC para estimar
    los cantones a partir de su provincia. Las proporciones se reescalan
    para que sumen 1. En los cantones con parroquias creadas después de
    2010 se mantiene constante la proporción del Censo 2022 (ver
    `metodo` en
    [dpa_pob](https://f-slg.github.io/pobecu/reference/dpa_pob.md)).

2.  *Total parroquial* = proporción x población oficial del cantón.

3.  *Sexo y edad.* Ajuste proporcional iterativo (IPF o *raking*): se
    parte de la estructura por sexo y edad de cada parroquia en el Censo
    2022 y se ajusta a dos márgenes, el total parroquial (paso 2) y la
    estructura oficial del cantón por sexo y edad.

4.  *Redondeo* a enteros por el método del mayor residuo, conservando
    exactamente los totales cantonales.

**Precauciones.** La extrapolación prolonga la tendencia observada entre
los dos censos: parroquias que crecieron o decrecieron mucho entre 2010
y 2022 siguen haciéndolo hasta 2035. Las cifras de 2022 no coinciden con
el conteo censal porque la proyección del INEC corrige la omisión censal
y se refiere al 30 de junio. El grupo de edad más alto es `"85+"`.

## Examples

``` r
head(pob_parroquias)
#>   dpa_parroq anio  area   sexo grupo_edad poblacion
#> 1     010150 2010 total hombre        0-4     15663
#> 2     010150 2010 total hombre        5-9     15104
#> 3     010150 2010 total hombre      10-14     14998
#> 4     010150 2010 total hombre      15-19     16459
#> 5     010150 2010 total hombre      20-24     17243
#> 6     010150 2010 total hombre      25-29     16196
```
