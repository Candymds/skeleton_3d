// Cráneo articulado con mandíbula accionada por servo SG90/MG90S.
// Ejes: X = ancho, Y = adelante (cara hacia +Y), Z = arriba.
// El plano z = 0 es la base plana del cráneo (apoya en la cama al imprimir).
//
// part = "assembly" | "cranium" | "mandible" | "link" | "servo_ghost"
include <params.scad>
include <anatomy.scad>

part      = "assembly";
jaw_angle = 0;      // apertura de la mandíbula en el ensamblaje (grados)
servo_deg = 0;      // giro del horn en el ensamblaje (grados)
$fn = 36;

s = skull_scale;
w_ref = wall / s;                 // pared expresada en unidades de referencia

gap_ref = 1;                      // separación entre dientes con la mandíbula cerrada

module sk() scale([s, s, s]) children();

// ---------------------------------------------------------------- cráneo
module vault(r = 0) { neuro(r); if (r > 0) nc_base_opening(r); }

module face() {
    translate([0, 45, 28]) scale([54, 45, 30]) sphere(1);
    for (sx = [-1, 1]) translate([sx * 47, 58, 20]) scale([9, 20, 9]) sphere(1);
}

module orbits() { orbit_cut(); }

module nose() { nasal_cut(); }

// Cavidad interior: solo la parte posterior (la cara queda maciza)
module cavity() {
    union() {
        intersection() {
            vault(w_ref);
            translate([-100, -200, -10]) cube([200, 238, 300]);
        }
        // sobre el plano de la tapa el cráneo es hueco en toda su longitud
        intersection() {
            neuro(w_ref);
            translate([-100, -200, cap_z / s - 1]) cube([200, 400, 300]);
        }
    }
}

// Borde de centrado: mitad interior de la pared, justo sobre el plano de corte
module lip() {
    intersection() {
        difference() { neuro(1.9); neuro(w_ref); }
        translate([-200, -200, cap_z / s - 0.7]) cube([400, 400, 0.7 + lip_h / s]);
    }
}

// ---- piezas absolutas (ya escaladas)
function pivot() = [0, pivot_y, pivot_z];

module xcyl(x0, x1, r, y, z) {          // cilindro con eje X
    translate([x0, y, z]) rotate([0, 90, 0]) cylinder(r = r, h = x1 - x0);
}

function stop_pt() = [pivot_y + stop_r * cos(stop_dir), pivot_z + stop_r * sin(stop_dir)];

module slab() {
    intersection() {
        sk() vault(0);
        translate([slab_x - slab_t, slab_y_back, 0])
            cube([slab_t, slab_y_front - slab_y_back, cap_z]);
    }
}

function body_z0() = servo_z - (servo_body_l - servo_shaft_off);
function body_z1() = servo_z + servo_shaft_off;

module servo_pocket() {
    c = clearance;
    translate([slab_x - slab_t - 1, servo_y - servo_body_w / 2 - c, body_z0() - c])
        cube([slab_t + 2, servo_body_w + 2 * c, servo_body_l + 2 * c]);
    // tornillos de las orejas
    zc = body_z0() + servo_body_l / 2;
    for (dz = [-1, 1]) xcyl(slab_x - slab_t - 1, slab_x + 0.01, servo_screw_d / 2, servo_y, zc + dz * servo_hole_span / 2);
    // canal para el cable hacia la base abierta
    translate([slab_x - slab_t - 1, servo_y - 2, -1]) cube([slab_t + 2, 4, body_z0()]);
}

module boss(sx) {
    // saliente que sostiene el eje; atraviesa la pared lateral
    x0 = sx > 0 ? 27 : -40;
    xcyl(x0, x0 + 13, 5.5, pivot_y, pivot_z);
}

module stop_pad() {    // solo lado +X
    p = stop_pt();
    hull() {
        xcyl(27, 33, 5.5, pivot_y, pivot_z);
        xcyl(27, 33, stop_peg_d / 2 + 1, p[0], p[1]);
    }
}

