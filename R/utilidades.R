#' Normalizar nombres geográficos
#'
#' Convierte nombres a una forma comparable: mayúsculas, sin tildes ni
#' diéresis, `Ñ` como `N`, sin signos de puntuación y con espacios simples.
#' Útil para unir tablas que escriben los nombres de forma distinta
#' ("Cañar", "CANAR", "cañar ").
#'
#' @param x Vector de texto.
#' @return Vector de texto normalizado.
#' @export
#' @examples
#' normalizar_nombre(c("Cañar", "  san  José de Chimbo", "CHECA (JIDCAY)"))
normalizar_nombre <- function(x) {
  x <- as.character(x)
  latin <- !is.na(x) & Encoding(x) == "latin1"
  x[latin] <- enc2utf8(x[latin])
  # Se trabaja con puntos de codigo Unicode para que el resultado sea el mismo
  # en cualquier configuracion regional (Windows, macOS, Linux, locale "C").
  con <- c(0xe1, 0xe9, 0xed, 0xf3, 0xfa, 0xfc, 0xf1,
           0xc1, 0xc9, 0xcd, 0xd3, 0xda, 0xdc, 0xd1)
  sin <- utf8ToInt("aeiouunAEIOUUN")
  limpiar <- function(s) {
    if (is.na(s)) return(NA_character_)
    cp <- utf8ToInt(s)
    if (anyNA(cp)) cp <- utf8ToInt(iconv(s, "latin1", "UTF-8"))
    if (anyNA(cp)) return(NA_character_)
    i <- match(cp, con)
    cp[!is.na(i)] <- sin[i[!is.na(i)]]
    cp[cp > 127L] <- 32L
    intToUtf8(cp)
  }
  x <- vapply(x, limpiar, character(1), USE.NAMES = FALSE)
  x <- gsub("[^A-Za-z0-9 ]", " ", x)
  x <- toupper(x)
  x <- gsub(" +", " ", x)
  trimws(x)
}

#' Formatear códigos DPA
#'
#' Devuelve códigos DPA como texto con el número correcto de dígitos,
#' recuperando los ceros a la izquierda que se pierden cuando un código se
#' guarda como número en Excel (por ejemplo, `701` en lugar de `"0701"`).
#'
#' @param x Vector de códigos (número o texto).
#' @param nivel `"provincia"` (2 dígitos), `"canton"` (4) o `"parroquia"` (6).
#' @return Vector de texto. Los valores que no son códigos válidos se
#'   devuelven como `NA` con una advertencia.
#' @export
#' @examples
#' formatear_codigo(c(1, 11, "7"), "provincia")
#' formatear_codigo(c(701, 1101), "canton")
#' formatear_codigo(110150, "parroquia")
formatear_codigo <- function(x, nivel = c("parroquia", "canton", "provincia")) {
  nivel <- match.arg(nivel)
  ancho <- c(provincia = 2L, canton = 4L, parroquia = 6L)[[nivel]]
  original <- x
  x <- trimws(as.character(x))
  x <- sub("\\.0+$", "", x)
  invalido <- !is.na(x) & (!grepl("^[0-9]+$", x) | nchar(x) > ancho)
  x[invalido] <- NA_character_
  ok <- !is.na(x)
  x[ok] <- formatC(as.integer(x[ok]), width = ancho, flag = "0")
  if (any(invalido)) {
    warning(sum(invalido), " valor(es) no son c\u00f3digos de ", .etiqueta(nivel),
            " v\u00e1lidos y se devolvieron como NA: ",
            paste(utils::head(unique(original[invalido]), 5), collapse = ", "),
            call. = FALSE)
  }
  x
}

#' Homologar códigos parroquiales a las unidades del Censo 2022
#'
#' El Censo 2022 y las estimaciones parroquiales de pobecu tratan cada
#' **cabecera cantonal** como una sola unidad (código terminado en `50`), sin
#' separar las parroquias urbanas. En cambio, la cartografía (por ejemplo, el
#' paquete geoecu) y muchos registros administrativos usan códigos de
#' parroquias urbanas (sufijos `01` a `49`, como las 15 parroquias urbanas de
#' Cuenca).
#'
#' Esta función convierte esos códigos al de su cabecera cantonal para poder
#' agregar los datos y unirlos con la población. Los códigos de parroquias
#' rurales (sufijo `51` a `99`) se devuelven sin cambios, salvo los casos
#' especiales documentados abajo.
#'
#' @details Casos especiales:
#' * `220254` (Tiputini, Aguarico): no figura como parroquia rural en el Censo
#'   2022; su población está incluida en la cabecera cantonal `220250`.
#'
#' @param codigo Vector de códigos de parroquia (número o texto).
#' @return Vector de texto con códigos de 6 dígitos.
#' @export
#' @examples
#' # Parroquias urbanas de Cuenca -> cabecera cantonal de Cuenca
#' homologar_parroquia(c("010101", "010115", "010150", "010151"))
#'
#' # Agregar casos por parroquia urbana a la unidad del censo
#' casos <- data.frame(dpa_parroq = c("010101", "010102", "010151"),
#'                     casos = c(3, 5, 1))
#' casos$dpa_parroq <- homologar_parroquia(casos$dpa_parroq)
#' aggregate(casos ~ dpa_parroq, casos, sum)
homologar_parroquia <- function(codigo) {
  x <- formatear_codigo(codigo, "parroquia")
  sufijo <- suppressWarnings(as.integer(substr(x, 5, 6)))
  urbana <- !is.na(sufijo) & sufijo <= 50
  x[urbana] <- paste0(substr(x[urbana], 1, 4), "50")
  especiales <- c("220254" = "220250")
  i <- x %in% names(especiales)
  x[i] <- especiales[x[i]]
  x
}

