#' Mapa con población: capas de geoecu unidas a pobecu
#'
#' Devuelve la capa geográfica del nivel indicado (del paquete
#' [geoecu](https://github.com/f-slg/geoecu)) con la población de pobecu ya
#' unida, lista para mapear. Ambos paquetes usan los códigos DPA, así que no
#' hace falta preparar nada.
#'
#' Las cifras de población usan las unidades del Censo 2022, y geoecu (desde
#' la versión 0.4.0) la Organización Territorial del Estado del CONALI
#' (2026). Para que cada cifra se dibuje sobre el territorio al que
#' corresponde, la capa se convierte primero a las unidades del censo con
#' [agrupar_unidades()]: por ejemplo, el cantón Borbón se dibuja dentro de
#' Eloy Alfaro y la parroquia Sosote dentro de Rocafuerte. Con geoecu 0.3.0
#' y anteriores, las parroquias urbanas se fusionan en su cabecera cantonal.
#'
#' Las zonas en estudio de geoecu (territorios con límites aún no resueltos)
#' se conservan para que el mapa no tenga huecos, con población `NA` en cada
#' año y desagregación.
#'
#' @inheritParams poblacion
#' @param nivel `"canton"` (por defecto), `"provincia"` o `"parroquia"`.
#' @param anio Año o años. Por defecto, el año en curso si está disponible;
#'   si no, el último año disponible.
#' @param resolucion,crs Resolución y sistema de coordenadas de la capa, como
#'   en `geoecu::read_cantones()`.
#' @return Un objeto `sf` con las columnas de [agrupar_unidades()], las de
#'   [poblacion()] (`anio`, `poblacion` y las desagregaciones pedidas) y
#'   `densidad` (habitantes por km²). Con varios años o desagregaciones, cada
#'   polígono se repite una vez por combinación (útil para `facet_wrap()`).
#' @seealso [agrupar_unidades()], [pob_tasa()].
#' @export
#' @examplesIf requireNamespace("geoecu", quietly = TRUE) && geoecu::geoecu_datos_disponibles()
#' m <- pob_mapa("canton", anio = 2025, provincia = "Loja")
#' plot(m["densidad"], logz = TRUE)
#'
#' # Parroquias de Cuenca
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

  pob <- poblacion(nivel, anio = anio, provincia = provincia, canton = canton,
                   sexo = sexo, area = area, edad = edad)
  # Los filtros se resuelven con el catalogo de pobecu (unidades del censo) y
  # la capa se lee por provincia: un canton del censo puede tener partes que
  # en geoecu son otro canton
  cod_prov <- .resolver_codigos(provincia, "provincia")
  cod_cant <- suppressMessages(.resolver_codigos(canton, "canton", dentro = cod_prov))
  if (!is.null(cod_cant)) cod_prov <- unique(substr(cod_cant, 1, 2))

  capa <- switch(nivel,
    provincia = geoecu::read_provincias(provincia = cod_prov, resolucion = resolucion,
                                        crs = crs),
    canton    = agrupar_unidades(geoecu::read_cantones(
      provincia = cod_prov, resolucion = resolucion, crs = crs)),
    parroquia = agrupar_unidades(geoecu::read_parroquias(
      provincia = cod_prov, resolucion = resolucion, crs = crs))
  )
  if (!is.null(cod_cant)) capa <- capa[capa$dpa_canton %in% cod_cant, ]

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
  # Las unidades sin poblacion (zonas en estudio) se repiten en cada
  # combinacion de anio y desagregacion, para que filtrar o usar
  # facet_wrap() no las pierda
  combos <- unique(pob[, setdiff(names(pob), c(clave, "poblacion")), drop = FALSE])
  sin <- is.na(res$anio)
  if (any(sin)) {
    vacias <- res[rep(which(sin), each = nrow(combos)), ]
    for (v in names(combos)) vacias[[v]] <- rep(combos[[v]], times = sum(sin))
    res <- rbind(res[!sin, ], vacias)
  }
  if (!"area_km2" %in% names(res)) {
    stop("Se requiere geoecu 0.4.1 o posterior, que incluye `area_km2`. ",
         "Actualízalo con install.packages(\"geoecu\") o remotes::install_github(\"f-slg/geoecu\").",
         call. = FALSE)
  }
  res$densidad <- res$poblacion / res$area_km2
  orden <- intersect(c(clave, "anio", "sexo", "area", "edad"), names(res))
  res <- res[do.call(order, unname(lapply(orden, function(v) res[[v]]))), ]
  rownames(res) <- NULL
  sf::st_as_sf(res)
}

