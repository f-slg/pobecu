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

  Semilla local reproducible; se restaura el estado aleatorio.

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
#>                       nombre anio poblacion                       origen
#> 1810                    Loja 1900     26865                modelo_pobecu
#> 1811                    Loja 2022    217989 referencia_parroquial_pobecu
#> 1812                    Loja 2100    295253                modelo_pobecu
#> 1813                Chantaco 1900       327                modelo_pobecu
#> 1814                Chantaco 2022      1054 referencia_parroquial_pobecu
#> 1815                Chantaco 2100       570                modelo_pobecu
#> 1816           Chuquiribamba 1900       624                modelo_pobecu
#> 1817           Chuquiribamba 2022      2171 referencia_parroquial_pobecu
#> 1818           Chuquiribamba 2100      1222                modelo_pobecu
#> 1819                El Cisne 1900       299                modelo_pobecu
#> 1820                El Cisne 2022      1673 referencia_parroquial_pobecu
#> 1821                El Cisne 2100      1556                modelo_pobecu
#> 1822                  Gualel 1900       393                modelo_pobecu
#> 1823                  Gualel 2022      2127 referencia_parroquial_pobecu
#> 1824                  Gualel 2100      1965                modelo_pobecu
#> 1825                Jimbilla 1900       259                modelo_pobecu
#> 1826                Jimbilla 2022      1034 referencia_parroquial_pobecu
#> 1827                Jimbilla 2100       695                modelo_pobecu
#> 1828               Malacatos 1900       974                modelo_pobecu
#> 1829               Malacatos 2022      8810 referencia_parroquial_pobecu
#> 1830               Malacatos 2100     13295                modelo_pobecu
#> 1831               San Lucas 1900       887                modelo_pobecu
#> 1832               San Lucas 2022      4787 referencia_parroquial_pobecu
#> 1833               San Lucas 2100      4361                modelo_pobecu
#> 1834 San Pedro De Vilcabamba 1900       247                modelo_pobecu
#> 1835 San Pedro De Vilcabamba 2022      1332 referencia_parroquial_pobecu
#> 1836 San Pedro De Vilcabamba 2100      1214                modelo_pobecu
#> 1837                Santiago 1900       420                modelo_pobecu
#> 1838                Santiago 2022      1086 referencia_parroquial_pobecu
#> 1839                Santiago 2100       504                modelo_pobecu
#> 1840                  Taquil 1900       721                modelo_pobecu
#> 1841                  Taquil 2022      3802 referencia_parroquial_pobecu
#> 1842                  Taquil 2100      3368                modelo_pobecu
#> 1843              Vilcabamba 1900       736                modelo_pobecu
#> 1844              Vilcabamba 2022      5615 referencia_parroquial_pobecu
#> 1845              Vilcabamba 2100      7206                modelo_pobecu
#> 1846                 Yangana 1900       316                modelo_pobecu
#> 1847                 Yangana 2022      1449 referencia_parroquial_pobecu
#> 1848                 Yangana 2100      1107                modelo_pobecu
#> 1849                 Quinara 1900       224                modelo_pobecu
#> 1850                 Quinara 2022      1534 referencia_parroquial_pobecu
#> 1851                 Quinara 2100      1782                modelo_pobecu
#>      horizonte
#> 1810       110
#> 1811         0
#> 1812        65
#> 1813       110
#> 1814         0
#> 1815        65
#> 1816       110
#> 1817         0
#> 1818        65
#> 1819       110
#> 1820         0
#> 1821        65
#> 1822       110
#> 1823         0
#> 1824        65
#> 1825       110
#> 1826         0
#> 1827        65
#> 1828       110
#> 1829         0
#> 1830        65
#> 1831       110
#> 1832         0
#> 1833        65
#> 1834       110
#> 1835         0
#> 1836        65
#> 1837       110
#> 1838         0
#> 1839        65
#> 1840       110
#> 1841         0
#> 1842        65
#> 1843       110
#> 1844         0
#> 1845        65
#> 1846       110
#> 1847         0
#> 1848        65
#> 1849       110
#> 1850         0
#> 1851        65
# }
```
