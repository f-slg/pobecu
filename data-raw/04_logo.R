# -----------------------------------------------------------------------------
# pobecu · Logo (hexágono)
#
# Mismo estilo que geoecu (azul marino y dorado). Muestra la pirámide de
# población real del Ecuador en 2025 (barras) y la proyección a 2050
# (contorno punteado), a partir de los datos del paquete.
#
# Requisitos: pobecu instalado (o devtools::load_all())
# Uso:        Rscript data-raw/04_logo.R
# -----------------------------------------------------------------------------
library(grid)
library(pobecu)

azul   <- "#0F2233"
azul2  <- "#1B3A52"
dorado <- "#F2B705"
blanco <- "#F4F6F8"

# --- Datos: pirámide nacional por grupos quinquenales (85+ agrupado) ---------
piramide <- function(a) {
  x <- poblacion("nacional", anio = a, sexo = TRUE, edad = seq(0, 85, 5))
  list(h = x$poblacion[x$sexo == "hombre"], m = x$poblacion[x$sexo == "mujer"])
}
p25 <- piramide(2025)
p50 <- piramide(2050)
n <- length(p25$h)
escala <- max(unlist(c(p25, p50)))

# --- Lienzo ------------------------------------------------------------------
alto <- 1200
ancho <- round(alto * sqrt(3) / 2)
dir.create("man/figures", showWarnings = FALSE, recursive = TRUE)
png("man/figures/logo.png", width = ancho, height = alto, bg = "transparent",
    type = "cairo", antialias = "subpixel")

hexagono <- function(r) {
  ang <- pi / 2 + (0:5) * pi / 3
  list(x = 0.5 + r * cos(ang) * alto / ancho / 2, y = 0.5 + r * sin(ang) / 2)
}
h_ext <- hexagono(0.995)
h_med <- hexagono(0.955)
h_int <- hexagono(0.925)

grid.newpage()
grid.polygon(h_ext$x, h_ext$y, gp = gpar(fill = dorado, col = NA))
grid.polygon(h_med$x, h_med$y,
             gp = gpar(col = NA, fill = radialGradient(c(azul2, azul),
                                                       cx1 = 0.5, cy1 = 0.6, r2 = 0.7)))
grid.polygon(h_int$x, h_int$y,
             gp = gpar(fill = NA, col = adjustcolor(dorado, 0.35), lwd = 1.6))

# --- Pirámide ----------------------------------------------------------------
pushViewport(viewport(x = 0.5, y = 0.565, width = 0.58, height = 0.40))
alto_barra <- 1 / n
semi <- 0.47                  # media anchura disponible a cada lado
hueco <- 0.012                # separación central
for (i in seq_len(n)) {
  y <- (i - 1) * alto_barra
  wh <- semi * p25$h[i] / escala
  wm <- semi * p25$m[i] / escala
  grid.rect(x = 0.5 - hueco - wh, y = y, width = wh, height = alto_barra * 0.84,
            just = c("left", "bottom"), gp = gpar(fill = blanco, col = NA))
  grid.rect(x = 0.5 + hueco, y = y, width = wm, height = alto_barra * 0.84,
            just = c("left", "bottom"), gp = gpar(fill = dorado, col = NA))
}
# Contorno 2050 (escalones)
contorno <- function(v, lado) {
  xs <- 0.5 + lado * (hueco + semi * v / escala)
  ys <- (seq_len(n) - 1) * alto_barra
  list(x = rep(xs, each = 2), y = as.vector(rbind(ys, ys + alto_barra * 0.84)))
}
for (lado in c(-1, 1)) {
  cc <- contorno(if (lado < 0) p50$h else p50$m, lado)
  grid.lines(cc$x, cc$y, gp = gpar(col = adjustcolor(dorado, 0.9), lwd = 4.5,
                                   lty = "22", lineend = "round"))
}
grid.text("2025", x = 0.08, y = 1.04, just = "left",
          gp = gpar(col = adjustcolor(blanco, 0.8), fontsize = 30, fontface = "bold"))
grid.text("2050", x = 0.92, y = 1.04, just = "right",
          gp = gpar(col = adjustcolor(dorado, 0.9), fontsize = 30, fontface = "bold"))
popViewport()

# --- Nombre ------------------------------------------------------------------
tam <- 150
g_pob <- textGrob("pob", gp = gpar(fontsize = tam, fontface = "bold", col = blanco))
g_ecu <- textGrob("ecu", gp = gpar(fontsize = tam, fontface = "bold", col = dorado))
w1 <- convertWidth(grobWidth(g_pob), "npc", valueOnly = TRUE)
w2 <- convertWidth(grobWidth(g_ecu), "npc", valueOnly = TRUE)
x0 <- 0.5 - (w1 + w2) / 2
grid.text("pob", x = x0, y = 0.245, just = "left",
          gp = gpar(fontsize = tam, fontface = "bold", col = blanco))
grid.text("ecu", x = x0 + w1, y = 0.245, just = "left",
          gp = gpar(fontsize = tam, fontface = "bold", col = dorado))

invisible(dev.off())
message("Escrito: man/figures/logo.png")
