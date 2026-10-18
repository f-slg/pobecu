# -----------------------------------------------------------------------------
# pobecu · Paso 2: estimación parroquial 2010-2035
#
# El INEC no publica proyecciones por parroquia. Esta estimación reparte la
# proyección oficial de cada cantón (Revisión 2024) entre sus parroquias, de
# modo que la suma de las parroquias es siempre igual a la cifra oficial del
# cantón, por sexo y grupo de edad.
#
# 1. Participación de cada parroquia en su cantón: se calcula en los censos 2010
#    y 2022 y se interpola/extrapola con una función logística (lineal en la
#    escala logit), el mismo método que usa el INEC para los cantones respecto
#    de su provincia. Luego se reescala para que sume 1 en cada cantón.
#    En los cantones con parroquias creadas después de 2010 (sin población en
#    el Censo 2010) se mantiene constante la participación del Censo 2022.
# 2. Población total parroquial = participación x población oficial del cantón.
# 3. Sexo y edad: ajuste proporcional iterativo (IPF / "raking"). La semilla es
#    la estructura por sexo y grupo quinquenal de cada parroquia en el Censo
#    2022; los márgenes son el total parroquial (paso 2) y la estructura oficial
#    del cantón por sexo y edad.
# 4. Redondeo a enteros por el método del mayor residuo, de forma que cada
#    celda cantonal por sexo y edad coincide exactamente con el INEC.
#
# Entradas: data-raw/build/inec_edad_simple.rds, data-raw/build/censo_parroquias.rds
# Salida:   data-raw/build/parroquias_estimadas.rds
#
# Uso: Rscript data-raw/02_estimar_parroquias.R
# -----------------------------------------------------------------------------
dir_build <- "data-raw/build"
inec <- readRDS(file.path(dir_build, "inec_edad_simple.rds"))$datos
censo <- readRDS(file.path(dir_build, "censo_parroquias.rds"))
parr <- censo$parroquias
est <- censo$estructura
grupos <- levels(est$grupo)

# Momentos de referencia: censos (noviembre) y proyecciones (30 de junio)
t_2010 <- 2010 + 333 / 365   # 28-nov-2010
t_2022 <- 2022 + 318 / 365   # mediados de noviembre de 2022
anios <- 2010:2035
t_proy <- anios + 0.5

# --- Proyección cantonal oficial por sexo y grupo (85+ agrupa 85-100+) -------
cant <- inec[inec$nivel == "canton" , ]
cant$grupo <- factor(grupos[pmin(cant$edad %/% 5, 17) + 1], levels = grupos)
cant <- aggregate(poblacion ~ codigo + anio + sexo + grupo, cant, sum)
names(cant)[1] <- "dpa_canton"

# --- 1. Participaciones -------------------------------------------------------
logit <- function(p) log(p / (1 - p))
expit <- function(x) 1 / (1 + exp(-x))

parr$s2022 <- parr$p2022 / ave(parr$p2022, parr$dpa_canton, FUN = sum)
nuevas <- tapply(is.na(parr$p2010) | parr$p2010 == 0, parr$dpa_canton, any)
parr$metodo <- ifelse(nuevas[parr$dpa_canton], "participacion_constante", "logistica")
unica <- ave(rep(1, nrow(parr)), parr$dpa_canton, FUN = sum) == 1
parr$metodo[unica] <- "parroquia_unica"

parr$s2010 <- NA_real_
ok <- parr$metodo == "logistica"
parr$s2010[ok] <- parr$p2010[ok] / ave(parr$p2010[ok], parr$dpa_canton[ok], FUN = sum)

participacion <- function(fila) {
  if (fila$metodo != "logistica") return(rep(fila$s2022, length(t_proy)))
  b <- (logit(fila$s2022) - logit(fila$s2010)) / (t_2022 - t_2010)
  expit(logit(fila$s2022) + b * (t_proy - t_2022))
}
S <- t(vapply(seq_len(nrow(parr)), function(i) participacion(parr[i, ]),
              numeric(length(anios))))
dimnames(S) <- list(parr$dpa_parroq, anios)
# Reescalar para que sumen 1 en cada cantón
for (j in seq_along(anios)) S[, j] <- S[, j] / ave(S[, j], parr$dpa_canton, FUN = sum)

