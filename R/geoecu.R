#' Mapa con población: capas de geoecu unidas a pobecu
#'
#' Devuelve la capa geográfica del nivel indicado (del paquete
#' [geoecu](https://github.com/f-slg/geoecu)) con la población de pobecu ya
#' unida, lista para mapear. Ambos paquetes usan los mismos códigos DPA, así
#' que no hace falta preparar nada.
#'
#' En el nivel parroquial las parroquias urbanas de geoecu se fusionan en su
#' cabecera cantonal con [agrupar_cabeceras()], porque esa es la unidad del
#' Censo 2022 y de la estimación parroquial.
#'
#' @inheritParams poblacion
#' @param nivel `"canton"` (por defecto), `"provincia"` o `"parroquia"`.
#' @param anio Año o años. Por defecto, el año en curso si está disponible;
#'   si no, el último año disponible.
#' @param resolucion,crs Resolución y sistema de coordenadas de la capa, como
#'   en `geoecu::read_cantones()`.
#' @return Un objeto `sf` con las columnas de la capa, las de [poblacion()]
#'   (`anio`, `poblacion` y las desagregaciones pedidas) y `densidad`
#'   (habitantes por km²). Con varios años o desagregaciones, cada polígono
#'   se repite una vez por combinación (útil para `facet_wrap()`).
#' @seealso [agrupar_cabeceras()], [pob_tasa()].
#' @export
#' @examplesIf requireNamespace("geoecu", quietly = TRUE) && geoecu::geoecu_datos_disponibles()
#' m <- pob_mapa("canton", anio = 2025, provincia = "Loja")
#' plot(m["densidad"], logz = TRUE)
#'
#' # Parroquias de Cuenca: las 15 urbanas se fusionan en la cabecera
#' pob_mapa("parroquia", anio = 2030, canton = "Cuenca")
pob_mapa <- function(nivel = c("canton", "provincia", "parroquia"), anio = NULL,
                     provincia = NULL, canton = NULL, sexo = FALSE, area = FALSE,
                     edad = NULL, resolucion = c("baja", "alta"), crs = 4326) {
  .exigir_geoecu()
  nivel <- match.arg(nivel)
  resolucion <- match.arg(resolucion)
  if (is.null(anio)) {
    actual <- as.integer(format(Sys.Date(), "%Y"))
    disp <- .pobecu_anios[[nivel]]
    anio <- if (actual %in% disp) actual else max(disp)
  }

  capa <- switch(nivel,
    provincia = geoecu::read_provincias(provincia = provincia, resolucion = resolucion,
                                        crs = crs),
    canton    = geoecu::read_cantones(provincia = provincia, canton = canton,
                                      resolucion = resolucion, crs = crs),
    parroquia = agrupar_cabeceras(
      geoecu::read_parroquias(provincia = provincia, canton = canton,
                              resolucion = resolucion, crs = crs))
  )
  pob <- poblacion(nivel, anio = anio, provincia = provincia, canton = canton,
                   sexo = sexo, area = area, edad = edad)

  clave <- .columnas_nivel(nivel)$codigo
  # Los nombres vienen de la capa; de pobecu solo se toman los datos
  pob <- pob[, setdiff(names(pob), setdiff(names(capa), clave)), drop = FALSE]

  sin_geo <- setdiff(unique(pob[[clave]]), capa[[clave]])
  if (length(sin_geo)) {
    nombres <- .tabla_nivel(nivel)
    nombres <- nombres[nombres[[clave]] %in% sin_geo, , drop = FALSE]
    warning(length(sin_geo), " unidad(es) de pobecu sin pol\u00edgono en geoecu: ",
            paste0(nombres[[clave]], " (", nombres[[.columnas_nivel(nivel)$nombre]], ")",
                   collapse = ", "), call. = FALSE)
  }

  res <- merge(capa, pob, by = clave, all.x = TRUE, sort = FALSE)
  res$densidad <- res$poblacion / res$area_km2
  orden <- intersect(c(clave, "anio", "sexo", "area", "edad"), names(res))
  res <- res[do.call(order, unname(lapply(orden, function(v) res[[v]]))), ]
  rownames(res) <- NULL
  sf::st_as_sf(res)
}