module cranium_body() {
    union() {
        intersection() {
            difference() {
                sk() union() { vault(0); midface(); brow(); nasal_bridge(); zygomatic_arch(); mastoid(); }
                sk() cavity();
                sk() translate([-80, 38, -5]) cube([160, 100, 16]);   // bajo la cara: solo quedan los dientes
            }
            translate([-200, -200, -10]) cube([400, 400, cap_z + 10]);   // el cuerpo termina en el plano de la tapa
        }
        sk() lip();
        sk() teeth(16, 0);
        slab();
        boss(1); boss(-1);
        stop_pad();
    }
}

// Orificios en la pared +X, alineados con los ejes de los tornillos de las orejas y del horn
module access_holes() {
    zc = body_z0() + servo_body_l / 2;
    for (z = [zc - servo_hole_span / 2, zc + servo_hole_span / 2, servo_z])
        xcyl(8, 70, access_d / 2, servo_y, z);
}

module cranium() {
    p = stop_pt();
    difference() {
        intersection() {
            cranium_body();
            translate([-200, -200, 0]) cube([400, 400, 400]);
        }
        sk() orbits();
        sk() nose();
        servo_pocket();
        access_holes();
        xcyl(19.5, 34, (stop_peg_d + 0.1) / 2, p[0], p[1]);          // perno de tope extraíble
        for (sx = [-1, 1]) xcyl(sx > 0 ? 24 : -45, sx > 0 ? 45 : -24, (axle_d + 0.1) / 2, pivot_y, pivot_z);
    }
}

// Tapa superior: calota sobre el plano de corte, con ranura para el borde de centrado
module cap_part() {
    cc = lip_clear / s;
    difference() {
        sk() difference() {
            intersection() {
                difference() { neuro(0); neuro(w_ref); }
                translate([-200, -200, cap_z / s]) cube([400, 400, 300]);
            }
            intersection() {
                difference() { neuro(1.9 - cc); neuro(w_ref + cc); }
                translate([-200, -200, cap_z / s - 1]) cube([400, 400, 1 + lip_h / s + 1]);
            }
        }
        translate([-4, -80, cap_z - 0.01]) cube([8, 50, 1.6]);          // muesca trasera para palanquear
    }
}

module stop_pin() { p = stop_pt(); xcyl(19.5, 33, stop_peg_d / 2, p[0], p[1]); }

// ---------------------------------------------------------------- mandíbula
function lever_pt() = [pivot_y + lever_dy, pivot_z + lever_dz];

// posición del tope en el sistema de la mandíbula para una apertura a
function stop_in_jaw(a) =
    let(p = stop_pt(), dy = p[0] - pivot_y, dz = p[1] - pivot_z)
    [pivot_y + dy * cos(a) - dz * sin(a), pivot_z + dy * sin(a) + dz * cos(a)];

module ramus(sx) {
    x0 = sx > 0 ? 20.1 : -25.2;
    hull() {
        xcyl(x0, x0 + 5.1, 5.5, pivot_y, pivot_z);                 // cóndilo
        xcyl(x0, x0 + 5.1, 2.8, 14, 15);                            // punta de la coronoides
        xcyl(x0, x0 + 5.1, 3, -13, 7);                              // borde posterior
        translate([x0, 9.5, -6.5]) cube([5.1, 5, 1]);               // borde anterior, unión con el cuerpo
        translate([x0, -19, -19]) cube([5.1, 4, 14]);               // ángulo goniaco
    }
}

module lever() {
    l = lever_pt();
    hull() {
        xcyl(20.1, 25.2, 5.5, pivot_y, pivot_z);
        xcyl(20.1, 25.2, 4, l[0], l[1]);
    }
}

module stop_slot() {
    k = (0.4 / stop_r) * 180 / PI;          // holgura del tope en grados
    n = 12;
    for (i = [0 : n - 1]) {
        a0 = k + (jaw_open_max - 2 * k) * i / n;
        a1 = k + (jaw_open_max - 2 * k) * (i + 1) / n;
        hull() {
            xcyl(19, 26, stop_peg_d / 2 + 0.4, stop_in_jaw(a0)[0], stop_in_jaw(a0)[1]);
            xcyl(19, 26, stop_peg_d / 2 + 0.4, stop_in_jaw(a1)[0], stop_in_jaw(a1)[1]);
        }
    }
}

