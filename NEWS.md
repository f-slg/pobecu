# pobecu 0.3.0

* `pob_ajustar()` y `pob_estimar()` construyen escenarios 1900-2100 para
  24 provincias, 221 cantones y 1042 unidades parroquiales, coherentes con
  el total nacional. Modelo estructural en logaritmos y participaciones CLR,
  extrapolación amortiguada, bandas Monte Carlo condicionales, diagnósticos
  y referencias conservadas. No representan jurisdicciones históricas.
* `pob_estimar()` usa una semilla propia para cada grupo territorial,
  derivada de `semilla`, y solo simula las ramas que contienen los
  territorios pedidos: una consulta por provincia o cantón tarda menos de un
  segundo en lugar de unos 30. Las estimaciones puntuales no cambian y las
  bandas de un territorio son las mismas se pida solo o con el resto.
* Metodología técnica, validación temporal en ambos sentidos, análisis de
  sensibilidad y gráficos reproducibles en el README.

* `homologar_parroquia()` ya no convierte el sufijo `00`, que no existe, en
  la cabecera cantonal (por ejemplo, `110100` daba `110150` y la tasa se
  calculaba con otro denominador sin aviso). Ahora se deja igual y
  `pob_unir()` lo informa como no encontrado.
* `normalizar_nombre()` y las búsquedas por nombre reconocen los textos con
  tildes como caracteres combinados (Unicode NFD), habituales al copiar de
  algunos sistemas: "Cañar" ya no se convierte en `CAN AR`.
* `pob_unir()` interpreta correctamente columnas de años de tipo factor y
  rechaza años decimales o no finitos, sin truncarlos silenciosamente.
* `pob_unir()` y `pob_tasa()` conservan las tablas vacías.
* `pob_tasa()` devuelve `NA_real_` con advertencia cuando la población es
  cero. Valida numeradores numéricos no negativos y una base finita positiva;
  conserva `NA` y admite numeradores ponderados fraccionarios.
* Nuevas pruebas de regresión para esos casos.
* Auditoría reproducible contra los Excel originales del INEC, mediante un
  lector independiente del proceso de construcción, y evidencias en `validacion/`.
* README generado desde R Markdown con resultados reales, seis gráficos,
  interpretación y ejemplos completos. Incluye un guion R y un generador HTML.

* `pob_fuentes()` devuelve un objeto de clase `pob_fuentes`; la información
  sobre versión y fuentes se muestra con su método `print()`.
* Requiere geoecu 0.4.1 o posterior (en Suggests), cuya superficie
  `area_km2` se calcula con una proyección de igual área; la `densidad` de
  `pob_mapa()` usa esas superficies corregidas.

# pobecu 0.2.0

## Compatibilidad con geoecu 0.4.0

geoecu 0.4.0 usa la Organización Territorial del Estado del CONALI (2026),
con 223 cantones y sin parroquias urbanas; pobecu sigue usando las unidades
del Censo 2022 (221 cantones y 1042 parroquias), que son las de las
proyecciones del INEC. Para que ambos paquetes encajen:

* `pob_mapa()` convierte la capa de geoecu a las unidades del censo antes de
  unir la población. Los cantones Borbón y Sevilla Don Bosco se dibujan
  dentro de Eloy Alfaro y Morona, y las parroquias creadas después del censo
  dentro de la parroquia que las contenía, así que no quedan territorios sin
  población ni densidades infladas. Las zonas en estudio se conservan con
  `poblacion = NA`. Sigue funcionando con geoecu 0.3.0.
* Nueva función `agrupar_unidades()`, para capas de cantones y de
  parroquias. Reemplaza a `agrupar_cabeceras()`, que se mantiene como alias.
* `homologar_parroquia()` convierte también los códigos del CONALI que no
  existen en el censo (Borbón, Sevilla Don Bosco, Bella Vista, Sosote, Shuar
  Pastaza, Juan Montalvo, La Magdalena, La Primavera y Miss Ecuador).
* Nueva función `homologar_canton()` (`0809` -> `0802`, `1413` -> `1401`).
* `poblacion()` y `pob_mapa()` aceptan los cantones Borbón y Sevilla Don
  Bosco en el filtro `canton` y avisan de que se usa el cantón del censo.
* `pob_unir()` y `pob_tasa()` rechazan los códigos de cantón o parroquia
  del CONALI que hay que convertir y agregar antes, en lugar de dejar la
  población en `NA`.
* **Cambio incompatible:** la columna `tipo` de `dpa_pob` usa los mismos
  valores que geoecu: `"cabecera cantonal"` y `"parroquia rural"` (antes
  `"cabecera"` y `"rural"`).
* `data-raw/01_preparar_datos.R` funciona con el catálogo de geoecu 0.4.0, y
  el nuevo `data-raw/06_equivalencias_conali.R` comprueba la tabla de
  equivalencias con `geoecu::dpa_equivalencias`.
* La viñeta "Mapas de población con geoecu" explica las diferencias entre
  ambas divisiones territoriales.

# pobecu 0.1.0

* Primera versión.
* Estimaciones y proyecciones oficiales del INEC, Revisión 2024 (con áreas,
  2025): nacional 1950-2050, provincial 1990-2035 y cantonal 2010-2035, por
  sexo, edad y área urbana/rural.
* Estimación parroquial 2010-2035 (1042 parroquias del Censo 2022) coherente
  con la proyección cantonal oficial.
* Funciones `poblacion()`, `pob_unir()`, `pob_tasa()`, `homologar_parroquia()`,
  `buscar_pob()` y `pob_fuentes()`.
* Integración con geoecu: `pob_mapa()` (capa `sf` con población y densidad) y
  `agrupar_cabeceras()` (fusiona parroquias urbanas en su cabecera cantonal).
* Viñetas `metodologia` y `pobecu-geoecu`.
* Logo.
