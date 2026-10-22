# -----------------------------------------------------------------------------
# pobecu · Equivalencias entre la DPA del CONALI (2026) y el Censo 2022
#
# geoecu 0.4.0 usa la Organización Territorial del Estado del CONALI (2026),
# con dos cantones (Borbón y Sevilla Don Bosco) y varias parroquias creadas o
# recodificadas después del Censo 2022. pobecu sigue las unidades del censo.
# Este script obtiene, para cada código del CONALI que no existe en pobecu, la
# unidad del censo que lo contiene, y comprueba la tabla `.pobecu_conali` de
# R/zzz.R.
#
# Método: se usa geoecu::dpa_equivalencias (superposición de áreas entre las
# capas de geoecu 0.3.0, con los límites del censo, y 0.4.0). Las parroquias
# urbanas de 0.3.0 se llevan a su cabecera cantonal y cada parroquia del
# CONALI se asigna a la unidad censal que aporta la mayor parte de su área.
#
# Requisitos: geoecu >= 0.4.0 y las capas de alta resolución de geoecu 0.3.0
# (release datos-v0.1.0) para las áreas.
#
# Uso: Rscript data-raw/06_equivalencias_conali.R
# -----------------------------------------------------------------------------
stopifnot(utils::packageVersion("geoecu") >= "0.4.0")
suppressPackageStartupMessages(library(sf))
source("R/zzz.R")
load("data/dpa_pob.rda")

gpkg_anterior <- file.path(tools::R_user_dir("geoecu", "cache"), "datos-v0.1.0",
                           "geoecu_dpa_alta.gpkg")
if (!file.exists(gpkg_anterior)) {
  utils::download.file(
    "https://github.com/f-slg/geoecu/releases/download/datos-v0.1.0/geoecu_dpa_alta.gpkg",
    gpkg_anterior <- tempfile(fileext = ".gpkg"), mode = "wb")
}
anterior <- st_read(gpkg_anterior, layer = "parroquias", quiet = TRUE)

eq <- geoecu::dpa_equivalencias
eq$area <- eq$proporcion * anterior$area_km2[match(eq$dpa_parroq_anterior, anterior$dpa_parroq)]
# Unidad del censo de cada parroquia anterior: las urbanas, a su cabecera
sufijo <- as.integer(substr(eq$dpa_parroq_anterior, 5, 6))
eq$censo <- ifelse(sufijo <= 50, paste0(substr(eq$dpa_parroq_anterior, 1, 4), "50"),
                   eq$dpa_parroq_anterior)
eq$censo[eq$censo == "220254"] <- "220250"   # Tiputini, en la cabecera de Aguarico

conali <- geoecu::dpa[geoecu::dpa$tipo != "zona en estudio", ]
solo_conali <- setdiff(conali$dpa_parroq, dpa_pob$dpa_parroq)
calculada <- do.call(rbind, lapply(solo_conali, function(cod) {
  e <- eq[eq$dpa_parroq == cod, ]
  a <- tapply(e$area, e$censo, sum)
  data.frame(conali = cod, censo = names(which.max(a)),
             parte = round(max(a) / sum(a), 3),
             cambio = if (any(e$principal & e$proporcion > 0.9 &
                              !e$censo %in% conali$dpa_parroq)) "codigo" else "nueva")
}))
print(calculada)

# La tabla del paquete debe coincidir con la calculada
m <- merge(calculada, .pobecu_conali, by = "conali", suffixes = c("", "_paquete"))
stopifnot(nrow(m) == nrow(.pobecu_conali), nrow(calculada) == nrow(.pobecu_conali),
          identical(m$censo, m$censo_paquete), identical(m$cambio, m$cambio_paquete))

# Cada unidad del censo queda representada al menos por un polígono del CONALI
i <- match(conali$dpa_parroq, .pobecu_conali$conali)
cod_censo <- ifelse(is.na(i), conali$dpa_parroq, .pobecu_conali$censo[i])
stopifnot(setequal(cod_censo, dpa_pob$dpa_parroq))

# Cantones creados después del censo
cant <- unique(data.frame(conali = substr(.pobecu_conali$conali, 1, 4),
                          censo = substr(.pobecu_conali$censo, 1, 4)))
cant <- cant[cant$conali != cant$censo & !cant$conali %in% dpa_pob$dpa_canton, ]
stopifnot(identical(stats::setNames(cant$censo, cant$conali), .pobecu_cantones_conali))
message("Equivalencias CONALI 2026 - Censo 2022 verificadas.")
