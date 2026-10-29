# Ejecutar desde la raíz del repositorio:
# Rscript data-raw/07_validar_fuentes.R [proyecciones.xlsx] [censo.xlsx] [edades.rds]
# Lee los Excel directamente; NO usa funciones_lectura.R ni los RDS de build.
# Requiere readxl y pkgload. Conserva evidencias incluso si hay diferencias.
args <- commandArgs(trailingOnly = TRUE)
f <- if (length(args)) args[1] else
  "data-raw/insumos/Tabulados_Estimacion_Proyeccion_v2.xlsx"
fc <- if (length(args) > 1) args[2] else
  "data-raw/insumos/01_2022_CPV_Estructura_poblacional.xlsx"
fs <- if (length(args) > 2) args[3] else "data-raw/release/pobecu_edad_simple.rds"
pkgload::load_all(quiet = TRUE)
salida <- "validacion"
dir.create(salida, showWarnings = FALSE)
resultados <- list()
comparar <- function(nombre, esperado, observado, claves) {
  llave <- function(x) do.call(paste, c(lapply(x[claves], as.character), sep = "|"))
  a <- llave(esperado); b <- llave(observado)
  stopifnot(!anyDuplicated(a), !anyDuplicated(b))
  i <- match(a, b)
  delta <- observado$poblacion[i] - esperado$poblacion
  iguales <- (is.na(observado$poblacion[i]) & is.na(esperado$poblacion) & !is.na(i)) |
    (!is.na(delta) & delta == 0)
  extra <- sum(!b %in% a)
  resultados[[length(resultados) + 1L]] <<- data.frame(
    comprobacion = nombre, celdas = length(a),
    diferencias = sum(!iguales), faltantes = sum(is.na(i)), extras = extra,
    max_diferencia = if (any(is.finite(delta))) max(abs(delta), na.rm = TRUE) else 0)
  if (any(!iguales)) {
    detalle <- esperado[!iguales, , drop = FALSE]
    detalle$observado <- observado$poblacion[i[!iguales]]
    write.csv(detalle, file.path(salida, paste0("diferencias-", nombre, ".csv")),
              row.names = FALSE, na = "NA")
  }
  message(nombre, ": ", length(a), " celdas; ", sum(!iguales), " diferencias; ", extra, " extras")
}

# Lector de auditoría: posiciones verificadas en los encabezados originales.
# También conserva las columnas Total para contrastarlas con hombre + mujer.
leer <- function(hoja, nivel, areas = FALSE) {
  message("Leyendo hoja ", hoja)
  d <- as.data.frame(readxl::read_excel(f, hoja, col_names = FALSE,
                                       col_types = "text", .name_repair = "minimal"))
  ce <- switch(nivel, nacional = 2L, provincia = 4L, canton = 6L)
  stopifnot(d[6, ce] == "Edad")
  cs <- seq.int(ce + 1L, ncol(d))
  llenar <- function(v) {
    ix <- cummax(ifelse(is.na(v), 0L, seq_along(v)))
    v[ix]
  }
  years <- as.integer(llenar(unlist(d[7, cs])))
  areas_col <- if (areas) llenar(unlist(d[8, cs])) else rep("Total", length(cs))
  sexes <- unlist(d[if (areas) 9L else 8L, cs])
  filas <- which(grepl("^[0-9]+( y más)?$", d[[ce]]))
  edades <- as.integer(sub(" y más", "", d[[ce]][filas], fixed = TRUE))
  codigo <- switch(nivel, nacional = rep("00", length(filas)),
    provincia = sprintf("%02d", as.integer(d[[2]][filas])),
    canton = sprintf("%04d", as.integer(d[[4]][filas])))
  usar <- which(sexes %in% c("Hombre", "Mujer", "Total"))
  do.call(rbind, lapply(usar, function(j) data.frame(
    codigo = codigo, anio = years[j],
    area = unname(c(Total = "total", Urbano = "urbana", Rural = "rural")[areas_col[j]]),
    sexo = unname(tolower(sexes[j])), edad = edades,
    poblacion = as.numeric(d[[cs[j]]][filas]))))
}

