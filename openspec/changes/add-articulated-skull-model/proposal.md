# Proposal

## Why

Queremos un esqueleto que "hable" para decoración/animatrónica. El primer paso es un cráneo imprimible en 3D cuya mandíbula se mueva, diseñado desde el inicio para ser accionado por un servomotor, de modo que no haga falta modificar piezas después de imprimirlas.

## What Changes

- Nuevo modelo 3D paramétrico de un cráneo humano estilizado, dividido en piezas imprimibles (cráneo/calvaria y mandíbula).
- Mandíbula separada que articula sobre un eje en la zona de la articulación temporomandibular.
- Alojamiento para un servomotor micro (SG90/MG90S) dentro del cráneo, con tornillos de fijación y paso de cable.
- Mecanismo de transmisión (horn + varilla/enlace) que convierte el giro del servo en apertura y cierre de la mandíbula.
- Exportación de STL por pieza y guía de ensamblaje e impresión.

## Capabilities

### New Capabilities
- `skull-printable-model`: Geometría del cráneo dividida en piezas imprimibles en FDM sin soportes complejos, con tolerancias y parámetros ajustables.
- `jaw-articulation`: Mandíbula móvil con eje de giro y rango de apertura definidos, sin colisiones con el cráneo.
- `skull-anatomy`: Rasgos anatómicos reconocibles (órbitas, nariz, pómulos, arcos cigomáticos, dentición completa) con acabado facetado y presupuesto de polígonos.
- `assembly-access`: Ensamblaje por una persona sin pegamento: tapa superior removible, accesos a tornillos, mandíbula y servo instalables.
- `servo-drive`: Alojamiento del servo y transmisión que mueve la mandíbula para simular el habla.

### Modified Capabilities
<!-- Ninguna: el repositorio no tiene specs previas. -->

## Impact

- Código nuevo: archivos OpenSCAD (`.scad`) y STL exportados en el repositorio `skeleton_3d`.
- Hardware externo: 1 servo micro (SG90 o MG90S), 1 eje (perno M3 o filamento 1.75 mm), tornillos pequeños, y opcionalmente un microcontrolador para el control (fuera del alcance de este cambio).
- Supuestos (a confirmar en revisión): impresora FDM con cama ≥ 150×150 mm, material PLA/PETG, herramienta CAD OpenSCAD, y escala por defecto del 70 % de un cráneo humano adulto (~13 cm de largo), ajustable mediante un parámetro.
