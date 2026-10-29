#' pobecu: población del Ecuador por provincia, cantón y parroquia
#'
#' Estimaciones y proyecciones oficiales de población del INEC (Revisión
#' 2024) y una estimación parroquial derivada, con códigos DPA, listas para
#' calcular tasas y unir con otros datos.
#'
#' ## Funciones principales
#'
#' * [poblacion()] consulta la población por nivel, año, sexo, área y edad.
#' * [pob_unir()] y [pob_tasa()] unen la población con una tabla propia y
#'   calculan tasas.
#' * [homologar_parroquia()] y [homologar_canton()] convierten códigos de
#'   parroquias urbanas o de la DPA del CONALI (2026) a las unidades del
#'   Censo 2022.
#' * [pob_mapa()] y [agrupar_unidades()] unen la población con las capas de
#'   geoecu.
#' * [dpa_pob] es el catálogo de códigos y nombres; [buscar_pob()] busca en él.
#' * [pob_fuentes()] describe las fuentes y la versión de los datos.
#'
#' ## Datos
#'
#' Las tablas por grupos quinquenales vienen dentro del paquete
#' ([pob_nacional], [pob_provincias], [pob_cantones], [pob_parroquias]). Las
#' edades simples se descargan la primera vez desde los releases del
#' repositorio en GitHub y se guardan en caché ([pobecu_cache_dir()]).
#'
#' Cuando el INEC publique una nueva revisión de sus proyecciones, los
#' scripts de `data-raw/` regeneran todos los datos y se publica una nueva
#' versión del paquete.
#'
#' @keywords internal
"_PACKAGE"

#' Fuentes y versión de los datos
#'
#' Muestra de dónde provienen los datos de pobecu, qué periodo cubre cada
#' nivel y qué cifras son oficiales del INEC y cuáles son estimaciones del
#' paquete.
#'
#' @return Un `data.frame` de clase `pob_fuentes` con una fila por nivel. Al
#'   imprimirlo se muestran también la versión de los datos y las fuentes.
#' @export
#' @examples
#' pob_fuentes()
pob_fuentes <- function() {
  x <- data.frame(
    nivel = c("nacional", "provincia", "canton", "parroquia"),
    periodo = c("1950-2050", "1990-2035", "2010-2035", "2010-2035"),
    area = c("2010-2035", "2010-2035", "2010-2035", "no"),
    edad = c("0-100+", "0-100+", "0-100+", "0-4 ... 85+"),
    tipo = c("oficial", "oficial", "oficial", "estimaci\u00f3n pobecu"),
    fuente = c(rep(paste("INEC, Estimaciones y Proyecciones de Poblaci\u00f3n,",
                         .pobecu_revision), 3),
               "pobecu, a partir de INEC (proyecci\u00f3n cantonal) y Censo 2022"),
    stringsAsFactors = FALSE
  )
  class(x) <- c("pob_fuentes", "data.frame")
  x
}

#' @export
print.pob_fuentes <- function(x, ...) {
  cat("pobecu ", as.character(utils::packageVersion("pobecu")),
      " \u00b7 datos ", .pobecu_version_datos, "\n",
      "Estimaciones hasta 2022 y proyecciones desde 2023, al 30 de junio de cada a\u00f1o.\n\n",
      sep = "")
  print(as.data.frame(unclass(x))[, 1:5], row.names = FALSE)
  cat("\nFuentes:\n",
      "* INEC, Estimaciones y Proyecciones de Poblaci\u00f3n, ", .pobecu_revision, ".\n",
      "  https://www.ecuadorencifras.gob.ec/proyecciones-poblacionales/\n",
      "* INEC, VIII Censo de Poblaci\u00f3n y VII de Vivienda 2022.\n",
      "  https://www.censoecuador.gob.ec/resultados-censo/\n",
      "Las cifras parroquiales no son oficiales: ver ?pob_parroquias.\n", sep = "")
  invisible(x)
}