module mandible() {
    difference() {
        union() {
            sk() { jaw_body(); teeth(-11, -gap_ref); }
            ramus(1); ramus(-1);
            lever();
        }
        // escotadura sigmoidea entre cóndilo y coronoides
        for (sx = [-1, 1]) xcyl(sx > 0 ? 19 : -26, sx > 0 ? 26 : -19, 4.5, 7, 20.5);
        for (sx = [-1, 1]) xcyl(sx > 0 ? 19 : -26, sx > 0 ? 26 : -19, (axle_d + clearance) / 2, pivot_y, pivot_z);
        xcyl(19, 26, (link_pin_d + clearance) / 2, lever_pt()[0], lever_pt()[1]);
        stop_slot();
    }
}

// ---------------------------------------------------------------- enlace
function horn_pt(theta) = [servo_y + horn_r * cos(horn_phi0 - theta), servo_z + horn_r * sin(horn_phi0 - theta)];

module link_ass(theta) {
    h = horn_pt(theta);
    // el enlace se calcula con la longitud fija: la palanca real depende de jaw_angle
    // (en el ensamblaje se dibuja entre el horn y la palanca)
    l = lever_pt_at(jaw_angle);
    difference() {
        hull() {
            xcyl(16.8, 19.8, 3.5, h[0], h[1]);
            xcyl(16.8, 19.8, 3.5, l[0], l[1]);
        }
        xcyl(16, 21, (link_pin_d + clearance) / 2, h[0], h[1]);
        xcyl(16, 21, (link_pin_d + clearance) / 2, l[0], l[1]);
    }
}

function lever_pt_at(a) =
    [pivot_y + lever_dy * cos(a) + lever_dz * sin(a), pivot_z - lever_dy * sin(a) + lever_dz * cos(a)];

// Pieza imprimible: barra plana de longitud link_len entre centros
module link_part() {
    difference() {
        hull() {
            cylinder(r = 3.5, h = 3);
            translate([link_len, 0, 0]) cylinder(r = 3.5, h = 3);
        }
        translate([0, 0, -1]) cylinder(r = (link_pin_d + clearance) / 2, h = 5, $fn = 24);
        translate([link_len, 0, -1]) cylinder(r = (link_pin_d + clearance) / 2, h = 5, $fn = 24);
    }
}

// ---------------------------------------------------------------- servo (solo referencia)
module servo_ghost() {
    z0 = body_z0();
    x0 = slab_x - servo_ear_gap;
    translate([x0, servo_y - servo_body_w / 2, z0]) cube([servo_body_h, servo_body_w, servo_body_l]);
    translate([slab_x, servo_y - servo_body_w / 2, z0 - servo_ext]) cube([servo_ear_t, servo_body_w, servo_body_l + 2 * servo_ext]);
    xcyl(x0 + servo_body_h, x0 + servo_body_h + 4.5, 2.5, servo_y, servo_z);
}

module horn_ghost(theta) {
    h = horn_pt(theta);
    x0 = slab_x - servo_ear_gap + servo_body_h + 1;
    hull() {
        xcyl(x0, x0 + 3.5, 3.5, servo_y, servo_z);
        xcyl(x0, x0 + 1.5, 2, h[0], h[1]);
    }
}

// ---------------------------------------------------------------- salida
if (part == "cranium") cranium();
else if (part == "mandible") translate([0, 0, -JAW_BOTTOM * s]) mandible();
else if (part == "cap") translate([0, 0, -cap_z]) cap_part();
else if (part == "cap_assembled") cap_part();
else if (part == "stop_pin") stop_pin();
else if (part == "link") link_part();
else if (part == "servo_ghost") servo_ghost();
else if (part == "mandible_assembled") mandible();      // para pruebas: en su posición
else {
    color("ivory") cranium();
    color("white") cap_part();
    color("khaki") translate(pivot()) rotate([-jaw_angle, 0, 0]) translate(-pivot()) mandible();
    color("dimgray") { servo_ghost(); horn_ghost(servo_deg); }
    color("orange") link_ass(servo_deg);
}