# --- 2-4. Total parroquial, IPF y redondeo -------------------------------------
ipf <- function(semilla, filas, columnas, tol = 1e-8, max_iter = 500) {
  x <- semilla
  for (k in seq_len(max_iter)) {
    rf <- rowSums(x); x <- x * ifelse(rf > 0, filas / rf, 0)
    cf <- colSums(x); x <- sweep(x, 2, ifelse(cf > 0, columnas / cf, 0), "*")
    if (max(abs(rowSums(x) - filas)) < tol * max(1, sum(filas))) break
  }
  x
}

# Redondea cada columna a enteros conservando su total (mayor residuo)
redondear_columnas <- function(x, totales) {
  for (j in seq_len(ncol(x))) {
    v <- x[, j]; base <- floor(v)
    faltan <- totales[j] - sum(base)
    if (faltan > 0) {
      orden <- order(v - base, decreasing = TRUE)[seq_len(faltan)]
      base[orden] <- base[orden] + 1
    }
    x[, j] <- base
  }
  x
}

celdas <- paste(rep(c("hombre", "mujer"), each = length(grupos)), grupos, sep = "|")
semilla_de <- function(codigos) {
  e <- est[est$dpa_parroq %in% codigos, ]
  m <- matrix(0, length(codigos), length(celdas), dimnames = list(codigos, celdas))
  m[cbind(match(e$dpa_parroq, codigos), match(paste(e$sexo, e$grupo, sep = "|"), celdas))] <-
    e$poblacion
  m + 0.01   # evita celdas estructuralmente vacías
}

resultado <- vector("list", length(unique(parr$dpa_canton)))
names(resultado) <- unique(parr$dpa_canton)
for (k in names(resultado)) {
  codigos <- parr$dpa_parroq[parr$dpa_canton == k]
  semilla <- semilla_de(codigos)
  ck <- cant[cant$dpa_canton == k, ]
  piezas <- vector("list", length(anios))
  for (j in seq_along(anios)) {
    cj <- ck[ck$anio == anios[j], ]
    col_tot <- setNames(cj$poblacion, paste(cj$sexo, cj$grupo, sep = "|"))[celdas]
    fil_tot <- S[codigos, j] * sum(col_tot)
    x <- if (length(codigos) == 1) {
      matrix(col_tot, 1, dimnames = list(codigos, celdas))
    } else {
      redondear_columnas(ipf(semilla, fil_tot, col_tot), col_tot)
    }
    piezas[[j]] <- data.frame(
      dpa_parroq = rep(codigos, length(celdas)),
      anio = anios[j],
      sexo = rep(sub("\\|.*$", "", celdas), each = length(codigos)),
      grupo = rep(sub("^.*\\|", "", celdas), each = length(codigos)),
      poblacion = as.integer(as.vector(x)),
      stringsAsFactors = FALSE
    )
  }
  resultado[[k]] <- do.call(rbind, piezas)
}
res <- do.call(rbind, resultado)
rownames(res) <- NULL
res$grupo <- factor(res$grupo, levels = grupos)

# --- Comprobaciones -------------------------------------------------------------
res$dpa_canton <- substr(res$dpa_parroq, 1, 4)
a <- aggregate(poblacion ~ dpa_canton + anio + sexo + grupo, res, sum)
m <- merge(a, cant, by = c("dpa_canton", "anio", "sexo", "grupo"))
stopifnot(nrow(m) == nrow(cant), all(m$poblacion.x == m$poblacion.y))

tot <- aggregate(poblacion ~ dpa_parroq + anio, res, sum)
tot$objetivo <- S[cbind(tot$dpa_parroq, as.character(tot$anio))] *
  ave(tot$poblacion, substr(tot$dpa_parroq, 1, 4), tot$anio, FUN = sum)
desvio <- abs(tot$poblacion - tot$objetivo)
message("Desvío máximo del total parroquial respecto de la participación: ",
        round(max(desvio), 1), " personas (", round(100 * max(desvio / pmax(tot$objetivo, 1)), 2), "%)")
res$dpa_canton <- NULL

saveRDS(list(datos = res,
             metodo = parr[, c("dpa_parroq", "metodo", "s2010", "s2022")]),
        file.path(dir_build, "parroquias_estimadas.rds"), compress = "xz")
message("Escrito: parroquias_estimadas.rds (", nrow(res), " filas)")