#' Fusionar parroquias urbanas en su cabecera cantonal
#'
#' Convierte una capa de parroquias con códigos DPA de parroquias urbanas
#' (por ejemplo, `geoecu::read_parroquias()`) en las unidades del Censo 2022
#' que usa pobecu: las parroquias urbanas de cada cantón se unen en un solo
#' polígono con el código de la cabecera cantonal (sufijo `50`), y las
#' rurales se conservan. Los códigos se convierten con
#' [homologar_parroquia()].
#'
#' @param capa Un objeto `sf` con una columna `dpa_parroq` (y, si existen,
#'   `dpa_canton`, `canton`, `dpa_provin`, `provincia` y `area_km2`).
#' @return Un objeto `sf` con una fila por unidad censal: `dpa_parroq`,
#'   `parroquia` (nombre del Censo 2022), `tipo` (`"cabecera"` o `"rural"`),
#'   las columnas de cantón y provincia de la capa, `area_km2` (suma) y la
#'   geometría.
#' @export
#' @examplesIf requireNamespace("geoecu", quietly = TRUE) && geoecu::geoecu_datos_disponibles()
#' cuenca <- geoecu::read_parroquias(canton = "Cuenca")
#' nrow(cuenca)                      # 15 urbanas + 21 rurales
#' nrow(agrupar_cabeceras(cuenca))   # 1 cabecera + 21 rurales
agrupar_cabeceras <- function(capa) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Se necesita el paquete 'sf': install.packages(\"sf\").", call. = FALSE)
  }
  if (!inherits(capa, "sf") || !"dpa_parroq" %in% names(capa)) {
    stop("`capa` debe ser un objeto sf con una columna `dpa_parroq`.", call. = FALSE)
  }
  capa$dpa_parroq <- homologar_parroquia(capa$dpa_parroq)
  grupos <- split(seq_len(nrow(capa)), capa$dpa_parroq)

  atributos <- intersect(c("dpa_canton", "canton", "dpa_provin", "provincia"), names(capa))
  geom <- sf::st_geometry(capa)
  datos <- sf::st_drop_geometry(capa)

  filas <- lapply(names(grupos), function(cod) {
    i <- grupos[[cod]]
    d <- datos[i[1], atributos, drop = FALSE]
    d$dpa_parroq <- cod
    if ("area_km2" %in% names(datos)) d$area_km2 <- sum(datos$area_km2[i])
    d
  })
  res <- do.call(rbind, filas)
  geoms <- lapply(names(grupos), function(cod) {
    i <- grupos[[cod]]
    if (length(i) == 1) geom[[i]] else sf::st_union(geom[i])[[1]]
  })
  res <- sf::st_sf(res, geometry = sf::st_sfc(geoms, crs = sf::st_crs(capa)))

  cat <- pobecu::dpa_pob
  i <- match(res$dpa_parroq, cat$dpa_parroq)
  res$parroquia <- cat$parroquia[i]
  res$tipo <- cat$tipo[i]
  sin <- is.na(i)
  if (any(sin)) {
    res$parroquia[sin] <- as.character(datos$parroquia[match(res$dpa_parroq[sin],
                                                             homologar_parroquia(datos$dpa_parroq))])
    res$tipo[sin] <- ifelse(substr(res$dpa_parroq[sin], 5, 6) == "50", "cabecera", "rural")
  }

  cols <- c("dpa_parroq", "parroquia", "tipo", atributos,
            if ("area_km2" %in% names(res)) "area_km2")
  res <- res[order(res$dpa_parroq), cols]
  rownames(res) <- NULL
  res
}

.exigir_geoecu <- function() {
  if (!requireNamespace("geoecu", quietly = TRUE)) {
    stop("pob_mapa() usa las capas del paquete geoecu. Inst\u00e1lalo con ",
         "install.packages(\"geoecu\") o remotes::install_github(\"f-slg/geoecu\").",
         call. = FALSE)
  }
}
