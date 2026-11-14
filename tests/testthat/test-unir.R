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

test_that("pob_unir() explica por qu\u00e9 una fila queda sin poblaci\u00f3n", {
  d <- data.frame(dpa_canton = c(1101, 1101, 9999, NA), anio = c(2024, 2040, 2024, 2024))
  expect_warning(x <- pob_unir(d),
                 "3 fila\\(s\\) sin poblaci.*2 por c\u00f3digo no encontrado; 1 por a\u00f1o no disponible \\(2010-2035\\)")
  expect_equal(is.na(x$poblacion), c(FALSE, TRUE, TRUE, TRUE))

  d <- data.frame(dpa_provin = "11", anio = 2025, sexo = c("Hombre", "MUJER", "M"))
  expect_warning(x <- pob_unir(d, "provincia", sexo = TRUE),
                 "1 fila\\(s\\) sin poblaci.*1 por sexo no reconocido")
  expect_equal(is.na(x$poblacion), c(FALSE, FALSE, TRUE))

  d <- data.frame(dpa_provin = "11", anio = 2025, edad = c("0-4", "0 a 4"))
  expect_warning(pob_unir(d, "provincia", edad = "quinquenal"), "1 por edad no reconocida")
})
