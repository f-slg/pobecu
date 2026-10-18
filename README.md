# pobecu

<!-- badges: start -->
[![Licencia: MIT](https://img.shields.io/badge/licencia-MIT-blue.svg)](https://github.com/f-slg/pobecu/blob/main/LICENSE.md)
<!-- badges: end -->

**pobecu** da acceso en una línea de código a la **población del Ecuador por
provincia, cantón y parroquia**, con los **códigos de la División
Político-Administrativa (DPA)**, lista para calcular tasas, coberturas e
indicadores de salud, vigilancia epidemiológica o cualquier otro ámbito.

> **Nota:** pobecu es un paquete independiente, desarrollado a título
> personal. No es un producto oficial del INEC ni de ninguna otra institución.

- **Cifras oficiales del INEC** (*Estimaciones y Proyecciones de Población,
  Revisión 2024*): nacional 1950-2050, provincial 1990-2035 y cantonal
  2010-2035, por **sexo**, **edad** y **área urbana/rural**.
- **Estimación parroquial 2010-2035** (no oficial; el INEC no proyecta
  parroquias), construida para que **sume exactamente** la cifra oficial de
  cada cantón por sexo y edad.
- Grupos de edad a medida: quinquenales, edades simples, etapas de vida del
  INEC o cualquier corte (`c(0, 1, 5, 15, 65)`).
- Une la población con tus tablas por código DPA y calcula tasas, aunque los
  códigos vengan de Excel sin ceros a la izquierda.
- Funciona junto con [geoecu](https://github.com/f-slg/geoecu) (capas
  geográficas con los mismos códigos), pero no depende de él.

## Instalación

```r
# install.packages("remotes")
remotes::install_github("f-slg/pobecu")
```

Los grupos quinquenales vienen dentro del paquete. Las edades simples (2 MB)
se descargan la primera vez que se piden y se guardan en caché.

## Uso

```r
library(pobecu)

# Población de las provincias en 2025
poblacion("provincia", anio = 2025)

# Cantones de Loja por sexo, 2024 a 2026
poblacion("canton", anio = 2024:2026, provincia = "Loja", sexo = TRUE)

# Menores de 5 y adultos mayores, urbano/rural
poblacion("canton", anio = 2025, provincia = "Azuay", area = TRUE,
          edad = c(0, 5, 65))

# Etapas de vida del INEC (0-11, 12-17, 18-29, 30-64, 65+)
poblacion("provincia", anio = 2030, edad = "etapas")

# Parroquias de un cantón (estimación pobecu)
poblacion("parroquia", anio = 2030, canton = "Puyango", edad = "quinquenal")

# Serie nacional 1950-2050
poblacion("nacional")
```

### Tasas

```r
casos <- data.frame(dpa_canton = c(1101, 1102, 701), anio = 2024,
                    casos = c(120, 8, 40))
pob_tasa(casos, "casos")            # tasa por 100 000 habitantes
#>   dpa_canton anio casos poblacion     tasa
#> 1       1101 2024   120    257110 46.67263
#> 2       1102 2024     8     26544 30.13864
#> 3        701 2024    40    321196 12.45346
```

### Parroquias urbanas y geoecu

El Censo 2022 trata cada **cabecera cantonal** como una sola unidad (código
terminado en `50`). Si tus datos o tus mapas usan parroquias urbanas (por
ejemplo, las 15 de Cuenca en geoecu), conviértelas antes de unir:

```r
casos$dpa_parroq <- homologar_parroquia(casos$dpa_parroq)
casos <- aggregate(casos ~ dpa_parroq + anio, casos, sum)
pob_tasa(casos, "casos", nivel = "parroquia")
```

## Fuentes y método

| Nivel     | Periodo   | Sexo y edad  | Área urbana/rural | Tipo |
|-----------|-----------|--------------|-------------------|------|
| Nacional  | 1950-2050 | 0-100+       | 2010-2035         | Oficial INEC |
| Provincia | 1990-2035 | 0-100+       | 2010-2035         | Oficial INEC |
| Cantón    | 2010-2035 | 0-100+       | 2010-2035         | Oficial INEC |
| Parroquia | 2010-2035 | 0-4 ... 85+  | —                 | Estimación pobecu |

Las cifras son estimaciones hasta 2022 y proyecciones desde 2023, al 30 de
junio de cada año.

**Estimación parroquial.** Se reparte la proyección oficial de cada cantón
entre sus parroquias según su participación en los censos 2010 y 2022,
interpolada y extrapolada con una función logística (el mismo método que usa
el INEC para los cantones). La estructura por sexo y edad se ajusta por IPF
(*raking*) a partir del Censo 2022 y de la estructura oficial del cantón. Los
detalles están en `?pob_parroquias` y en los scripts de
[`data-raw/`](https://github.com/f-slg/pobecu/tree/main/data-raw).

**Actualización.** Cuando el INEC publique una nueva revisión de sus
proyecciones, los scripts de `data-raw/` regeneran todos los datos y se
publica una nueva versión. `pob_fuentes()` indica la revisión en uso.

- INEC, [Estimaciones y Proyecciones de Población](https://www.ecuadorencifras.gob.ec/proyecciones-poblacionales/).
- INEC, [VIII Censo de Población y VII de Vivienda 2022](https://www.censoecuador.gob.ec/resultados-censo/).
