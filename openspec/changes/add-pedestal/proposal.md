# Proposal

## Why

Sobre una superficie plana el cráneo no se apoya en su base sino en el borde inferior de la mandíbula, que queda 21.7 mm por debajo (z = −21.7). Al abrir la boca la mandíbula no puede bajar y es el cráneo el que gira: se levanta por detrás y se vuelca. Hace falta un soporte que levante el cráneo, deje libre la mandíbula y esconda la electrónica de control.

## What Changes

- Nuevo `pedestal.scad`: caja hueca con un pozo central abierto por delante donde la mandíbula se mueve libre, una ranura en la placa superior que recibe el aro de la base del cráneo y compartimentos para ESP32, batería, audio y lastre.
- Tapa inferior atornillada con insertos M3 y un aro que centra un altavoz de 40 mm bajo la boca.
- Parámetros del pedestal en `params.scad`, STL exportados por `export.sh` y un nuevo `tools/check_pedestal.py`.
- No cambia ninguna pieza del cráneo.

## Capabilities

### New Capabilities
- `pedestal-base`: soporte estable del cráneo con la mandíbula libre y espacio para la electrónica.

### Modified Capabilities
<!-- Ninguna. -->

## Impact

- Código nuevo: `pedestal.scad`, `tools/check_pedestal.py`; cambios en `params.scad`, `export.sh`, `tools/check_stl.py` y el README.
- Hardware externo: insertos y tornillos M3, lastre (300–400 g) y, opcionalmente, ESP32, batería 18650 con módulo de carga, amplificador I2S y altavoz de 40 mm.