#' Convertir una capa de geoecu a las unidades del Censo 2022
#'
#' Fusiona los polígonos de una capa de cantones o parroquias (por ejemplo,
#' `geoecu::read_cantones()` o `geoecu::read_parroquias()`) en las unidades
#' del Censo 2022 que usa pobecu, para unirla con la población sin perder ni
#' repetir territorio. Los códigos se convierten con [homologar_canton()] o
#' [homologar_parroquia()] y los polígonos con el mismo código se unen:
#'
#' * Con geoecu 0.4.0 y posteriores (CONALI 2026): los cantones Borbón y
#'   Sevilla Don Bosco vuelven a Eloy Alfaro y Morona, y las parroquias
#'   creadas después del censo (Sosote, Shuar Pastaza, Juan Montalvo, La
#'   Magdalena, La Primavera y Miss Ecuador) se unen a la parroquia censal
#'   que las contenía.
#' * Con geoecu 0.3.0 y anteriores: las parroquias urbanas de cada cantón se
#'   unen en su cabecera cantonal (por ejemplo, las 15 de Cuenca).
#'
#' Las unidades que no existen en pobecu, como las zonas en estudio, se
#' conservan con sus datos originales. `agrupar_cabeceras()` es el nombre
#' anterior de esta función y se mantiene por compatibilidad.
#'
#' @param capa Un objeto `sf` con una columna `dpa_parroq` (parroquias) o
#'   `dpa_canton` (cantones). Si existen, se usan también `tipo` y `area_km2`.
#' @return Un objeto `sf` con una fila por unidad del censo: el código, los
#'   nombres de pobecu (de la parroquia, el cantón y la provincia, según el
#'   nivel), `tipo` (`"cabecera cantonal"` o `"parroquia rural"` en el nivel
#'   parroquial; el de la capa en el cantonal), `area_km2` (suma) y la
#'   geometría.
#' @export
#' @examplesIf requireNamespace("geoecu", quietly = TRUE) && geoecu::geoecu_datos_disponibles()
#' esmeraldas <- geoecu::read_cantones(provincia = "Esmeraldas")
#' nrow(esmeraldas)                    # con Borbón
#' nrow(agrupar_unidades(esmeraldas))  # Borbón dentro de Eloy Alfaro
agrupar_unidades <- function(capa) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Se necesita el paquete 'sf': install.packages(\"sf\").", call. = FALSE)
  }
  nivel <- if (inherits(capa, "sf") && "dpa_parroq" %in% names(capa)) "parroquia"
           else if (inherits(capa, "sf") && "dpa_canton" %in% names(capa)) "canton"
  if (is.null(nivel)) {
    stop("`capa` debe ser un objeto sf con una columna `dpa_parroq` o `dpa_canton`.",
         call. = FALSE)
  }
  cols <- .columnas_nivel(nivel)
  homologar <- if (nivel == "parroquia") homologar_parroquia else homologar_canton
  grupos <- split(seq_len(nrow(capa)), homologar(capa[[cols$codigo]]))
  primera <- vapply(grupos, `[`, integer(1), 1L)

  geom <- sf::st_geometry(capa)
  datos <- sf::st_drop_geometry(capa)
  geoms <- lapply(grupos, function(i) {
    if (length(i) == 1) geom[[i]] else sf::st_union(geom[i])[[1]]
  })

  # Nombres de pobecu; las unidades que no estan en pobecu conservan los de la capa
  catalogo <- .tabla_nivel(nivel)
  res <- data.frame(codigo = names(grupos), stringsAsFactors = FALSE)
  names(res) <- cols$codigo
  i <- match(res[[cols$codigo]], catalogo[[cols$codigo]])
  for (v in setdiff(intersect(names(catalogo), c(names(datos), "tipo")), cols$codigo)) {
    res[[v]] <- catalogo[[v]][i]
    sin <- is.na(i)
    if (any(sin) && v %in% names(datos)) res[[v]][sin] <- as.character(datos[[v]][primera[sin]])
  }
  if (nivel == "canton" && "tipo" %in% names(datos)) {
    res$tipo <- as.character(datos$tipo[primera])
  }
  if ("area_km2" %in% names(datos)) {
    res$area_km2 <- vapply(grupos, function(i) sum(datos$area_km2[i]), numeric(1),
                           USE.NAMES = FALSE)
  }

  orden <- c(cols$codigo, cols$nombre, "tipo",
             "dpa_canton", "canton", "dpa_provin", "provincia", "area_km2")
  res <- res[, intersect(orden, names(res)), drop = FALSE]
  res <- sf::st_sf(res, geometry = sf::st_sfc(unname(geoms), crs = sf::st_crs(capa)))
  rownames(res) <- NULL
  res
}

#' @rdname agrupar_unidades
#' @export
agrupar_cabeceras <- function(capa) {
  agrupar_unidades(capa)
}

.exigir_geoecu <- function() {
  if (!requireNamespace("geoecu", quietly = TRUE)) {
    stop("pob_mapa() usa las capas del paquete geoecu. Inst\u00e1lalo con ",
         "install.packages(\"geoecu\") o remotes::install_github(\"f-slg/geoecu\").",
         call. = FALSE)
  }
}
