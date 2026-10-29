#' Ajustar un modelo territorial de población para 1900-2100
#'
#' Ajusta tendencias locales lineales mediante máxima verosimilitud y filtro
#' de Kalman: logaritmo del total nacional y coordenadas log-ratio centradas
#' de las participaciones de cada territorio en su padre. La extrapolación
#' amortigua la pendiente y la distribución descendente conserva los totales.
#' @param entrenamiento Años de las tablas publicados que se pueden utilizar.
#'   NULL usa todos. Deben quedar al menos ocho años consecutivos por nivel.
#' @param ventana Máximo de años utilizados en cada extremo, al menos ocho.
#' @param phi_total Amortiguación anual de la pendiente nacional, en (0,1].
#' @param phi_partes Amortiguación de las participaciones, en (0,1].
#' @return Objeto `pob_modelo` con datos de referencia, modelos en ambos
#'   sentidos temporales, parámetros y tabla `diagnosticos` de cada ajuste.
#' @details Se incluyen proyecciones publicadas en el entrenamiento por defecto.
#'   Se condiciona a esas trayectorias; no se ajustan fecundidad, mortalidad ni
#'   migración por cohortes. Las unidades son las de referencia del Censo 2022,
#'   incluso para años en los que no existían administrativamente. La
#'   retrospectiva ajusta el modelo a la serie invertida: no es un suavizador
#'   histórico ni evidencia censal del siglo XX. Consulte la metodología del
#'   README antes de interpretar horizontes lejanos.
#' @export
#' @examples
#' \donttest{
#' modelo <- pob_ajustar()
#' head(modelo$diagnosticos)
#' }
pob_ajustar <- function(entrenamiento = NULL, ventana = 20,
                        phi_total = 0.98, phi_partes = 0.95) {
  if (!is.null(entrenamiento)) entrenamiento <- .anios_modelo(entrenamiento)
  .escalar_modelo(ventana, 8, 201, "ventana", entero = TRUE)
  .escalar_modelo(phi_total, 0, 1, "phi_total", abierto = TRUE)
  .escalar_modelo(phi_partes, 0, 1, "phi_partes", abierto = TRUE)
  niveles <- c("nacional", "provincia", "canton", "parroquia")
  tablas <- stats::setNames(lapply(niveles, function(n) {
    d <- poblacion(n)
    if (!is.null(entrenamiento)) d <- d[d$anio %in% entrenamiento, , drop = FALSE]
    d
  }), niveles)
  .ajustar_jerarquia(tablas, ventana, phi_total, phi_partes)
}

