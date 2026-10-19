# Tasks

## 1. Estructura y parámetros

- [x] 1.1 Crear `skull.scad` con parámetros globales (escala por defecto 0.70, holguras, dimensiones del servo, diámetro del eje) y verificar que `openscad -o /dev/null skull.scad` renderiza sin errores
- [x] 1.2 Crear un script `export.sh` que genere un STL por pieza y verificar que se crean los archivos esperados en `stl/`

## 2. Cráneo

- [x] 2.1 Modelar calvaria con órbitas, cavidad nasal, pómulos y maxilar superior con dientes, y verificar visualmente la vista previa y que el STL es manifold
- [x] 2.2 Dividir el cráneo en piezas imprimibles y verificar que cada caja envolvente es ≤ 150 mm a escala 70 %
- [x] 2.3 Añadir orificios del eje de la mandíbula (coaxiales) y verificar el diámetro con la holgura configurada

## 3. Mandíbula

- [x] 3.1 Modelar mandíbula con dientes inferiores y ramas con orificios del eje, y verificar que el STL es manifold
- [x] 3.2 Añadir topes mecánicos de 0° y 25° y verificar con un script de OpenSCAD que no hay intersección a pasos de 5°

## 4. Servo y transmisión

- [x] 4.1 Modelar cavidad del servo SG90/MG90S con orejas, tornillos y paso de cable, y verificar que el volumen del servo (con holgura) cabe sin intersectar las paredes
- [x] 4.2 Diseñar el brazo de la mandíbula, el horn y la varilla, y verificar con una animación o barrido que el servo cubre el rango 0–25° sin atascos
- [x] 4.3 Verificar que el cable sale sin interferir con la mandíbula en todo el recorrido

## 5. Documentación e integración

- [x] 5.1 Escribir `README.md` con lista de materiales, orientación de impresión, ajustes sugeridos y pasos de ensamblaje, y verificar que cada pieza aparece con su orientación
- [ ] 5.2 Imprimir y ensamblar un prototipo, y verificar que la mandíbula se abre y cierra con el servo accionado desde un probador de servos
- [x] 5.3 Ejecutar `openspec validate add-articulated-skull-model` y verificar que no reporta errores

## 6. Realismo anatómico

- [x] 6.1 Crear `anatomy.scad` con perfiles y puntos de referencia, y generar el neurocráneo lofteado; verificar que el STL es cerrado, tiene base plana en z = 0 y relación ancho/largo entre 0.72 y 0.85
- [x] 6.2 Modelar frente, arco superciliar, órbitas, abertura nasal en pera y maxilar; verificar con renders de frente y de lado que cada rasgo es distinguible
- [x] 6.3 Modelar hueso y arco cigomáticos que absorban el saliente del eje, y apófisis mastoides; verificar con `tools/check_assembly.py` que no hay colisiones con la mandíbula entre 0° y 30°
- [x] 6.4 Generar la dentición completa de 14 dientes por arco con formas por tipo; verificar con un script que la separación superior–inferior cerrada está entre 0.5 y 1 mm
- [x] 6.5 Rediseñar la mandíbula con mentón, ángulo, coronoides y cóndilo manteniendo grosor de rama, pivote, palanca y tope; verificar que `tools/check_assembly.py` y `tools/kinematics.py` siguen pasando
- [x] 6.6 Añadir al verificador el presupuesto de triángulos y verificar que cráneo (3000–9000) y mandíbula (800–3000) cumplen
- [x] 6.7 Actualizar el README con las zonas que llevan soporte, añadir el interruptor «Aristas» al visor y republicarlo; verificar que el visor carga sin errores de consola

## 7. Ensamblaje por una persona

- [x] 7.1 Dividir el cráneo con una tapa removible de borde de centrado y verificar que ambas piezas son mallas cerradas, que la tapa no intersecta el cuerpo y que cada una cabe en 150 mm
- [x] 7.2 Sustituir el saliente del tope por un orificio con perno extraíble y verificar que la mandíbula sube por la base sin colisión y que los topes siguen actuando a 0° y 30°
- [x] 7.3 Añadir orificios de acceso a los dos tornillos del servo y al del horn y verificar con rayos que la línea de acceso está libre
- [x] 7.4 Verificar que el servo entra por la base hasta su ventana sin colisión y que el cable queda libre
- [x] 7.5 Actualizar README (orden de montaje, tapa, perno, orificios), el visor con la tapa, y verificar que todos los chequeos pasan
