# Spec Delta

## Purpose

Define los rasgos anatómicos que hacen reconocible el modelo como un cráneo humano, manteniendo un acabado facetado (low poly) que se imprime con pocos soportes.

## ADDED Requirements

### Requirement: Rasgos anatómicos reconocibles
El cráneo SHALL incluir arco superciliar, órbitas con reborde, abertura nasal en forma de pera con puente nasal, pómulos, arcos cigomáticos y apófisis mastoides.

#### Scenario: Vista de frente y de lado
- **WHEN** se renderiza el modelo de frente y de perfil
- **THEN** cada rasgo de la lista es visible y distinguible como forma propia

### Requirement: Proporciones humanas
El neurocráneo SHALL tener una relación ancho/largo entre 0.72 y 0.85, y la altura de cada órbita SHALL ser entre 0.75 y 0.95 veces su anchura.

#### Scenario: Medición de proporciones
- **WHEN** se miden el ancho y el largo del neurocráneo en el STL
- **THEN** la relación ancho/largo está entre 0.72 y 0.85

### Requirement: Dentición completa alineada
Cada arco SHALL tener 14 dientes con forma según su tipo (incisivos, caninos, premolares y molares), y los dientes superiores e inferiores SHALL coincidir en posición con la mandíbula cerrada.

#### Scenario: Mandíbula cerrada
- **WHEN** la mandíbula está en 0°
- **THEN** cada diente inferior queda bajo su diente superior con una separación de 0.5 a 1 mm

### Requirement: Mandíbula con silueta anatómica
La mandíbula SHALL tener mentón, ángulo goniaco, apófisis coronoides y cóndilo en el eje de giro.

#### Scenario: Vista lateral de la mandíbula
- **WHEN** se observa la mandíbula de perfil
- **THEN** se distinguen el mentón, el ángulo, la coronoides y el cóndilo

### Requirement: Acabado facetado con presupuesto de polígonos
El cráneo SHALL tener entre 3000 y 9000 triángulos y la mandíbula entre 800 y 3000, con facetas planas visibles.

#### Scenario: Conteo de triángulos
- **WHEN** se cuentan los triángulos de cada STL exportado
- **THEN** ambos valores están dentro de su rango

### Requirement: Soportes documentados
La guía de impresión SHALL indicar en qué zonas se necesitan soportes (arcos cigomáticos, bordes de órbitas, mentón) y en cuáles no.

#### Scenario: Consulta de la guía
- **WHEN** se lee la sección de soportes del README
- **THEN** aparece cada zona con voladizo y se indica que el alojamiento del servo y los orificios del eje no los necesitan
