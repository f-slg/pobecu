# -----------------------------------------------------------------------------
# pobecu · Paso 1: leer y ordenar los datos oficiales del INEC
#
# Entradas (data-raw/insumos/, se descargan si faltan):
#   - Tabulados_Estimacion_Proyeccion_v2.xlsx  Estimaciones y Proyecciones de
#     Población, Revisión 2024 (con áreas, 2025). INEC.
#   - 01_2022_CPV_Estructura_poblacional.xlsx  Tabulados del Censo de
#     Población y Vivienda 2022. INEC.
#   - Catálogo DPA del paquete geoecu (para asignar códigos a las parroquias,
#     ya que los tabulados del censo solo traen nombres).
#
# Salidas (data-raw/build/):
#   - inec_edad_simple.rds   nacional, provincial y cantonal, por año, área,
#                            sexo y edad simple (0-100+)
#   - censo_parroquias.rds   parroquias del Censo 2022 con código DPA,
#                            población 2010 y 2022, y estructura por sexo y edad
#
# Uso: Rscript data-raw/01_preparar_datos.R
# -----------------------------------------------------------------------------
source("data-raw/funciones_lectura.R")
source("R/zzz.R")

dir_in <- "data-raw/insumos"
dir_build <- "data-raw/build"
dir.create(dir_in, showWarnings = FALSE, recursive = TRUE)
dir.create(dir_build, showWarnings = FALSE, recursive = TRUE)

urls <- c(
  "Tabulados_Estimacion_Proyeccion_v2.xlsx" = paste0(
    "https://www.ecuadorencifras.gob.ec/documentos/web-inec/Poblacion_y_Demografia/",
    "Proyecciones_Poblacionales/censo_2022/revision_2024_areas/",
    "Tabulados_Estimacion_Proyeccion_v2.xlsx"),
  "01_2022_CPV_Estructura_poblacional.xlsx" = paste0(
    "https://www.censoecuador.gob.ec/wp-content/uploads/2024/04/",
    "01_2022_CPV_Estructura_poblacional.xlsx")
)
for (nm in names(urls)) {
  destino <- file.path(dir_in, nm)
  if (!file.exists(destino)) {
    message("Descargando ", nm)
    utils::download.file(urls[[nm]], destino, mode = "wb", quiet = TRUE)
  }
}
f_proy  <- file.path(dir_in, names(urls)[1])
f_censo <- file.path(dir_in, names(urls)[2])

# Catálogo DPA de geoecu (instalado o en la carpeta hermana del repositorio).
# Desde geoecu 0.4.0 es la Organización Territorial del Estado del CONALI
# (2026); sus códigos se llevan a los del censo con la tabla de R/zzz.R.
dpa_geoecu <- local({
  if (requireNamespace("geoecu", quietly = TRUE)) return(geoecu::dpa)
  e <- new.env()
  load("../geoecu/data/dpa.rda", envir = e)
  e$dpa
})

# --- 1. Proyecciones INEC por edad simple ------------------------------------
# Por área (urbana/rural) solo hay datos 2010-2035; urbana + rural = total.
# El nivel nacional 1950-2009 y 2036-2050 no tiene desagregación por área.
message("Leyendo proyecciones INEC...")
nac_total <- leer_tabulado_inec(f_proy, "1.1")
nac_area  <- leer_tabulado_inec(f_proy, "1.4", con_area = TRUE)
prov_total <- leer_tabulado_inec(f_proy, "2.1")
prov_area  <- leer_tabulado_inec(f_proy, "2.4", con_area = TRUE)
cant_area  <- leer_tabulado_inec(f_proy, "3.4", con_area = TRUE)

# Nacional: área 2010-2035, y "total" fuera de ese rango
nac <- rbind(nac_area, nac_total[!nac_total$anio %in% unique(nac_area$anio), ])
prov <- rbind(prov_area, prov_total[!prov_total$anio %in% unique(prov_area$anio), ])
inec <- rbind(
  cbind(nivel = "nacional", nac),
  cbind(nivel = "provincia", prov),
  cbind(nivel = "canton", cant_area)
)
inec$poblacion <- as.integer(round(inec$poblacion))

# Comprobaciones de coherencia
tot <- function(x, a) sum(x$poblacion[x$anio == a])
for (a in c(2010L, 2022L, 2035L)) {
  stopifnot(tot(inec[inec$nivel == "nacional", ], a) == tot(inec[inec$nivel == "provincia", ], a),
            tot(inec[inec$nivel == "nacional", ], a) == tot(inec[inec$nivel == "canton", ], a))
}
stopifnot(all.equal(tot(prov_total, 2020L), tot(prov_area, 2020L)))

nombres <- leer_nombres_inec(f_proy)
saveRDS(list(datos = inec, nombres = nombres),
        file.path(dir_build, "inec_edad_simple.rds"), compress = "xz")
message("Escrito: inec_edad_simple.rds (", nrow(inec), " filas)")

