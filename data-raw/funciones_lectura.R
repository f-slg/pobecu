# -----------------------------------------------------------------------------
# pobecu · Funciones de lectura de los tabulados del INEC
#
# Las usan 01_preparar_inec.R y 02_parroquias.R. No forman parte del paquete.
# -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(readxl))

# Lee una hoja de "Tabulados_Estimacion_Proyeccion" (INEC, Revisión 2024) con
# edades simples en filas y año x [área x] sexo en columnas, y la devuelve en
# formato largo: [codigo], anio, [area], sexo, edad, poblacion.
leer_tabulado_inec <- function(archivo, hoja, con_area = FALSE) {
  d <- suppressMessages(read_excel(archivo, hoja, col_names = FALSE,
                                   col_types = "text"))
  d <- as.data.frame(d)

  # Fila de encabezado: la que contiene "Edad"
  f_enc <- which(apply(d, 1, function(r) any(r %in% "Edad")))[1]
  enc <- unlist(d[f_enc, ])
  col_edad <- which(enc == "Edad")
  col_prov <- which(enc == "Código Provincia")
  col_cant <- which(enc == "Código Cantón")

  f_anio <- f_enc + 1
  f_area <- if (con_area) f_enc + 2 else NA
  f_sexo <- if (con_area) f_enc + 3 else f_enc + 2
  f_dato <- f_sexo + 1

  rellenar <- function(x) {          # arrastra el último valor no vacío
    for (i in seq_along(x)[-1]) if (is.na(x[i])) x[i] <- x[i - 1]
    x
  }
  cols <- (col_edad + 1):ncol(d)
  anio <- rellenar(unlist(d[f_anio, cols]))
  sexo <- unlist(d[f_sexo, cols])
  area <- if (con_area) rellenar(unlist(d[f_area, cols])) else rep("Total", length(cols))

  datos <- d[f_dato:nrow(d), , drop = FALSE]
  edad <- datos[[col_edad]]
  ok <- grepl("^[0-9]+( y más)?$", edad)
  # Algunas celdas guardan el código como número (1 en lugar de "01")
  pad <- function(x, n) ifelse(grepl("^[0-9]+$", x),
                               formatC(suppressWarnings(as.integer(x)), width = n, flag = "0"),
                               NA_character_)
  if (length(col_prov)) {
    datos[[col_prov]] <- pad(datos[[col_prov]], 2)
    ok <- ok & !is.na(datos[[col_prov]])
  }
  if (length(col_cant)) datos[[col_cant]] <- pad(datos[[col_cant]], 4)
  datos <- datos[ok, , drop = FALSE]
  edad <- sub(" y más$", "", datos[[col_edad]])

  usar <- which(sexo %in% c("Hombre", "Mujer"))
  piezas <- lapply(usar, function(j) {
    data.frame(
      codigo = if (length(col_cant)) datos[[col_cant]]
               else if (length(col_prov)) datos[[col_prov]] else "00",
      anio = as.integer(anio[j]),
      area = c(Total = "total", Urbano = "urbana", Rural = "rural")[[area[j]]],
      sexo = c(Hombre = "hombre", Mujer = "mujer")[[sexo[j]]],
      edad = as.integer(edad),
      poblacion = as.numeric(datos[[cols[j]]]),
      stringsAsFactors = FALSE
    )
  })
  res <- do.call(rbind, piezas)
  stopifnot(!anyNA(res$poblacion), !anyNA(res$edad), !anyNA(res$anio))
  res
}

# Nombres oficiales de provincias y cantones tal como los escribe el INEC.
leer_nombres_inec <- function(archivo) {
  d <- as.data.frame(suppressMessages(read_excel(archivo, "3.1", col_names = FALSE,
                                                 col_types = "text")))
  d <- d[grepl("^[0-9]+$", d[[4]]), 2:5]
  names(d) <- c("dpa_provin", "provincia", "dpa_canton", "canton")
  d$dpa_provin <- formatC(as.integer(d$dpa_provin), width = 2, flag = "0")
  d$dpa_canton <- formatC(as.integer(d$dpa_canton), width = 4, flag = "0")
  d <- unique(d)
  rownames(d) <- NULL
  d
}

# Lee una hoja del tabulado "Estructura poblacional" del Censo 2022 y devuelve
# las filas de parroquia (descarta totales nacionales, provinciales y cantonales).
leer_censo <- function(archivo, hoja, n_niveles = 3) {
  d <- as.data.frame(suppressMessages(read_excel(archivo, hoja, col_names = FALSE,
                                                 col_types = "text")))
  d <- d[-(1:9), -1]
  d <- d[!is.na(d[[1]]) & !is.na(d[[2]]) & !grepl("^Nota", d[[1]]), ]
  d <- d[!grepl("^Total", d[[1]]) & !grepl("^Total", d[[2]]) &
         !grepl("^Total", d[[3]]), ]
  rownames(d) <- NULL
  d
}

# Normalización de nombres para cruzar tablas (mismo criterio que geoecu).
normalizar <- function(x) {
  x <- iconv(x, "UTF-8", "ASCII//TRANSLIT")
  x <- toupper(gsub("[^A-Za-z0-9 ]", " ", x))
  trimws(gsub(" +", " ", x))
}
