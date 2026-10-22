# Changelog

## pobecu 0.2.0

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
