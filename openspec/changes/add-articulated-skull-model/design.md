# Design

## Context

Repositorio nuevo sin código. El modelo debe ser editable por parámetros y reproducible, por lo que se plantea en OpenSCAD. Ver proposal.md para la motivación y los supuestos de hardware.

## Goals / Non-Goals

**Goals:**
- Un único conjunto de archivos `.scad` paramétricos que genere todas las piezas.
- Mecanismo simple, imprimible en FDM y ensamblable con herramientas básicas.

**Non-Goals:**
- Firmware o electrónica de control (sincronización con audio, microcontrolador).
- Esqueleto completo (columna, costillas, extremidades).
- Anatomía exacta; se busca un cráneo reconocible y estilizado.

## Decisions

- **OpenSCAD en lugar de Blender/Fusion:** es texto versionable en git, paramétrico y exporta STL por línea de comandos. Alternativa: Blender (más orgánico, pero no paramétrico ni diffable).
- **Servo SG90/MG90S:** barato, común y suficiente para una mandíbula ligera. Alternativa: MG996R (más fuerte pero más grande); se deja como parámetro de dimensiones del alojamiento.
- **Servo en la calvaria, transmisión por varilla:** el servo va en la parte posterior-superior del cráneo con el horn conectado a la mandíbula mediante una varilla corta (filamento o alambre). Alternativa: servo directo sobre el eje de la mandíbula, descartada porque obliga a colocar el servo en la zona de las mejillas y complica la estética.
- **Eje de perno M3 o filamento 1.75 mm:** evita bisagras imprimidas en sitio, que suelen fallar con holguras pequeñas.
- **Partición del cráneo en calvaria + base/cara:** facilita instalar el servo y evita soportes en la cavidad. La mandíbula se imprime aparte con la rama apoyada sobre la cama.
- **Geometría anatómica low poly:** neurocráneo lofteado con `polyhedron()` a partir de cortes en forma de superelipse, y el resto de rasgos (órbitas, pera nasal, maxilar, arcos cigomáticos, dientes) con `hull()` de puntos de referencia guardados en `anatomy.scad`. Alternativa: esferoides y cilindros (primera versión), descartada porque no se lee como cráneo real. Se mantienen los invariantes del mecanismo (pivote, ramas, placa del servo).
- **Soportes aceptados:** se permiten voladizos en los arcos cigomáticos, el borde de las órbitas y el mentón; se documentan en el README.

## Risks / Trade-offs

- [El cráneo estilizado puede verse poco realista] → Iterar sobre parámetros de proporciones tras la primera impresión de prueba.
- [Holguras de impresión varían según impresora] → Parámetro de holgura y una pieza de prueba de calibración del eje.
- [Par insuficiente del SG90 con mandíbula pesada] → Mandíbula con paredes finas y relleno bajo; opción de cambiar el servo.
- [Varilla puede interferir con la cavidad craneal] → Verificar el recorrido en el modelo antes de imprimir.
- **Tapa superior removible (calota):** el cráneo se divide en un plano horizontal por encima de las cejas, como un cráneo de laboratorio. La tapa se imprime con el borde plano sobre la cama (sin soportes) y se fija con un borde de centrado por ajuste a presión. Alternativas: cráneo en dos mitades (obliga a pegar) y cráneo cerrado con orificios (seis operaciones a ciegas con herramientas largas).
- **Tres orificios en la pared trasera derecha:** los tornillos del servo y del horn tienen el eje en X, y un destornillador no los alcanza inclinado desde arriba. Los alfileres del enlace y el perno de tope se colocan con pinzas desde arriba y no necesitan orificio.
- **Perno de tope extraíble:** un perno de filamento de 1.75 mm sustituye al saliente integral para que la mandíbula pueda subir por la base.
