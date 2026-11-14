test_that("homologar_parroquia() lleva las urbanas a la cabecera", {
  expect_equal(homologar_parroquia(c("010101", "010115", "010150", "010151", 220254)),
               c("010150", "010150", "010150", "010151", "220250"))
})

test_that("homologar_parroquia() no convierte el sufijo 00, que no existe", {
  expect_equal(homologar_parroquia("110100"), "110100")
  expect_warning(u <- pob_unir(data.frame(dpa_parroq = "110100", anio = 2025),
                               nivel = "parroquia"), "sin poblaci")
  expect_true(is.na(u$poblacion))
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
  # Misma palabra con la tilde como carácter combinado (forma NFD)
  expect_equal(normalizar_nombre("Can\u0303ar"), "CANAR")
  expect_equal(nrow(poblacion("provincia", 2025, provincia = "Can\u0303ar")), 1)
})

test_that("buscar_pob() encuentra por nombre y código", {
  expect_equal(nrow(buscar_pob("puyango", "canton")), 1)
  expect_equal(buscar_pob("11", "provincia")$provincia, "Loja")
  expect_true(nrow(buscar_pob("arenal")) >= 1)
})

test_that("formatear_codigo() no inventa la provincia 00 ni usa notaci\u00f3n cient\u00edfica", {
  expect_warning(x <- formatear_codigo(c("01", "101"), "canton"), "no son c")
  expect_equal(x, c(NA, "0101"))
  expect_warning(expect_equal(formatear_codigo(0, "provincia"), NA_character_))
  expect_equal(formatear_codigo(c(100000, 110150, NA), "parroquia"),
               c("100000", "110150", NA))
  expect_warning(x <- formatear_codigo(c(701, 1101.5), "canton"), "1101.5")
  expect_equal(x, c("0701", NA))
})

test_that("normalizar_nombre() conserva la letra base de otros acentos", {
  expect_equal(normalizar_nombre(c("S\u00e3o Jo\u00e3o", "Cura\u00e7ao", "voil\u00e0", "\u00c0\u00ca\u00c7")),
               c("SAO JOAO", "CURACAO", "VOILA", "AEC"))
})

test_that("los filtros y las b\u00fasquedas rechazan NA y textos vac\u00edos", {
  expect_equal(nrow(buscar_pob(NA)), 0)
  expect_error(poblacion("provincia", 2025, provincia = NA), "no admite NA")
  expect_error(poblacion("canton", 2025, canton = ""), "cant\u00f3n no admite")
  expect_error(pob_estimar("provincia", 2030, provincia = c("Loja", " ")), "no admite NA")
})

test_that("formatear_codigo() y normalizar_nombre() coinciden con las de geoecu", {
  # geoecu exporta las mismas funciones; desde 0.4.2 deben dar lo mismo
  skip_if_not_installed("geoecu", "0.4.1.9000")
  codigos <- list(c(1, 11, "7", NA), c(701, 1101, 100000, 1101.5), "01", 0,
                  c("0101", "abc", "12345", " 110150 ", "110150.0"),
                  factor(c("1101", "0701")), c(150, 10150, 1e6))
  for (x in codigos) for (nivel in c("provincia", "canton", "parroquia")) {
    expect_identical(suppressWarnings(formatear_codigo(x, nivel)),
                     suppressWarnings(geoecu::formatear_codigo(x, nivel)))
  }
  nombres <- c("Ca\u00f1ar", "  san  Jos\u00e9 de Chimbo ", "CHECA (JIDCAY)", NA,
               "Can\u0303ar", "S\u00e3o Jo\u00e3o", "Cura\u00e7ao", "O'Higgins", "")
  expect_identical(normalizar_nombre(nombres), geoecu::normalizar_nombre(nombres))
})
