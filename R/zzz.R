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
