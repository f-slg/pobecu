# Pruebas de la cach\u00e9 y la descarga que no necesitan internet: usan una
# cach\u00e9 temporal y una "fuente" local con `pobecu.url_base`.

cache_temporal <- function(env = parent.frame()) {
  carpeta <- tempfile("pobecu-cache-")
  dir.create(carpeta)
  anterior <- Sys.getenv("R_USER_CACHE_DIR", unset = NA)
  variable <- Sys.getenv("POBECU_CARPETA", unset = NA)
  opcion <- getOption("pobecu.carpeta")
  olvidar <- function() assign("simple", NULL, envir = pobecu:::.pobecu_env)
  # La restauración se registra antes de cambiar nada
  do.call(on.exit, list(substitute({
    if (is.na(anterior)) Sys.unsetenv("R_USER_CACHE_DIR") else
      Sys.setenv(R_USER_CACHE_DIR = anterior)
    if (!is.na(variable)) Sys.setenv(POBECU_CARPETA = variable)
    options(pobecu.carpeta = opcion)
    olvidar()
    unlink(carpeta, recursive = TRUE)
  }, list(anterior = anterior, variable = variable, opcion = opcion,
          olvidar = olvidar, carpeta = carpeta)), add = TRUE), envir = env)
  Sys.setenv(R_USER_CACHE_DIR = carpeta)
  Sys.unsetenv("POBECU_CARPETA")
  options(pobecu.carpeta = NULL)
  olvidar()
  carpeta
}

fuente_local <- function(env = parent.frame()) {
  carpeta <- tempfile("pobecu-fuente-")
  dir.create(carpeta)
  saveRDS(data.frame(nivel = "provincia", codigo = "11", edad = 0:499, poblacion = 1L),
          file.path(carpeta, "pobecu_edad_simple.rds"), compress = FALSE)
  ruta <- normalizePath(carpeta, winslash = "/")
  url <- paste0(if (startsWith(ruta, "/")) "file://" else "file:///", ruta)
  anterior <- options(pobecu.url_base = url)
  do.call(on.exit, list(substitute({
    options(anterior)
    unlink(carpeta, recursive = TRUE)
  }, list(anterior = anterior, carpeta = carpeta)), add = TRUE), envir = env)
  carpeta
}

test_that("la URL de los datos respeta pobecu.url_base", {
  anterior <- options(pobecu.url_base = NULL)
  on.exit(options(anterior), add = TRUE)
  expect_match(pobecu:::.url_datos(),
               "^https://github.com/f-slg/pobecu/releases/download/datos-v[0-9.]+/pobecu_edad_simple.rds$")
  options(pobecu.url_base = "https://ejemplo.org/datos/")
  expect_equal(pobecu:::.url_datos(), "https://ejemplo.org/datos/pobecu_edad_simple.rds")
})

test_that("pobecu_usar_carpeta valida la carpeta y devuelve la anterior", {
  inicial <- getOption("pobecu.carpeta")
  on.exit(options(pobecu.carpeta = inicial), add = TRUE)
  expect_error(pobecu_usar_carpeta(file.path(tempdir(), "no-existe-pobecu")),
               "No existe la carpeta")
  pobecu_usar_carpeta(tempdir())
  expect_equal(pobecu_usar_carpeta(NULL), normalizePath(tempdir(), winslash = "/"))
  expect_null(getOption("pobecu.carpeta"))
})

test_that("la descarga guarda el archivo en la cach\u00e9 sin dejar temporales", {
  cache_temporal()
  fuente <- fuente_local()

  expect_false(pobecu_datos_disponibles())
  expect_message(destino <- pobecu:::.descargar(), "Descargando")
  expect_equal(destino, file.path(pobecu_cache_dir(), "pobecu_edad_simple.rds"))
  expect_true(pobecu_datos_disponibles())
  expect_equal(list.files(pobecu_cache_dir()), "pobecu_edad_simple.rds")
  # Ya está en caché: no se vuelve a descargar, y se lee una sola vez
  expect_no_message(expect_equal(pobecu:::.ruta_datos(), destino))
  expect_equal(nrow(pobecu:::.datos_simple()), 500)

  expect_message(pobecu_limpiar_cache(), "eliminada")
  expect_false(pobecu_datos_disponibles())
  expect_length(ls(pobecu:::.cache_verificada, all.names = TRUE), 0L)
})

test_that("la descarga falla con un mensaje claro si la fuente no existe", {
  cache_temporal()
  anterior <- options(pobecu.url_base = paste0("file://", tempfile("no-existe-")))
  on.exit(options(anterior), add = TRUE)
  expect_error(suppressMessages(pobecu:::.descargar()), "No se pudieron descargar")
  expect_equal(length(list.files(pobecu_cache_dir())), 0L)
})

test_that("un archivo de cach\u00e9 que no es el oficial se detecta", {
  falso <- tempfile(fileext = ".rds")
  writeLines("descarga interrumpida", falso)
  on.exit(unlink(falso), add = TRUE)
  anterior <- options(pobecu.url_base = NULL)
  on.exit(options(anterior), add = TRUE)
  expect_false(pobecu:::.cache_integra(falso))
  # Con otra fuente configurada no hay huella que comparar
  options(pobecu.url_base = "https://ejemplo.org")
  expect_true(pobecu:::.cache_integra(falso))
})

test_that("un archivo propio que no se puede leer se explica", {
  cache_temporal()
  carpeta <- tempfile("pobecu-propia-")
  dir.create(carpeta)
  on.exit(unlink(carpeta, recursive = TRUE), add = TRUE)
  writeLines("no es un RDS", file.path(carpeta, "pobecu_edad_simple.rds"))
  anterior <- pobecu_usar_carpeta(carpeta)
  on.exit(pobecu_usar_carpeta(anterior), add = TRUE)
  expect_error(poblacion("provincia", anio = 2025, edad = "simple"),
               "No se pudo leer el archivo de edades simples")
})

test_that("una cach\u00e9 da\u00f1ada se repara descargando de nuevo", {
  skip_on_cran()
  skip_if_offline("github.com")
  cache_temporal()
  anterior <- options(pobecu.url_base = NULL)
  on.exit(options(anterior), add = TRUE)

  dir.create(pobecu_cache_dir(), recursive = TRUE)
  ruta <- file.path(pobecu_cache_dir(), "pobecu_edad_simple.rds")
  writeLines("descarga interrumpida", ruta)
  expect_message(x <- poblacion("provincia", anio = 2025, provincia = "Loja",
                                edad = "simple"),
                 "se descarga de nuevo")
  expect_equal(nrow(x), 101)
  expect_identical(unname(tools::md5sum(ruta)), pobecu:::.pobecu_md5)
})