#' Buscar en el catálogo de pobecu
#'
#' Busca por nombre (sin importar tildes ni mayúsculas) o por código en el
#' catálogo [dpa_pob].
#'
#' @param texto Texto a buscar: parte de un nombre o un código.
#' @param nivel Nivel en el que buscar: `"parroquia"`, `"canton"` o
#'   `"provincia"`.
#' @return Un `data.frame` con las coincidencias en el nivel indicado.
#' @export
#' @examples
#' buscar_pob("arenal")
#' buscar_pob("puyango", nivel = "canton")
#' buscar_pob("11", nivel = "provincia")
buscar_pob <- function(texto, nivel = c("parroquia", "canton", "provincia")) {
  nivel <- match.arg(nivel)
  tabla <- .tabla_nivel(nivel)
  cols <- .columnas_nivel(nivel)
  texto <- as.character(texto)[1]

  if (grepl("^[0-9]+$", trimws(texto))) {
    hit <- startsWith(tabla[[cols$codigo]], trimws(texto))
  } else {
    hit <- grepl(normalizar_nombre(texto), normalizar_nombre(tabla[[cols$nombre]]),
                 fixed = TRUE)
  }
  res <- tabla[hit, , drop = FALSE]
  rownames(res) <- NULL
  res
}

# --- internas ----------------------------------------------------------------

.etiqueta <- function(nivel) {
  c(provincia = "provincia", canton = "cant\u00f3n", parroquia = "parroquia")[[nivel]]
}

.articulo <- function(nivel) {
  c(provincia = "la provincia", canton = "el cant\u00f3n",
    parroquia = "la parroquia")[[nivel]]
}

.columnas_nivel <- function(nivel) {
  switch(nivel,
    provincia = list(codigo = "dpa_provin", nombre = "provincia"),
    canton    = list(codigo = "dpa_canton", nombre = "canton"),
    parroquia = list(codigo = "dpa_parroq", nombre = "parroquia")
  )
}

.tabla_nivel <- function(nivel) {
  catalogo <- pobecu::dpa_pob
  cols <- switch(nivel,
    provincia = c("dpa_provin", "provincia"),
    canton    = c("dpa_canton", "canton", "dpa_provin", "provincia"),
    parroquia = c("dpa_parroq", "parroquia", "tipo", "dpa_canton", "canton",
                  "dpa_provin", "provincia")
  )
  tabla <- unique(catalogo[, cols, drop = FALSE])
  tabla <- tabla[order(tabla[[cols[1]]]), , drop = FALSE]
  rownames(tabla) <- NULL
  tabla
}

# Convierte nombres o codigos a codigos DPA validos del nivel indicado.
# `dentro` restringe la busqueda a ciertas provincias (para cantones).
.resolver_codigos <- function(x, nivel, dentro = NULL) {
  if (is.null(x)) return(NULL)
  tabla <- .tabla_nivel(nivel)
  if (!is.null(dentro)) tabla <- tabla[tabla$dpa_provin %in% dentro, , drop = FALSE]
  cols <- .columnas_nivel(nivel)
  x <- as.character(x)

  codigos <- character(0)
  for (valor in x) {
    if (grepl("^\\s*[0-9]+(\\.0+)?\\s*$", valor)) {
      cod <- suppressWarnings(formatear_codigo(valor, nivel))
      if (is.na(cod) || !cod %in% tabla[[cols$codigo]]) {
        stop("No existe el c\u00f3digo de ", .etiqueta(nivel), " '", valor, "'.",
             call. = FALSE)
      }
    } else {
      hit <- normalizar_nombre(tabla[[cols$nombre]]) == normalizar_nombre(valor)
      cod <- tabla[[cols$codigo]][hit]
      if (length(cod) == 0) {
        cercanos <- unique(tabla[[cols$nombre]][agrep(
          normalizar_nombre(valor), normalizar_nombre(tabla[[cols$nombre]]),
          max.distance = 0.2)])
        stop("No se encontr\u00f3 ", .articulo(nivel), " '", valor, "'.",
             if (length(cercanos)) paste0(" \u00bfQuisiste decir: ",
               paste(utils::head(cercanos, 5), collapse = ", "), "?"),
             call. = FALSE)
      }
      if (length(cod) > 1) {
        opciones <- tabla[hit, , drop = FALSE]
        plural <- c(provincia = "provincias", canton = "cantones",
                    parroquia = "parroquias")[[nivel]]
        stop("El nombre '", valor, "' corresponde a varios/as ", plural, ": ",
             paste0(opciones[[cols$codigo]], " (", opciones$provincia, ")",
                    collapse = ", "),
             ". Usa el c\u00f3digo o filtra tambi\u00e9n por provincia.",
             call. = FALSE)
      }
    }
    codigos <- c(codigos, cod)
  }
  unique(codigos)
}
