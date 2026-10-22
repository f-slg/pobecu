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
