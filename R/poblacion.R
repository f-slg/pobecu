#' Población por provincia, cantón o parroquia
#'
#' Consulta la población de un nivel territorial y uno o varios años, con la
#' desagregación que necesites (sexo, área urbana/rural y edad). Es la forma
#' más sencilla de obtener denominadores para tasas, coberturas o
#' indicadores.
#'
#' Las cifras nacionales, provinciales y cantonales son las estimaciones
#' (hasta 2022) y proyecciones (desde 2023) oficiales del INEC, Revisión 2024.
#' Las parroquiales son una estimación de pobecu que reparte la proyección
#' oficial de cada cantón entre sus parroquias (ver [pob_parroquias]); no son
#' cifras oficiales.
#'
#' @param nivel `"canton"` (por defecto), `"provincia"`, `"parroquia"` o
#'   `"nacional"`.
#' @param anio Años a consultar. `NULL` (por defecto) devuelve todos los
#'   disponibles: 1950-2050 (nacional), 1990-2035 (provincial) y 2010-2035
#'   (cantonal y parroquial). Las cifras se refieren al 30 de junio de cada año.
#' @param provincia Provincias a incluir, por nombre (sin importar tildes ni
#'   mayúsculas) o código: `"Loja"`, `"11"` o `11`. `NULL` incluye todo el país.
#' @param canton Cantones a incluir (niveles `"canton"` y `"parroquia"`), por
#'   nombre o código. Si un nombre se repite en varias provincias (por
#'   ejemplo, Bolívar u Olmedo), usa el código o indica también `provincia`.
#' @param sexo Si es `TRUE`, desagrega por sexo al nacer (`"hombre"`,
#'   `"mujer"`).
#' @param area Si es `TRUE`, desagrega por área de residencia (`"urbana"`,
#'   `"rural"`). Solo para los niveles nacional, provincial y cantonal, y para
#'   los años 2010-2035.
#' @param edad Desagregación por edad:
#'   * `NULL` (por defecto): sin desagregar.
#'   * `"quinquenal"`: grupos de 5 años (`"0-4"`, ..., `"100+"`; en el nivel
#'     parroquial el último grupo es `"85+"`).
#'   * `"simple"`: años cumplidos, de 0 a 100 (100 = 100 y más).
#'   * `"etapas"`: etapas de vida del INEC (0-11, 12-17, 18-29, 30-64, 65+).
#'   * Un vector numérico con las edades de inicio de cada grupo, por ejemplo
#'     `c(0, 1, 5, 15, 65)` para 0, 1-4, 5-14, 15-64 y 65+.
#'
#'   Los grupos quinquenales (y los cortes múltiplos de 5) vienen dentro del
#'   paquete. Las edades simples, las etapas y los demás cortes usan datos que
#'   se descargan la primera vez (ver [pobecu_datos_disponibles()]) y no
#'   están disponibles para parroquias.
#'
#' @return Un `data.frame` con los códigos y nombres del nivel (`dpa_provin`,
#'   `provincia`, `dpa_canton`, `canton`, `dpa_parroq`, `parroquia`, según
#'   corresponda), `anio`, las columnas de desagregación pedidas (`sexo`,
#'   `area`, `edad`) y `poblacion`.
#'
#' @seealso [pob_unir()] y [pob_tasa()] para unir la población con tus datos.
#' @export
#' @examples
#' # Población total de las provincias en 2025
#' poblacion("provincia", anio = 2025)
#'
#' # Cantones de Loja por sexo, 2024 a 2026
#' poblacion("canton", anio = 2024:2026, provincia = "Loja", sexo = TRUE)
#'
#' # Menores de 5 años y de 65 y más, por cantón urbano/rural
#' poblacion("canton", anio = 2025, provincia = "Azuay", area = TRUE,
#'           edad = c(0, 5, 65))
#'
#' # Parroquias de un cantón por grupos quinquenales (estimación pobecu)
#' poblacion("parroquia", anio = 2030, canton = "Puyango", edad = "quinquenal")
#'
#' # Serie nacional 1950-2050
#' nac <- poblacion("nacional")
#' plot(nac$anio, nac$poblacion / 1e6, type = "l",
#'      xlab = "Año", ylab = "Millones de habitantes")
#'
#' @examplesIf pobecu_datos_disponibles()
#' # Edades simples (se descargan la primera vez)
#' poblacion("provincia", anio = 2025, provincia = "Pichincha", edad = "simple")
poblacion <- function(nivel = c("canton", "provincia", "parroquia", "nacional"),
                      anio = NULL, provincia = NULL, canton = NULL,
                      sexo = FALSE, area = FALSE, edad = NULL) {
  nivel <- match.arg(nivel)
  anio <- .validar_anio(anio, nivel)
  stopifnot(is.logical(sexo), length(sexo) == 1, is.logical(area), length(area) == 1)

  if (nivel == "nacional" && (!is.null(provincia) || !is.null(canton))) {
    stop("El nivel nacional no admite filtros por provincia o cant\u00f3n.", call. = FALSE)
  }
  if (nivel == "provincia" && !is.null(canton)) {
    stop("Para filtrar por cant\u00f3n usa nivel = \"canton\" o \"parroquia\".", call. = FALSE)
  }
  if (area) {
    if (nivel == "parroquia") {
      stop("No hay desagregaci\u00f3n urbana/rural para parroquias. ",
           "La cabecera cantonal (c\u00f3digo XX50) concentra el \u00e1rea urbana.",
           call. = FALSE)
    }
    fuera <- setdiff(anio, .pobecu_anios_area)
    if (length(fuera)) {
      stop("La desagregaci\u00f3n por \u00e1rea solo existe para 2010-2035. ",
           "A\u00f1os fuera de ese rango: ", .rango_texto(fuera), ".", call. = FALSE)
    }
  }
  cod_prov <- .resolver_codigos(provincia, "provincia")
  cod_cant <- .resolver_codigos(canton, "canton", dentro = cod_prov)

  modo <- .modo_edad(edad, nivel)
  d <- if (modo$fuente == "simple") .tabla_simple(nivel) else .tabla_quinquenal(nivel)

  # Filtros
  d <- d[d$anio %in% anio, , drop = FALSE]
  if (!is.null(cod_prov)) d <- d[substr(d$codigo, 1, 2) %in% cod_prov, , drop = FALSE]
  if (!is.null(cod_cant)) d <- d[substr(d$codigo, 1, 4) %in% cod_cant, , drop = FALSE]

  # Edad
  if (!is.null(modo$cortes)) {
    i <- findInterval(d$edad_inicio, modo$cortes)
    d$edad <- factor(modo$etiquetas[i], levels = modo$etiquetas)
  } else if (modo$tipo == "simple") {
    d$edad <- d$edad_inicio
  } else if (modo$tipo == "quinquenal") {
    d$edad <- d$grupo_edad
  }

  por <- c("codigo", "anio", if (sexo) "sexo", if (area) "area",
           if (modo$tipo != "ninguna") "edad")
  res <- .agregar(d, por)
  res <- res[do.call(order, unname(as.list(res[por]))), , drop = FALSE]
  for (v in intersect(c("sexo", "area"), names(res))) res[[v]] <- as.character(res[[v]])

  res <- .agregar_nombres(res, nivel)
  rownames(res) <- NULL
  if (nivel == "parroquia") .aviso_parroquia()
  res
}

