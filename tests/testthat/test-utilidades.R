test_that("homologar_parroquia() lleva las urbanas a la cabecera", {
  expect_equal(homologar_parroquia(c("010101", "010115", "010150", "010151", 220254)),
               c("010150", "010150", "010150", "010151", "220250"))
})

test_that("homologar_parroquia() convierte los códigos del CONALI 2026", {
  # Borbón (cabecera y rural), Sevilla Don Bosco, Bella Vista y parroquias nuevas
  expect_equal(homologar_parroquia(c("080950", "080961", "141350", "200351",
                                     "131251", "170257", "210456")),
               c("080253", "080264", "140157", "200353",
                 "131250", "170250", "210450"))
  # Las zonas en estudio no cambian
  expect_equal(homologar_parroquia(c("139090", "140190", "900651")),
               c("139090", "140190", "900651"))
  # Los demás códigos del CONALI son unidades del censo
  skip_if_not_installed("geoecu", "0.4.0")
  d <- geoecu::dpa[geoecu::dpa$tipo != "zona en estudio", ]
  expect_true(all(homologar_parroquia(d$dpa_parroq) %in% dpa_pob$dpa_parroq))
  expect_setequal(homologar_parroquia(d$dpa_parroq), dpa_pob$dpa_parroq)
  expect_true(all(homologar_canton(d$dpa_canton) %in% dpa_pob$dpa_canton))
})

test_that("homologar_canton() lleva los cantones nuevos al del censo", {
  expect_equal(homologar_canton(c("0809", 1413, "1101")), c("0802", "1401", "1101"))
})

test_that("los cantones nuevos se aceptan como filtro", {
  expect_message(b <- poblacion("canton", anio = 2025, canton = "Borbón"), "0802")
  expect_equal(b$dpa_canton, "0802")
  expect_equal(suppressMessages(poblacion("canton", anio = 2025, canton = "1413"))$dpa_canton,
               "1401")
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
