test_that("pob_unir() une por código y año, aunque falten ceros", {
  casos <- data.frame(dpa_canton = c(1101, 701), anio = 2024, casos = c(120, 40))
  x <- pob_unir(casos)
  esperado <- poblacion("canton", anio = 2024, canton = c("1101", "0701"))$poblacion
  expect_equal(x$poblacion, esperado[c(2, 1)])
})

test_that("pob_unir() acepta un año fijo y desagregación por sexo", {
  d <- data.frame(dpa_provin = "11", sexo = c("Hombre", "mujer"))
  x <- pob_unir(d, "provincia", anio = 2025, sexo = TRUE)
  expect_equal(sum(x$poblacion), poblacion("provincia", anio = 2025, provincia = 11)$poblacion)
})

test_that("pob_unir() avisa y rechaza lo que no puede unir", {
  expect_warning(pob_unir(data.frame(dpa_canton = c("1101", "9999"), anio = 2025)),
                 "sin poblaci")
  expect_error(pob_unir(data.frame(dpa_parroq = "010101", anio = 2025), "parroquia"),
               "homologar_parroquia")
  expect_error(pob_unir(data.frame(dpa_parroq = "131251", anio = 2025), "parroquia"),
               "homologar_parroquia")
  expect_error(pob_unir(data.frame(dpa_canton = "0809", anio = 2025)), "homologar_canton")
  expect_error(pob_unir(data.frame(x = 1)), "columna de c")
})

test_that("pob_tasa() calcula tasas", {
  d <- data.frame(dpa_provin = "17", anio = 2025, casos = 100)
  x <- pob_tasa(d, "casos", nivel = "provincia")
  expect_equal(x$tasa, 100 / x$poblacion * 1e5)
})
