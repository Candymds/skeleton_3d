// Anatomía del cráneo en unidades de referencia (humano adulto, mm).
// Ejes: X ancho, Y adelante, Z arriba. z = 0 es el plano de oclusión (puntas de los dientes).
// Los perfiles se definen por cortes a lo largo de Y, de atrás hacia adelante.

// ----- Neurocráneo lofteado -----
//          occipucio ........................ bóveda ........................ frente
NC_Y  = [-96, -92, -84, -72, -58, -42, -24,  -4,  16,  36,  54,  68,  78,  85,  90];
NC_W  = [  6,  30,  46,  58,  65,  69,  70,  70,  67,  61,  55,  49,  44,  39,  33];  // semiancho superior
NC_ZT = [ 66,  78,  94, 108, 119, 126, 130, 132, 132, 130, 127, 122, 115, 104,  92];  // techo
NC_ZB = [ 54,  44,  28,  10,   4,  -2,  -2,  -2,  -2,  -2,  10,  28,  42,  56,  70];  // suelo
NC_WL = [  4,  14,  26,  40,  46,  48,  49,  49,  48,  46,  42,  38,  34,  30,  26];  // semiancho de la base
NC_N  = len(NC_Y);
NC_M  = 22;                  // puntos por anillo
nexp  = 2.6;                 // exponente de la superelipse de la bóveda

function sgnpow(v, e) = sign(v) * pow(abs(v), e);

// anillo i, contraído r hacia dentro (r > 0 para la cavidad)
function nc_ring(i, r = 0) =
    let(w = NC_W[i] - r, wl = NC_WL[i] - r, zt = NC_ZT[i] - r, zb = NC_ZB[i] + r,
        zm = max(zb + 6, min(62, (zt + zb) / 2)), d = zm - zb, hu = zt - zm,
        wm = wl + (w - wl) * 0.45)
    concat(
        [for (k = [0 : 12]) let(t = k * 15) [w * sgnpow(cos(t), 2 / nexp), zm + hu * sgnpow(sin(t), 2 / nexp)]],
        [[-w * 0.99, zm - 0.22 * d], [-wm, zm - 0.62 * d],
         [-wl, zb], [-wl * 0.5, zb], [0, zb], [wl * 0.5, zb], [wl, zb],
         [wm, zm - 0.62 * d], [w * 0.99, zm - 0.22 * d]]);

module neuro(r = 0) {
    pts = [for (i = [0 : NC_N - 1])
            let(y = NC_Y[i] + (i == 0 ? r : 0))
            for (p = nc_ring(i, r)) [p[0], y, p[1]]];
    M = NC_M; n = NC_N;
    faces = concat(
        [[for (j = [M - 1 : -1 : 0]) j]],
        [[for (j = [0 : M - 1]) (n - 1) * M + j]],
        [for (i = [0 : n - 2], j = [0 : M - 1], k = [0, 1])
            let(a = i * M + j, b = i * M + (j + 1) % M,
                c = (i + 1) * M + (j + 1) % M, d = (i + 1) * M + j)
            k == 0 ? [a, b, c] : [a, c, d]]);
    polyhedron(points = pts, faces = faces, convexity = 6);
}

// Abertura de la base: corta el suelo de la cavidad entre los cortes con suelo bajo (z <= 10)
module nc_base_opening(r) {
    idx = [for (i = [0 : NC_N - 1]) if (NC_ZB[i] <= 10 && NC_Y[i] < 40) i];
    left  = [for (i = idx) [-(NC_WL[i] - r), NC_Y[i]]];
    right = [for (i = [len(idx) - 1 : -1 : 0]) [NC_WL[idx[i]] - r, NC_Y[idx[i]]]];
    translate([0, 0, -5]) linear_extrude(20) polygon(concat(left, right));
}

// ----- Cara (todas las formas son hull() de pocos puntos para mantener el estilo facetado) -----
module pt(p, r = 2.5) translate(p) sphere(r, $fn = 6);
module chain(ps, r = 2.5) { for (i = [0 : len(ps) - 2]) hull() { pt(ps[i], r); pt(ps[i + 1], r); } }
module mirror_x() { children(); mirror([1, 0, 0]) children(); }

// Macizo facial: frontal, huesos propios, maxilar y pómulos (se talla con órbitas y nariz)
module midface() {
    hull() {
        mirror_x() {
            pt([46, 76, 78]); pt([52, 72, 50]); pt([58, 56, 40]); pt([56, 40, 36]);
            pt([36, 84, 16]); pt([38, 50, 13]); pt([20, 88, 40]); pt([20, 90, 24]); pt([50, 66, 56]);
        }
        pt([0, 90, 82]); pt([0, 90, 16]);
    }
}

// Arco superciliar y glabela
module brow() {
    mirror_x() chain([[3, 91, 81], [16, 92, 80], [31, 89, 78], [44, 80, 75]], 5);
}

