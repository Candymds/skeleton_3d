"""Verifica el pedestal: el cráneo apoya en la ranura sin intersectar, la ranura lo retiene en
horizontal, la mandíbula se mueve libre en todo su recorrido y el centro de masa del conjunto
cae dentro del apoyo."""
import math, sys
from pathlib import Path
import numpy as np
import trimesh
from trimesh import transformations as T
from shapely.geometry import MultiPoint, Point

sys.path.insert(0, str(Path(__file__).parent))
from kinematics import load_params, ROOT

p = load_params()
craneo = trimesh.load(ROOT / "stl" / "craneo.stl")
cap = trimesh.load(ROOT / "stl" / "test" / "tapa_ensamblada.stl")
jaw0 = trimesh.load(ROOT / "stl" / "test" / "mandibula_ensamblada.stl")
ped = trimesh.load(ROOT / "stl" / "test" / "pedestal_ensamblado.stl")
lid = trimesh.load(ROOT / "stl" / "test" / "tapa_inferior_ensamblada.stl")
base = trimesh.util.concatenate([ped, lid])
pivot = [0, p["pivot_y"], p["pivot_z"]]


def overlap(a, b):
    r = trimesh.boolean.intersection([a, b], engine="manifold")
    return 0.0 if r.is_empty else float(r.volume)


def moved(mesh, off):
    m = mesh.copy(); m.apply_translation(off); return m


ok = True

v = overlap(craneo, ped)
print(f"cráneo en la ranura: intersección {v:.3f} mm3 -> {'OK' if v < 0.5 else 'FALLA'}")
ok &= v < 0.5

# apoyo: lo que el cráneo tocaría si bajara 0.3 mm más (huella del aro sobre el fondo de la ranura)
contact = trimesh.boolean.intersection([moved(craneo, [0, 0, -0.3]), ped], engine="manifold")
area = 0.0 if contact.is_empty else contact.volume / 0.3
print(f"superficie de apoyo del aro: {area:.0f} mm2 -> {'OK' if area > 200 else 'FALLA'}")
ok &= area > 200

# retención: desplazado 1 mm en cualquier dirección horizontal, el cráneo choca con la ranura
free = [d for d in ([1, 0, 0], [-1, 0, 0], [0, 1, 0], [0, -1, 0]) if overlap(moved(craneo, d), ped) < 0.5]
print(f"retención horizontal de la ranura: {'OK' if not free else 'FALLA, se desliza hacia ' + str(free)}")
ok &= not free

# la mandíbula se mueve libre dentro del pozo (y no toca la tapa inferior ni el altavoz)
angles = list(range(0, int(p["jaw_open_max"]) + 1, 5))
worst = 0.0
for a in angles:
    jaw = jaw0.copy()
    jaw.apply_transform(T.rotation_matrix(-math.radians(a), [1, 0, 0], point=pivot))
    worst = max(worst, overlap(jaw, base))
print(f"mandíbula de 0° a {angles[-1]}° dentro del pozo: intersección máxima {worst:.3f} mm3 -> {'OK' if worst < 0.5 else 'FALLA'}")
ok &= worst < 0.5

# altavoz de 40 mm y hasta 20 mm de fondo sobre la tapa inferior, con 3 mm de margen hasta la mandíbula
spk = trimesh.creation.cylinder(radius=p["spk_d"] / 2, height=23,
                                transform=T.translation_matrix([0, p["spk_y"], p["ped_bottom"] + 11.5]))
vs = 0.0
for a in angles:
    jaw = jaw0.copy()
    jaw.apply_transform(T.rotation_matrix(-math.radians(a), [1, 0, 0], point=pivot))
    vs = max(vs, overlap(jaw, spk))
print(f"altavoz de 20 mm de fondo con 3 mm de margen: intersección {vs:.3f} mm3 -> {'OK' if vs < 0.5 else 'FALLA'}")
ok &= vs < 0.5

# el cable del servo baja por la base abierta (como en check_assembly.py) hasta el pozo y cruza
# la pared trasera del pozo por su ranura hacia la bandeja trasera
from trimesh.creation import box
cable = trimesh.util.concatenate([
    box(extents=[6, 4, 12], transform=T.translation_matrix([-8, p["servo_y"], -6])),
    box(extents=[6, 10, 4], transform=T.translation_matrix([-8, p["well_y0"] - 2, -6]))])
vc = overlap(cable, base)
print(f"paso del cable del servo al compartimento trasero: intersección {vc:.3f} mm3 -> {'OK' if vc < 0.5 else 'FALLA'}")
ok &= vc < 0.5

# centro de masa (cráneo, tapa y mandíbula, misma densidad) sobre la huella de apoyo del aro
parts = [craneo, cap, jaw0]
vol = sum(m.volume for m in parts)
com = sum(m.center_mass * m.volume for m in parts) / vol
hull = MultiPoint([tuple(q[:2]) for q in contact.vertices]).convex_hull if area else None
inside = hull is not None and hull.contains(Point(com[0], com[1]))
margin = hull.exterior.distance(Point(com[0], com[1])) if hull is not None else 0.0
print(f"centro de masa del cráneo en x={com[0]:.1f} y={com[1]:.1f}: dentro del apoyo con {margin:.1f} mm de margen -> "
      f"{'OK' if inside else 'FALLA'}")
ok &= inside

sys.exit(0 if ok else 1)
