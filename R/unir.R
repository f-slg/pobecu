#' Unir la población con una tabla propia
#'
#' Agrega a tu tabla (por ejemplo, casos por cantón y año) una columna con la
#' población correspondiente, usando el código DPA y, si existe, el año.
#' Los códigos se limpian con [formatear_codigo()], así que funcionan aunque
#' vengan de Excel sin ceros a la izquierda.
#'
#' @param datos Un `data.frame` con una columna de códigos DPA.
#' @param nivel `"canton"` (por defecto), `"provincia"` o `"parroquia"`.
#' @param codigo Nombre de la columna de `datos` con el código DPA. Por
#'   defecto se usa `dpa_provin`, `dpa_canton` o `dpa_parroq` según el nivel.
#' @param anio Nombre de la columna de `datos` con el año, o un año fijo
#'   (número) para toda la tabla. Por defecto se usa la columna `anio` si
#'   existe.
#' @param sexo,edad Desagregación de la población, como en [poblacion()]. Si
#'   la usas, `datos` debe tener columnas `sexo` (`"hombre"`/`"mujer"`) y/o
#'   `edad` con los mismos valores que devuelve [poblacion()].
#' @return `datos` con una columna adicional `poblacion`. Las filas sin
#'   coincidencia quedan con `NA` y se avisa con una advertencia.
#' @export
#' @examples
#' casos <- data.frame(dpa_canton = c(1101, 1102, 701), anio = 2024,
#'                     casos = c(120, 8, 40))
#' pob_unir(casos)
#'
#' # Por sexo
#' casos_sexo <- data.frame(dpa_provin = "11", anio = 2025,
#'                          sexo = c("hombre", "mujer"), casos = c(10, 14))
#' pob_unir(casos_sexo, nivel = "provincia", sexo = TRUE)
pob_unir <- function(datos, nivel = c("canton", "provincia", "parroquia"),
                     codigo = NULL, anio = NULL, sexo = FALSE, edad = NULL) {
  nivel <- match.arg(nivel)
  if (!is.data.frame(datos)) stop("`datos` debe ser un data.frame.", call. = FALSE)
  if ("poblacion" %in% names(datos)) {
    stop("`datos` ya tiene una columna `poblacion`.", call. = FALSE)
  }
  col_cod <- if (is.null(codigo)) .columnas_nivel(nivel)$codigo else codigo
  if (!col_cod %in% names(datos)) {
    stop("No se encontr\u00f3 la columna de c\u00f3digos '", col_cod, "' en `datos`. ",
         "Ind\u00edcala con el argumento `codigo`.", call. = FALSE)
  }
  cod <- formatear_codigo(datos[[col_cod]], nivel)
  .revisar_codigos(cod, nivel)

  # Ano: columna, numero fijo o columna `anio` por defecto
  if (is.numeric(anio)) {
    if (length(anio) != 1) stop("`anio` fijo debe ser un solo a\u00f1o.", call. = FALSE)
    anios <- rep(as.integer(anio), nrow(datos))
  } else {
    col_anio <- if (is.null(anio)) "anio" else anio
    if (!col_anio %in% names(datos)) {
      stop("No se encontr\u00f3 la columna de a\u00f1o '", col_anio, "'. ",
           "Ind\u00edcala con `anio` o usa un a\u00f1o fijo, por ejemplo anio = 2025.",
           call. = FALSE)
    }
    anios <- as.integer(datos[[col_anio]])
  }
  anios_validos <- intersect(unique(stats::na.omit(anios)), .pobecu_anios[[nivel]])
  if (!length(anios_validos)) {
    stop("Ning\u00fan a\u00f1o de `datos` est\u00e1 disponible para el nivel ", nivel, ".",
         call. = FALSE)
  }

  pob <- poblacion(nivel, anio = anios_validos, sexo = sexo, edad = edad)
  cols <- .columnas_nivel(nivel)
  clave_pob <- paste(pob[[cols$codigo]], pob$anio,
                     if (sexo) pob$sexo, if (!is.null(edad)) as.character(pob$edad))
  clave_dat <- paste(cod, anios,
                     if (sexo) tolower(trimws(.columna(datos, "sexo"))),
                     if (!is.null(edad)) as.character(.columna(datos, "edad")))
  datos$poblacion <- pob$poblacion[match(clave_dat, clave_pob)]

  faltan <- is.na(datos$poblacion)
  if (any(faltan)) {
    warning(sum(faltan), " fila(s) sin poblaci\u00f3n (c\u00f3digo, a\u00f1o u otra ",
            "desagregaci\u00f3n no encontrados).", call. = FALSE)
  }
  datos
}

#' Calcular tasas con la población de pobecu
#'
#' Une la población con [pob_unir()] y calcula una tasa por cada `por`
#' habitantes (por defecto, por 100 000).
#'
#' @inheritParams pob_unir
#' @param casos Nombre de la columna de `datos` con el numerador (casos,
#'   defunciones, nacimientos, etc.).
#' @param por Base de la tasa. Por defecto 100 000 habitantes.
#' @param ... Otros argumentos para [pob_unir()] (`codigo`, `anio`, `sexo`,
#'   `edad`).
#' @return `datos` con las columnas `poblacion` y `tasa`.
#' @export
#' @examples
#' casos <- data.frame(dpa_provin = c("01", "11", "17"), anio = 2024,
#'                     casos = c(35, 52, 210))
#' pob_tasa(casos, "casos", nivel = "provincia")
pob_tasa <- function(datos, casos, nivel = c("canton", "provincia", "parroquia"),
                     por = 1e5, ...) {
  nivel <- match.arg(nivel)
  if (!casos %in% names(datos)) {
    stop("No se encontr\u00f3 la columna '", casos, "' en `datos`.", call. = FALSE)
  }
  datos <- pob_unir(datos, nivel = nivel, ...)
  datos$tasa <- datos[[casos]] / datos$poblacion * por
  datos
}

# --- internas ----------------------------------------------------------------

.columna <- function(datos, nombre) {
  if (!nombre %in% names(datos)) {
    stop("Para unir por ", nombre, ", `datos` debe tener una columna `", nombre, "`.",
         call. = FALSE)
  }
  datos[[nombre]]
}

# Rechaza codigos que no son unidades del censo pero se pueden convertir:
# unirlos sin agregar repetiria la poblacion en varias filas
.revisar_codigos <- function(cod, nivel) {
  if (nivel == "provincia") return(invisible())
  cod <- unique(cod[!is.na(cod)])
  if (nivel == "parroquia") {
    otros <- cod[!cod %in% pobecu::dpa_pob$dpa_parroq & homologar_parroquia(cod) != cod]
    funcion <- "homologar_parroquia()"
    detalle <- paste0("de parroquias urbanas o posteriores al Censo 2022 ",
                      "(por ejemplo, de geoecu >= 0.4.0)")
  } else {
    otros <- cod[homologar_canton(cod) != cod]
    funcion <- "homologar_canton()"
    detalle <- "de cantones creados despu\u00e9s del Censo 2022 (Borb\u00f3n, Sevilla Don Bosco)"
  }
  if (length(otros)) {
    stop("Hay c\u00f3digos ", detalle, ": ", paste(utils::head(otros, 5), collapse = ", "),
         if (length(otros) > 5) ", ...", ". La poblaci\u00f3n usa las unidades del ",
         "Censo 2022: convierte los c\u00f3digos con ", funcion,
         " y agrega tus datos antes de unir.", call. = FALSE)
  }
}