// Puente nasal (huesos propios)
module nasal_bridge() {
    hull() {
        mirror_x() { pt([6, 90, 80], 3); pt([8, 97, 62], 3); }
        pt([0, 99, 58], 3);
    }
}

// Arco cigomático: del pómulo a la raíz sobre el eje de la mandíbula
module zygomatic_arch() {
    mirror_x() chain([[56, 56, 38], [62, 38, 34], [61, 14, 31], [57, -6, 28]], 6);
}

module mastoid() {
    mirror_x() hull() { pt([50, -27, 16], 5); translate([46, -32, 0]) cube([8, 10, 2]); }
}

module orbit_cut() {
    mirror_x() hull() {
        translate([31, 102, 58]) rotate([90, 0, 0]) scale([21, 17.5, 1]) rotate(22.5) cylinder(r = 1, h = 0.1, $fn = 8);
        translate([35, 52, 55]) rotate([90, 0, 0]) scale([12, 10, 1]) rotate(22.5) cylinder(r = 1, h = 0.1, $fn = 8);
    }
}

nasal_pear = [[0, 58], [5, 54], [8.5, 44], [12, 35], [9, 29], [3, 28], [0, 32],
              [-3, 28], [-9, 29], [-12, 35], [-8.5, 44], [-5, 54]];
module nasal_cut() {
    translate([0, 112, 43]) rotate([90, 0, 0]) linear_extrude(height = 52, scale = 0.65)
        translate([0, -43]) polygon(nasal_pear);
}

// ----- Dentición: 7 dientes por lado (2 incisivos, canino, 2 premolares, 2 molares) -----
// Trayectoria: arco de elipse (a, b) centrado en (0, tc), último molar en el tramo recto.
teeth_a = 29; teeth_b = 35; teeth_cy = 45;
T_ANG  = [6, 19, 34, 50, 64, 78];                  // ángulo en la elipse de los 6 primeros
T_W    = [8, 6.5, 7.5, 7, 6.5, 10, 9.5];           // ancho
T_D    = [5.5, 5, 7, 8, 8, 10.5, 10.5];            // fondo
T_KIND = [0, 0, 1, 2, 2, 3, 3];                    // 0 incisivo, 1 canino, 2 premolar, 3 molar
function tooth_pos(k) = k < 6
    ? [teeth_a * sin(T_ANG[k]), teeth_cy + teeth_b * cos(T_ANG[k]),
       atan2(-teeth_b * sin(T_ANG[k]), teeth_a * cos(T_ANG[k]))]
    : [teeth_a, 42.3, -90];

// forma de la corona (ancho, fondo) en la punta según el tipo
function tip_wd(kind, w, d) =
    kind == 0 ? [w * 0.95, d * 0.30] :
    kind == 1 ? [w * 0.30, d * 0.30] :
    kind == 2 ? [w * 0.75, d * 0.65] : [w * 0.85, d * 0.80];

module slab_xy(w, d, z) translate([-w / 2, -d / 2, z - 0.05]) cube([w, d, 0.1]);

module tooth(k, attach, tip) {
    p = tooth_pos(k); w = T_W[k] + 0.8; d = T_D[k];
    t = tip_wd(T_KIND[k], w, d); mid = tip + (attach - tip) * 0.4;
    translate([p[0], p[1], 0]) rotate([0, 0, p[2]]) {
        hull() { slab_xy(w, d, attach); slab_xy(w * 0.97, d * 0.95, mid); }
        hull() { slab_xy(w * 0.97, d * 0.95, mid); slab_xy(t[0], t[1], tip); }
    }
}

module teeth(attach, tip) {
    for (k = [0 : 6]) {
        tooth(k, attach, tip);
        mirror([1, 0, 0]) tooth(k, attach, tip);
    }
}

// ----- Cuerpo de la mandíbula (referencia). Cada punto: [x, y, z_inferior, fondo] -----
// El borde inferior es plano (z = -31) hasta el ángulo goniaco, donde sube hacia la rama.
JB = [[0, 84, -31, 10], [14, 80, -31, 8], [24, 70, -31, 8], [29, 55, -31, 8],
      [29, 38, -31, 8], [29, 15, -31, 8], [29, -8, -28, 8], [29, -24, -19, 8]];
JAW_BOTTOM = -31;
module jb_box(p) translate([p[0] - 7.2, p[1] - p[3] / 2, p[2]]) cube([14.4, p[3], -8 - p[2]]);
module jaw_body() {
    mirror_x() for (i = [0 : len(JB) - 2]) hull() { jb_box(JB[i]); jb_box(JB[i + 1]); }
    // mentón: faceta que sobresale hacia delante
    hull() { translate([-7.2, 86, JAW_BOTTOM]) cube([14.4, 4, 14]); translate([-7.2, 80, -12]) cube([14.4, 6, 4]); }
}
