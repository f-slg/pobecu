# Población por provincia, cantón o parroquia

Consulta la población de un nivel territorial y uno o varios años, con
la desagregación que necesites (sexo, área urbana/rural y edad). Es la
forma más sencilla de obtener denominadores para tasas, coberturas o
indicadores.

## Usage

``` r
poblacion(
  nivel = c("canton", "provincia", "parroquia", "nacional"),
  anio = NULL,
  provincia = NULL,
  canton = NULL,
  sexo = FALSE,
  area = FALSE,
  edad = NULL
)
```

## Arguments

- nivel:

  `"canton"` (por defecto), `"provincia"`, `"parroquia"` o `"nacional"`.

- anio:

  Años a consultar. `NULL` (por defecto) devuelve todos los disponibles:
  1950-2050 (nacional), 1990-2035 (provincial) y 2010-2035 (cantonal y
  parroquial). Las cifras se refieren al 30 de junio de cada año.

- provincia:

  Provincias a incluir, por nombre (sin importar tildes ni mayúsculas) o
  código: `"Loja"`, `"11"` o `11`. `NULL` incluye todo el país.

- canton:

  Cantones a incluir (niveles `"canton"` y `"parroquia"`), por nombre o
  código. Si un nombre se repite en varias provincias (por ejemplo,
  Bolívar u Olmedo), usa el código o indica también `provincia`.

- sexo:

  Si es `TRUE`, desagrega por sexo al nacer (`"hombre"`, `"mujer"`).

- area:

  Si es `TRUE`, desagrega por área de residencia (`"urbana"`,
  `"rural"`). Solo para los niveles nacional, provincial y cantonal, y
  para los años 2010-2035.

