# Evaluación de los escenarios territoriales 1900–2100

Reproducir desde la raíz con `Rscript data-raw/09_validar_modelos.R`.
No se descargan datos ni se modifican las tablas incluidas en el paquete.

- `coherencia.csv`: conservación exacta de 34043 referencias y 49446 sumas
  padre-año; diferencia máxima cero. Se calculan las 258888 filas de la
  jerarquía completa entre 1900 y 2100, con conteos enteros no negativos.
- `diagnosticos.csv`: 2576 ajustes (1288 series, dos direcciones): ventanas,
  pendientes, varianzas, convergencia, método efectivo y mensajes numéricos.
  La raíz usa logaritmos; el resto, CLR. Las pendientes retrospectivas están
  expresadas en tiempo invertido. Para convertirlas a tasas no basta con
  tratarlas como porcentajes poblacionales.
- `validacion-temporal.csv`: dos cortes temporales, todos los niveles truncados
  simultáneamente. Prospectiva: entrenamiento hasta 2025 y evaluación 2026–2035.
  Retrospectiva: entrenamiento desde 2015 y evaluación 2010–2014. El modelo
  estructural se compara con mantener constante la referencia del extremo.
  Las métricas comparan trayectorias del paquete, no nuevos censos.
- `sesion.txt`: versiones de R y bibliotecas utilizadas.

Configuración: ventana máxima 20 años; phi nacional 0.98, phi participaciones
0.95; semilla 2026. Evaluación temporal: 100 simulaciones y nivel nominal 95%.
Auditoría y gráficos: 200 simulaciones. Las bandas condicionan a parámetros y
estados fijos y omiten incertidumbre de las fuentes. Sus cuantiles no se suman.
Los RDS completos se escriben en `data-raw/build/`, fuera del paquete y de Git.

## Resultados y alcance

A cinco años prospectivos, el WAPE es 0.278% nacional, 0.303% provincial,
0.407% cantonal y 0.658% parroquial. En la retrospectiva es 1.358%, 1.460%,
1.477% y 1.544%, respectivamente. El referente constante obtiene mayor WAPE
para esos ocho casos. Esto no prueba superioridad universal sobre otros modelos.

La cobertura retrospectiva a cinco años es 83.3% provincial, 91.9% cantonal y
92.6% parroquial, inferior al 95% nominal. Prospectivamente es casi 100% para
ese horizonte. Las bandas no están calibradas como intervalos demográficos:
los errores están correlacionados territorialmente, los datos fuente están
suavizados y los modelos fuente no aportan aquí su incertidumbre. La cobertura
nacional por horizonte usa una sola observación, por lo que vale cero o uno y
no permite evaluar una tasa de cobertura estable.

En el ajuste completo, 2337 ajustes convergen con el modelo estructural libre,
145 con ruido de observación fijado a cero, 82 son constantes degeneradas y
12 usan el respaldo lineal explícito. El paquete advierte esos respaldos y
registra cada uno. Estos conteos pueden variar ligeramente entre plataformas
por diferencias numéricas del optimizador.

No hay validación local de 1900 ni de 2100. Las unidades se mantienen en la
referencia censal de 2022; no se reconstruyen jurisdicciones históricas. La
coherencia contable tampoco demuestra exactitud histórica o predictiva.