# --- internas ----------------------------------------------------------------

.validar_anio <- function(anio, nivel) {
  disponibles <- .pobecu_anios[[nivel]]
  if (is.null(anio)) return(disponibles)
  if (!is.numeric(anio) || anyNA(anio) || any(anio %% 1 != 0)) {
    stop("`anio` debe ser un vector de a\u00f1os enteros.", call. = FALSE)
  }
  anio <- unique(as.integer(anio))
  fuera <- setdiff(anio, disponibles)
  if (length(fuera)) {
    stop("A\u00f1os no disponibles para el nivel ", nivel, ": ", .rango_texto(fuera),
         ". Disponibles: ", min(disponibles), "-", max(disponibles), ".", call. = FALSE)
  }
  anio
}

.rango_texto <- function(x) {
  x <- sort(x)
  if (length(x) > 3 && all(diff(x) == 1)) paste0(x[1], "-", x[length(x)])
  else paste(x, collapse = ", ")
}

# Decide de donde salen las edades y como se agrupan
.modo_edad <- function(edad, nivel) {
  if (is.null(edad)) return(list(tipo = "ninguna", fuente = "quinquenal"))
  if (is.character(edad)) {
    edad <- match.arg(edad, c("quinquenal", "simple", "etapas"))
    if (edad == "quinquenal") return(list(tipo = "quinquenal", fuente = "quinquenal"))
    if (edad == "simple") {
      .exigir_simple(nivel)
      return(list(tipo = "simple", fuente = "simple"))
    }
    edad <- .pobecu_etapas
  }
  if (!is.numeric(edad) || anyNA(edad) || any(edad < 0) || any(edad %% 1 != 0)) {
    stop("`edad` debe ser NULL, \"quinquenal\", \"simple\", \"etapas\" o un vector ",
         "de edades enteras de inicio de cada grupo.", call. = FALSE)
  }
  cortes <- sort(unique(c(0, as.integer(edad))))
  max_edad <- if (nivel == "parroquia") 85L else 100L
  if (any(cortes > max_edad)) {
    stop("Los cortes de edad no pueden superar ", max_edad, " en el nivel ", nivel, ".",
         call. = FALSE)
  }
  fuente <- if (all(cortes %% 5 == 0)) "quinquenal" else "simple"
  if (fuente == "simple") .exigir_simple(nivel)
  list(tipo = "cortes", fuente = fuente, cortes = cortes,
       etiquetas = .etiquetas_edad(cortes))
}

