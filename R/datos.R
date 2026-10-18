#' Población nacional, provincial y cantonal del INEC
#'
#' Estimaciones (1950-2022) y proyecciones (2023 en adelante) oficiales de
#' población del Instituto Nacional de Estadística y Censos (INEC), Revisión
#' 2024, por año, área de residencia, sexo al nacer y grupos quinquenales de
#' edad. Las cifras corresponden al 30 de junio de cada año.
#'
#' Para consultarlas de forma cómoda (filtrar, agregar, cambiar los grupos de
#' edad o agregar nombres) usa [poblacion()].
#'
#' @details
#' * Periodos: nacional 1950-2050, provincial 1990-2035, cantonal 2010-2035.
#' * Área: en 2010-2035 cada combinación aparece dos veces, `"urbana"` y
#'   `"rural"`, que suman el total. Fuera de ese periodo (solo nacional y
#'   provincial) hay una sola fila con `area = "total"`. Según el INEC, la
#'   población por área es una estimación derivada de las proyecciones
#'   cantonales.
#' * Método del INEC: componentes demográficos por cohortes para los niveles
#'   nacional y provincial; extrapolación logística de la participación de
#'   cada cantón en su provincia para el nivel cantonal.
#' * Los tres niveles son coherentes entre sí: la suma de los cantones de una
#'   provincia es igual a la provincia, y la suma de las provincias es igual
#'   al total nacional.
#'
#' @format `data.frame` en formato largo con las columnas:
#' \describe{
#'   \item{dpa_provin, dpa_canton}{Código DPA (factor; solo en
#'     `pob_provincias` y `pob_cantones`).}
#'   \item{anio}{Año (entero).}
#'   \item{area}{`"total"`, `"urbana"` o `"rural"` (factor).}
#'   \item{sexo}{`"hombre"` o `"mujer"` (factor).}
#'   \item{grupo_edad}{Grupo quinquenal: `"0-4"`, `"5-9"`, ..., `"95-99"`,
#'     `"100+"` (factor ordenado por edad).}
#'   \item{poblacion}{Número de personas (entero).}
#' }
#'
#' @source INEC, *Estimaciones y Proyecciones de Población, Revisión 2024*
#'   (tabulados con áreas de residencia, 2025),
#'   <https://www.ecuadorencifras.gob.ec/proyecciones-poblacionales/>.
#'   Ver `data-raw/` en el repositorio para el procesamiento completo.
#'
#' @name pob_inec
#' @examples
#' head(pob_cantones)
#' # Población nacional por año
#' tapply(pob_nacional$poblacion, pob_nacional$anio, sum)[c("1950", "2025", "2050")]
NULL

#' @rdname pob_inec
"pob_nacional"

#' @rdname pob_inec
"pob_provincias"

#' @rdname pob_inec
"pob_cantones"

#' Población parroquial estimada, 2010-2035
#'
#' Estimación de la población de las 1042 parroquias del Censo 2022 (221
#' cabeceras cantonales y 821 parroquias rurales) por año, sexo al nacer y
#' grupos quinquenales de edad. **No es una cifra oficial**: el INEC no
#' publica proyecciones parroquiales. pobecu la construye a partir de la
#' proyección oficial de cada cantón, de modo que la suma de las parroquias
#' de un cantón es exactamente igual a la cifra oficial del INEC para ese
#' cantón, año, sexo y grupo de edad.
#'
#' @details
#' **Unidades.** Como en el Censo 2022, cada cabecera cantonal (código
#' terminado en `50`) es una sola unidad que incluye a todas las parroquias
#' urbanas del cantón. Para unir datos que usan códigos de parroquias urbanas
#' (por ejemplo, las capas del paquete geoecu), conviértelos con
#' [homologar_parroquia()].
#'
#' **Método.**
#' 1. *Participación en el cantón.* Se calcula la proporción de la población
#'    del cantón que vive en cada parroquia en los censos 2010 y 2022, y se
#'    interpola y extrapola con una función logística (lineal en la escala
#'    logit), el mismo método que usa el INEC para estimar los cantones a
#'    partir de su provincia. Las proporciones se reescalan para que sumen 1.
#'    En los cantones con parroquias creadas después de 2010 se mantiene
#'    constante la proporción del Censo 2022 (ver `metodo` en [dpa_pob]).
#' 2. *Total parroquial* = proporción x población oficial del cantón.
#' 3. *Sexo y edad.* Ajuste proporcional iterativo (IPF o *raking*): se parte
#'    de la estructura por sexo y edad de cada parroquia en el Censo 2022 y se
#'    ajusta a dos márgenes, el total parroquial (paso 2) y la estructura
#'    oficial del cantón por sexo y edad.
#' 4. *Redondeo* a enteros por el método del mayor residuo, conservando
#'    exactamente los totales cantonales.
#'
#' **Precauciones.** La extrapolación prolonga la tendencia observada entre
#' los dos censos: parroquias que crecieron o decrecieron mucho entre 2010 y
#' 2022 siguen haciéndolo hasta 2035. Las cifras de 2022 no coinciden con el
#' conteo censal porque la proyección del INEC corrige la omisión censal y
#' se refiere al 30 de junio. El grupo de edad más alto es `"85+"`.
#'
#' @format `data.frame` con las columnas `dpa_parroq` (factor), `anio`, `area`
#'   (siempre `"total"`), `sexo`, `grupo_edad` (`"0-4"`, ..., `"80-84"`,
#'   `"85+"`) y `poblacion`.
#'
#' @source Elaboración propia a partir de INEC, *Estimaciones y Proyecciones
#'   de Población, Revisión 2024*, y del VIII Censo de Población y VII de
#'   Vivienda 2022 (tabulados de estructura poblacional),
#'   <https://www.censoecuador.gob.ec/resultados-censo/>.
#'
#' @examples
#' head(pob_parroquias)
"pob_parroquias"

#' Catálogo de parroquias, cantones y provincias de pobecu
#'
#' Una fila por parroquia del Censo 2022, con sus códigos DPA, nombres
#' oficiales del INEC, la población censal 2010 y 2022 y el método usado en
#' la estimación parroquial.
#'
#' @format Un `data.frame` con 1042 filas y 10 columnas:
#' \describe{
#'   \item{dpa_parroq}{Código DPA de la parroquia (6 dígitos, texto). Las
#'     cabeceras cantonales terminan en `50`.}
#'   \item{parroquia}{Nombre de la parroquia según el Censo 2022.}
#'   \item{tipo}{`"cabecera"` (cabecera cantonal, incluye las parroquias
#'     urbanas) o `"rural"`.}
#'   \item{dpa_canton, canton}{Código y nombre del cantón.}
#'   \item{dpa_provin, provincia}{Código y nombre de la provincia.}
#'   \item{metodo}{Método de la estimación parroquial: `"logistica"`,
#'     `"participacion_constante"` (cantones con parroquias creadas después
#'     de 2010) o `"parroquia_unica"` (cantones de una sola parroquia).}
#'   \item{censo_2010, censo_2022}{Población empadronada en los censos 2010
#'     (en los límites de 2022; `NA` para parroquias creadas después de 2010)
#'     y 2022.}
#' }
#'
#' @source INEC, VIII Censo de Población y VII de Vivienda 2022, tablas 2.1 y
#'   5.2 de *Estructura poblacional*. Los códigos de las parroquias rurales se
#'   asignaron por nombre a partir de la División Político-Administrativa
#'   oficial.
#'
#' @examples
#' head(dpa_pob)
#' table(dpa_pob$provincia, dpa_pob$tipo)
"dpa_pob"
