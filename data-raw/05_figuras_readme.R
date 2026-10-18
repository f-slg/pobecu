# -----------------------------------------------------------------------------
# pobecu · Figuras del README
#
# Genera las imágenes de man/figures/ que muestra el README a partir de los
# datos reales del paquete (nada simulado).
#
# Requisitos: pobecu, geoecu (con capas descargadas), ggplot2, patchwork
# Uso:        Rscript data-raw/05_figuras_readme.R
# -----------------------------------------------------------------------------
library(pobecu)
library(geoecu)
library(ggplot2)
library(patchwork)

dir_fig <- "man/figures"
azul   <- "#0F2233"
dorado <- "#F2B705"
gris   <- "grey45"

tema <- theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 12.5, color = azul),
        plot.subtitle = element_text(size = 9.5, color = gris),
        plot.caption = element_text(size = 8, color = "grey55"),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "white", color = NA))
tema_mapa <- theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 12.5, color = azul),
        plot.subtitle = element_text(size = 9.5, color = gris),
        legend.position = "bottom",
        legend.title = element_text(size = 9, color = "grey30"),
        legend.text = element_text(size = 8, color = "grey30"),
        plot.background = element_rect(fill = "white", color = NA))
mil <- scales::label_number(big.mark = " ")

# --- 1. Serie nacional y pirámides -------------------------------------------
nac <- poblacion("nacional")
nac$serie <- ifelse(nac$anio <= 2022, "Estimación", "Proyección")
g_serie <- ggplot(nac, aes(anio, poblacion / 1e6)) +
  annotate("rect", xmin = 2022.5, xmax = 2050.5, ymin = -Inf, ymax = Inf,
           fill = dorado, alpha = 0.08) +
  geom_line(aes(linetype = serie), color = azul, linewidth = 1) +
  geom_point(data = nac[nac$anio %in% c(1950, 2025, 2050), ], color = dorado, size = 2.4) +
  geom_text(data = nac[nac$anio %in% c(1950, 2025, 2050), ],
            aes(label = sprintf("%.1f M", poblacion / 1e6)), vjust = -1, size = 3.2,
            color = azul) +
  scale_linetype_manual(values = c("solid", "22"), name = NULL) +
  scale_y_continuous(limits = c(0, 24), expand = expansion(0)) +
  labs(title = "Ecuador, 1950-2050", subtitle = "millones de habitantes al 30 de junio",
       x = NULL, y = NULL) +
  tema + theme(legend.position = c(0.25, 0.85))

pir <- poblacion("nacional", anio = c(2025, 2050), sexo = TRUE, edad = seq(0, 90, 5))
pir$valor <- ifelse(pir$sexo == "hombre", -1, 1) * pir$poblacion / 1e3
pir$anio <- factor(pir$anio)
g_pir <- ggplot(pir, aes(valor, edad)) +
  geom_col(data = pir[pir$anio == "2025", ], aes(fill = sexo), width = 0.85) +
  geom_step(data = transform(pir[pir$anio == "2050", ], y = as.integer(edad)),
            aes(x = valor, y = y - 0.5, group = sexo), direction = "vh",
            color = azul, linewidth = 0.7, linetype = "22") +
  scale_fill_manual(values = c(hombre = "#8FA3B5", mujer = dorado), name = NULL) +
  scale_x_continuous(labels = function(x) mil(abs(x))) +
  scale_y_discrete(breaks = c("0-4", "20-24", "40-44", "60-64", "80-84")) +
  labs(title = "Pirámide 2025 y 2050", subtitle = "miles de personas; contorno: 2050",
       x = NULL, y = NULL) +
  tema + theme(legend.position = "bottom")

cant <- reubicar_galapagos(pob_mapa("canton", anio = 2025, crs = 32717))
prov <- reubicar_galapagos(read_provincias(crs = 32717))
g_dens <- ggplot(cant) +
  geom_sf(aes(fill = densidad), color = "white", linewidth = 0.08) +
  geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.2) +
  geom_sf(data = marco_galapagos(prov), fill = NA, color = "grey78", linewidth = 0.3) +
  scale_fill_gradientn(colours = c("#FFF4D2", "#F2C14E", "#D9822B", "#8C3B12", "#3B1A08"),
                       trans = "log10", breaks = c(1, 10, 100, 1000), labels = mil,
                       name = "hab/km²") +
  guides(fill = guide_colorbar(barwidth = 9, barheight = 0.5)) +
  labs(title = "221 cantones", subtitle = "densidad de población, 2025") +
  tema_mapa

