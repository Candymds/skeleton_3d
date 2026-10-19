# Spec Delta

## Purpose

Define cómo se ensambla el modelo: una sola persona debe poder montar el servo, el mecanismo y la mandíbula sin pegar piezas, y el cráneo debe verse completo una vez cerrado.

## ADDED Requirements

### Requirement: Tapa superior removible
El cráneo SHALL tener una tapa superior que se retira y se coloca sin herramientas ni pegamento, con un borde de centrado, y que al estar colocada deja el cráneo con aspecto completo.

#### Scenario: Cerrar y abrir
- **WHEN** se coloca la tapa sobre el cuerpo
- **THEN** el borde de centrado encaja con holgura de 0.1 a 0.3 mm y no queda intersección de volúmenes entre tapa y cuerpo

### Requirement: Interior accesible con la tapa retirada
Con la tapa retirada, el servo, el horn, el enlace y el perno de tope SHALL poder instalarse sin desmontar otras piezas.

#### Scenario: Instalación del servo
- **WHEN** se baja el servo desde arriba con la tapa retirada y se desliza hacia su ventana siguiendo la trayectoria de montaje
- **THEN** no intersecta el cráneo en ningún punto del recorrido

### Requirement: Mandíbula instalable por la base
La mandíbula SHALL poder subirse por la base abierta hasta su posición sin que el perno de tope lo impida, y el perno de tope SHALL colocarse después como pieza separada.

#### Scenario: Subida de la mandíbula
- **WHEN** se mueve la mandíbula verticalmente desde 80 mm bajo la base hasta su posición con el perno de tope aún no colocado
- **THEN** no intersecta el cráneo ni el servo

### Requirement: Acceso en línea recta a los tornillos
Los dos tornillos de las orejas del servo y el tornillo del horn SHALL tener un orificio de acceso en la pared lateral alineado con su eje, de modo que un destornillador recto los alcance.

#### Scenario: Línea de acceso libre
- **WHEN** se traza un rayo a lo largo de X desde fuera del cráneo hasta cada tornillo
- **THEN** el rayo no choca con el cráneo, la mandíbula ni el servo

### Requirement: Cable hacia la placa de control
El cable del servo SHALL salir por la base abierta sin quedar pellizcado por la mandíbula en ningún ángulo, de modo que el conector pueda llegar a una placa externa.

#### Scenario: Recorrido del cable
- **WHEN** la mandíbula recorre su rango de 0° a 30°
- **THEN** el canal del cable permanece libre