- edad:

  Desagregación por edad:

  - `NULL` (por defecto): sin desagregar.

  - `"quinquenal"`: grupos de 5 años (`"0-4"`, ..., `"100+"`; en el
    nivel parroquial el último grupo es `"85+"`).

  - `"simple"`: años cumplidos, de 0 a 100 (100 = 100 y más).

  - `"etapas"`: etapas de vida del INEC (0-11, 12-17, 18-29, 30-64,
    65+).

  - Un vector numérico con las edades de inicio de cada grupo, por
    ejemplo `c(0, 1, 5, 15, 65)` para 0, 1-4, 5-14, 15-64 y 65+.

  Los grupos quinquenales (y los cortes múltiplos de 5) vienen dentro
  del paquete. Las edades simples, las etapas y los demás cortes usan
  datos que se descargan la primera vez (ver
  [`pobecu_datos_disponibles()`](https://f-slg.github.io/pobecu/reference/pobecu_datos_disponibles.md))
  y no están disponibles para parroquias.

## Value

Un `data.frame` con los códigos y nombres del nivel (`dpa_provin`,
`provincia`, `dpa_canton`, `canton`, `dpa_parroq`, `parroquia`, según
corresponda), `anio`, las columnas de desagregación pedidas (`sexo`,
`area`, `edad`) y `poblacion`.

## Details

Las cifras nacionales, provinciales y cantonales son las estimaciones
(hasta 2022) y proyecciones (desde 2023) oficiales del INEC, Revisión
2024. Las parroquiales son una estimación de pobecu que reparte la
proyección oficial de cada cantón entre sus parroquias (ver
[pob_parroquias](https://f-slg.github.io/pobecu/reference/pob_parroquias.md));
no son cifras oficiales.

## See also

[`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md) y
[`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md)
para unir la población con tus datos.

## Examples

``` r
# Población total de las provincias en 2025
poblacion("provincia", anio = 2025)
#>    dpa_provin                      provincia anio poblacion
#> 1          01                          Azuay 2025    834958
#> 2          02                        Bolívar 2025    204351
#> 3          03                          Cañar 2025    237460
#> 4          04                         Carchi 2025    177020
#> 5          05                       Cotopaxi 2025    493382
#> 6          06                     Chimborazo 2025    487355
#> 7          07                         El Oro 2025    753036
#> 8          08                     Esmeraldas 2025    605377
#> 9          09                         Guayas 2025   4788157
#> 10         10                       Imbabura 2025    498140
#> 11         11                           Loja 2025    498457
#> 12         12                       Los Ríos 2025    978487
#> 13         13                         Manabí 2025   1715057
#> 14         14                Morona Santiago 2025    209875
#> 15         15                           Napo 2025    140498
#> 16         16                        Pastaza 2025    120932
#> 17         17                      Pichincha 2025   3294478
#> 18         18                     Tungurahua 2025    581842
#> 19         19               Zamora Chinchipe 2025    118936
#> 20         20                      Galápagos 2025     30265
#> 21         21                      Sucumbíos 2025    204121
#> 22         22                       Orellana 2025    196020
#> 23         23 Santo Domingo De Los Tsáchilas 2025    528509
#> 24         24                    Santa Elena 2025    406947

# Cantones de Loja por sexo, 2024 a 2026
poblacion("canton", anio = 2024:2026, provincia = "Loja", sexo = TRUE)
#>    dpa_canton       canton dpa_provin provincia anio   sexo poblacion
#> 1        1101         Loja         11      Loja 2024 hombre    123655
#> 2        1101         Loja         11      Loja 2024  mujer    133455
#> 3        1101         Loja         11      Loja 2025 hombre    124296
#> 4        1101         Loja         11      Loja 2025  mujer    134218
#> 5        1101         Loja         11      Loja 2026 hombre    125024
#> 6        1101         Loja         11      Loja 2026  mujer    134953
#> 7        1102       Calvas         11      Loja 2024 hombre     13110
#> 8        1102       Calvas         11      Loja 2024  mujer     13434
#> 9        1102       Calvas         11      Loja 2025 hombre     13018
#> 10       1102       Calvas         11      Loja 2025  mujer     13356
#> 11       1102       Calvas         11      Loja 2026 hombre     12966
#> 12       1102       Calvas         11      Loja 2026  mujer     13276
#> 13       1103     Catamayo         11      Loja 2024 hombre     17637
#> 14       1103     Catamayo         11      Loja 2024  mujer     18555
#> 15       1103     Catamayo         11      Loja 2025 hombre     17748
#> 16       1103     Catamayo         11      Loja 2025  mujer     18680
#> 17       1103     Catamayo         11      Loja 2026 hombre     17867
#> 18       1103     Catamayo         11      Loja 2026  mujer     18802
#> 19       1104       Celica         11      Loja 2024 hombre      7531
#> 20       1104       Celica         11      Loja 2024  mujer      7190
#> 21       1104       Celica         11      Loja 2025 hombre      7508
#> 22       1104       Celica         11      Loja 2025  mujer      7168
#> 23       1104       Celica         11      Loja 2026 hombre      7492
#> 24       1104       Celica         11      Loja 2026  mujer      7144
#> 25       1105 Chaguarpamba         11      Loja 2024 hombre      3524
#> 26       1105 Chaguarpamba         11      Loja 2024  mujer      3384
#> 27       1105 Chaguarpamba         11      Loja 2025 hombre      3504
#> 28       1105 Chaguarpamba         11      Loja 2025  mujer      3371
#> 29       1105 Chaguarpamba         11      Loja 2026 hombre      3492
#> 30       1105 Chaguarpamba         11      Loja 2026  mujer      3357
#> 31       1106    Espíndola         11      Loja 2024 hombre      7323
#> 32       1106    Espíndola         11      Loja 2024  mujer      7045
#> 33       1106    Espíndola         11      Loja 2025 hombre      7278
#> 34       1106    Espíndola         11      Loja 2025  mujer      6999
#> 35       1106    Espíndola         11      Loja 2026 hombre      7246
#> 36       1106    Espíndola         11      Loja 2026  mujer      6961
#> 37       1107    Gonzanamá         11      Loja 2024 hombre      6220
#> 38       1107    Gonzanamá         11      Loja 2024  mujer      6216
#> 39       1107    Gonzanamá         11      Loja 2025 hombre      6208
#> 40       1107    Gonzanamá         11      Loja 2025  mujer      6213
#> 41       1107    Gonzanamá         11      Loja 2026 hombre      6204
#> 42       1107    Gonzanamá         11      Loja 2026  mujer      6213
#> 43       1108       Macará         11      Loja 2024 hombre      9236
#> 44       1108       Macará         11      Loja 2024  mujer      9382
#> 45       1108       Macará         11      Loja 2025 hombre      9193
#> 46       1108       Macará         11      Loja 2025  mujer      9327
#> 47       1108       Macará         11      Loja 2026 hombre      9154
#> 48       1108       Macará         11      Loja 2026  mujer      9286
#> 49       1109       Paltas         11      Loja 2024 hombre     11508
#> 50       1109       Paltas         11      Loja 2024  mujer     11559
#> 51       1109       Paltas         11      Loja 2025 hombre     11432
#> 52       1109       Paltas         11      Loja 2025  mujer     11497
#> 53       1109       Paltas         11      Loja 2026 hombre     11381
#> 54       1109       Paltas         11      Loja 2026  mujer     11442
#> 55       1110      Puyango         11      Loja 2024 hombre      8254
#> 56       1110      Puyango         11      Loja 2024  mujer      8318
#> 57       1110      Puyango         11      Loja 2025 hombre      8248
#> 58       1110      Puyango         11      Loja 2025  mujer      8311
#> 59       1110      Puyango         11      Loja 2026 hombre      8242
#> 60       1110      Puyango         11      Loja 2026  mujer      8313
#> 61       1111     Saraguro         11      Loja 2024 hombre     14032
#> 62       1111     Saraguro         11      Loja 2024  mujer     15712
#> 63       1111     Saraguro         11      Loja 2025 hombre     13953
#> 64       1111     Saraguro         11      Loja 2025  mujer     15635
#> 65       1111     Saraguro         11      Loja 2026 hombre     13891
#> 66       1111     Saraguro         11      Loja 2026  mujer     15571
#> 67       1112    Sozoranga         11      Loja 2024 hombre      3525
#> 68       1112    Sozoranga         11      Loja 2024  mujer      3432
#> 69       1112    Sozoranga         11      Loja 2025 hombre      3501
#> 70       1112    Sozoranga         11      Loja 2025  mujer      3416
#> 71       1112    Sozoranga         11      Loja 2026 hombre      3486
#> 72       1112    Sozoranga         11      Loja 2026  mujer      3399
#> 73       1113    Zapotillo         11      Loja 2024 hombre      7846
#> 74       1113    Zapotillo         11      Loja 2024  mujer      7351
#> 75       1113    Zapotillo         11      Loja 2025 hombre      7909
#> 76       1113    Zapotillo         11      Loja 2025  mujer      7424
#> 77       1113    Zapotillo         11      Loja 2026 hombre      7981
#> 78       1113    Zapotillo         11      Loja 2026  mujer      7485
#> 79       1114       Pindal         11      Loja 2024 hombre      5649
#> 80       1114       Pindal         11      Loja 2024  mujer      5238
#> 81       1114       Pindal         11      Loja 2025 hombre      5698
#> 82       1114       Pindal         11      Loja 2025  mujer      5289
#> 83       1114       Pindal         11      Loja 2026 hombre      5753
#> 84       1114       Pindal         11      Loja 2026  mujer      5332
#> 85       1115     Quilanga         11      Loja 2024 hombre      1968
#> 86       1115     Quilanga         11      Loja 2024  mujer      1984
#> 87       1115     Quilanga         11      Loja 2025 hombre      1953
#> 88       1115     Quilanga         11      Loja 2025  mujer      1972
#> 89       1115     Quilanga         11      Loja 2026 hombre      1944
#> 90       1115     Quilanga         11      Loja 2026  mujer      1960
#> 91       1116       Olmedo         11      Loja 2024 hombre      2095
#> 92       1116       Olmedo         11      Loja 2024  mujer      2070
#> 93       1116       Olmedo         11      Loja 2025 hombre      2080
#> 94       1116       Olmedo         11      Loja 2025  mujer      2054
#> 95       1116       Olmedo         11      Loja 2026 hombre      2069
#> 96       1116       Olmedo         11      Loja 2026  mujer      2043

# Menores de 5 años y de 65 y más, por cantón urbano/rural
poblacion("canton", anio = 2025, provincia = "Azuay", area = TRUE,
          edad = c(0, 5, 65))
#>    dpa_canton                canton dpa_provin provincia anio   area edad
#> 1        0101                Cuenca         01     Azuay 2025 urbana  0-4
#> 2        0101                Cuenca         01     Azuay 2025 urbana 5-64
#> 3        0101                Cuenca         01     Azuay 2025 urbana  65+
#> 4        0101                Cuenca         01     Azuay 2025  rural  0-4
#> 5        0101                Cuenca         01     Azuay 2025  rural 5-64
#> 6        0101                Cuenca         01     Azuay 2025  rural  65+
#> 7        0102                 Girón         01     Azuay 2025 urbana  0-4
#> 8        0102                 Girón         01     Azuay 2025 urbana 5-64
#> 9        0102                 Girón         01     Azuay 2025 urbana  65+
#> 10       0102                 Girón         01     Azuay 2025  rural  0-4
#> 11       0102                 Girón         01     Azuay 2025  rural 5-64
#> 12       0102                 Girón         01     Azuay 2025  rural  65+
#> 13       0103              Gualaceo         01     Azuay 2025 urbana  0-4
#> 14       0103              Gualaceo         01     Azuay 2025 urbana 5-64
#> 15       0103              Gualaceo         01     Azuay 2025 urbana  65+
#> 16       0103              Gualaceo         01     Azuay 2025  rural  0-4
#> 17       0103              Gualaceo         01     Azuay 2025  rural 5-64
#> 18       0103              Gualaceo         01     Azuay 2025  rural  65+
#> 19       0104                 Nabón         01     Azuay 2025 urbana  0-4
#> 20       0104                 Nabón         01     Azuay 2025 urbana 5-64
#> 21       0104                 Nabón         01     Azuay 2025 urbana  65+
#> 22       0104                 Nabón         01     Azuay 2025  rural  0-4
#> 23       0104                 Nabón         01     Azuay 2025  rural 5-64
#> 24       0104                 Nabón         01     Azuay 2025  rural  65+
#> 25       0105                 Paute         01     Azuay 2025 urbana  0-4
#> 26       0105                 Paute         01     Azuay 2025 urbana 5-64
#> 27       0105                 Paute         01     Azuay 2025 urbana  65+
#> 28       0105                 Paute         01     Azuay 2025  rural  0-4
#> 29       0105                 Paute         01     Azuay 2025  rural 5-64
#> 30       0105                 Paute         01     Azuay 2025  rural  65+
#> 31       0106                Pucará         01     Azuay 2025 urbana  0-4
#> 32       0106                Pucará         01     Azuay 2025 urbana 5-64
#> 33       0106                Pucará         01     Azuay 2025 urbana  65+
#> 34       0106                Pucará         01     Azuay 2025  rural  0-4
#> 35       0106                Pucará         01     Azuay 2025  rural 5-64
#> 36       0106                Pucará         01     Azuay 2025  rural  65+
#> 37       0107          San Fernando         01     Azuay 2025 urbana  0-4
#> 38       0107          San Fernando         01     Azuay 2025 urbana 5-64
#> 39       0107          San Fernando         01     Azuay 2025 urbana  65+
#> 40       0107          San Fernando         01     Azuay 2025  rural  0-4
#> 41       0107          San Fernando         01     Azuay 2025  rural 5-64
#> 42       0107          San Fernando         01     Azuay 2025  rural  65+
#> 43       0108          Santa Isabel         01     Azuay 2025 urbana  0-4
#> 44       0108          Santa Isabel         01     Azuay 2025 urbana 5-64
#> 45       0108          Santa Isabel         01     Azuay 2025 urbana  65+
#> 46       0108          Santa Isabel         01     Azuay 2025  rural  0-4
#> 47       0108          Santa Isabel         01     Azuay 2025  rural 5-64
#> 48       0108          Santa Isabel         01     Azuay 2025  rural  65+
#> 49       0109                Sígsig         01     Azuay 2025 urbana  0-4
#> 50       0109                Sígsig         01     Azuay 2025 urbana 5-64
#> 51       0109                Sígsig         01     Azuay 2025 urbana  65+
#> 52       0109                Sígsig         01     Azuay 2025  rural  0-4
#> 53       0109                Sígsig         01     Azuay 2025  rural 5-64
#> 54       0109                Sígsig         01     Azuay 2025  rural  65+
#> 55       0110                   Oña         01     Azuay 2025 urbana  0-4
#> 56       0110                   Oña         01     Azuay 2025 urbana 5-64
#> 57       0110                   Oña         01     Azuay 2025 urbana  65+
#> 58       0110                   Oña         01     Azuay 2025  rural  0-4
#> 59       0110                   Oña         01     Azuay 2025  rural 5-64
#> 60       0110                   Oña         01     Azuay 2025  rural  65+
#> 61       0111             Chordeleg         01     Azuay 2025 urbana  0-4
#> 62       0111             Chordeleg         01     Azuay 2025 urbana 5-64
#> 63       0111             Chordeleg         01     Azuay 2025 urbana  65+
#> 64       0111             Chordeleg         01     Azuay 2025  rural  0-4
#> 65       0111             Chordeleg         01     Azuay 2025  rural 5-64
#> 66       0111             Chordeleg         01     Azuay 2025  rural  65+
#> 67       0112                El Pan         01     Azuay 2025 urbana  0-4
#> 68       0112                El Pan         01     Azuay 2025 urbana 5-64
#> 69       0112                El Pan         01     Azuay 2025 urbana  65+
#> 70       0112                El Pan         01     Azuay 2025  rural  0-4
#> 71       0112                El Pan         01     Azuay 2025  rural 5-64
#> 72       0112                El Pan         01     Azuay 2025  rural  65+
#> 73       0113        Sevilla De Oro         01     Azuay 2025 urbana  0-4
#> 74       0113        Sevilla De Oro         01     Azuay 2025 urbana 5-64
#> 75       0113        Sevilla De Oro         01     Azuay 2025 urbana  65+
#> 76       0113        Sevilla De Oro         01     Azuay 2025  rural  0-4
#> 77       0113        Sevilla De Oro         01     Azuay 2025  rural 5-64
#> 78       0113        Sevilla De Oro         01     Azuay 2025  rural  65+
#> 79       0114            Guachapala         01     Azuay 2025 urbana  0-4
#> 80       0114            Guachapala         01     Azuay 2025 urbana 5-64
#> 81       0114            Guachapala         01     Azuay 2025 urbana  65+
#> 82       0114            Guachapala         01     Azuay 2025  rural  0-4
#> 83       0114            Guachapala         01     Azuay 2025  rural 5-64
#> 84       0114            Guachapala         01     Azuay 2025  rural  65+
#> 85       0115 Camilo Ponce Enríquez         01     Azuay 2025 urbana  0-4
#> 86       0115 Camilo Ponce Enríquez         01     Azuay 2025 urbana 5-64
#> 87       0115 Camilo Ponce Enríquez         01     Azuay 2025 urbana  65+
#> 88       0115 Camilo Ponce Enríquez         01     Azuay 2025  rural  0-4
#> 89       0115 Camilo Ponce Enríquez         01     Azuay 2025  rural 5-64
#> 90       0115 Camilo Ponce Enríquez         01     Azuay 2025  rural  65+
#>    poblacion
#> 1      24508
#> 2     317271
#> 3      34874
#> 4      20752
#> 5     206303
#> 6      20345
#> 7        366
#> 8       3647
#> 9        477
#> 10       627
#> 11      6135
#> 12      1171
#> 13      1240
#> 14     11719
#> 15      1369
#> 16      2943
#> 17     23703
#> 18      3452
#> 19       103
#> 20      1028
#> 21       169
#> 22      1136
#> 23     10476
#> 24      1956
#> 25       736
#> 26      7667
#> 27       719
#> 28      1553
#> 29     14376
#> 30      2298
#> 31        75
#> 32       677
#> 33       106
#> 34       843
#> 35      7053
#> 36       996
#> 37       116
#> 38      1084
#> 39       207
#> 40       188
#> 41      1780
#> 42       351
#> 43       571
#> 44      5219
#> 45       509
#> 46      1317
#> 47     11376
#> 48      1793
#> 49       334
#> 50      3459
#> 51       404
#> 52      2122
#> 53     16824
#> 54      2613
#> 55        93
#> 56       837
#> 57        99
#> 58       203
#> 59      1876
#> 60       374
#> 61       363
#> 62      3800
#> 63       444
#> 64       796
#> 65      6082
#> 66       874
#> 67        25
#> 68       422
#> 69        59
#> 70       149
#> 71      1652
#> 72       448
#> 73        38
#> 74       583
#> 75       108
#> 76       295
#> 77      3057
#> 78       484
#> 79        93
#> 80      1028
#> 81       127
#> 82       198
#> 83      1892
#> 84       318
#> 85      1305
#> 86      9628
#> 87       405
#> 88      1636
#> 89     11392
#> 90       639

# Parroquias de un cantón por grupos quinquenales (estimación pobecu)
poblacion("parroquia", anio = 2030, canton = "Puyango", edad = "quinquenal")
#>     dpa_parroq  parroquia dpa_canton  canton dpa_provin provincia anio  edad
#> 1       111050     Alamor       1110 Puyango         11      Loja 2030   0-4
#> 2       111050     Alamor       1110 Puyango         11      Loja 2030   5-9
#> 3       111050     Alamor       1110 Puyango         11      Loja 2030 10-14
#> 4       111050     Alamor       1110 Puyango         11      Loja 2030 15-19
#> 5       111050     Alamor       1110 Puyango         11      Loja 2030 20-24
#> 6       111050     Alamor       1110 Puyango         11      Loja 2030 25-29
#> 7       111050     Alamor       1110 Puyango         11      Loja 2030 30-34
#> 8       111050     Alamor       1110 Puyango         11      Loja 2030 35-39
#> 9       111050     Alamor       1110 Puyango         11      Loja 2030 40-44
#> 10      111050     Alamor       1110 Puyango         11      Loja 2030 45-49
#> 11      111050     Alamor       1110 Puyango         11      Loja 2030 50-54
#> 12      111050     Alamor       1110 Puyango         11      Loja 2030 55-59
#> 13      111050     Alamor       1110 Puyango         11      Loja 2030 60-64
#> 14      111050     Alamor       1110 Puyango         11      Loja 2030 65-69
#> 15      111050     Alamor       1110 Puyango         11      Loja 2030 70-74
#> 16      111050     Alamor       1110 Puyango         11      Loja 2030 75-79
#> 17      111050     Alamor       1110 Puyango         11      Loja 2030 80-84
#> 18      111050     Alamor       1110 Puyango         11      Loja 2030   85+
#> 19      111051      Ciano       1110 Puyango         11      Loja 2030   0-4
#> 20      111051      Ciano       1110 Puyango         11      Loja 2030   5-9
#> 21      111051      Ciano       1110 Puyango         11      Loja 2030 10-14
#> 22      111051      Ciano       1110 Puyango         11      Loja 2030 15-19
#> 23      111051      Ciano       1110 Puyango         11      Loja 2030 20-24
#> 24      111051      Ciano       1110 Puyango         11      Loja 2030 25-29
#> 25      111051      Ciano       1110 Puyango         11      Loja 2030 30-34
#> 26      111051      Ciano       1110 Puyango         11      Loja 2030 35-39
#> 27      111051      Ciano       1110 Puyango         11      Loja 2030 40-44
#> 28      111051      Ciano       1110 Puyango         11      Loja 2030 45-49
#> 29      111051      Ciano       1110 Puyango         11      Loja 2030 50-54
#> 30      111051      Ciano       1110 Puyango         11      Loja 2030 55-59
#> 31      111051      Ciano       1110 Puyango         11      Loja 2030 60-64
#> 32      111051      Ciano       1110 Puyango         11      Loja 2030 65-69
#> 33      111051      Ciano       1110 Puyango         11      Loja 2030 70-74
#> 34      111051      Ciano       1110 Puyango         11      Loja 2030 75-79
#> 35      111051      Ciano       1110 Puyango         11      Loja 2030 80-84
#> 36      111051      Ciano       1110 Puyango         11      Loja 2030   85+
#> 37      111052  El Arenal       1110 Puyango         11      Loja 2030   0-4
#> 38      111052  El Arenal       1110 Puyango         11      Loja 2030   5-9
#> 39      111052  El Arenal       1110 Puyango         11      Loja 2030 10-14
#> 40      111052  El Arenal       1110 Puyango         11      Loja 2030 15-19
#> 41      111052  El Arenal       1110 Puyango         11      Loja 2030 20-24
#> 42      111052  El Arenal       1110 Puyango         11      Loja 2030 25-29
#> 43      111052  El Arenal       1110 Puyango         11      Loja 2030 30-34
#> 44      111052  El Arenal       1110 Puyango         11      Loja 2030 35-39
#> 45      111052  El Arenal       1110 Puyango         11      Loja 2030 40-44
#> 46      111052  El Arenal       1110 Puyango         11      Loja 2030 45-49
#> 47      111052  El Arenal       1110 Puyango         11      Loja 2030 50-54
#> 48      111052  El Arenal       1110 Puyango         11      Loja 2030 55-59
#> 49      111052  El Arenal       1110 Puyango         11      Loja 2030 60-64
#> 50      111052  El Arenal       1110 Puyango         11      Loja 2030 65-69
#> 51      111052  El Arenal       1110 Puyango         11      Loja 2030 70-74
#> 52      111052  El Arenal       1110 Puyango         11      Loja 2030 75-79
#> 53      111052  El Arenal       1110 Puyango         11      Loja 2030 80-84
#> 54      111052  El Arenal       1110 Puyango         11      Loja 2030   85+
#> 55      111053    El Limo       1110 Puyango         11      Loja 2030   0-4
#> 56      111053    El Limo       1110 Puyango         11      Loja 2030   5-9
#> 57      111053    El Limo       1110 Puyango         11      Loja 2030 10-14
#> 58      111053    El Limo       1110 Puyango         11      Loja 2030 15-19
#> 59      111053    El Limo       1110 Puyango         11      Loja 2030 20-24
#> 60      111053    El Limo       1110 Puyango         11      Loja 2030 25-29
#> 61      111053    El Limo       1110 Puyango         11      Loja 2030 30-34
#> 62      111053    El Limo       1110 Puyango         11      Loja 2030 35-39
#> 63      111053    El Limo       1110 Puyango         11      Loja 2030 40-44
#> 64      111053    El Limo       1110 Puyango         11      Loja 2030 45-49
#> 65      111053    El Limo       1110 Puyango         11      Loja 2030 50-54
#> 66      111053    El Limo       1110 Puyango         11      Loja 2030 55-59
#> 67      111053    El Limo       1110 Puyango         11      Loja 2030 60-64
#> 68      111053    El Limo       1110 Puyango         11      Loja 2030 65-69
#> 69      111053    El Limo       1110 Puyango         11      Loja 2030 70-74
#> 70      111053    El Limo       1110 Puyango         11      Loja 2030 75-79
#> 71      111053    El Limo       1110 Puyango         11      Loja 2030 80-84
#> 72      111053    El Limo       1110 Puyango         11      Loja 2030   85+
#> 73      111054 Mercadillo       1110 Puyango         11      Loja 2030   0-4
#> 74      111054 Mercadillo       1110 Puyango         11      Loja 2030   5-9
#> 75      111054 Mercadillo       1110 Puyango         11      Loja 2030 10-14
#> 76      111054 Mercadillo       1110 Puyango         11      Loja 2030 15-19
#> 77      111054 Mercadillo       1110 Puyango         11      Loja 2030 20-24
#> 78      111054 Mercadillo       1110 Puyango         11      Loja 2030 25-29
#> 79      111054 Mercadillo       1110 Puyango         11      Loja 2030 30-34
#> 80      111054 Mercadillo       1110 Puyango         11      Loja 2030 35-39
#> 81      111054 Mercadillo       1110 Puyango         11      Loja 2030 40-44
#> 82      111054 Mercadillo       1110 Puyango         11      Loja 2030 45-49
#> 83      111054 Mercadillo       1110 Puyango         11      Loja 2030 50-54
#> 84      111054 Mercadillo       1110 Puyango         11      Loja 2030 55-59
#> 85      111054 Mercadillo       1110 Puyango         11      Loja 2030 60-64
#> 86      111054 Mercadillo       1110 Puyango         11      Loja 2030 65-69
#> 87      111054 Mercadillo       1110 Puyango         11      Loja 2030 70-74
#> 88      111054 Mercadillo       1110 Puyango         11      Loja 2030 75-79
#> 89      111054 Mercadillo       1110 Puyango         11      Loja 2030 80-84
#> 90      111054 Mercadillo       1110 Puyango         11      Loja 2030   85+
#> 91      111055  Vicentino       1110 Puyango         11      Loja 2030   0-4
#> 92      111055  Vicentino       1110 Puyango         11      Loja 2030   5-9
#> 93      111055  Vicentino       1110 Puyango         11      Loja 2030 10-14
#> 94      111055  Vicentino       1110 Puyango         11      Loja 2030 15-19
#> 95      111055  Vicentino       1110 Puyango         11      Loja 2030 20-24
#> 96      111055  Vicentino       1110 Puyango         11      Loja 2030 25-29
#> 97      111055  Vicentino       1110 Puyango         11      Loja 2030 30-34
#> 98      111055  Vicentino       1110 Puyango         11      Loja 2030 35-39
#> 99      111055  Vicentino       1110 Puyango         11      Loja 2030 40-44
#> 100     111055  Vicentino       1110 Puyango         11      Loja 2030 45-49
#> 101     111055  Vicentino       1110 Puyango         11      Loja 2030 50-54
#> 102     111055  Vicentino       1110 Puyango         11      Loja 2030 55-59
#> 103     111055  Vicentino       1110 Puyango         11      Loja 2030 60-64
#> 104     111055  Vicentino       1110 Puyango         11      Loja 2030 65-69
#> 105     111055  Vicentino       1110 Puyango         11      Loja 2030 70-74
#> 106     111055  Vicentino       1110 Puyango         11      Loja 2030 75-79
#> 107     111055  Vicentino       1110 Puyango         11      Loja 2030 80-84
#> 108     111055  Vicentino       1110 Puyango         11      Loja 2030   85+
#>     poblacion
#> 1         628
#> 2         666
#> 3         746
#> 4         721
#> 5         663
#> 6         689
#> 7         701
#> 8         723
#> 9         617
#> 10        623
#> 11        550
#> 12        462
#> 13        358
#> 14        405
#> 15        308
#> 16        214
#> 17        153
#> 18        107
#> 19         75
#> 20         77
#> 21        100
#> 22        112
#> 23         91
#> 24         89
#> 25         71
#> 26         95
#> 27         95
#> 28         99
#> 29         83
#> 30         74
#> 31         61
#> 32         49
#> 33         44
#> 34         25
#> 35         19
#> 36         12
#> 37         77
#> 38        100
#> 39        112
#> 40        114
#> 41         90
#> 42         82
#> 43         79
#> 44         84
#> 45         78
#> 46         96
#> 47         68
#> 48         80
#> 49         52
#> 50         59
#> 51         39
#> 52         38
#> 53         19
#> 54         20
#> 55        205
#> 56        181
#> 57        201
#> 58        225
#> 59        207
#> 60        186
#> 61        186
#> 62        183
#> 63        164
#> 64        137
#> 65        125
#> 66        105
#> 67         76
#> 68         77
#> 69         66
#> 70         57
#> 71         42
#> 72         17
#> 73         93
#> 74        108
#> 75        111
#> 76        113
#> 77         79
#> 78         85
#> 79        101
#> 80         95
#> 81         94
#> 82         78
#> 83         53
#> 84         66
#> 85         73
#> 86         58
#> 87         64
#> 88         35
#> 89         34
#> 90         33
#> 91         48
#> 92         71
#> 93         74
#> 94         85
#> 95         56
#> 96         60
#> 97         42
#> 98         55
#> 99         74
#> 100        48
#> 101        65
#> 102        46
#> 103        45
#> 104        33
#> 105        29
#> 106        38
#> 107        31
#> 108        19

# Serie nacional 1950-2050
nac <- poblacion("nacional")
plot(nac$anio, nac$poblacion / 1e6, type = "l",
     xlab = "Año", ylab = "Millones de habitantes")


# Edades simples (se descargan la primera vez)
poblacion("provincia", anio = 2025, provincia = "Pichincha", edad = "simple")
#>     dpa_provin provincia anio edad poblacion
#> 1           17 Pichincha 2025    0     35773
#> 2           17 Pichincha 2025    1     36363
#> 3           17 Pichincha 2025    2     37254
#> 4           17 Pichincha 2025    3     38605
#> 5           17 Pichincha 2025    4     40434
#> 6           17 Pichincha 2025    5     42537
#> 7           17 Pichincha 2025    6     44518
#> 8           17 Pichincha 2025    7     46177
#> 9           17 Pichincha 2025    8     47593
#> 10          17 Pichincha 2025    9     48796
#> 11          17 Pichincha 2025   10     49793
#> 12          17 Pichincha 2025   11     50632
#> 13          17 Pichincha 2025   12     51370
#> 14          17 Pichincha 2025   13     51945
#> 15          17 Pichincha 2025   14     52370
#> 16          17 Pichincha 2025   15     52620
#> 17          17 Pichincha 2025   16     52624
#> 18          17 Pichincha 2025   17     52452
#> 19          17 Pichincha 2025   18     52133
#> 20          17 Pichincha 2025   19     51731
#> 21          17 Pichincha 2025   20     51358
#> 22          17 Pichincha 2025   21     51111
#> 23          17 Pichincha 2025   22     51092
#> 24          17 Pichincha 2025   23     51382
#> 25          17 Pichincha 2025   24     51967
#> 26          17 Pichincha 2025   25     52636
#> 27          17 Pichincha 2025   26     53183
#> 28          17 Pichincha 2025   27     53589
#> 29          17 Pichincha 2025   28     53943
#> 30          17 Pichincha 2025   29     54316
#> 31          17 Pichincha 2025   30     54722
#> 32          17 Pichincha 2025   31     55194
#> 33          17 Pichincha 2025   32     55680
#> 34          17 Pichincha 2025   33     56094
#> 35          17 Pichincha 2025   34     56360
#> 36          17 Pichincha 2025   35     57019
#> 37          17 Pichincha 2025   36     57339
#> 38          17 Pichincha 2025   37     56832
#> 39          17 Pichincha 2025   38     56381
#> 40          17 Pichincha 2025   39     55993
#> 41          17 Pichincha 2025   40     55378
#> 42          17 Pichincha 2025   41     54415
#> 43          17 Pichincha 2025   42     53297
#> 44          17 Pichincha 2025   43     52218
#> 45          17 Pichincha 2025   44     51100
#> 46          17 Pichincha 2025   45     49744
#> 47          17 Pichincha 2025   46     48200
#> 48          17 Pichincha 2025   47     46606
#> 49          17 Pichincha 2025   48     45012
#> 50          17 Pichincha 2025   49     43398
#> 51          17 Pichincha 2025   50     41773
#> 52          17 Pichincha 2025   51     40121
#> 53          17 Pichincha 2025   52     38490
#> 54          17 Pichincha 2025   53     36934
#> 55          17 Pichincha 2025   54     35422
#> 56          17 Pichincha 2025   55     33961
#> 57          17 Pichincha 2025   56     32572
#> 58          17 Pichincha 2025   57     31261
#> 59          17 Pichincha 2025   58     30045
#> 60          17 Pichincha 2025   59     28929
#> 61          17 Pichincha 2025   60     27904
#> 62          17 Pichincha 2025   61     26934
#> 63          17 Pichincha 2025   62     26001
#> 64          17 Pichincha 2025   63     25069
#> 65          17 Pichincha 2025   64     24106
#> 66          17 Pichincha 2025   65     23100
#> 67          17 Pichincha 2025   66     22076
#> 68          17 Pichincha 2025   67     21057
#> 69          17 Pichincha 2025   68     20036
#> 70          17 Pichincha 2025   69     19016
#> 71          17 Pichincha 2025   70     18001
#> 72          17 Pichincha 2025   71     17003
#> 73          17 Pichincha 2025   72     16026
#> 74          17 Pichincha 2025   73     15062
#> 75          17 Pichincha 2025   74     14100
#> 76          17 Pichincha 2025   75     13204
#> 77          17 Pichincha 2025   76     12085
#> 78          17 Pichincha 2025   77     10630
#> 79          17 Pichincha 2025   78      9412
#> 80          17 Pichincha 2025   79      8620
#> 81          17 Pichincha 2025   80      7898
#> 82          17 Pichincha 2025   81      7146
#> 83          17 Pichincha 2025   82      6418
#> 84          17 Pichincha 2025   83      5728
#> 85          17 Pichincha 2025   84      5093
#> 86          17 Pichincha 2025   85      3696
#> 87          17 Pichincha 2025   86      3071
#> 88          17 Pichincha 2025   87      2456
#> 89          17 Pichincha 2025   88      2149
#> 90          17 Pichincha 2025   89      1870
#> 91          17 Pichincha 2025   90      1614
#> 92          17 Pichincha 2025   91      1378
#> 93          17 Pichincha 2025   92      1166
#> 94          17 Pichincha 2025   93       972
#> 95          17 Pichincha 2025   94       799
#> 96          17 Pichincha 2025   95       648
#> 97          17 Pichincha 2025   96       519
#> 98          17 Pichincha 2025   97       408
#> 99          17 Pichincha 2025   98       313
#> 100         17 Pichincha 2025   99       235
#> 101         17 Pichincha 2025  100       672
```
