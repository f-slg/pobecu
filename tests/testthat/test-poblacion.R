test_that("poblacion() devuelve cifras oficiales conocidas del INEC", {
  g <- poblacion("canton", anio = c(2010, 2022, 2035), canton = "Guayaquil")
  expect_equal(g$poblacion, c(2417957L, 2908589L, 3218450L))
  expect_equal(sum(poblacion("provincia", anio = 2025)$poblacion), 18103660L)
})

test_that("poblacion() filtra y desagrega", {
  x <- poblacion("canton", anio = 2025, provincia = "Loja", sexo = TRUE)
  expect_equal(nrow(x), 16 * 2)
  expect_setequal(unique(x$sexo), c("hombre", "mujer"))
  expect_true(all(x$provincia == "Loja"))

  a <- poblacion("provincia", anio = 2025, provincia = "11", area = TRUE)
  expect_equal(sum(a$poblacion), poblacion("provincia", anio = 2025, provincia = 11)$poblacion)
  expect_setequal(a$area, c("urbana", "rural"))
})

test_that("los cortes de edad múltiplos de 5 conservan el total", {
  t <- poblacion("nacional", anio = 2030)$poblacion
  e <- poblacion("nacional", anio = 2030, edad = c(0, 5, 15, 65))
  expect_equal(as.character(e$edad), c("0-4", "5-14", "15-64", "65+"))
  expect_equal(sum(e$poblacion), t)
  q <- poblacion("nacional", anio = 2030, edad = "quinquenal")
  expect_equal(nrow(q), 21)
})

test_that("poblacion() da errores claros", {
  expect_error(poblacion("canton", anio = 2000), "no disponibles")
  expect_error(poblacion("parroquia", area = TRUE), "urbana/rural")
  expect_error(poblacion("parroquia", edad = "simple"), "quinquenales")
  expect_error(poblacion("parroquia", edad = c(0, 2)), "quinquenales")
  expect_error(poblacion("canton", canton = "Bolivar"), "varios")
  expect_error(poblacion("canton", provincia = "Lojaa"), "Quisiste")
  expect_error(poblacion("provincia", anio = 1995, area = TRUE), "2010-2035")
})

test_that("edades simples cuando los datos están disponibles", {
  skip_if_not(pobecu_datos_disponibles())
  s <- poblacion("provincia", anio = 2025, provincia = "Pichincha", edad = "simple")
  expect_equal(nrow(s), 101)
  expect_equal(sum(s$poblacion),
               poblacion("provincia", anio = 2025, provincia = "Pichincha")$poblacion)
  e <- poblacion("canton", anio = 2025, canton = "Loja", edad = "etapas")
  expect_equal(as.character(e$edad), c("0-11", "12-17", "18-29", "30-64", "65+"))
})
