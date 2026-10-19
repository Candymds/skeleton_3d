# skeleton_3d — cráneo con mandíbula articulada

Cráneo estilizado imprimible en 3D cuya mandíbula se mueve con un servo micro
(SG90 / MG90S) para simular que el esqueleto habla. Modelo paramétrico en OpenSCAD.

Escala por defecto: **70 %** de un cráneo humano adulto (≈ 13 cm de largo).
Cada pieza cabe en 150 × 150 × 150 mm. Estilo low poly con anatomía reconocible: órbitas, abertura nasal en pera, pómulos, arcos cigomáticos y dentición completa (14 dientes por arco).

## Piezas

| Archivo STL | Pieza | Orientación de impresión | Soportes |
|---|---|---|---|
| `stl/craneo.stl` | Cuerpo del cráneo: base, cara, dientes superiores, arcos cigomáticos, placa y alojamiento del servo, con el borde de centrado arriba | Tal cual está exportado: base plana (z = 0) sobre la cama, cúpula hacia arriba | **Sí, pocos y de árbol o «solo desde la cama»**: arcos cigomáticos, borde posterior de la base (sube desde la cama hacia el occipucio), arco superciliar, puente nasal y mastoides. **No**: alojamiento del servo, orificios del eje, órbitas ni la zona bajo la cara (puente corto sobre el paladar, entre los dientes) |
| `stl/tapa.stl` | Tapa superior (calota sobre las cejas) con ranura para el borde de centrado | Borde plano sobre la cama, cúpula hacia arriba | No |
| `stl/mandibula.stl` | Mandíbula con dientes, ramas con coronoides y cóndilo, y palanca | Tal cual: borde inferior plano sobre la cama, ramas verticales | **Solo en el ángulo goniaco** (borde inferior que sube hacia la rama). Los orificios del eje quedan horizontales y se puentean |
| `stl/enlace.stl` | Enlace horn → palanca | Plano | No |
| `stl/pedestal.stl` | Pedestal: caja hueca con el pozo de la mandíbula, la ranura de apoyo del cráneo y los compartimentos de la electrónica | Tal cual: placa superior sobre la cama, abierto hacia arriba | No |
| `stl/tapa_inferior.stl` | Tapa inferior del pedestal con el aro del altavoz | Tal cual: plana sobre la cama | No |

`stl/test/` contiene mallas solo para verificación (no se imprimen).

Ajustes sugeridos: PLA o PETG, capa 0.2 mm, 3 perímetros, relleno 15 %.
Si tus piezas móviles quedan duras o flojas, cambia `clearance` en `params.scad`.

## Materiales

- 1 servo SG90 o MG90S con su horn de un brazo, 2 tornillos de las orejas y el tornillo del horn (autorroscantes ≈ 2 × 8 mm).
- 2 ejes de mandíbula: filamento de 1.75 mm (o pernos M3 si cambias `axle_d` a 3), de ≈ 20 mm cada uno.
- 1 perno de tope: filamento de 1.75 mm, de ≈ 14 mm.
- 2 alfileres o clips de ≈ 1.5 mm para el enlace (`link_pin_d`), de ≈ 8 mm.
- Un destornillador recto de punta fina (PH0) y unas pinzas.
- Opcional: una tira de cinta de enmascarar si la tapa queda holgada. No hace falta pegamento.

Para el pedestal:

- 4 insertos de latón M3 (orificio de 4.2 mm, 6 mm de largo) y 4 tornillos M3 × 8 de cabeza avellanada.
- 300–400 g de lastre (tuercas o arandelas M10–M12, o perdigones en bolsa) y 4 patas de goma adhesivas.
- Electrónica sugerida: ESP32 (DevKit o S3/C3 mini), batería 18650 con protección y portapilas, módulo de carga USB-C con salida de 5 V y al menos 1 A (tipo IP5306), interruptor de Ø 6 mm, condensador de 1000 µF entre 5 V y GND del servo, alargador de servo de 15 cm.
- Opcional, para la voz: amplificador I2S MAX98357A y altavoz de 40 mm (4–8 Ω, 2–3 W, hasta 20 mm de fondo).

## Ensamblaje (una persona, sin pegar piezas)

El cráneo es un cuerpo y una tapa que se separan a la altura de las cejas. Todo el montaje se hace con la tapa retirada.

