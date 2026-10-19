"""Verifica los requisitos de anatomía: proporciones, dentición, holgura de oclusión y presupuesto de polígonos."""
import re, sys
from pathlib import Path
import trimesh

ROOT = Path(__file__).resolve().parent.parent
src = (ROOT / "anatomy.scad").read_text()


def arr(name):
    m = re.search(rf"{name}\s*=\s*\[([^\]]*)\]", src)
    return [float(v) for v in m.group(1).split(",")]


ok = True
def report(label, good, detail):
    global ok
    ok &= bool(good)
    print(f"{label:34s} {detail} -> {'OK' if good else 'FALLA'}")

# 1. Proporciones del neurocráneo (ancho máximo / largo)
Y, W = arr("NC_Y"), arr("NC_W")
ratio = 2 * max(W) / (max(Y) - min(Y))
report("ancho/largo del neurocráneo", 0.72 <= ratio <= 0.85, f"{ratio:.3f} (0.72–0.85)")

# 2. Órbitas: altura / anchura medidas en el STL (corte a y = 74 mm de referencia, dentro de la órbita)
cr = trimesh.load(ROOT / "stl" / "craneo.stl")
s = 0.70
sec = cr.section(plane_origin=[0, 74 * s, 0], plane_normal=[0, 1, 0])
planar, to3d = sec.to_planar()
ratios = []
for poly in planar.polygons_full:
    for ring in poly.interiors:
        pts = [(to3d @ [x, y, 0, 1])[:3] for x, y in ring.coords]
        xs = [p[0] for p in pts]; zs = [p[2] for p in pts]
        cx = (min(xs) + max(xs)) / 2
        if 20 * s < abs(cx) < 45 * s:
            ratios.append((max(zs) - min(zs)) / (max(xs) - min(xs)))
good = len(ratios) == 2 and all(0.75 <= r <= 0.95 for r in ratios)
report("altura/anchura de las órbitas", good, f"{[round(r, 2) for r in ratios]} (0.75–0.95)")

# 3. Dentición: 7 dientes por lado en cada arco, mismas posiciones arriba y abajo
n = len(arr("T_W"))
report("dientes por arco", 2 * n == 14, f"{2 * n}")

# 4. Holgura de oclusión: puntas superiores en z = 0, coronas inferiores bajo ellas
jaw = trimesh.load(ROOT / "stl" / "test" / "mandibula_ensamblada.stl")
front = jaw.vertices[jaw.vertices[:, 1] > 24]          # solo la zona de los dientes
top_lower = front[:, 2].max()
gap = cr.bounds[0][2] - top_lower
report("holgura de oclusión (mm)", 0.5 <= gap <= 1.0, f"{gap:.2f} (0.5–1.0)")

# 5. Presupuesto de polígonos
for name, mesh, lo, hi in (("craneo", cr, 3000, 9000), ("mandibula", jaw, 800, 3000)):
    report(f"triángulos {name}", lo <= len(mesh.faces) <= hi, f"{len(mesh.faces)} ({lo}–{hi})")

sys.exit(0 if ok else 1)
