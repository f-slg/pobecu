# -----------------------------------------------------------------------------
# pobecu · Paso 3: objetos del paquete y archivos del release
#
# Genera:
#   - data/pob_nacional.rda, data/pob_provincias.rda, data/pob_cantones.rda,
#     data/pob_parroquias.rda   población por grupos quinquenales (incluida)
#   - data/dpa_pob.rda           catálogo de códigos y nombres INEC
#   - data-raw/release/pobecu_edad_simple.rds   edades simples (asset del
#     release de GitHub; se descarga en el primer uso)
#
# Uso: Rscript data-raw/03_construir_datos.R
# -----------------------------------------------------------------------------
dir_build <- "data-raw/build"
dir_release <- "data-raw/release"
dir.create(dir_release, showWarnings = FALSE, recursive = TRUE)
dir.create("data", showWarnings = FALSE)

inec_obj <- readRDS(file.path(dir_build, "inec_edad_simple.rds"))
inec <- inec_obj$datos
nombres <- inec_obj$nombres
censo <- readRDS(file.path(dir_build, "censo_parroquias.rds"))
parr_est <- readRDS(file.path(dir_build, "parroquias_estimadas.rds"))

grupos_inec <- c(paste(seq(0, 95, 5), seq(4, 99, 5), sep = "-"), "100+")
grupos_parr <- levels(parr_est$datos$grupo)

utf8 <- function(x) {
  for (v in names(x)) if (is.character(x[[v]])) x[[v]] <- enc2utf8(x[[v]])
  x
}

# --- Catálogo DPA ---------------------------------------------------------------
cat_prov <- unique(nombres[, c("dpa_provin", "provincia")])
p <- censo$parroquias
dpa_pob <- data.frame(
  dpa_parroq = p$dpa_parroq,
  parroquia = p$parroquia,
  tipo = p$tipo,
  dpa_canton = p$dpa_canton,
  canton = nombres$canton[match(p$dpa_canton, nombres$dpa_canton)],
  dpa_provin = substr(p$dpa_canton, 1, 2),
  stringsAsFactors = FALSE
)
dpa_pob$provincia <- cat_prov$provincia[match(dpa_pob$dpa_provin, cat_prov$dpa_provin)]
met <- parr_est$metodo
dpa_pob$metodo <- as.vector(met$metodo[match(dpa_pob$dpa_parroq, met$dpa_parroq)])
dpa_pob$censo_2010 <- as.integer(p$p2010)
dpa_pob$censo_2022 <- as.integer(p$p2022)
dpa_pob <- utf8(dpa_pob[order(dpa_pob$dpa_parroq), ])
rownames(dpa_pob) <- NULL
stopifnot(nrow(dpa_pob) == 1042, !anyNA(dpa_pob$canton), !anyNA(dpa_pob$provincia))

# --- Tablas quinquenales --------------------------------------------------------
quinquenal <- function(d, codigo) {
  d$grupo_edad <- factor(grupos_inec[pmin(d$edad %/% 5, 20) + 1], levels = grupos_inec)
  a <- aggregate(poblacion ~ codigo + anio + area + sexo + grupo_edad, d, sum)
  names(a)[1] <- codigo
  a <- a[order(a[[1]], a$anio, a$area, a$sexo, a$grupo_edad), ]
  if (codigo == "nacional") a[[1]] <- NULL
  a$area <- factor(a$area, levels = c("total", "urbana", "rural"))
  a$sexo <- factor(a$sexo, levels = c("hombre", "mujer"))
  a$poblacion <- as.integer(a$poblacion)
  rownames(a) <- NULL
  a
}
pob_nacional   <- quinquenal(inec[inec$nivel == "nacional", ], "nacional")
pob_provincias <- quinquenal(inec[inec$nivel == "provincia", ], "dpa_provin")
pob_cantones   <- quinquenal(inec[inec$nivel == "canton", ], "dpa_canton")

pob_parroquias <- parr_est$datos
names(pob_parroquias)[names(pob_parroquias) == "grupo"] <- "grupo_edad"
pob_parroquias$area <- factor("total", levels = c("total", "urbana", "rural"))
pob_parroquias$sexo <- factor(pob_parroquias$sexo, levels = c("hombre", "mujer"))
pob_parroquias <- pob_parroquias[order(pob_parroquias$dpa_parroq, pob_parroquias$anio,
                                       pob_parroquias$sexo, pob_parroquias$grupo_edad),
                                 c("dpa_parroq", "anio", "area", "sexo", "grupo_edad", "poblacion")]
rownames(pob_parroquias) <- NULL

for (nm in c("pob_nacional", "pob_provincias", "pob_cantones", "pob_parroquias")) {
  x <- get(nm)
  for (v in names(x)) if (is.character(x[[v]])) x[[v]] <- factor(x[[v]])
  assign(nm, x)
}
# Los códigos se guardan como factor para reducir el tamaño; el paquete los
# convierte a texto al consultarlos.

save(pob_nacional, file = "data/pob_nacional.rda", compress = "xz")
save(pob_provincias, file = "data/pob_provincias.rda", compress = "xz")
save(pob_cantones, file = "data/pob_cantones.rda", compress = "xz")
save(pob_parroquias, file = "data/pob_parroquias.rda", compress = "xz")
save(dpa_pob, file = "data/dpa_pob.rda", compress = "xz")

# --- Edades simples (release) -----------------------------------------------------
simple <- inec
simple$area <- factor(simple$area, levels = c("total", "urbana", "rural"))
simple$sexo <- factor(simple$sexo, levels = c("hombre", "mujer"))
simple$nivel <- factor(simple$nivel, levels = c("nacional", "provincia", "canton"))
simple$codigo <- factor(simple$codigo)
simple$edad <- as.integer(simple$edad)
saveRDS(simple, file.path(dir_release, "pobecu_edad_simple.rds"), compress = "xz")

tam <- file.size(c(list.files("data", full.names = TRUE),
                   file.path(dir_release, "pobecu_edad_simple.rds")))
names(tam) <- c(list.files("data"), "pobecu_edad_simple.rds")
print(round(tam / 1024))