principal <- (g_serie | g_pir | g_dens) + plot_layout(widths = c(1.15, 1, 1.05))
ggsave(file.path(dir_fig, "README-principal.png"), principal, width = 12.5, height = 4.4,
       dpi = 150, bg = "white")

# --- 2. Estimación parroquial: crecimiento 2025-2035 --------------------------
parr <- suppressMessages(pob_mapa("parroquia", anio = c(2025, 2035), crs = 32717))
parr <- suppressWarnings(reubicar_galapagos(parr))
a <- parr[parr$anio == 2025, ]
b <- sf::st_drop_geometry(parr[parr$anio == 2035, c("dpa_parroq", "poblacion")])
a$tasa <- 100 * ((b$poblacion[match(a$dpa_parroq, b$dpa_parroq)] / a$poblacion)^(1 / 10) - 1)
a$tasa_c <- pmax(pmin(a$tasa, 3), -3)
g_parr <- ggplot(a) +
  geom_sf(aes(fill = tasa_c), color = "white", linewidth = 0.03) +
  geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.2) +
  geom_sf(data = marco_galapagos(prov), fill = NA, color = "grey78", linewidth = 0.3) +
  scale_fill_gradient2(low = "#2E6E5C", mid = "#F7F3E8", high = "#C2410C", midpoint = 0,
                       limits = c(-3, 3), breaks = -3:3,
                       labels = c("≤ -3", "-2", "-1", "0", "1", "2", "≥ 3"),
                       name = "% anual") +
  guides(fill = guide_colorbar(barwidth = 11, barheight = 0.5)) +
  labs(title = "1042 parroquias", subtitle = "crecimiento medio anual proyectado 2025-2035") +
  tema_mapa

# Ejemplo del método: participación de las parroquias de un cantón
k <- "2403"   # Salinas (Santa Elena)
ej <- suppressMessages(poblacion("parroquia", canton = k))
tot <- tapply(ej$poblacion, ej$anio, sum)
ej$part <- 100 * ej$poblacion / tot[as.character(ej$anio)]
cen <- dpa_pob[dpa_pob$dpa_canton == k, ]
cen <- rbind(data.frame(parroquia = cen$parroquia, anio = 2010.9,
                        part = 100 * cen$censo_2010 / sum(cen$censo_2010)),
             data.frame(parroquia = cen$parroquia, anio = 2022.9,
                        part = 100 * cen$censo_2022 / sum(cen$censo_2022)))
fin <- ej[ej$anio == 2035, ]
g_met <- ggplot(ej, aes(anio, part, group = parroquia)) +
  annotate("rect", xmin = 2022.9, xmax = 2035.5, ymin = -Inf, ymax = Inf,
           fill = dorado, alpha = 0.08) +
  geom_line(color = azul, linewidth = 0.7) +
  geom_point(data = cen, color = dorado, size = 2.2) +
  geom_text(data = fin, aes(label = parroquia), hjust = 0, nudge_x = 0.3, size = 2.9,
            color = azul) +
  scale_x_continuous(limits = c(2010, 2042), breaks = c(2010, 2022, 2035)) +
  labs(title = "Método: participación en el cantón",
       subtitle = "Salinas (Santa Elena). Puntos: censos 2010 y 2022; líneas: curva logística",
       x = NULL, y = "% de la población del cantón") +
  tema

parroquial <- (g_met | g_parr) + plot_layout(widths = c(1, 1.1))
ggsave(file.path(dir_fig, "README-parroquias.png"), parroquial, width = 11.5, height = 4.8,
       dpi = 150, bg = "white")

# --- 3. Pirámides por año: 1950, 1990, 2025, 2050 ------------------------------
anios_pir <- c(1950, 1990, 2025, 2050)
pa <- poblacion("nacional", anio = anios_pir, sexo = TRUE, edad = seq(0, 90, 5))
pa$pct <- 100 * pa$poblacion / ave(pa$poblacion, pa$anio, FUN = sum)
pa$valor <- ifelse(pa$sexo == "hombre", -1, 1) * pa$pct
tot <- tapply(pa$poblacion, pa$anio, sum)
pa$panel <- factor(paste0(pa$anio, "\n", sprintf("%.1f millones", tot[as.character(pa$anio)] / 1e6),
                          ifelse(pa$anio > 2022, " (proyección)", "")))
