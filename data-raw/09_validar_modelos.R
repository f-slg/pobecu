# Ejecutar desde la raíz. No descarga insumos ni reemplaza tablas oficiales.
pkgload::load_all(quiet = TRUE)
dir.create("validacion/modelos-poblacion", recursive = TRUE, showWarnings = FALSE)
carpeta <- "validacion/modelos-poblacion"
niveles <- c("nacional", "provincia", "canton", "parroquia")
fuentes <- setNames(lapply(niveles, poblacion), niveles)
claves <- c(nacional = NA, provincia = "dpa_provin", canton = "dpa_canton", parroquia = "dpa_parroq")
resultados <- list()
for (sentido in c("prospectiva", "retrospectiva")) {
  # Truncar todos los niveles evita que el total padre revele el año retenido.
  entrenar <- if (sentido == "prospectiva") 1950:2025 else 2015:2050
  evaluar <- if (sentido == "prospectiva") 2026:2035 else 2010:2014
  m <- pob_ajustar(entrenamiento = entrenar)
  p <- pob_estimar("todos", evaluar, m, simulaciones = 100)
  for (n in niveles) {
    ref <- fuentes[[n]]; ref$codigo <- if (n == "nacional") "EC" else ref[[claves[n]]]
    test <- ref[ref$anio %in% evaluar, ]
    pred <- p[p$nivel == n, ]
    pred <- pred[match(paste(test$codigo,test$anio), paste(pred$codigo,pred$anio)), ]
    train <- ref[ref$anio %in% entrenar, ]
    ancla <- if(sentido == "prospectiva") max(train$anio) else min(train$anio)
    base <- train[train$anio == ancla, ]; base <- base[match(test$codigo,base$codigo), ]
    for (metodo in c("estructural_CLR", "constante")) {
      estimado <- if(metodo == "estructural_CLR") pred$poblacion else base$poblacion
      for (h in sort(unique(abs(test$anio-ancla)))) {
        ids <- abs(test$anio-ancla) == h
        error <- estimado[ids] - test$poblacion[ids]
        resultados[[length(resultados)+1L]] <- data.frame(sentido,nivel=n,metodo,horizonte=h,
          n=sum(ids), MAE=mean(abs(error)), RMSE=sqrt(mean(error^2)),
          WAPE=100*sum(abs(error))/sum(test$poblacion[ids]),
          cobertura_condicional=if(metodo=="estructural_CLR") mean(test$poblacion[ids] >= pred$limite_inferior[ids] &
            test$poblacion[ids] <= pred$limite_superior[ids]) else NA_real_)
      }
    }
  }
}
write.csv(do.call(rbind,resultados), file.path(carpeta,"validacion-temporal.csv"),row.names=FALSE)
# Auditoría completa de todas las unidades y años del escenario predeterminado.
m <- pob_ajustar()
p <- pob_estimar("todos", modelo=m, simulaciones=200)
write.csv(m$diagnosticos,file.path(carpeta,"diagnosticos.csv"),row.names=FALSE)
auditoria <- list()
for (n in niveles[-1]) {
  d <- p[p$nivel == n, ]
  sumas <- aggregate(poblacion ~ padre + anio,d,sum)
  j <- match(paste(sumas$padre,sumas$anio),paste(p$codigo,p$anio))
  error <- max(abs(sumas$poblacion-p$poblacion[j]))
  stopifnot(error==0)
  auditoria[[n]] <- data.frame(prueba=paste("suma",n), filas=nrow(sumas), diferencia_maxima=error)
}
for (n in niveles) {
  d <- m$tablas[[n]]; j <- match(paste(d$codigo,d$anio),paste(p$codigo,p$anio))
  error <- max(abs(d$poblacion-p$poblacion[j])); stopifnot(error==0)
  auditoria[[paste0(n,"_ref")]] <- data.frame(prueba=paste("referencia",n),filas=nrow(d),diferencia_maxima=error)
}
stopifnot(nrow(p)==1288*201,all(is.finite(p$poblacion)), all(p$poblacion>=0),
          all(p$poblacion==floor(p$poblacion)))
write.csv(do.call(rbind,auditoria), file.path(carpeta,"coherencia.csv"),row.names=FALSE)
# Resultados completos locales: excluidos del paquete y del control de versiones.
dir.create("data-raw/build",recursive=TRUE,showWarnings=FALSE)
saveRDS(m,"data-raw/build/modelo-poblacion.rds")
saveRDS(p,"data-raw/build/poblacion-1900-2100.rds")
writeLines(sub("[ \t]+$", "", capture.output(sessionInfo())),
           file.path(carpeta,"sesion.txt"))
