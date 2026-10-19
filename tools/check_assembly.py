"""Verifica el ensamblaje: la mandíbula no intersecta el cráneo en todo su recorrido
y el servo (sin holgura) cabe en el alojamiento sin intersectar paredes ni mandíbula."""
import math, sys
from pathlib import Path
import numpy as np
import trimesh
from trimesh import transformations as T

sys.path.insert(0, str(Path(__file__).parent))
from kinematics import load_params, ROOT

p = load_params()
craneo = trimesh.load(ROOT / "stl" / "craneo.stl")
jaw0 = trimesh.load(ROOT / "stl" / "test" / "mandibula_ensamblada.stl")
servo = trimesh.load(ROOT / "stl" / "test" / "servo.stl")
pin = trimesh.load(ROOT / "stl" / "test" / "perno.stl")
cap = trimesh.load(ROOT / "stl" / "test" / "tapa_ensamblada.stl")
pivot = [0, p["pivot_y"], p["pivot_z"]]


def overlap(a, b):
    r = trimesh.boolean.intersection([a, b], engine="manifold")
    return 0.0 if r.is_empty else float(r.volume)


ok = True
step = 5
angles = list(range(0, int(p["jaw_open_max"]) + 1, step))
if angles[-1] != p["jaw_open_max"]:
    angles.append(p["jaw_open_max"])
for a in angles:
    jaw = jaw0.copy()
    jaw.apply_transform(T.rotation_matrix(-math.radians(a), [1, 0, 0], point=pivot))
    v = overlap(craneo, jaw) + overlap(pin, jaw)      # el perno de tope hace de tope mecánico
    vs = overlap(servo, jaw)
    good = v < 0.5 and vs < 0.5
    ok &= good
    print(f"mandíbula {a:5.1f}°: intersección con cráneo {v:8.3f} mm3, con servo {vs:8.3f} mm3 -> {'OK' if good else 'FALLA'}")

# canal del cable: sale por el extremo inferior del servo y baja por la base abierta
from trimesh.creation import box
z0 = p["servo_z"] - (p["servo_body_l"] - p["servo_shaft_off"])
cable = box(extents=[6, 4, z0 + 12], transform=T.translation_matrix([-8, p["servo_y"], (z0 - 12) / 2]))
cab = overlap(cable, craneo)
for a in angles:
    jaw = jaw0.copy()
    jaw.apply_transform(T.rotation_matrix(-math.radians(a), [1, 0, 0], point=pivot))
    cab += overlap(cable, jaw)
print(f"canal del cable libre (todos los ángulos): {cab:.3f} mm3 -> {'OK' if cab < 0.5 else 'FALLA'}")
ok &= cab < 0.5

# diámetro real de los orificios del eje
def hole_d(mesh, x, expected):
    sec = mesh.section(plane_origin=[x, 0, 0], plane_normal=[1, 0, 0])
    planar, to3d = sec.to_planar()
    poly = planar.polygons_full
    best = None
    for g in poly:
        for ring in g.interiors:
            from shapely.geometry import Polygon
            h = Polygon(ring)
            c = h.centroid
            c3 = (to3d @ [c.x, c.y, 0, 1])[:3]
            if abs(c3[1] - p["pivot_y"]) < 1.5 and abs(c3[2] - p["pivot_z"]) < 1.5:
                best = 2 * math.sqrt(h.area / math.pi)
    return best
for name, mesh, x, exp in (("cráneo (saliente +X)", craneo, 35, p["axle_d"] + 0.1),
                           ("mandíbula (rama +X)", jaw0, 22, p["axle_d"] + p["clearance"])):
    d = hole_d(mesh, x, exp)
    good = d is not None and abs(d - exp) < 0.08
    ok &= good
    print(f"orificio del eje en {name}: medido {d if d is None else round(d, 3)} mm, esperado {exp:.2f} mm -> {'OK' if good else 'FALLA'}")

vs_c = overlap(servo, craneo)
print(f"servo vs cráneo: {vs_c:.3f} mm3 -> {'OK' if vs_c < 0.5 else 'FALLA'}")
ok &= vs_c < 0.5
# --- Tapa: encaja sin intersectar el cuerpo ni el mecanismo ---
vc = overlap(craneo, cap)
vj = overlap(jaw0, cap) + overlap(servo, cap)
print(f"tapa vs cuerpo: {vc:.3f} mm3, vs mandíbula y servo: {vj:.3f} mm3 -> {'OK' if vc < 0.5 and vj < 0.5 else 'FALLA'}")
ok &= vc < 0.5 and vj < 0.5

# --- Instalación: la mandíbula sube por la base (sin perno); el servo baja desde arriba (sin tapa) y desliza hacia -X ---
def sweep(mesh, offsets, obstacles):
    worst = 0.0
    for off in offsets:
        m = mesh.copy(); m.apply_translation(off)
        worst = max(worst, max(overlap(o, m) for o in obstacles))
    return worst
jaw_path = [[0, 0, -dz] for dz in range(80, -1, -5)]
vjaw = sweep(jaw0, jaw_path, [craneo, servo])
print(f"subida de la mandíbula por la base: intersección máxima {vjaw:.3f} mm3 -> {'OK' if vjaw < 0.5 else 'FALLA'}")
ok &= vjaw < 0.5
servo_path = [[17, 0, dz] for dz in range(60, -1, -5)] + [[dx, 0, 0] for dx in range(17, -1, -1)]
vsv = sweep(servo, servo_path, [craneo, jaw0])
print(f"entrada del servo desde arriba y deslizamiento a su ventana: intersección máxima {vsv:.3f} mm3 -> {'OK' if vsv < 0.5 else 'FALLA'}")
ok &= vsv < 0.5

# --- Acceso: rayos a lo largo de -X desde fuera hasta cada tornillo ---
zc = z0 + p["servo_body_l"] / 2
targets = {"tornillo oreja inferior": (zc - p["servo_hole_span"] / 2, 8.0),
           "tornillo oreja superior": (zc + p["servo_hole_span"] / 2, 8.0),
           "tornillo del horn": (p["servo_z"], 17.0)}
obst = trimesh.util.concatenate([craneo, jaw0])
for name, (z, xt) in targets.items():
    # haz de 5 rayos (el eje y 4 puntos a 1.5 mm) para comprobar el paso de un destornillador de 3 mm
    free = True
    for dy, dz in [(0, 0), (1.5, 0), (-1.5, 0), (0, 1.5), (0, -1.5)]:
        o = [[90.0, p["servo_y"] + dy, z + dz]]
        hits, _, _ = obst.ray.intersects_location(o, [[-1, 0, 0]])
        if len(hits) and hits[:, 0].max() > xt:
            free = False
    print(f"acceso en línea recta a {name}: {'libre' if free else 'BLOQUEADO'} -> {'OK' if free else 'FALLA'}")
    ok &= free

sys.exit(0 if ok else 1)
