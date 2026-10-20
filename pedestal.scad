// Pedestal para el cráneo: caja hueca con un pozo central donde la mandíbula se mueve libre,
// una ranura en la placa superior que recibe el aro de la base del cráneo y espacio para la
// electrónica (ESP32, batería, audio) y el lastre alrededor del pozo.
// Mismos ejes que skull.scad: X = ancho, Y = adelante, Z = arriba; z = 0 es la base del cráneo.
//
// La ranura se calcula con el cráneo de skull.scad, así que sigue a cualquier cambio de su geometría.
//
// part = "assembly" | "pedestal" | "lid" | "pedestal_assembled" | "lid_assembled"
include <params.scad>
use <skull.scad>

part = "assembly";
$fn = 48;

ped_top = ped_seat;                        // cara superior del pedestal
ped_h   = ped_top - ped_bottom;
c       = clearance;
t       = ped_wall;

// ---------------------------------------------------------------- 2D
module rrect(x0, y0, x1, y1, r) {
    translate([x0, y0]) offset(r = r) offset(delta = -r) square([x1 - x0, y1 - y0]);
}
module outline(inset = 0) {
    rrect(-ped_w / 2 + inset, ped_y0 + inset, ped_w / 2 - inset, ped_y1 - inset, max(ped_r - inset, 0.5));
}
module zslab(z0, z1) { translate([0, 0, z0]) linear_extrude(z1 - z0) children(); }

// Huella del cráneo entre z = 0 y la cara superior, con holgura: unión de cortes horizontales
module skull_footprint() {
    offset(delta = c) union() {
        for (z = [0.05, 1, 2, 3, ped_seat - 0.05, ped_seat + 0.5])
            projection(cut = true) translate([0, 0, -z]) cranium();
    }
}

// ---------------------------------------------------------------- cuerpo
corners = [[-1, -1], [1, -1], [-1, 1], [1, 1]];
function boss_pos(k) = [k[0] * (ped_w / 2 - t - boss_d / 2 + 0.5),
                        k[1] > 0 ? ped_y1 - t - boss_d / 2 + 0.5 : ped_y0 + t + boss_d / 2 - 0.5];

module well() {          // pozo de la mandíbula: abierto arriba, abajo y por delante
    translate([-well_hw, well_y0, ped_bottom - 1]) cube([2 * well_hw, ped_y1 - well_y0 + 1, ped_h + 2]);
}

module cavity() {        // compartimentos alrededor del pozo, abiertos por abajo
    difference() {
        zslab(ped_bottom - 1, ped_top - ped_top_t) outline(t);
        translate([-well_hw - t, well_y0 - t, ped_bottom - 2]) cube([2 * (well_hw + t), ped_y1 - well_y0 + t + 1, ped_h + 4]);
        for (k = corners) translate([each boss_pos(k), ped_bottom - 2]) cylinder(d = boss_d, h = ped_h + 4);
    }
}

module pedestal_body() {
    difference() {
        zslab(ped_bottom, ped_top) outline();
        cavity();
        well();
        zslab(0, ped_top + 1) skull_footprint();                                // ranura de apoyo
        for (k = corners) translate([each boss_pos(k), ped_bottom - 1]) cylinder(d = insert_d, h = insert_l + 1);
        // paso del cable del servo: del pozo a la bandeja trasera
        translate([-14, well_y0 - t - 1, ped_top - ped_top_t - 8]) cube([12, t + 2, 8]);
        // paso de los cables del altavoz: del pozo al compartimento derecho
        translate([well_hw - 1, spk_y - 5, ped_bottom - 1]) cube([t + 2, 10, 7]);
        // pared trasera: USB-C e interruptor
        translate([-30, ped_y0 + t + 1, ped_bottom + 10]) rotate([90, 0, 0])
            linear_extrude(t + 2) offset(r = 1) square([usb_w - 2, usb_h - 2], center = true);
        translate([30, ped_y0 + t + 1, ped_bottom + 12]) rotate([90, 0, 0]) cylinder(d = switch_d, h = t + 2);
    }
}

// ---------------------------------------------------------------- tapa inferior
module lid_body() {
    difference() {
        union() {
            zslab(ped_bottom - lid_t, ped_bottom) outline();
            // aro que centra el altavoz (mira hacia arriba, hacia la boca)
            translate([0, spk_y, ped_bottom]) difference() {
                cylinder(d = spk_d + 2 * 1.6, h = 4);
                translate([0, 0, -1]) cylinder(d = spk_d, h = 6);
            }
        }
        for (k = corners) translate([each boss_pos(k), ped_bottom - lid_t - 1]) {
            cylinder(d = lid_screw_d, h = lid_t + 2);
            cylinder(d1 = 6.5, d2 = lid_screw_d, h = 1.6);                     // avellanado
        }
    }
}

// ---------------------------------------------------------------- salida
if (part == "pedestal") translate([0, 0, ped_top]) rotate([180, 0, 0]) pedestal_body();   // placa superior sobre la cama
else if (part == "lid") translate([0, 0, lid_t - ped_bottom]) lid_body();
else if (part == "pedestal_assembled") pedestal_body();
else if (part == "lid_assembled") lid_body();
else {
    color("dimgray") pedestal_body();
    color("gray") lid_body();
    color("ivory") import("stl/craneo.stl", convexity = 10);
    color("khaki") import("stl/test/mandibula_ensamblada.stl", convexity = 10);
}