pa$panel <- factor(pa$panel, levels = unique(pa$panel[order(pa$anio)]))
g_pirs <- ggplot(pa, aes(valor, edad, fill = sexo)) +
  geom_col(width = 0.88) +
  geom_vline(xintercept = 0, color = "white", linewidth = 0.6) +
  facet_wrap(~panel, nrow = 1) +
  scale_fill_manual(values = c(hombre = "#8FA3B5", mujer = dorado), name = NULL,
                    labels = c("Hombres", "Mujeres")) +
  scale_x_continuous(labels = function(x) paste0(abs(x), "%"), breaks = c(-8, -4, 0, 4, 8)) +
  scale_y_discrete(breaks = c("0-4", "20-24", "40-44", "60-64", "80-84")) +
  labs(title = "De pirámide a pilar: estructura por edad del Ecuador",
       subtitle = "porcentaje de la población total en cada grupo quinquenal (90+ agrupado)",
       x = NULL, y = NULL,
       caption = "Fuente: INEC, Estimaciones y Proyecciones de Población, Revisión 2024 · pobecu") +
  tema + theme(legend.position = "top", legend.justification = "left",
               strip.text = element_text(face = "bold", color = azul, size = 10))
ggsave(file.path(dir_fig, "README-piramides.png"), g_pirs, width = 12, height = 4.6,
       dpi = 150, bg = "white")

# --- 4. Grandes grupos de edad 1950-2050 y pirámide provincial ---------------
gg <- poblacion("nacional", edad = c(0, 15, 65))
gg$pct <- 100 * gg$poblacion / ave(gg$poblacion, gg$anio, FUN = sum)
gg$edad <- factor(gg$edad, levels = c("65+", "15-64", "0-14"),
                  labels = c("65 y más", "15 a 64", "0 a 14"))
g_grupos <- ggplot(gg, aes(anio, pct, fill = edad)) +
  geom_area(color = "white", linewidth = 0.3) +
  geom_vline(xintercept = 2022.5, linetype = "22", color = azul) +
  annotate("text", x = 2024, y = 96, label = "proyección", hjust = 0, size = 3,
           color = azul) +
  scale_fill_manual(values = c("65 y más" = "#8C3B12", "15 a 64" = "#F2C14E",
                               "0 a 14" = "#2E6E5C"), name = NULL) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), expand = expansion(0)) +
  scale_x_continuous(expand = expansion(0)) +
  labs(title = "Envejecimiento, 1950-2050",
       subtitle = "porcentaje de la población nacional por grandes grupos de edad",
       x = NULL, y = NULL) +
  tema + theme(legend.position = "top", legend.justification = "left")

# Pirámide provincial por área: urbano y rural de una provincia
pp <- poblacion("provincia", anio = 2025, provincia = "Chimborazo", sexo = TRUE,
                area = TRUE, edad = seq(0, 80, 5))
pp$valor <- ifelse(pp$sexo == "hombre", -1, 1) * pp$poblacion / 1e3
pp$area <- factor(pp$area, levels = c("urbana", "rural"), labels = c("Urbana", "Rural"))
g_area <- ggplot(pp, aes(valor, edad, fill = sexo)) +
  geom_col(width = 0.88) +
  facet_wrap(~area) +
  scale_fill_manual(values = c(hombre = "#8FA3B5", mujer = dorado), name = NULL,
                    labels = c("Hombres", "Mujeres")) +
  scale_x_continuous(labels = function(x) mil(abs(x))) +
  scale_y_discrete(breaks = c("0-4", "20-24", "40-44", "60-64", "80+")) +
  labs(title = "Chimborazo, 2025: área urbana y rural",
       subtitle = "miles de personas por sexo y grupo de edad", x = NULL, y = NULL) +
  tema + theme(legend.position = "top", legend.justification = "left",
               strip.text = element_text(face = "bold", color = azul))

estructura <- (g_grupos | g_area) + plot_layout(widths = c(1.1, 1))
ggsave(file.path(dir_fig, "README-estructura.png"), estructura, width = 12, height = 4.6,
       dpi = 150, bg = "white")

message("Figuras escritas en ", dir_fig)
