# Tasks

## 1. Pedestal

- [x] 1.1 Añadir los parámetros del pedestal a `params.scad` y verificar que `tools/kinematics.py` sigue leyendo el archivo
- [x] 1.2 Crear `pedestal.scad` con el cuerpo, el pozo, la ranura de apoyo y la tapa inferior, y verificar que renderiza sin errores
- [x] 1.3 Exportar `stl/pedestal.stl` y `stl/tapa_inferior.stl` desde `export.sh` y verificar con `tools/check_stl.py`

## 2. Verificación

- [x] 2.1 Crear `tools/check_pedestal.py`: apoyo, retención, mandíbula libre, altavoz, cable y centro de masa
- [ ] 2.2 Imprimir el pedestal y comprobar con el cráneo real que no cabecea al hablar
