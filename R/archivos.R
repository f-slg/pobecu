#' Carpeta de caché de pobecu
#'
#' Los datos por edad simple se descargan la primera vez que se piden y se
#' guardan aquí para no volver a descargarlos. La ubicación sigue las
#' convenciones de cada sistema operativo ([tools::R_user_dir()]). La primera
#' vez que se usan en cada sesión se comprueba su huella; si el archivo está
#' incompleto o modificado, se descarga de nuevo. Para usar un archivo
#' propio, indica otra carpeta con [pobecu_usar_carpeta()].
#'
#' @return Ruta de la carpeta de caché (texto).
#' @export
#' @examples
#' pobecu_cache_dir()
pobecu_cache_dir <- function() {
  file.path(tools::R_user_dir("pobecu", which = "cache"), .pobecu_version_datos)
}

#' Borrar los datos descargados
#'
#' Elimina los datos guardados en la caché. Se volverán a descargar la
#' próxima vez que se necesiten.
#'
#' @return `TRUE` de forma invisible.
#' @export
#' @examplesIf interactive()
#' pobecu_limpiar_cache()
pobecu_limpiar_cache <- function() {
  carpeta <- tools::R_user_dir("pobecu", which = "cache")
  if (dir.exists(carpeta)) unlink(carpeta, recursive = TRUE)
  .pobecu_env$simple <- NULL
  rm(list = ls(.cache_verificada, all.names = TRUE), envir = .cache_verificada)
  message("Cach\u00e9 de pobecu eliminada.")
  invisible(TRUE)
}

#' Usar datos desde una carpeta local
#'
#' Indica a pobecu una carpeta que contiene `pobecu_edad_simple.rds`. Útil
#' para trabajar sin conexión o en servidores institucionales.
#'
#' También puedes definir la variable de entorno `POBECU_CARPETA` (por
#' ejemplo, en tu `.Renviron`) para que la carpeta se use siempre.
#'
#' @param carpeta Ruta a la carpeta. Usa `NULL` para volver al comportamiento
#'   por defecto (caché y descarga).
#' @return La carpeta anterior, de forma invisible.
#' @export
#' @examples
#' anterior <- pobecu_usar_carpeta(tempdir())
#' pobecu_datos_disponibles()
#' pobecu_usar_carpeta(anterior)
pobecu_usar_carpeta <- function(carpeta) {
  if (!is.null(carpeta)) {
    if (!dir.exists(carpeta)) stop("No existe la carpeta: ", carpeta, call. = FALSE)
    carpeta <- normalizePath(carpeta, winslash = "/")
  }
  anterior <- getOption("pobecu.carpeta")
  options(pobecu.carpeta = carpeta)
  .pobecu_env$simple <- NULL
  invisible(anterior)
}

#' ¿Están disponibles los datos por edad simple sin descargar?
#'
#' Los grupos quinquenales vienen dentro del paquete; las edades simples
#' (0 a 100 y más) se descargan la primera vez que se piden con
#' `poblacion(edad = "simple")` u otros cortes de edad que no son múltiplos
#' de 5. Esta función indica si ya están en la carpeta local o en la caché.
#'
#' @return `TRUE` o `FALSE`.
#' @export
#' @examples
#' pobecu_datos_disponibles()
pobecu_datos_disponibles <- function() {
  !is.null(.ruta_local())
}

# --- internas ----------------------------------------------------------------

.carpeta_usuario <- function() {
  carpeta <- getOption("pobecu.carpeta")
  if (is.null(carpeta)) {
    env <- Sys.getenv("POBECU_CARPETA", unset = "")
    if (nzchar(env)) carpeta <- env
  }
  carpeta
}

.ruta_local <- function() {
  carpeta <- .carpeta_usuario()
  candidatos <- c(
    if (!is.null(carpeta)) file.path(carpeta, .pobecu_archivo_simple),
    file.path(pobecu_cache_dir(), .pobecu_archivo_simple)
  )
  existe <- candidatos[file.exists(candidatos)]
  if (length(existe)) existe[[1]] else NULL
}

.url_datos <- function() {
  base <- getOption(
    "pobecu.url_base",
    sprintf("https://github.com/%s/releases/download/%s",
            .pobecu_repo, .pobecu_version_datos)
  )
  paste0(sub("/$", "", base), "/", .pobecu_archivo_simple)
}