#' Reconstruir y proyectar población territorial entre 1900 y 2100
#'
#' Extiende las trayectorias con un modelo estructural y composicional
#' jerárquico. Conserva exactamente las referencias utilizadas por el modelo.
#' @param nivel Nivel territorial o `"todos"` para la jerarquía completa.
#' @param anio Años enteros entre 1900 y 2100; por defecto todo el periodo.
#' @param modelo Resultado de [pob_ajustar()]. NULL ajusta un modelo nuevo.
#' @param provincia Filtro provincial por nombre o código.
#' @param canton Filtro cantonal por nombre o código, solo cantones/parroquias.
#' @param simulaciones Número de trayectorias Monte Carlo, de 100 a 10000.
#' @param semilla Semilla local reproducible; se restaura el estado aleatorio.
#' @param nivel_intervalo Cobertura nominal de bandas condicionales (0,1).
#' @return Tabla con códigos, nombres, población entera, origen, dirección,
#'   horizonte, referencia temporal y bandas marginales. El atributo
#'   `metodologia` registra parámetros y supuestos. Los cuantiles marginales
#'   no se suman. La trayectoria central sí suma exactamente a sus padres.
#' @details Las bandas simulan innovaciones gaussianas con varianzas estimadas,
#'   condicionadas a los estados finales y parámetros ajustados. No incluyen
#'   incertidumbre de parámetros, censos, límites ni modelos fuente. En años
#'   de referencia las bandas son NA. Los resultados extrapolados no son
#'   cifras oficiales. No se modifican las tablas consultadas por [poblacion()].
#'   La amortiguación es una hipótesis de escenario aplicada al extrapolar,
#'   no un parámetro estimado por máxima verosimilitud. No hay desagregación
#'   por sexo, edad o residencia en este modelo de totales territoriales.
#' @export
#' @examples
#' \donttest{
#' m <- pob_ajustar()
#' p <- pob_estimar("parroquia", c(1900, 2022, 2100), m, canton = "Loja")
#' p[c("nombre", "anio", "poblacion", "origen", "horizonte")]
#' }
pob_estimar <- function(nivel = c("provincia", "canton", "parroquia", "nacional", "todos"),
                        anio = 1900:2100, modelo = NULL, provincia = NULL,
                        canton = NULL, simulaciones = 500, semilla = 2026,
                        nivel_intervalo = 0.95) {
  nivel <- match.arg(nivel)
  anio <- .anios_modelo(anio)
  if (any(anio < 1900 | anio > 2100)) stop("El rango admitido es 1900-2100.", call. = FALSE)
  .escalar_modelo(simulaciones, 100, 10000, "simulaciones", entero = TRUE)
  .escalar_modelo(semilla, 0, .Machine$integer.max, "semilla", entero = TRUE)
  .escalar_modelo(nivel_intervalo, 0, 1, "nivel_intervalo", abierto = TRUE)
  if (nivel_intervalo == 1) stop("`nivel_intervalo` debe ser menor que 1.", call. = FALSE)
  if (nivel %in% c("nacional", "todos") && (!is.null(provincia) || !is.null(canton)))
    stop("Los filtros requieren un nivel territorial espec\u00edfico.", call. = FALSE)
  if (nivel == "provincia" && !is.null(canton)) stop("Use nivel canton o parroquia.", call. = FALSE)
  cp <- .resolver_codigos(provincia, "provincia")
  cc <- .resolver_codigos(canton, "canton", dentro = cp)
  if (is.null(modelo)) modelo <- pob_ajustar()
  if (!inherits(modelo, "pob_modelo")) stop("`modelo` debe proceder de pob_ajustar().", call. = FALSE)
  tenia <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (tenia) anterior <- get(".Random.seed", envir = .GlobalEnv)
  on.exit(if (tenia) assign(".Random.seed", anterior, envir = .GlobalEnv)
          else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
            rm(".Random.seed", envir = .GlobalEnv), add = TRUE)
  set.seed(semilla)
  # Siempre se simula el mismo árbol y rango continuo; pedir menos años o
  # filtrar no altera una trayectoria para semilla y configuración iguales.
  anos <- 1900:2100
  salidas <- list()
  # Solo se resumen los territorios y años pedidos; la simulación del árbol
  # completo no cambia, así que los resultados son los mismos.
  necesita <- function(nodo) (nivel == "todos" || nodo$nivel == nivel) &&
    (is.null(cp) || substr(nodo$codigo, 1, 2) %in% cp) &&
    (is.null(cc) || substr(nodo$codigo, 1, 4) %in% cc)
  guardar <- function(nodo, punto, draws, rango) {
    if (!necesita(nodo)) return(invisible(NULL))
    conocido <- anos >= min(rango) & anos <= max(rango)
    q <- matrix(NA_real_, length(anos), 2)
    filas <- which(!conocido & anos %in% anio)
    if (length(filas)) q[filas, ] <- .cuantiles_filas(draws[filas, , drop = FALSE],
      c((1-nivel_intervalo)/2, (1+nivel_intervalo)/2))
    h <- pmax(min(rango) - anos, anos - max(rango), 0)
    d <- data.frame(nivel = nodo$nivel, codigo = nodo$codigo, nombre = nodo$nombre,
      padre = nodo$padre, anio = anos, poblacion = punto,
      limite_inferior = q[, 1], limite_superior = q[, 2],
      origen = ifelse(conocido, if (nodo$nivel == "parroquia") "referencia_parroquial_pobecu" else "referencia_INEC",
                      "modelo_pobecu"),
      direccion = ifelse(conocido, "referencia", ifelse(anos < min(rango), "retrospectiva", "prospectiva")),
      horizonte = h, extrapolacion_extrema = h > 30,
      referencia_desde = min(rango), referencia_hasta = max(rango),
      modelo = ifelse(conocido, "sin_modificar", "estructural_CLR_amortiguado_v1"),
      tipo_intervalo = ifelse(conocido, "no_disponible", "simulacion_condicional"),
      nivel_intervalo = ifelse(conocido, NA_real_, nivel_intervalo),
      unidad_territorial = "referencia_Censo_2022")
    salidas[[nodo$codigo]] <<- d[d$anio %in% anio, , drop = FALSE]
  }
  raiz <- modelo$raiz
  z <- .extender_estado(raiz, anos, simulaciones, modelo$phi_total)
  punto <- round(exp(z$punto)); draws <- exp(z$draws)
  if (any(!is.finite(draws)) || any(!is.finite(punto)) || any(punto > 2^53))
    stop("Extrapolaci\u00f3n nacional no representable; revise ajustes y amortiguaci\u00f3n.", call. = FALSE)
  conocido <- match(anos, raiz$anios); ok <- !is.na(conocido)
  punto[ok] <- raiz$conteos[conocido[ok]]
  draws[ok, ] <- punto[ok]
  guardar(list(nivel = "nacional", codigo = "EC", nombre = "Ecuador", padre = NA_character_), punto, draws, raiz$anios)
  recorrer <- function(padre, p, sim) {
    grupo <- modelo$grupos[[padre]]
    if (is.null(grupo)) return(invisible(NULL))
    k <- length(grupo$series)
    zs <- lapply(grupo$series, .extender_estado, anos = anos, nsim = simulaciones, phi = modelo$phi_partes)
    central <- do.call(cbind, lapply(zs, `[[`, "punto"))
    central <- exp(central - apply(central, 1, max))
    central <- central / rowSums(central)
    pesos <- lapply(zs, `[[`, "draws")
    maximo <- Reduce(pmax, pesos)
    pesos <- lapply(pesos, function(x) exp(x - maximo))
    denominador <- Reduce(`+`, pesos)
    pesos <- lapply(pesos, function(x) x / denominador)
    enteros <- t(matrix(vapply(seq_along(anos), function(i) .repartir_entero(p[i], central[i, ]), numeric(k)), nrow = k))
    idx <- match(anos, grupo$anios); ok <- !is.na(idx)
    enteros[ok, ] <- grupo$conteos[idx[ok], , drop = FALSE]
    for (j in seq_len(k)) {
      hijo <- grupo$nodos[j, ]
      s <- sim * pesos[[j]]
      s[ok, ] <- enteros[ok, j]
      guardar(hijo, enteros[, j], s, grupo$anios)
      recorrer(hijo$codigo, enteros[, j], s)
    }
    invisible(NULL)
  }
  recorrer("EC", punto, draws)
  r <- do.call(rbind, salidas); rownames(r) <- NULL
  r$dpa_provin <- ifelse(r$nivel == "nacional", NA_character_, substr(r$codigo, 1, 2))
  r$dpa_canton <- ifelse(r$nivel %in% c("canton", "parroquia"), substr(r$codigo, 1, 4), NA_character_)
  r$dpa_parroq <- ifelse(r$nivel == "parroquia", r$codigo, NA_character_)
  attr(r, "metodologia") <- list(version = 1L, ventana = modelo$ventana,
    phi_total = modelo$phi_total, phi_partes = modelo$phi_partes,
    simulaciones = simulaciones, semilla = semilla, nivel_intervalo = nivel_intervalo,
    fuente = .pobecu_revision, entrenamiento = lapply(modelo$tablas, function(x) range(x$anio)),
    condicionamiento = "Estados y par\u00e1metros fijos; innovaciones independientes antes de normalizar CLR",
    territorio = "Unidades de referencia Censo 2022; no jurisdicciones hist\u00f3ricas")
  r
}

