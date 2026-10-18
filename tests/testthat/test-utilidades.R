test_that("homologar_parroquia() lleva las urbanas a la cabecera", {
  expect_equal(homologar_parroquia(c("010101", "010115", "010150", "010151", 220254)),
               c("010150", "010150", "010150", "010151", "220250"))
})

test_that("formatear_codigo() y normalizar_nombre() funcionan", {
  expect_equal(formatear_codigo(c(1, "7"), "provincia"), c("01", "07"))
  expect_equal(formatear_codigo(701, "canton"), "0701")
  expect_warning(formatear_codigo("abc", "canton"), "no son c")
  expect_equal(normalizar_nombre("  Cañar "), "CANAR")
})

test_that("buscar_pob() encuentra por nombre y código", {
  expect_equal(nrow(buscar_pob("puyango", "canton")), 1)
  expect_equal(buscar_pob("11", "provincia")$provincia, "Loja")
  expect_true(nrow(buscar_pob("arenal")) >= 1)
})
