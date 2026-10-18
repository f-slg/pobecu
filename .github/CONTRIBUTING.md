# Cómo contribuir a pobecu

¡Gracias por tu interés! Toda ayuda es bienvenida, desde avisar de un error
hasta proponer una función nueva.

## Preguntas

Si tienes una duda de uso ("¿cómo calculo...?", "¿qué significa...?"),
pregunta en [Discussions › Q&A](https://github.com/f-slg/pobecu/discussions/categories/q-a).
Así la respuesta queda disponible para todos.

## Reportar un problema

Abre un [issue](https://github.com/f-slg/pobecu/issues/new/choose) y elige la
plantilla que corresponda:

- **Reportar un error:** una función falla o da un resultado incorrecto.
  Incluye un ejemplo mínimo que se pueda copiar y ejecutar.
- **Problema con los datos:** algo no coincide con las cifras del INEC (o la estimación parroquial). Indica la fuente
  con la que comparas.
- **Proponer una mejora:** cuéntanos qué necesitas hacer.

## Enviar cambios

1. Haz un *fork* y crea una rama para tu cambio.
2. Si cambias funciones, actualiza la documentación con
   `roxygen2::roxygenise()` y agrega o ajusta tests en `tests/testthat/`.
3. Verifica que el paquete pase `R CMD check` sin errores ni advertencias.
4. Abre un *pull request* explicando qué cambia y por qué.

Los datos se generan con los scripts de [`data-raw/`](https://github.com/f-slg/pobecu/tree/main/data-raw/):
si propones un cambio en los datos, modifica el script y no los archivos
generados.

La documentación y los mensajes del paquete están en español.

## Código de conducta

Este proyecto sigue un [código de conducta](https://github.com/f-slg/pobecu/blob/main/.github/CODE_OF_CONDUCT.md)
(Contributor Covenant 2.1). Al participar, te comprometes a respetarlo.