.ajustar_jerarquia <- function(tablas, ventana, phi_total, phi_partes) {
  niveles <- c("nacional", "provincia", "canton", "parroquia")
  claves <- c(NA, "dpa_provin", "dpa_canton", "dpa_parroq")
  for (i in seq_along(niveles)) {
    d <- tablas[[i]]
    a <- sort(unique(d$anio))
    if (length(a) < 8L || any(diff(a) != 1)) stop("Se necesitan al menos ocho a\u00f1os consecutivos por nivel.", call. = FALSE)
    ids <- if (i == 1) rep("EC", nrow(d)) else as.character(d[[claves[i]]])
    if (anyDuplicated(paste(ids, d$anio)) || any(table(ids) != length(a)) ||
        anyNA(d$poblacion) || any(!is.finite(d$poblacion) | d$poblacion < 0 | d$poblacion != floor(d$poblacion)))
      stop("Las referencias deben ser completas, \u00fanicas y enteras no negativas.", call. = FALSE)
    d$codigo <- ids
    d$nombre <- if (i == 1) "Ecuador" else d[[niveles[i]]]
    d$padre <- if (i <= 2) "EC" else substr(ids, 1, if (i == 3) 2 else 4)
    d <- d[order(d$codigo, d$anio), ]
    tablas[[i]] <- d
    if (i > 1) {
      anterior <- tablas[[i-1]]
      if (!all(a %in% anterior$anio)) stop("La referencia del padre debe cubrir los a\u00f1os de sus hijos.", call. = FALSE)
      suma <- stats::aggregate(poblacion ~ padre + anio, d, sum)
      m <- match(paste(suma$padre, suma$anio), paste(anterior$codigo, anterior$anio))
      if (anyNA(m) || any(suma$poblacion != anterior$poblacion[m]) ||
          !setequal(unique(d$padre), unique(anterior$codigo)))
        stop("Las referencias territoriales no suman a sus padres.", call. = FALSE)
    }
  }
  raiz <- .serie_estado(log(tablas[[1]]$poblacion), tablas[[1]]$anio, ventana)
  raiz$conteos <- tablas[[1]]$poblacion
  grupos <- list(); diagnosticos <- list()
  diagnosticar <- function(s, codigo, padre, nivel) {
    for (sentido in c("retro", "pro")) {
      f <- s[[sentido]]
      diagnosticos[[paste(codigo, sentido)]] <<- data.frame(codigo, padre, nivel,
        sentido, entrenamiento_desde = min(f$anios), entrenamiento_hasta = max(f$anios),
        n = length(f$anios), metodo = f$metodo, convergencia = f$convergencia,
        pendiente = f$pendiente, var_nivel = f$q[1], var_pendiente = f$q[2],
        var_observacion = f$q[3], advertencia = f$advertencia)
    }
  }
  diagnosticar(raiz, "EC", NA_character_, "nacional")
  for (i in 2:4) {
    d <- tablas[[i]]
    for (pa in sort(unique(d$padre))) {
      g <- d[d$padre == pa, ]; ids <- sort(unique(g$codigo)); anos <- sort(unique(g$anio))
      conteos <- vapply(ids, function(id) g$poblacion[g$codigo == id], numeric(length(anos)))
      # Pseudoconteo solo para transformar; nunca altera las referencias.
      logp <- log(conteos + 0.5)
      clr <- logp - rowMeans(logp)
      series <- lapply(seq_along(ids), function(j) .serie_estado(clr[, j], anos, ventana))
      nodos <- g[match(ids, g$codigo), c("codigo", "nombre", "padre")]; nodos$nivel <- niveles[i]
      grupos[[pa]] <- list(series = series, nodos = nodos, anios = anos, conteos = conteos)
      for (j in seq_along(ids)) diagnosticar(series[[j]], ids[j], pa, niveles[i])
    }
  }
  diag <- do.call(rbind, diagnosticos); rownames(diag) <- NULL
  fallos <- sum(diag$metodo == "respaldo_lineal")
  if (fallos) warning(fallos, " ajustes usan respaldo lineal; consulte $diagnosticos.", call. = FALSE)
  structure(list(raiz = raiz, grupos = grupos, tablas = tablas, diagnosticos = diag,
    ventana = ventana, phi_total = phi_total, phi_partes = phi_partes), class = "pob_modelo")
}

