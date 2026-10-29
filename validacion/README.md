# Contraste de pobecu con las fuentes originales

Fecha de contraste: **28 de octubre de 2026**. Base del código revisado:
`15b8f61283f026b4f04a5243c8802c74094706f7` (pobecu 0.2.0).
Las correcciones de funciones y documentación se preparan como 0.2.0.9000.

## Resultado y alcance

No se encontraron diferencias en las **2 696 094 celdas de edades simples**
del archivo publicado ni en las **560 574 celdas quinquenales** incluidas en
el paquete, al compararlas con los tabulados originales del INEC.
Tampoco hubo claves faltantes, sobrantes o duplicadas en esos cruces.

| Nivel | Celdas de edad simple | Celdas quinquenales | Diferencias |
|---|---:|---:|---:|
| Nacional | 25 654 | 5 334 | 0 |
| Provincial | 349 056 | 72 576 | 0 |
| Cantonal | 2 321 384 | 482 664 | 0 |

Se contrastaron además los conteos censales 2010 y 2022 de **1042 parroquias**
por año (2084 valores), utilizando provincia, cantón y parroquia como clave,
no la posición de las filas. Los faltantes censales de 2010 se comparan como
faltantes; no se sustituyen por ceros.

La suma de las estimaciones parroquiales coincide con el total cantonal en
**206 856 combinaciones de cantón, año, sexo y edad**: 221 cantones × 26 años
× 2 sexos × 18 grupos de edad, agrupando 85 y más años en una sola categoría.
También se verifican las sumas de provincias al país y de cantones a provincias
en todos los años y grupos compartidos. El detalle reproducible se conserva en
[resumen.csv](resumen.csv); cada fila identifica la comprobación y su número de celdas.

Las comprobaciones de totales y subtotales reutilizan celdas; no deben sumarse
para declarar un número de observaciones independientes.

## Fuentes y verificación de los archivos

Se descargaron nuevamente los dos Excel desde sus dominios oficiales y el RDS
desde el release de GitHub. Sus huellas SHA-256 coinciden byte por byte con las
copias locales usadas para construir el paquete.

1. [INEC: Tabulados de Estimaciones y Proyecciones, Revisión 2024 con áreas](https://www.ecuadorencifras.gob.ec/documentos/web-inec/Poblacion_y_Demografia/Proyecciones_Poblacionales/censo_2022/revision_2024_areas/Tabulados_Estimacion_Proyeccion_v2.xlsx).
   Hojas 1.1, 2.1 y 3.1: población total por sexo y edad simple.
   Hojas 1.4, 2.4 y 3.4: población por área, sexo y edad simple.
   SHA-256: `35dba440e116cad9e606d58960c1c27affc690392f6a29eacf651309bc5e01cd`.
2. [INEC: Estructura poblacional del Censo 2022](https://www.censoecuador.gob.ec/wp-content/uploads/2024/04/01_2022_CPV_Estructura_poblacional.xlsx).
   Hoja 5.2: conteos parroquiales de 2010 y 2022.
   SHA-256: `7e7d0d5ad13b8c5ec93bfacce5bc518984e591ce1b3f3abe2095326ea6bbafcd`.
3. [pobecu: edades simples, release datos-v0.1.0](https://github.com/f-slg/pobecu/releases/download/datos-v0.1.0/pobecu_edad_simple.rds).
   SHA-256: `a6135525efaed33a26d4a16201ed2d55c61ec906c856cab840f160e498a23ebd`.

[ejecucion.txt](ejecucion.txt) registra la fecha, versión de R, versión del paquete
y huellas MD5 de los archivos efectivamente leídos por el script.
Las huellas identifican los archivos contrastados; no reemplazan las fuentes.

### Diferencia en la página resumen del INEC

El 28 de octubre de 2026, la [página resumen](https://www.ecuadorencifras.gob.ec/proyecciones-poblacionales/)
mostraba **18 815 497** tanto en la columna nacional 2024 como en 2030.
El Excel original y pobecu dan **17 966 573 para 2024** y **18 815 497 para 2030**.
La discrepancia está en el resumen web, no en las tablas de pobecu. No se
modificaron datos para ajustarlos a ese resumen.

## Procedimiento independiente

[07_validar_fuentes.R](../data-raw/07_validar_fuentes.R) utiliza `readxl` para leer
los archivos originales. No llama a `funciones_lectura.R` ni toma la tabla
`data-raw/build/inec_edad_simple.rds` como referencia.

1. Lee las seis hojas de proyecciones con sus encabezados de año, sexo y área.
2. Comprueba hombre + mujer contra las columnas Total del Excel.
3. Comprueba urbano + rural contra las hojas sin desagregación por área.
4. Contrasta cada celda con el RDS publicado, usando código, año, área, sexo y edad.
5. Agrega las edades originales y contrasta cada grupo quinquenal incluido.
6. Compara los conteos parroquiales censales por claves territoriales normalizadas.
7. Comprueba todas las sumas parroquia → cantón y las jerarquías oficiales.
8. Guarda el resumen y termina con error si hay diferencias, faltantes o extras.

No se reconstruyeron ni sobrescribieron los datos del paquete durante la auditoría.

## Reproducir

Desde una copia del repositorio, en R:

```r
install.packages(c("readxl", "pkgload"))
dir.create("data-raw/insumos", recursive = TRUE, showWarnings = FALSE)
dir.create("data-raw/release", recursive = TRUE, showWarnings = FALSE)
options(timeout = max(300, getOption("timeout")))

download.file(
  paste0("https://www.ecuadorencifras.gob.ec/documentos/web-inec/",
         "Poblacion_y_Demografia/Proyecciones_Poblacionales/censo_2022/",
         "revision_2024_areas/Tabulados_Estimacion_Proyeccion_v2.xlsx"),
  "data-raw/insumos/Tabulados_Estimacion_Proyeccion_v2.xlsx", mode = "wb")
download.file(
  paste0("https://www.censoecuador.gob.ec/wp-content/uploads/2024/04/",
         "01_2022_CPV_Estructura_poblacional.xlsx"),
  "data-raw/insumos/01_2022_CPV_Estructura_poblacional.xlsx", mode = "wb")
download.file(
  paste0("https://github.com/f-slg/pobecu/releases/download/",
         "datos-v0.1.0/pobecu_edad_simple.rds"),
  "data-raw/release/pobecu_edad_simple.rds", mode = "wb")
```

Después, en la terminal del proyecto:

```sh
Rscript data-raw/07_validar_fuentes.R
```

También acepta tres rutas explícitas: Excel de proyecciones, Excel del censo
y RDS de edades simples. El proceso puede tardar varios minutos y requiere
memoria para leer el tabulado cantonal completo.

## Límites del contraste

- Comprueba fidelidad de las cifras respecto de esta publicación del INEC;
  no evalúa si sus supuestos demográficos predecirán correctamente el futuro.
- Las 975 312 celdas parroquiales son estimaciones del paquete. No existe una
  proyección oficial parroquial equivalente contra la cual contrastarlas.
- Verificar los totales censales y cantonales no valida por sí solo la
  distribución parroquial por sexo y edad ni la elección del modelo logístico/IPF.
- No se realizó una validación externa predictiva ni se calcularon intervalos
  de incertidumbre para las parroquias.
- No se auditó geométricamente cada límite del CONALI. Algunas homologaciones
  parroquiales asignan territorios a su origen mayoritario y son aproximaciones.
- No se alteraron los archivos `.rda` ni el release de datos: el contraste no
  identificó una razón para reemplazarlos.
