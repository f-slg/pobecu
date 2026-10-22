test_that("pob_mapa() une población a las capas de geoecu", {
  skip_if_not_installed("geoecu")
  skip_if_not_installed("sf")
  skip_if_not(geoecu::geoecu_datos_disponibles())
  m <- pob_mapa("canton", anio = 2025, provincia = "Loja")
  expect_s3_class(m, "sf")
  expect_equal(nrow(m), 16)
  expect_equal(sum(m$poblacion), poblacion("provincia", anio = 2025, provincia = "Loja")$poblacion)
  expect_true(all(m$densidad > 0))
})

test_that("pob_mapa() cubre todo el país sin perder población", {
  skip_if_not_installed("geoecu")
  skip_if_not_installed("sf")
  skip_if_not(geoecu::geoecu_datos_disponibles())
  total <- sum(poblacion("provincia", anio = 2025)$poblacion)
  for (nivel in c("provincia", "canton", "parroquia")) {
    m <- expect_silent(suppressMessages(pob_mapa(nivel, anio = 2025)))
    expect_equal(sum(m$poblacion, na.rm = TRUE), total)
    # Solo las zonas en estudio quedan sin población
    if ("tipo" %in% names(m)) {
      expect_true(all(m$tipo[is.na(m$poblacion)] == "zona en estudio"))
    }
  }
})

test_that("las zonas en estudio se repiten en cada combinación", {
  skip_if_not_installed("geoecu", "0.4.0")
  skip_if_not_installed("sf")
  skip_if_not(geoecu::geoecu_datos_disponibles())
  m <- pob_mapa("provincia", anio = c(2025, 2035), edad = c(0, 65))
  expect_false(anyNA(m$anio))
  expect_false(anyNA(m$edad))
  expect_equal(sum(m$dpa_provin == "90"), 4)
  expect_true(all(is.na(m$poblacion[m$dpa_provin == "90"])))
})

test_that("agrupar_unidades() vuelve a las unidades del censo", {
  skip_if_not_installed("geoecu", "0.4.0")
  skip_if_not_installed("sf")
  skip_if_not(geoecu::geoecu_datos_disponibles())
  # Cantones: Borbón vuelve a Eloy Alfaro
  esm <- geoecu::read_cantones(provincia = "Esmeraldas")
  a <- agrupar_unidades(esm)
  expect_setequal(a$dpa_canton, dpa_pob$dpa_canton[dpa_pob$dpa_provin == "08"])
  expect_equal(a$area_km2[a$dpa_canton == "0802"],
               sum(esm$area_km2[esm$dpa_canton %in% c("0802", "0809")]))
  # Parroquias: Sosote vuelve a Rocafuerte
  roc <- geoecu::read_parroquias(canton = "Rocafuerte")
  p <- agrupar_unidades(roc)
  expect_setequal(p$dpa_parroq, dpa_pob$dpa_parroq[dpa_pob$dpa_canton == "1312"])
  expect_equal(sum(p$area_km2), sum(roc$area_km2))
  # El filtro por un cantón nuevo devuelve el cantón del censo completo
  b <- suppressMessages(pob_mapa("canton", anio = 2025, canton = "Borbón"))
  expect_equal(b$dpa_canton, "0802")
})

test_that("agrupar_cabeceras() sigue funcionando", {
  skip_if_not_installed("geoecu")
  skip_if_not_installed("sf")
  skip_if_not(geoecu::geoecu_datos_disponibles())
  cuenca <- geoecu::read_parroquias(canton = "Cuenca")
  a <- agrupar_cabeceras(cuenca)
  expect_equal(nrow(a), sum(dpa_pob$dpa_canton == "0101"))
  expect_setequal(a$dpa_parroq, dpa_pob$dpa_parroq[dpa_pob$dpa_canton == "0101"])
  expect_equal(sum(a$area_km2), sum(cuenca$area_km2))
  p <- suppressMessages(pob_mapa("parroquia", anio = 2030, canton = "Cuenca"))
  expect_equal(sum(p$poblacion), poblacion("canton", anio = 2030, canton = "Cuenca")$poblacion)
})