.serie_estado <- function(z, anos, ventana) {
  n <- length(z); v <- min(n, ventana)
  list(z = z, anios = anos,
       retro = .ajuste_estado(rev(z[seq_len(v)]), rev(anos[seq_len(v)])),
       pro = .ajuste_estado(utils::tail(z, v), utils::tail(anos, v)))
}

.ajuste_estado <- function(z, anos) {
  if (any(!is.finite(z))) stop("Transformaci\u00f3n no finita: revise el total nacional.", call. = FALSE)
  advertencias <- character()
  if (max(abs(diff(z))) < 1e-12) {
    return(list(anios = anos, pendiente = 0, q = c(0,0,0), metodo = "constante_degenerada",
                convergencia = 0L, advertencia = ""))
  }
  # Escalar evita que varianzas diminutas de las participaciones impidan optimizar.
  escala <- stats::sd(diff(z))
  if (!is.finite(escala) || escala < 1e-8) escala <- max(stats::sd(z), 1e-8)
  fit <- tryCatch(withCallingHandlers(stats::StructTS((z-z[1])/escala, type = "trend",
    optim.control = list(maxit = 500)), warning = function(w) {
      advertencias <<- c(advertencias, conditionMessage(w)); invokeRestart("muffleWarning")
    }), error = function(e) { advertencias <<- c(advertencias, conditionMessage(e)); NULL })
  variante <- "StructTS_tendencia_local"
  if (is.null(fit) || fit$code != 0) {
    # Segundo ajuste estructural restringe el ruido de observación a cero.
    # Adecuado como respaldo explícito para tablas de trayectorias suavizadas.
    segundo <- tryCatch(withCallingHandlers(stats::StructTS((z-z[1])/escala,
      type = "trend", fixed = c(NA, NA, 0), optim.control = list(maxit = 500)),
      warning = function(w) { advertencias <<- c(advertencias, conditionMessage(w));
        invokeRestart("muffleWarning") }), error = function(e) NULL)
    if (!is.null(segundo) && segundo$code == 0) {
      fit <- segundo; variante <- "StructTS_sin_ruido_observacion"
    }
  }
  convergencia <- if (is.null(fit)) 99L else fit$code
  valido <- !is.null(fit) && convergencia == 0 && all(is.finite(fit$coef)) &&
    all(fit$coef >= 0) && all(is.finite(fit$model$a))
  if (valido) {
    pendiente <- fit$model$a[2] * escala
    q <- unname(fit$coef) * escala^2
    metodo <- variante
  } else {
    # Respaldo explícito, diagnosticado y avisado: deriva OLS y ruido de nivel.
    x <- seq_along(z); lm <- stats::lm(z ~ x)
    pendiente <- unname(stats::coef(lm)[2])
    q <- c(mean(diff(stats::residuals(lm))^2), 0, 0)
    metodo <- "respaldo_lineal"
  }
  list(anios = anos, pendiente = pendiente, q = q, metodo = metodo,
       convergencia = convergencia, advertencia = paste(unique(advertencias), collapse = " | "))
}

