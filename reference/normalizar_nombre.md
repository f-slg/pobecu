# Normalizar nombres geográficos

Convierte nombres a una forma comparable: mayúsculas, sin tildes ni
diéresis, `Ñ` como `N`, sin signos de puntuación y con espacios simples.
Útil para unir tablas que escriben los nombres de forma distinta
("Cañar", "CANAR", "cañar ").

## Usage

``` r
normalizar_nombre(x)
```

## Arguments

- x:

  Vector de texto.

## Value

Vector de texto normalizado.

## Examples

``` r
normalizar_nombre(c("Cañar", "  san  José de Chimbo", "CHECA (JIDCAY)"))
#> [1] "CANAR"              "SAN JOSE DE CHIMBO" "CHECA JIDCAY"      
```
