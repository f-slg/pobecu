# Changelog

## pobecu 0.3.1

- Los datos por edad simple se verifican: la descarga se comprueba con
  una huella MD5, se guarda con un nombre temporal y se renombra al
  terminar, y el archivo en caché se comprueba la primera vez que se usa
  en cada sesión. Un archivo incompleto ya no bloquea el paquete con el
  error “formato de entrada desconocido”: se descarga de nuevo. Los
  archivos de
  [`pobecu_usar_carpeta()`](https://f-slg.github.io/pobecu/reference/pobecu_usar_carpeta.md)
  no se verifican, y si no se pueden leer se explica.
- [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md) y
  [`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md)
  indican en la advertencia cuántas filas quedan sin población por el
  código, por el año o por el sexo o la edad.
- [`formatear_codigo()`](https://f-slg.github.io/pobecu/reference/formatear_codigo.md)
  devuelve `NA`, con advertencia, en lugar de inventar la provincia
  `"00"`: `"01"` como cantón ya no se convierte en `"0001"`. Además, los
  números grandes ya no pasan por notación científica (`100000` se
  mostraba como `1e+05`).
- Los filtros `provincia` y `canton` explican el error cuando reciben
  `NA` o un texto vacío, `sexo` y `area` cuando no son `TRUE` o `FALSE`,
  y `buscar_pob(NA)` devuelve una tabla sin filas.
- [`normalizar_nombre()`](https://f-slg.github.io/pobecu/reference/normalizar_nombre.md)
  conserva la letra base de otras vocales acentuadas y de la cedilla
  (`à`, `ê`, `ã`, `ç`…), que antes se convertían en espacios.
- [`formatear_codigo()`](https://f-slg.github.io/pobecu/reference/formatear_codigo.md)
  y
  [`normalizar_nombre()`](https://f-slg.github.io/pobecu/reference/normalizar_nombre.md)
  se comportan igual que las de geoecu 0.4.2, y una prueba lo comprueba
  cuando geoecu está instalado.
- `citation("pobecu")` incluye el DOI del paquete en CRAN
  (<https://doi.org/10.32614/CRAN.package.pobecu>) y el ORCID del autor,
  que también figura en `DESCRIPTION`. Nuevo `CITATION.cff` en el
  repositorio.

## pobecu 0.3.0

CRAN release: 2026-11-07

- [`pob_ajustar()`](https://f-slg.github.io/pobecu/reference/pob_ajustar.md)
  y
  [`pob_estimar()`](https://f-slg.github.io/pobecu/reference/pob_estimar.md)
  construyen escenarios 1900-2100 para 24 provincias, 221 cantones y
  1042 unidades parroquiales, coherentes con el total nacional. Modelo
  estructural en logaritmos y participaciones CLR, extrapolación
  amortiguada, bandas Monte Carlo condicionales, diagnósticos y
  referencias conservadas. No representan jurisdicciones históricas.

- [`pob_estimar()`](https://f-slg.github.io/pobecu/reference/pob_estimar.md)
  usa una semilla propia para cada grupo territorial, derivada de
  `semilla`, y solo simula las ramas que contienen los territorios
  pedidos: una consulta por provincia o cantón tarda menos de un segundo
  en lugar de unos 30. Las estimaciones puntuales no cambian y las
  bandas de un territorio son las mismas se pida solo o con el resto.

- Metodología técnica, validación temporal en ambos sentidos, análisis
  de sensibilidad y gráficos reproducibles en el README.

- [`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md)
  ya no convierte el sufijo `00`, que no existe, en la cabecera cantonal
  (por ejemplo, `110100` daba `110150` y la tasa se calculaba con otro
  denominador sin aviso). Ahora se deja igual y
  [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md)
  lo informa como no encontrado.

- [`normalizar_nombre()`](https://f-slg.github.io/pobecu/reference/normalizar_nombre.md)
  y las búsquedas por nombre reconocen los textos con tildes como
  caracteres combinados (Unicode NFD), habituales al copiar de algunos
  sistemas: “Cañar” ya no se convierte en `CAN AR`.

- [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md)
  interpreta correctamente columnas de años de tipo factor y rechaza
  años decimales o no finitos, sin truncarlos silenciosamente.

- [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md) y
  [`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md)
  conservan las tablas vacías.

- [`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md)
  devuelve `NA_real_` con advertencia cuando la población es cero.
  Valida numeradores numéricos no negativos y una base finita positiva;
  conserva `NA` y admite numeradores ponderados fraccionarios.

- Nuevas pruebas de regresión para esos casos.

- Auditoría reproducible contra los Excel originales del INEC, mediante
  un lector independiente del proceso de construcción, y evidencias en
  `validacion/`.

- README generado desde R Markdown con resultados reales, seis gráficos,
  interpretación y ejemplos completos. Incluye un guion R y un generador
  HTML.

- [`pob_fuentes()`](https://f-slg.github.io/pobecu/reference/pob_fuentes.md)
  devuelve un objeto de clase `pob_fuentes`; la información sobre
  versión y fuentes se muestra con su método
  [`print()`](https://rdrr.io/r/base/print.html).

- Requiere geoecu 0.4.1 o posterior (en Suggests), cuya superficie
  `area_km2` se calcula con una proyección de igual área; la `densidad`
  de
  [`pob_mapa()`](https://f-slg.github.io/pobecu/reference/pob_mapa.md)
  usa esas superficies corregidas.

## pobecu 0.2.0

CRAN release: 2026-11-07

### Compatibilidad con geoecu 0.4.0

geoecu 0.4.0 usa la Organización Territorial del Estado del CONALI
(2026), con 223 cantones y sin parroquias urbanas; pobecu sigue usando
las unidades del Censo 2022 (221 cantones y 1042 parroquias), que son
las de las proyecciones del INEC. Para que ambos paquetes encajen:

- [`pob_mapa()`](https://f-slg.github.io/pobecu/reference/pob_mapa.md)
  convierte la capa de geoecu a las unidades del censo antes de unir la
  población. Los cantones Borbón y Sevilla Don Bosco se dibujan dentro
  de Eloy Alfaro y Morona, y las parroquias creadas después del censo
  dentro de la parroquia que las contenía, así que no quedan territorios
  sin población ni densidades infladas. Las zonas en estudio se
  conservan con `poblacion = NA`. Sigue funcionando con geoecu 0.3.0.
- Nueva función
  [`agrupar_unidades()`](https://f-slg.github.io/pobecu/reference/agrupar_unidades.md),
  para capas de cantones y de parroquias. Reemplaza a
  [`agrupar_cabeceras()`](https://f-slg.github.io/pobecu/reference/agrupar_unidades.md),
  que se mantiene como alias.
- [`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md)
  convierte también los códigos del CONALI que no existen en el censo
  (Borbón, Sevilla Don Bosco, Bella Vista, Sosote, Shuar Pastaza, Juan
  Montalvo, La Magdalena, La Primavera y Miss Ecuador).
- Nueva función
  [`homologar_canton()`](https://f-slg.github.io/pobecu/reference/homologar_canton.md)
  (`0809` -\> `0802`, `1413` -\> `1401`).
- [`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md)
  y [`pob_mapa()`](https://f-slg.github.io/pobecu/reference/pob_mapa.md)
  aceptan los cantones Borbón y Sevilla Don Bosco en el filtro `canton`
  y avisan de que se usa el cantón del censo.
- [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md) y
  [`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md)
  rechazan los códigos de cantón o parroquia del CONALI que hay que
  convertir y agregar antes, en lugar de dejar la población en `NA`.
- **Cambio incompatible:** la columna `tipo` de `dpa_pob` usa los mismos
  valores que geoecu: `"cabecera cantonal"` y `"parroquia rural"` (antes
  `"cabecera"` y `"rural"`).
- `data-raw/01_preparar_datos.R` funciona con el catálogo de geoecu
  0.4.0, y el nuevo `data-raw/06_equivalencias_conali.R` comprueba la
  tabla de equivalencias con
  [`geoecu::dpa_equivalencias`](https://f-slg.github.io/geoecu/reference/dpa_equivalencias.html).
- La viñeta “Mapas de población con geoecu” explica las diferencias
  entre ambas divisiones territoriales.

## pobecu 0.1.0

- Primera versión.
- Estimaciones y proyecciones oficiales del INEC, Revisión 2024 (con
  áreas, 2025): nacional 1950-2050, provincial 1990-2035 y cantonal
  2010-2035, por sexo, edad y área urbana/rural.
- Estimación parroquial 2010-2035 (1042 parroquias del Censo 2022)
  coherente con la proyección cantonal oficial.
- Funciones
  [`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md),
  [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md),
  [`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md),
  [`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md),
  [`buscar_pob()`](https://f-slg.github.io/pobecu/reference/buscar_pob.md)
  y
  [`pob_fuentes()`](https://f-slg.github.io/pobecu/reference/pob_fuentes.md).
- Integración con geoecu:
  [`pob_mapa()`](https://f-slg.github.io/pobecu/reference/pob_mapa.md)
  (capa `sf` con población y densidad) y
  [`agrupar_cabeceras()`](https://f-slg.github.io/pobecu/reference/agrupar_unidades.md)
  (fusiona parroquias urbanas en su cabecera cantonal).
- Viñetas `metodologia` y `pobecu-geoecu`.
- Logo.
