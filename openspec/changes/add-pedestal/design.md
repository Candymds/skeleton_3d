# Design

## Context

El cráneo (escala 70 %) tiene la base abierta: un aro de unos 3 mm en los lados (|x| ≈ 31.5–35, y de −34 a +22). La mandíbula ocupa |x| ≤ 25.3 y, en su recorrido de 0° a 30°, baja hasta z ≈ −50 y llega atrás hasta y ≈ −35. Delante de y = +22 la mandíbula está justo bajo el maxilar, así que solo se puede apoyar el cráneo por los lados y por detrás.

## Goals / Non-Goals

**Goals:**
- Que el cráneo no se mueva al hablar, sin cambiar sus piezas.
- Que el ESP32, la batería, el audio y el lastre queden dentro del soporte.
- Piezas imprimibles sin soportes en una cama de 150 × 150 mm.

**Non-Goals:**
- Firmware y esquema eléctrico.
- Aspecto decorativo (lápida, vértebras): el pedestal es liso y se puede decorar después.

## Decisions

- **Pedestal hueco con pozo central** en lugar de placa lastrada (la mandíbula chocaría) o de columna trasera (cráneo en voladizo y cambio en la base del cráneo).
- **Ranura de apoyo calculada con el propio cráneo:** `pedestal.scad` hace `use <skull.scad>` y talla la unión de cortes horizontales de `cranium()` entre z = 0 y `ped_seat`, ampliada con `clearance`. Sigue cualquier cambio de la geometría del cráneo. Importar `stl/craneo.stl` se descartó porque CGAL no puede proyectar esa malla.
- **Pozo sin suelo:** las paredes del pozo bajan hasta la tapa inferior, que hace de suelo. El cuerpo se imprime con la placa superior sobre la cama y no tiene voladizos.
- **Compartimentos comunicados** alrededor del pozo (laterales y trasero) para no tener que pasar cables entre ellos.
- **Altavoz en la tapa inferior, bajo la boca**, en la zona del pozo donde la mandíbula baja menos (y = −12).

## Risks / Trade-offs

- [El centro de masa estimado por volumen queda a 3.3 mm del borde delantero del apoyo] → La ranura retiene el cráneo en horizontal y la cara pesa menos de lo que indica su volumen; si cabecea al probarlo, añadir dos insertos M3 en la base del cráneo (cambio en `skull.scad`, fuera de este cambio).
- [La ranura depende de la holgura de cada impresora] → Usa el mismo `clearance` que las piezas móviles.