.exigir_simple <- function(nivel) {
  if (nivel == "parroquia") {
    stop("En el nivel parroquial solo hay grupos quinquenales (hasta 85+). ",
         "Usa edad = \"quinquenal\" o cortes m\u00faltiplos de 5.", call. = FALSE)
  }
}

.etiquetas_edad <- function(cortes) {
  fin <- c(cortes[-1] - 1L, NA)
  et <- ifelse(is.na(fin), paste0(cortes, "+"),
               ifelse(fin == cortes, as.character(cortes), paste0(cortes, "-", fin)))
  et
}

# Tablas internas en formato comun:
# codigo (texto), anio, area, sexo, edad_inicio, [grupo_edad], poblacion
.tabla_quinquenal <- function(nivel) {
  d <- switch(nivel,
    nacional  = pobecu::pob_nacional,
    provincia = pobecu::pob_provincias,
    canton    = pobecu::pob_cantones,
    parroquia = pobecu::pob_parroquias
  )
  col <- switch(nivel, nacional = NULL, provincia = "dpa_provin",
                canton = "dpa_canton", parroquia = "dpa_parroq")
  d$codigo <- if (is.null(col)) rep("00", nrow(d)) else as.character(d[[col]])
  d$edad_inicio <- as.integer(sub("[-+].*$", "", as.character(d$grupo_edad)))
  d
}

.tabla_simple <- function(nivel) {
  s <- .datos_simple()
  d <- s[s$nivel == nivel, , drop = FALSE]
  d$codigo <- as.character(d$codigo)
  d$edad_inicio <- d$edad
  d
}

# Suma `poblacion` por las columnas indicadas, conservando el orden y el tipo
.agregar <- function(d, por) {
  clave <- do.call(paste, c(unname(as.list(d[por])), sep = "\r"))
  suma <- rowsum(as.numeric(d$poblacion), clave, reorder = FALSE)
  res <- d[!duplicated(clave), por, drop = FALSE]
  res$poblacion <- as.integer(round(suma[, 1]))
  res
}

.agregar_nombres <- function(res, nivel) {
  if (nivel == "nacional") {
    res$codigo <- NULL
    return(res)
  }
  tabla <- .tabla_nivel(nivel)
  cols <- .columnas_nivel(nivel)
  tabla$tipo <- NULL
  i <- match(res$codigo, tabla[[cols$codigo]])
  res$codigo <- NULL
  cbind(tabla[i, , drop = FALSE], res)
}

.aviso_parroquia <- function() {
  if (isTRUE(.pobecu_env$aviso_parroquia)) return(invisible())
  .pobecu_env$aviso_parroquia <- TRUE
  message("Nota: las cifras parroquiales son una estimaci\u00f3n de pobecu a partir de ",
          "las proyecciones cantonales del INEC; no son cifras oficiales. ",
          "Ver ?pob_parroquias. (Este aviso se muestra una vez por sesi\u00f3n.)")
}
