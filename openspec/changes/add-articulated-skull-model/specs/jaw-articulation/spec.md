# Spec Delta

## Purpose

Define el comportamiento de la mandíbula móvil: su eje de giro, su rango de apertura y su ausencia de interferencias con el cráneo.

## ADDED Requirements

### Requirement: Mandíbula gira sobre un eje
La mandíbula SHALL articular sobre un único eje horizontal ubicado en la zona de la articulación temporomandibular, usando un perno M3 o filamento de 1.75 mm como eje.

#### Scenario: Ensamblaje del eje
- **WHEN** se inserta el eje por los orificios coaxiales del cráneo y la mandíbula
- **THEN** la mandíbula gira libremente sin juego lateral apreciable

### Requirement: Rango de apertura
La mandíbula SHALL tener un rango de apertura de al menos 0° (cerrada) a 25° (abierta), con tope mecánico en ambos extremos.

#### Scenario: Apertura máxima
- **WHEN** la mandíbula se abre hasta su tope
- **THEN** el ángulo medido en el mentón es de al menos 25° y no hay contacto entre piezas salvo en el tope diseñado

### Requirement: Sin colisiones en el recorrido
Ninguna parte de la mandíbula SHALL intersectar el cráneo en todo el rango de apertura.

#### Scenario: Verificación de recorrido
- **WHEN** se evalúa la mandíbula en pasos de 5° a lo largo del rango
- **THEN** la intersección de volúmenes entre mandíbula y cráneo es vacía, salvo el contacto en la posición cerrada
