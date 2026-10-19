"""Genera viewer.html (visor 3D autocontenido) a partir de los STL y de params.scad."""
import base64, sys
from pathlib import Path
import numpy as np, trimesh

sys.path.insert(0, str(Path(__file__).parent))
import kinematics as k

ROOT = k.ROOT


def mesh(path):
    m = trimesh.load(path)
    m.merge_vertices()
    enc = lambda a: base64.b64encode(a.tobytes()).decode()
    return {"v": enc(np.asarray(m.vertices, dtype="<f4")), "i": enc(np.asarray(m.faces, dtype="<u4"))}


p = k.load_params()
L = p["link_len"]
table = [round(k.jaw_angle_for(p, t, L), 3) for t in range(0, int(p["servo_travel"]) + 1)]
keys = ["pivot_y", "pivot_z", "lever_dy", "lever_dz", "servo_y", "servo_z", "horn_r", "horn_phi0", "servo_travel"]
import json
data = {
    "params": {x: p[x] for x in keys},
    "table": table,
    "cranium": mesh(ROOT / "stl" / "craneo.stl"),
    "cap": mesh(ROOT / "stl" / "test" / "tapa_ensamblada.stl"),
    "jaw": mesh(ROOT / "stl" / "test" / "mandibula_ensamblada.stl"),
    "servo": mesh(ROOT / "stl" / "test" / "servo.stl"),
}
cr = trimesh.util.concatenate([trimesh.load(ROOT / "stl" / "craneo.stl"), trimesh.load(ROOT / "stl" / "test" / "tapa_ensamblada.stl")])
ext = cr.bounds[1] - cr.bounds[0]
dims = f"{ext[0]:.0f} × {ext[1]:.0f} × {ext[2]:.0f} mm"
html = (Path(__file__).parent / "viewer_template.html").read_text().replace("__DATA__", json.dumps(data)).replace("__DIMS__", dims)
(ROOT / "viewer.html").write_text(html)
print(f"viewer.html: {len(html)/1024:.0f} KB")