# --- 2. Parroquias del Censo 2022 ---------------------------------------------
message("Leyendo Censo 2022...")
c52 <- leer_censo(f_censo, "5.2")[, 1:5]
names(c52) <- c("provincia", "canton", "parroquia", "p2010", "p2022")
c52$p2010 <- as.numeric(c52$p2010)
c52$p2022 <- as.numeric(c52$p2022)

# Cantón: por nombre de provincia + cantón contra los nombres oficiales del INEC
clave <- function(p, k) paste(normalizar(p), normalizar(k))
c52$dpa_canton <- nombres$dpa_canton[match(clave(c52$provincia, c52$canton),
                                           clave(nombres$provincia, nombres$canton))]
stopifnot(!anyNA(c52$dpa_canton))

# En cada cantón la primera fila es la cabecera cantonal (código XX50, que en el
# Censo 2022 agrupa a todas las parroquias urbanas); el resto son rurales.
c52$tipo <- ifelse(!duplicated(c52$dpa_canton), "cabecera cantonal", "parroquia rural")

base <- function(x) normalizar(sub("\\s*\\(.*$", "", x))
abrev <- function(x) {
  x <- gsub("\\bSTA\\b", "SANTA", x)
  x <- gsub("\\bSAN +FCO\\b", "SAN FRANCISCO", x)
  x <- gsub("\\bDR\\b", "DOCTOR", x)
  gsub("\\b11\\b", "ONCE", x)
}
rur <- parroquias_rurales_censo(dpa_geoecu)
rur$k <- abrev(base(rur$parroquia))
c52$k <- abrev(normalizar(c52$parroquia))

c52$dpa_parroq <- NA_character_
es_cab <- c52$tipo == "cabecera cantonal"
c52$dpa_parroq[es_cab] <- paste0(c52$dpa_canton[es_cab], "50")

# a) coincidencia exacta dentro del cantón
i <- which(!es_cab)
c52$dpa_parroq[i] <- rur$dpa_parroq[match(paste(c52$dpa_canton[i], c52$k[i]),
                                          paste(rur$dpa_canton, rur$k))]
# b) coincidencia aproximada (distancia de edición <= 3, única) dentro del cantón
for (j in which(!es_cab & is.na(c52$dpa_parroq))) {
  cand <- rur[rur$dpa_canton == c52$dpa_canton[j] & !rur$dpa_parroq %in% c52$dpa_parroq, ]
  d <- utils::adist(c52$k[j], cand$k)[1, ]
  if (length(d) && min(d) <= 3 && sum(d == min(d)) == 1) {
    c52$dpa_parroq[j] <- cand$dpa_parroq[which.min(d)]
  }
}
# c) casos revisados a mano
manual <- c("0607|SAN GERARDO" = "060755",               # San Gerardo de Pacaicaguán
            "2001|ISLA SANTA MARIA FLOREANA" = "200152")  # Isla Santa María (Floreana)
for (nm in names(manual)) {
  p <- strsplit(nm, "|", fixed = TRUE)[[1]]
  c52$dpa_parroq[c52$dpa_canton == p[1] & c52$k == p[2]] <- manual[[nm]]
}
stopifnot(!anyNA(c52$dpa_parroq), !anyDuplicated(c52$dpa_parroq))

# Nombre oficial del INEC (Censo 2022) para la parroquia
c52$parroquia <- trimws(c52$parroquia)

# Estructura por sexo y grupos quinquenales (tabla 2.1, mismo orden de filas)
c21 <- leer_censo(f_censo, "2.1")[, 1:7]
names(c21) <- c("provincia", "canton", "parroquia", "grupo", "total", "hombre", "mujer")
c21 <- c21[!grepl("^Total", c21$grupo), ]
c21$id <- rep(seq_len(nrow(c52)), each = 18)
stopifnot(nrow(c21) == 18 * nrow(c52))
c21$grupo <- sub("^De ", "", c21$grupo)
c21$grupo <- sub(" o más$", "+", c21$grupo)
grupos <- unique(c21$grupo)
stopifnot(length(grupos) == 18, grupos[18] == "85+")

est <- data.frame(
  dpa_parroq = rep(c52$dpa_parroq[c21$id], 2),
  sexo = rep(c("hombre", "mujer"), each = nrow(c21)),
  grupo = factor(rep(c21$grupo, 2), levels = grupos),
  poblacion = as.numeric(c(c21$hombre, c21$mujer))
)
est$poblacion[is.na(est$poblacion)] <- 0   # celdas vacías del tabulado = 0
# La estructura suma exactamente la población 2022 de la tabla 5.2
chk <- tapply(est$poblacion, est$dpa_parroq, sum)
stopifnot(all(chk[c52$dpa_parroq] == c52$p2022))

censo <- list(
  parroquias = c52[, c("dpa_parroq", "parroquia", "tipo", "dpa_canton", "p2010", "p2022")],
  estructura = est
)
saveRDS(censo, file.path(dir_build, "censo_parroquias.rds"), compress = "xz")
message("Escrito: censo_parroquias.rds (", nrow(c52), " parroquias)")
