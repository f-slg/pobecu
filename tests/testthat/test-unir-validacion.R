test_that("los años factor y texto se interpretan por su valor", {
  d <- data.frame(dpa_canton = c("1101", "0701"), anio = c(2025, 2024))
  esperado <- pob_unir(d)$poblacion
  d$anio <- factor(d$anio, levels = c(2025, 2024))
  expect_equal(pob_unir(d)$poblacion, esperado)
  d$anio <- as.character(d$anio)
  expect_equal(pob_unir(d)$poblacion, esperado)
  d$anio[2] <- NA_character_
  expect_warning(x <- pob_unir(d), "sin poblaci")
  expect_equal(x$poblacion[1], esperado[1])
  expect_true(is.na(x$poblacion[2]))
})

test_that("los años inválidos no se truncan ni se pierden silenciosamente", {
  d <- data.frame(dpa_canton = "1101", anio = 2025.9)
  expect_error(pob_unir(d), "enteros finitos")
  expect_error(pob_unir(d, anio = 2025.9), "enteros finitos")
  for (a in list(Inf, "202x", "", 1e20)) {
    d$anio <- a
    expect_error(pob_unir(d), "enteros finitos")
  }
})

test_that("las tasas distinguen población cero, casos cero y datos faltantes", {
  d <- data.frame(dpa_parroq = rep("060256", 3), anio = 2025,
                  sexo = "hombre", edad = "70-74", casos = c(1, 0, NA_real_))
  expect_warning(x <- pob_tasa(d, "casos", "parroquia", sexo = TRUE,
                               edad = "quinquenal"), "poblaci.*cero")
  expect_equal(x$poblacion, rep(0L, 3))
  expect_identical(x$tasa, rep(NA_real_, 3))
  d <- data.frame(dpa_canton = "1101", anio = 2025, casos = c(0, NA, 2.5))
  x <- pob_tasa(d, "casos")
  expect_equal(x$tasa[1], 0)
  expect_true(is.na(x$tasa[2]))
  expect_equal(x$tasa[3], 2.5 / x$poblacion[3] * 1e5)
})

test_that("tasas rechazan bases y numeradores inválidos", {
  d <- data.frame(dpa_canton = "1101", anio = 2025, casos = 1)
  for (p in list(0, -1, Inf, NA_real_, c(100, 1000), "100")) {
    expect_error(pob_tasa(d, "casos", por = p), "finito mayor")
  }
  for (n in list(-1, Inf, "10", factor("10"))) {
    d$casos <- n
    expect_error(pob_tasa(d, "casos"), "casos deben")
  }
})

test_that("unir y calcular tasas conserva tablas vacías", {
  d <- data.frame(dpa_canton = character(), anio = integer(), casos = numeric())
  x <- pob_tasa(d, "casos")
  expect_equal(nrow(x), 0L)
  expect_named(x, c(names(d), "poblacion", "tasa"))
})