simple <- readRDS(fs)
claves <- c("codigo", "anio", "area", "sexo", "edad")
for (nivel in c("nacional", "provincia", "canton")) {
  prefijo <- match(nivel, c("nacional", "provincia", "canton"))
  total <- leer(paste0(prefijo, ".1"), nivel)
  area <- leer(paste0(prefijo, ".4"), nivel, TRUE)
  for (tipo in c("total", "area")) {
    tabla <- get(tipo)
    control <- tabla[tabla$sexo == "total", ]
    suma <- aggregate(poblacion ~ codigo + anio + area + edad,
                      tabla[tabla$sexo != "total", ], sum)
    comparar(paste(nivel, tipo, "sexos", sep = "-"), control, suma,
             c("codigo", "anio", "area", "edad"))
  }
  total <- total[total$sexo != "total", ]
  area <- area[area$sexo != "total", ]
  suma <- aggregate(poblacion ~ codigo + anio + sexo + edad, area, sum)
  comparar(paste0(nivel, "-urbano-rural"),
           total[total$anio %in% unique(area$anio), ], suma,
           c("codigo", "anio", "sexo", "edad"))
  oficial <- rbind(area, total[!total$anio %in% unique(area$anio), ])
  comparar(paste0(nivel, "-edades-simples"), oficial,
           simple[simple$nivel == nivel, ], claves)
  oficial$edad <- pmin(oficial$edad %/% 5 * 5, 100)
  quin <- aggregate(poblacion ~ codigo + anio + area + sexo + edad, oficial, sum)
  incluido <- pobecu:::.tabla_quinquenal(nivel)
  incluido$edad <- incluido$edad_inicio
  comparar(paste0(nivel, "-quinquenales"), quin, incluido, claves)
}

# Contraste censal por nombres completos (no por la posición de las filas).
censo <- as.data.frame(readxl::read_excel(fc, "5.2", col_names = FALSE,
                                         col_types = "text", .name_repair = "minimal"))
censo <- censo[-seq_len(9), 2:6]
names(censo) <- c("provincia", "canton", "parroquia", "censo_2010", "censo_2022")
norm <- function(x) pobecu::normalizar_nombre(x)
cat <- pobecu::dpa_pob
for (v in c("provincia", "canton", "parroquia")) {
  censo[[v]] <- norm(censo[[v]])
  cat[[v]] <- norm(cat[[v]])
}
censo <- censo[!is.na(censo$provincia) & !is.na(censo$canton) &
                 !grepl("^TOTAL|^NOTA", censo$provincia) &
                 !grepl("^TOTAL", censo$canton) & !grepl("^TOTAL", censo$parroquia), ]
stopifnot(nrow(censo) == 1042)
for (a in c("censo_2010", "censo_2022")) {
  censo$poblacion <- as.numeric(censo[[a]])
  cat$poblacion <- cat[[a]]
  comparar(a, censo, cat, c("provincia", "canton", "parroquia"))
}

# Coherencia exhaustiva de la estimación propia: todos los años, sexos y edades.
p <- pobecu::pob_parroquias
p$codigo <- substr(p$dpa_parroq, 1, 4)
p$edad <- as.integer(sub("[-+].*$", "", p$grupo_edad))
p <- aggregate(poblacion ~ codigo + anio + sexo + edad, p, sum)
k <- pobecu:::.tabla_quinquenal("canton")
k$edad <- pmin(k$edad_inicio, 85L)
k <- aggregate(poblacion ~ codigo + anio + sexo + edad, k, sum)
comparar("parroquias-suman-canton", k, p, c("codigo", "anio", "sexo", "edad"))
# Coherencia entre niveles oficiales para todas las combinaciones compartidas.
for (inferior in c("provincia", "canton")) {
  superior <- if (inferior == "provincia") "nacional" else "provincia"
  abajo <- pobecu:::.tabla_quinquenal(inferior)
  arriba <- pobecu:::.tabla_quinquenal(superior)
  abajo$codigo <- if (superior == "nacional") "00" else substr(abajo$codigo, 1, 2)
  arriba <- arriba[arriba$anio %in% abajo$anio, ]
  abajo <- aggregate(poblacion ~ codigo + anio + sexo + grupo_edad, abajo, sum)
  arriba <- aggregate(poblacion ~ codigo + anio + sexo + grupo_edad, arriba, sum)
  comparar(paste0(inferior, "-suma-", superior), arriba, abajo,
           c("codigo", "anio", "sexo", "grupo_edad"))
}
res <- do.call(rbind, resultados)
write.csv(res, file.path(salida, "resumen.csv"), row.names = FALSE)
writeLines(c(paste("Fecha:", Sys.Date()), paste("R:", R.version.string),
             paste("Paquete:", packageVersion("pobecu")),
             paste("Proyecciones MD5:", tools::md5sum(f)),
             paste("Censo MD5:", tools::md5sum(fc)),
             paste("Edades simples MD5:", tools::md5sum(fs))),
           file.path(salida, "ejecucion.txt"))
print(res, row.names = FALSE)
stopifnot(all(res$diferencias == 0), all(res$faltantes == 0), all(res$extras == 0))
