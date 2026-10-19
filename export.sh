#!/usr/bin/env bash
# Genera un STL por pieza en stl/ (piezas imprimibles) y stl/test/ (piezas para verificación).
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p stl stl/test
render() { openscad -o "$2" -D "part=\"$1\"" "${3:-skull.scad}" >/dev/null 2>&1; echo "  $2"; }
echo "Piezas imprimibles:"
render cranium  stl/craneo.stl
render mandible stl/mandibula.stl
render cap      stl/tapa.stl
render link     stl/enlace.stl
render pedestal stl/pedestal.stl       pedestal.scad
render lid      stl/tapa_inferior.stl  pedestal.scad
echo "Piezas de verificación (no se imprimen):"
render mandible_assembled stl/test/mandibula_ensamblada.stl
render servo_ghost        stl/test/servo.stl
render cap_assembled      stl/test/tapa_ensamblada.stl
render stop_pin           stl/test/perno.stl
render pedestal_assembled  stl/test/pedestal_ensamblado.stl       pedestal.scad
render lid_assembled       stl/test/tapa_inferior_ensamblada.stl  pedestal.scad
