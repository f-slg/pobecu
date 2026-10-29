# Desde la raíz del repositorio: Rscript data-raw/08_generar_guia.R
# Ejecuta los ejemplos, guarda las figuras y genera Markdown, HTML y R.
pkgload::load_all(quiet = TRUE)
if (file.exists("data-raw/release/pobecu_edad_simple.rds")) {
  pobecu::pobecu_usar_carpeta("data-raw/release")
}
dir.create("inst/examples", recursive = TRUE, showWarnings = FALSE)
rmarkdown::render("README.Rmd", output_format = "github_document", quiet = TRUE,
                  envir = new.env(parent = globalenv()))
rmarkdown::render("README.Rmd", output_format = "html_document",
                  output_file = "guia-pobecu.html", quiet = TRUE,
                  envir = new.env(parent = globalenv()))
knitr::purl("README.Rmd", output = "inst/examples/guia-pobecu.R",
            documentation = 2, quiet = TRUE)
# knitr puede dejar espacios después de #> y #'; evita diferencias de formato.
for (archivo in c("README.md", "inst/examples/guia-pobecu.R")) {
  lineas <- readLines(archivo, warn = FALSE, encoding = "UTF-8")
  writeLines(sub("[ \t]+$", "", lineas), archivo, useBytes = TRUE)
}
