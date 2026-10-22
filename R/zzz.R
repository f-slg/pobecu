# Repositorio de GitHub donde se publican los datos de edad simple como asset
# de un release. Para usar otro repositorio, cambia este valor (y las URL de
# DESCRIPTION y README).
.pobecu_repo <- "f-slg/pobecu"

# Etiqueta del release que contiene los datos de esta version.
.pobecu_version_datos <- "datos-v0.1.0"

.pobecu_archivo_simple <- "pobecu_edad_simple.rds"

# Revision de las proyecciones del INEC en la que se basan los datos.
.pobecu_revision <- "Revisi\u00f3n 2024 (actualizaci\u00f3n con \u00e1reas, 2025)"

.pobecu_niveles <- c("canton", "provincia", "parroquia", "nacional")

# Anos disponibles en cada nivel
.pobecu_anios <- list(
  nacional  = 1950:2050,
  provincia = 1990:2035,
  canton    = 2010:2035,
  parroquia = 2010:2035
)

# Anos con desagregacion urbana/rural (nacional, provincia y canton)
.pobecu_anios_area <- 2010:2035

# Etapas de vida usadas por el INEC en los tabulados de proyecciones
.pobecu_etapas <- c(0, 12, 18, 30, 65)

.pobecu_env <- new.env(parent = emptyenv())

# Codigos de la Organizacion Territorial del Estado (CONALI, 2026), que usa
# geoecu desde la version 0.4.0, que no existen en el Censo 2022, con la
# unidad censal que los contiene. "codigo": misma parroquia con otro codigo
# (cantones nuevos Borbon y Sevilla Don Bosco; Bella Vista). "nueva":
# parroquia creada despues del censo, cuya poblacion esta incluida en la
# parroquia censal de la que salio la mayor parte de su territorio.
# Se obtiene en data-raw/06_equivalencias_conali.R a partir de
# geoecu::dpa_equivalencias.
.pobecu_conali <- data.frame(
  conali = c("080950", "080951", "080952", "080953", "080954", "080955",
             "080956", "080957", "080958", "080959", "080960", "080961",
             "141350", "200351",
             "131251", "160167", "170257", "210456", "210457", "210458"),
  censo  = c("080253", "080251", "080252", "080255", "080256", "080258",
             "080259", "080260", "080261", "080262", "080263", "080264",
             "140157", "200353",
             "131250", "160162", "170250", "210450", "210450", "210450"),
  cambio = rep(c("codigo", "nueva"), c(14, 6)),
  stringsAsFactors = FALSE
)

# Cantones creados despues del Censo 2022 y el canton censal que los contiene
.pobecu_cantones_conali <- c("0809" = "0802",   # Borbon, antes en Eloy Alfaro
                             "1413" = "1401")   # Sevilla Don Bosco, antes en Morona
