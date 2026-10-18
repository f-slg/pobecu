test_that("los datos incluidos tienen la estructura esperada", {
  expect_equal(nrow(dpa_pob), 1042)
  expect_equal(sum(dpa_pob$tipo == "cabecera"), 221)
  expect_false(anyDuplicated(dpa_pob$dpa_parroq) > 0)
  expect_true(all(grepl("^[0-9]{6}$", dpa_pob$dpa_parroq)))
  expect_equal(range(pob_nacional$anio), c(1950L, 2050L))
  expect_equal(range(pob_provincias$anio), c(1990L, 2035L))
  expect_equal(range(pob_cantones$anio), c(2010L, 2035L))
  expect_equal(range(pob_parroquias$anio), c(2010L, 2035L))
  expect_equal(nlevels(pob_cantones$dpa_canton), 221)
})

test_that("los niveles son coherentes entre sí", {
  for (a in c(2010L, 2022L, 2035L)) {
    n <- sum(pob_nacional$poblacion[pob_nacional$anio == a])
    expect_equal(sum(pob_provincias$poblacion[pob_provincias$anio == a]), n)
    expect_equal(sum(pob_cantones$poblacion[pob_cantones$anio == a]), n)
    expect_equal(sum(pob_parroquias$poblacion[pob_parroquias$anio == a]), n)
  }
})

test_that("las parroquias suman exactamente el cantón por sexo", {
  p <- suppressMessages(poblacion("parroquia", anio = 2030, sexo = TRUE))
  p <- aggregate(poblacion ~ dpa_canton + sexo, p, sum)
  k <- poblacion("canton", anio = 2030, sexo = TRUE)
  m <- merge(p, k, by = c("dpa_canton", "sexo"))
  expect_equal(nrow(m), 442)
  expect_equal(m$poblacion.x, m$poblacion.y)
})
