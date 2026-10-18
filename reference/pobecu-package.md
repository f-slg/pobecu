# pobecu: población del Ecuador por provincia, cantón y parroquia

Estimaciones y proyecciones oficiales de población del INEC (Revisión
2024) y una estimación parroquial derivada, con códigos DPA, listas para
calcular tasas y unir con otros datos.

## Details

### Funciones principales

- [`poblacion()`](https://f-slg.github.io/pobecu/reference/poblacion.md)
  consulta la población por nivel, año, sexo, área y edad.

- [`pob_unir()`](https://f-slg.github.io/pobecu/reference/pob_unir.md) y
  [`pob_tasa()`](https://f-slg.github.io/pobecu/reference/pob_tasa.md)
  unen la población con una tabla propia y calculan tasas.

- [`homologar_parroquia()`](https://f-slg.github.io/pobecu/reference/homologar_parroquia.md)
  convierte códigos de parroquias urbanas al de su cabecera cantonal, la
  unidad del Censo 2022.

- [dpa_pob](https://f-slg.github.io/pobecu/reference/dpa_pob.md) es el
  catálogo de códigos y nombres;
  [`buscar_pob()`](https://f-slg.github.io/pobecu/reference/buscar_pob.md)
  busca en él.

- [`pob_fuentes()`](https://f-slg.github.io/pobecu/reference/pob_fuentes.md)
  describe las fuentes y la versión de los datos.

### Datos

Las tablas por grupos quinquenales vienen dentro del paquete
([pob_nacional](https://f-slg.github.io/pobecu/reference/pob_inec.md),
[pob_provincias](https://f-slg.github.io/pobecu/reference/pob_inec.md),
[pob_cantones](https://f-slg.github.io/pobecu/reference/pob_inec.md),
[pob_parroquias](https://f-slg.github.io/pobecu/reference/pob_parroquias.md)).
Las edades simples se descargan la primera vez desde los releases del
repositorio en GitHub y se guardan en caché
([`pobecu_cache_dir()`](https://f-slg.github.io/pobecu/reference/pobecu_cache_dir.md)).

Cuando el INEC publique una nueva revisión de sus proyecciones, los
scripts de `data-raw/` regeneran todos los datos y se publica una nueva
versión del paquete.

## See also

Useful links:

- <https://github.com/f-slg/pobecu>

- Report bugs at <https://github.com/f-slg/pobecu/issues>

## Author

**Maintainer**: Ronald Fabricio Salas Guerrero
<fabriciosalasguerrero@gmail.com> \[copyright holder\]

Authors:

- Ronald Fabricio Salas Guerrero <fabriciosalasguerrero@gmail.com>
  \[copyright holder\]
