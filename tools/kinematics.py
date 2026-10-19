"""Cinemática del mecanismo servo -> horn -> enlace -> palanca de la mandíbula.

Lee los parámetros de params.scad (solo líneas `nombre = numero;`) y verifica
que el recorrido del servo cubra la apertura requerida de la mandíbula.
Plano Y-Z; la mandíbula gira alrededor del pivote (eje X) por un ángulo `a`
(a = 0 cerrada; positivo = abierta, el mentón baja).
"""
import math, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def load_params(path=ROOT / "params.scad"):
    p = {}
    for line in Path(path).read_text().splitlines():
        m = re.match(r"\s*(\w+)\s*=\s*(-?[\d.]+)\s*;", line)
        if m:
            p[m.group(1)] = float(m.group(2))
    return p


def lever_point(p, a_deg):
    """Posición (y, z) del orificio de la palanca con la mandíbula abierta a_deg."""
    dy, dz = p["lever_dy"], p["lever_dz"]
    a = math.radians(a_deg)
    # rotación -a alrededor de X (el mentón baja): y' = y cos a + z sin a ; z' = -y sin a + z cos a
    return (p["pivot_y"] + dy * math.cos(a) + dz * math.sin(a),
            p["pivot_z"] - dy * math.sin(a) + dz * math.cos(a))


def horn_point(p, theta_deg):
    ang = math.radians(p["horn_phi0"] - theta_deg)
    return (p["servo_y"] + p["horn_r"] * math.cos(ang),
            p["servo_z"] + p["horn_r"] * math.sin(ang))


def link_length(p):
    l0, h0 = lever_point(p, 0), horn_point(p, 0)
    return math.dist(l0, h0)


def jaw_angle_for(p, theta_deg, L):
    """Ángulo de mandíbula (0..60) con enlace de longitud L; devuelve None si no hay solución."""
    h = horn_point(p, theta_deg)
    best, besterr = None, 1e9
    for i in range(0, 6001):
        a = i * 0.01
        err = abs(math.dist(lever_point(p, a), h) - L)
        if err < besterr:
            best, besterr = a, err
    return best if besterr < 0.05 else None


if __name__ == "__main__":
    p = load_params()
    L = link_length(p)
    print(f"longitud de enlace calculada: {L:.2f} mm (params.scad: {p.get('link_len'):.2f})")
    ok = abs(L - p["link_len"]) < 0.05
    prev = -1
    for th in range(0, int(p["servo_travel"]) + 1, 10):
        a = jaw_angle_for(p, th, p["link_len"])
        print(f"servo {th:3d}° -> mandíbula {a}")
        if a is None or a < prev - 1e-6:
            ok = False
        prev = a if a is not None else prev
    a_end = jaw_angle_for(p, p["servo_travel"], p["link_len"])
    ok = ok and a_end is not None and a_end >= p["jaw_open_min"]
    print("OK" if ok else "FALLA")
    sys.exit(0 if ok else 1)