.extender_estado <- function(s, anos, nsim, phi) {
  punto <- rep(NA_real_, length(anos)); draws <- matrix(NA_real_, length(anos), nsim)
  idx <- match(anos, s$anios); ok <- !is.na(idx)
  punto[ok] <- s$z[idx[ok]]; draws[ok, ] <- punto[ok]
  for (sentido in c("retro", "pro")) {
    retro <- sentido == "retro"
    indices <- if (retro) rev(which(anos < min(s$anios))) else which(anos > max(s$anios))
    if (!length(indices)) next
    f <- s[[sentido]]; anchor <- if (retro) s$z[1] else utils::tail(s$z, 1)
    mu <- rep(anchor, nsim); b <- rep(f$pendiente, nsim)
    centro <- anchor; pendiente <- f$pendiente
    borde <- if (retro) min(s$anios) else max(s$anios)
    for (h in seq_len(max(abs(anos[indices] - borde)))) {
      centro <- centro + phi * pendiente; pendiente <- phi * pendiente
      mu <- mu + phi*b + stats::rnorm(nsim, sd = sqrt(f$q[1]))
      b <- phi*b + stats::rnorm(nsim, sd = sqrt(f$q[2]))
      valor <- mu + stats::rnorm(nsim, sd = sqrt(f$q[3]))
      i <- match(borde + if (retro) -h else h, anos)
      if (!is.na(i)) { punto[i] <- centro; draws[i, ] <- valor }
    }
  }
  if (any(!is.finite(draws)) || any(!is.finite(punto))) stop("Trayectoria no finita.", call. = FALSE)
  list(punto = punto, draws = draws)
}

# Cuantiles tipo 7 (los de stats::quantile()) de cada fila, con un solo order().
.cuantiles_filas <- function(x, probs) {
  n <- ncol(x)
  s <- matrix(x[order(row(x), x)], nrow = n)
  indice <- 1 + (n - 1) * probs
  lo <- floor(indice); hi <- ceiling(indice)
  vapply(seq_along(probs), function(k) {
    a <- s[lo[k], ]; b <- s[hi[k], ]; h <- indice[k] - lo[k]
    i <- h > 0 & b != a
    a[i] <- (1 - h) * a[i] + h * b[i]
    a
  }, numeric(nrow(x)))
}

.repartir_entero <- function(total, pesos) {
  x <- total * pesos; y <- floor(x); resto <- round(total - sum(y))
  if (resto > 0) {
    ids <- order(-(x-y), seq_along(y))[seq_len(resto)]
    y[ids] <- y[ids] + 1
  }
  y
}

.anios_modelo <- function(x) {
  if (!is.numeric(x) || !length(x) || anyNA(x) || any(!is.finite(x)) || any(x != trunc(x)))
    stop("Los a\u00f1os deben ser enteros finitos no vac\u00edos.", call. = FALSE)
  sort(unique(x))
}

.escalar_modelo <- function(x, minimo, maximo, nombre, entero = FALSE, abierto = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x < minimo || x > maximo ||
      (abierto && x == minimo) || (entero && x != trunc(x)))
    stop("Par\u00e1metro inv\u00e1lido: ", nombre, call. = FALSE)
}
