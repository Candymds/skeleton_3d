# Spec Delta

## Purpose

Define el soporte del cráneo: lo mantiene estable mientras la mandíbula se mueve y aloja la electrónica de control.

## ADDED Requirements

### Requirement: Mandíbula libre
El pedestal SHALL dejar libre todo el recorrido de la mandíbula (0° a `jaw_open_max`) sin que toque el pedestal, la tapa inferior ni un altavoz de 40 mm y 20 mm de fondo.

#### Scenario: Apertura completa
- **WHEN** la mandíbula se abre de 0° a 30° con el cráneo apoyado en el pedestal
- **THEN** no hay intersección entre la mandíbula y el pedestal

### Requirement: Apoyo y retención del cráneo
El pedestal SHALL recibir el aro de la base del cráneo en una ranura que lo retenga en horizontal, sin cambios en las piezas del cráneo.

#### Scenario: Cráneo colocado
- **WHEN** se coloca el cráneo en la ranura
- **THEN** apoya sin intersectar y no puede deslizarse 1 mm en ninguna dirección horizontal

### Requirement: Electrónica oculta
El pedestal SHALL tener compartimentos cerrados por una tapa inferior atornillada para ESP32, batería, módulo de carga, interruptor, audio y lastre, con paso para el cable del servo desde el pozo.

#### Scenario: Cable del servo
- **WHEN** el cable del servo sale por la base abierta del cráneo
- **THEN** baja al pozo y pasa a la bandeja trasera por la ranura de la pared del pozo

### Requirement: Imprimible
Cada pieza del pedestal SHALL ser una malla cerrada de un solo cuerpo que quepa en 150 × 150 × 150 mm y se imprima sin soportes.

#### Scenario: Exportación
- **WHEN** se ejecuta `./export.sh`
- **THEN** se generan `stl/pedestal.stl` y `stl/tapa_inferior.stl` y `tools/check_stl.py` los da por buenos
