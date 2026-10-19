# Spec Delta

## Purpose

Define un cráneo reconocible, dividido en piezas que se pueden imprimir en una impresora 3D FDM doméstica y ensamblar sin modificaciones.

## ADDED Requirements

### Requirement: Cráneo dividido en piezas imprimibles
El modelo SHALL entregarse como piezas separadas (cráneo y mandíbula como mínimo), cada una exportable como STL independiente.

#### Scenario: Exportación por pieza
- **WHEN** se ejecuta el proceso de exportación
- **THEN** existe un archivo STL por cada pieza y cada uno es una malla cerrada (manifold)

### Requirement: Piezas caben en la cama de impresión
El modelo SHALL tener una escala por defecto de 70 % respecto a un cráneo humano adulto (aprox. 13 cm de largo), y cada pieza SHALL caber en un volumen de 150×150×150 mm con esa escala.

#### Scenario: Escala por defecto
- **WHEN** se exportan las piezas con la escala por defecto de 70 %
- **THEN** ninguna dimensión de la caja envolvente de ninguna pieza supera 150 mm

### Requirement: Escala y tolerancias paramétricas
El modelo SHALL exponer parámetros para la escala global y para la holgura entre piezas móviles.

#### Scenario: Cambio de escala
- **WHEN** se modifica el parámetro de escala
- **THEN** el alojamiento del servo y el eje mantienen sus dimensiones reales y el resto de la geometría se escala

### Requirement: Imprimible sin soportes críticos
Cada pieza SHALL poder orientarse para imprimirse sin soportes en las superficies de articulación y en el alojamiento del servo.

#### Scenario: Orientación documentada
- **WHEN** se consulta la guía de impresión
- **THEN** cada pieza indica su orientación recomendada y qué zonas requieren soportes, si alguna