.descargar <- function() {
  destino_dir <- pobecu_cache_dir()
  dir.create(destino_dir, recursive = TRUE, showWarnings = FALSE)
  destino <- file.path(destino_dir, .pobecu_archivo_simple)
  url <- .url_datos()

  message("Descargando datos por edad simple (2 MB) por \u00fanica vez...\n  ", url)
  tmp <- tempfile(fileext = ".rds")
  old <- options(timeout = max(300, getOption("timeout")))
  on.exit({ options(old); unlink(tmp) }, add = TRUE)

  ok <- tryCatch(
    utils::download.file(url, tmp, mode = "wb", quiet = TRUE) == 0,
    error = function(e) FALSE, warning = function(w) FALSE
  )
  if (!ok || !file.exists(tmp) || file.size(tmp) < 1000) {
    stop("No se pudieron descargar los datos desde:\n  ", url,
         "\nRevisa tu conexi\u00f3n o usa pobecu_usar_carpeta() con archivos locales.",
         call. = FALSE)
  }
  # Solo se verifica la huella del release oficial; con `pobecu.url_base`
  # se pueden usar otras fuentes bajo responsabilidad de quien las configura.
  oficial <- is.null(getOption("pobecu.url_base"))
  if (oficial && !identical(unname(tools::md5sum(tmp)), .pobecu_md5)) {
    stop("El archivo descargado no coincide con la versi\u00f3n esperada de los datos ",
         "(", .pobecu_version_datos, "). Puede estar incompleto o haber sido ",
         "modificado. Intenta de nuevo m\u00e1s tarde.", call. = FALSE)
  }
  # Se copia con otro nombre y se renombra al final: si el proceso se
  # interrumpe, no queda un archivo incompleto con el nombre definitivo.
  parcial <- paste0(destino, ".", Sys.getpid(), ".tmp")
  on.exit(unlink(parcial), add = TRUE)
  guardado <- file.copy(tmp, parcial, overwrite = TRUE) &&
    (suppressWarnings(file.rename(parcial, destino)) ||
       file.copy(parcial, destino, overwrite = TRUE))
  if (!guardado) {
    stop("No se pudo guardar el archivo en la cach\u00e9: ", destino, call. = FALSE)
  }
  if (oficial) assign(destino, TRUE, envir = .cache_verificada)
  destino
}

# Archivos de la caché cuya huella ya se comprobó en esta sesión.
.cache_verificada <- new.env(parent = emptyenv())

# ¿El archivo de la caché es el del release oficial? Se comprueba una vez por
# sesión. Con `pobecu.url_base` la fuente es otra y no hay huella que comparar.
.cache_integra <- function(ruta) {
  if (!is.null(getOption("pobecu.url_base"))) return(TRUE)
  if (exists(ruta, envir = .cache_verificada, inherits = FALSE)) return(TRUE)
  ok <- identical(unname(tools::md5sum(ruta)), .pobecu_md5)
  if (ok) assign(ruta, TRUE, envir = .cache_verificada)
  ok
}

.ruta_datos <- function() {
  ruta <- .ruta_local()
  if (is.null(ruta)) return(.descargar())
  # Solo se verifica la caché: una carpeta indicada por el usuario puede
  # contener datos propios.
  en_cache <- identical(ruta, file.path(pobecu_cache_dir(), .pobecu_archivo_simple))
  if (en_cache && !.cache_integra(ruta)) {
    message("El archivo en cach\u00e9 no coincide con la versi\u00f3n esperada de los ",
            "datos (incompleto o modificado); se descarga de nuevo.")
    ruta <- .descargar()
  }
  ruta
}

# Tabla de edades simples (se lee una vez por sesion)
.datos_simple <- function() {
  if (is.null(.pobecu_env$simple)) {
    ruta <- .ruta_datos()
    datos <- tryCatch(readRDS(ruta), error = function(e) NULL)
    if (!is.data.frame(datos)) {
      stop("No se pudo leer el archivo de edades simples:\n  ", ruta,
           "\nNo es el archivo `", .pobecu_archivo_simple, "` de pobecu o est\u00e1 ",
           "da\u00f1ado. Reempl\u00e1zalo o usa pobecu_usar_carpeta(NULL) para descargarlo.",
           call. = FALSE)
    }
    .pobecu_env$simple <- datos
  }
  .pobecu_env$simple
}
