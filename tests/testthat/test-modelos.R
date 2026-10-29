# Árbol sintético con ceros, un hijo único y tendencias cambiantes.
arbol_modelo <- function() {
  a <- 2010:2025
  nacional <- data.frame(anio = a, poblacion = 10000 + 100*(a-2010))
  provincia <- do.call(rbind, lapply(c("01", "02"), function(id)
    data.frame(dpa_provin = id, provincia = id, anio = a,
               poblacion = if(id=="01") 6000+60*(a-2010) else 4000+40*(a-2010))))
  canton <- provincia; canton$dpa_canton <- paste0(canton$dpa_provin,"01")
  canton$canton <- canton$dpa_canton
  parroquia <- do.call(rbind, lapply(c("50","51"), function(s) {
    d <- canton; d$dpa_parroq <- paste0(d$dpa_canton,s); d$parroquia <- d$dpa_parroq
    d$poblacion <- if(s=="50") d$poblacion else 0
    d
  }))
  list(nacional=nacional, provincia=provincia, canton=canton, parroquia=parroquia)
}

test_that("jerarquía preserva referencias, ceros y sumas hasta 1900 y 2100", {
  tab <- arbol_modelo()
  m <- .ajustar_jerarquia(tab, 12, .98, .95)
  set.seed(71); antes <- .Random.seed
  p <- pob_estimar("todos", c(1900,2010,2020,2025,2100), m, simulaciones=100)
  expect_identical(.Random.seed, antes)
  expect_true(all(is.finite(p$poblacion) & p$poblacion >= 0 & p$poblacion == floor(p$poblacion)))
  expect_true(all(p$limite_inferior <= p$limite_superior, na.rm=TRUE))
  for (n in c("provincia", "canton", "parroquia")) {
    hijos <- subset(p, nivel == n)
    s <- aggregate(poblacion ~ padre + anio, hijos, sum)
    ids <- match(paste(s$padre,s$anio), paste(p$codigo,p$anio))
    expect_equal(s$poblacion, p$poblacion[ids])
  }
  for (n in names(tab)) {
    d <- m$tablas[[n]]; d <- d[d$anio %in% p$anio, ]
    ids <- match(paste(d$codigo,d$anio), paste(p$codigo,p$anio))
    expect_equal(p$poblacion[ids], d$poblacion)
    expect_true(all(is.na(p$limite_inferior[ids])))
  }
  expect_true(all(subset(p, anio == 1900)$extrapolacion_extrema))
  q <- pob_estimar("provincia", 2100, m, provincia="01", simulaciones=100)
  expect_equal(q$poblacion, subset(p,nivel=="provincia" & codigo=="01" & anio==2100)$poblacion)
  expect_equal(q$limite_inferior, subset(p,nivel=="provincia" & codigo=="01" & anio==2100)$limite_inferior)
})

test_that("modelo rechaza argumentos y jerarquías inválidas", {
  expect_error(pob_ajustar(ventana=7), "ventana")
  expect_error(pob_ajustar(phi_total=0), "phi_total")
  expect_error(pob_estimar(anio=1899), "1900-2100")
  expect_error(pob_estimar(anio=2020.5), "enteros")
  expect_error(pob_estimar(simulaciones=0), "simulaciones")
  expect_error(pob_estimar(modelo=list()), "pob_ajustar")
  expect_error(pob_estimar(nivel_intervalo=1), "menor")
  expect_error(pob_estimar("todos", provincia="Loja"), "filtros")
  d <- arbol_modelo(); d$canton$poblacion[1] <- 0
  expect_error(.ajustar_jerarquia(d,12,.98,.95), "suman")
  d <- arbol_modelo(); d$provincia <- d$provincia[-1, ]
  expect_error(.ajustar_jerarquia(d,12,.98,.95), "completas")
  d <- arbol_modelo(); d$nacional <- d$nacional[d$nacional$anio != 2015, ]
  expect_error(.ajustar_jerarquia(d,12,.98,.95), "consecutivos")
})

test_that("la amortiguación sigue la fórmula declarada y cambia escenarios", {
  s <- list(z=0:9, anios=2000:2009,
            retro=list(pendiente=-1,q=c(0,0,0)), pro=list(pendiente=1,q=c(0,0,0)))
  r <- .extender_estado(s, 1998:2011, 100, .9)
  expect_equal(r$punto[1], -.9-.9^2)
  expect_equal(tail(r$punto,1), 9+.9+.9^2)
  expect_equal(r$draws[,1], r$punto)
  expect_equal(.repartir_entero(10,c(.33,.33,.34)), c(3,3,4))
})
