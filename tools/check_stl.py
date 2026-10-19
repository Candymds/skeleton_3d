"""Verifica las piezas imprimibles: malla cerrada, un solo cuerpo y tamaño máximo."""
import sys
from pathlib import Path
import trimesh

ROOT = Path(__file__).resolve().parent.parent
MAX_DIM = 150.0
PARTS = ["craneo", "tapa", "mandibula", "enlace", "pedestal", "tapa_inferior"]

ok = True
for name in PARTS:
    m = trimesh.load(ROOT / "stl" / f"{name}.stl")
    ext = m.bounds[1] - m.bounds[0]
    parts = len(m.split(only_watertight=False))
    good = m.is_watertight and m.is_winding_consistent and parts == 1 and max(ext) <= MAX_DIM and m.bounds[0][2] > -1e-6
    ok &= good
    print(f"{name:10s} cerrada={m.is_watertight} cuerpos={parts} caja={ext.round(1)} zmin={m.bounds[0][2]:.2f} vol={m.volume/1000:.1f}cm3 -> {'OK' if good else 'FALLA'}")
sys.exit(0 if ok else 1)
