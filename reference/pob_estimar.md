# Reconstruir y proyectar población territorial entre 1900 y 2100

Extiende las trayectorias con un modelo estructural y composicional
jerárquico. Conserva exactamente las referencias utilizadas por el
modelo.

## Usage

``` r
pob_estimar(
  nivel = c("provincia", "canton", "parroquia", "nacional", "todos"),
  anio = 1900:2100,
  modelo = NULL,
  provincia = NULL,
  canton = NULL,
  simulaciones = 500,
  semilla = 2026,
  nivel_intervalo = 0.95
)
```

## Arguments

- nivel:

  Nivel territorial o `"todos"` para la jerarquía completa.

- anio:

  Años enteros entre 1900 y 2100; por defecto todo el periodo.

- modelo:

  Resultado de
  [`pob_ajustar()`](https://f-slg.github.io/pobecu/reference/pob_ajustar.md).
  NULL ajusta un modelo nuevo.

- provincia:

  Filtro provincial por nombre o código.

- canton:

  Filtro cantonal por nombre o código, solo cantones/parroquias.

- simulaciones:

  Número de trayectorias Monte Carlo, de 100 a 10000.

- semilla:

  Semilla local reproducible; se restaura el estado aleatorio. Cada
  grupo territorial usa una semilla propia derivada de esta, por lo que
  filtrar territorios o años no cambia sus bandas.

- nivel_intervalo:

  Cobertura nominal de bandas condicionales (0,1).

## Value

Tabla con códigos, nombres, población entera, origen, dirección,
horizonte, referencia temporal y bandas marginales. El atributo
`metodologia` registra parámetros y supuestos. Los cuantiles marginales
no se suman. La trayectoria central sí suma exactamente a sus padres.

## Details

Las bandas simulan innovaciones gaussianas con varianzas estimadas,
condicionadas a los estados finales y parámetros ajustados. No incluyen
incertidumbre de parámetros, censos, límites ni modelos fuente. En años
de referencia las bandas son NA. Los resultados extrapolados no son
cifras oficiales. No se modifican las tablas consultadas por
[`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md).
La amortiguación es una hipótesis de escenario aplicada al extrapolar,
no un parámetro estimado por máxima verosimilitud. No hay desagregación
por sexo, edad o residencia en este modelo de totales territoriales.

## Examples

``` r
# \donttest{
m <- pob_ajustar()
#> Warning: 12 ajustes usan respaldo lineal; consulte $diagnosticos.
p <- pob_estimar("parroquia", c(1900, 2022, 2100), m, canton = "Loja")
p[c("nombre", "anio", "poblacion", "origen", "horizonte")]
#>                     nombre anio poblacion                       origen
#> 1                     Loja 1900     26865                modelo_pobecu
#> 2                     Loja 2022    217989 referencia_parroquial_pobecu
#> 3                     Loja 2100    295253                modelo_pobecu
#> 4                 Chantaco 1900       327                modelo_pobecu
#> 5                 Chantaco 2022      1054 referencia_parroquial_pobecu
#> 6                 Chantaco 2100       570                modelo_pobecu
#> 7            Chuquiribamba 1900       624                modelo_pobecu
#> 8            Chuquiribamba 2022      2171 referencia_parroquial_pobecu
#> 9            Chuquiribamba 2100      1222                modelo_pobecu
#> 10                El Cisne 1900       299                modelo_pobecu
#> 11                El Cisne 2022      1673 referencia_parroquial_pobecu
#> 12                El Cisne 2100      1556                modelo_pobecu
#> 13                  Gualel 1900       393                modelo_pobecu
#> 14                  Gualel 2022      2127 referencia_parroquial_pobecu
#> 15                  Gualel 2100      1965                modelo_pobecu
#> 16                Jimbilla 1900       259                modelo_pobecu
#> 17                Jimbilla 2022      1034 referencia_parroquial_pobecu
#> 18                Jimbilla 2100       695                modelo_pobecu
#> 19               Malacatos 1900       974                modelo_pobecu
#> 20               Malacatos 2022      8810 referencia_parroquial_pobecu
#> 21               Malacatos 2100     13295                modelo_pobecu
#> 22               San Lucas 1900       887                modelo_pobecu
#> 23               San Lucas 2022      4787 referencia_parroquial_pobecu
#> 24               San Lucas 2100      4361                modelo_pobecu
#> 25 San Pedro De Vilcabamba 1900       247                modelo_pobecu
#> 26 San Pedro De Vilcabamba 2022      1332 referencia_parroquial_pobecu
#> 27 San Pedro De Vilcabamba 2100      1214                modelo_pobecu
#> 28                Santiago 1900       420                modelo_pobecu
#> 29                Santiago 2022      1086 referencia_parroquial_pobecu
#> 30                Santiago 2100       504                modelo_pobecu
#> 31                  Taquil 1900       721                modelo_pobecu
#> 32                  Taquil 2022      3802 referencia_parroquial_pobecu
#> 33                  Taquil 2100      3368                modelo_pobecu
#> 34              Vilcabamba 1900       736                modelo_pobecu
#> 35              Vilcabamba 2022      5615 referencia_parroquial_pobecu
#> 36              Vilcabamba 2100      7206                modelo_pobecu
#> 37                 Yangana 1900       316                modelo_pobecu
#> 38                 Yangana 2022      1449 referencia_parroquial_pobecu
#> 39                 Yangana 2100      1107                modelo_pobecu
#> 40                 Quinara 1900       224                modelo_pobecu
#> 41                 Quinara 2022      1534 referencia_parroquial_pobecu
#> 42                 Quinara 2100      1782                modelo_pobecu
#>    horizonte
#> 1        110
#> 2          0
#> 3         65
#> 4        110
#> 5          0
#> 6         65
#> 7        110
#> 8          0
#> 9         65
#> 10       110
#> 11         0
#> 12        65
#> 13       110
#> 14         0
#> 15        65
#> 16       110
#> 17         0
#> 18        65
#> 19       110
#> 20         0
#> 21        65
#> 22       110
#> 23         0
#> 24        65
#> 25       110
#> 26         0
#> 27        65
#> 28       110
#> 29         0
#> 30        65
#> 31       110
#> 32         0
#> 33        65
#> 34       110
#> 35         0
#> 36        65
#> 37       110
#> 38         0
#> 39        65
#> 40       110
#> 41         0
#> 42        65
# }
```