1. Quita los soportes de las piezas impresas (arcos cigomáticos, ceja, puente nasal, borde trasero y ángulo de la mandíbula). Pasa un filamento por los orificios de eje para limpiarlos.
2. **Mandíbula:** súbela por la base abierta hasta alinear los orificios de las ramas con los salientes laterales. Inserta un eje de filamento en cada lado desde fuera. El perno de tope todavía no.
3. **Servo:** bájalo desde arriba, con el cable hacia la base, a la derecha de la placa, y deslízalo hacia la izquierda hasta que las orejas apoyen en la placa. Atornilla las dos orejas con el destornillador recto por el orificio de abajo y el de arriba del lado derecho trasero del cráneo (el del centro es para el tornillo del horn).
4. **Cable:** pásalo por el canal de la placa y déjalo salir por la base abierta, detrás de la mandíbula. El conector de 3 pines pasa por la base. Conéctalo a tu placa de control, que queda fuera del cráneo (en el pedestal, ver más abajo).
5. **Horn:** con el servo centrado en 0°, colócalo con el brazo apuntando hacia arriba y ligeramente hacia atrás (105° desde +Y) y atorníllalo por el orificio del centro del costado.
6. **Enlace:** une el orificio del horn y el de la palanca con los alfileres, colocados con pinzas desde arriba.
7. **Perno de tope:** inserta el perno de 14 mm desde dentro, por la ranura de la rama hasta el orificio de la almohadilla, y comprueba que la mandíbula se mueve de 0° a 30°.
8. Coloca la tapa: el borde de centrado encaja a presión. La muesca trasera sirve para sacarla con una punta plana.
9. Limita el servo por software a 0°–60°: ese recorrido abre la mandíbula ≈ 30°.

### Pedestal

El cráneo no se apoya en su base sino en la mandíbula, que cuelga por debajo: sobre una mesa se vuelca al abrir la boca. El pedestal lo levanta y deja la mandíbula libre en un pozo central.

1. Inserta en caliente los 4 insertos M3 en los pilares de las esquinas del pedestal.
2. Fija el altavoz (si lo usas) dentro del aro de la tapa inferior, mirando hacia arriba, y pasa sus cables al compartimento derecho por la muesca de la pared del pozo.
3. Coloca la electrónica: ESP32 en el compartimento izquierdo, amplificador a la derecha, batería y módulo de carga en la bandeja trasera, con el USB-C y el interruptor en sus orificios de la pared trasera. Reparte el lastre en el suelo de los compartimentos laterales.
4. Cierra con la tapa inferior (4 tornillos M3 × 8) y pega las patas de goma.
5. Con el cráneo ya montado, baja el cable del servo por el pozo, pásalo por la ranura de la pared trasera del pozo y conéctalo al alargador.
6. Apoya el cráneo con el aro de la base dentro de la ranura de la placa superior: encaja por los lados y por detrás, y la mandíbula queda colgando dentro del pozo.

Los tres orificios del costado trasero derecho son solo para el destornillador y se pueden tapar con cinta o pintura.

## Parámetros y herramientas

Todos los parámetros están en `params.scad` (escala, holguras, medidas del servo, geometría del mecanismo y del pedestal).
La ranura del pedestal se calcula con la geometría del cráneo, así que sigue a cualquier cambio de escala o forma.

```bash
./export.sh                      # genera los STL
python3 tools/kinematics.py      # recorrido servo → mandíbula
python3 tools/check_stl.py       # mallas cerradas, un cuerpo, ≤ 150 mm
python3 tools/check_assembly.py  # colisiones, tapa, montaje, acceso a tornillos, cable, orificios
python3 tools/check_anatomy.py   # proporciones, dentición, oclusión, triángulos
python3 tools/check_pedestal.py  # apoyo y retención del cráneo, mandíbula libre, altavoz, cable, centro de masa
python3 tools/build_viewer.py    # regenera viewer.html (visor 3D)
```

Dependencias: OpenSCAD 2021.01+ y `pip install trimesh manifold3d numpy scipy networkx shapely rtree`.

Si cambias la geometría de la palanca, el horn o la posición del servo, recalcula `link_len`
con `python3 tools/kinematics.py` (imprime la longitud calculada).

## Estado

Verificado en simulación (ver arriba). Las zonas con soporte son una estimación. Pendiente: imprimir y ensamblar un prototipo físico.
