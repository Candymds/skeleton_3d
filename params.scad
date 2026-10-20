// Parámetros del cráneo articulado. Unidades: mm.
// Reglas: este archivo solo contiene asignaciones numéricas `nombre = valor;`
// porque tools/kinematics.py lo lee directamente.

// --- Escala y tolerancias ---
skull_scale = 0.70;     // escala del cráneo respecto a un cráneo humano adulto
wall        = 2.4;      // grosor de pared impreso (absoluto, no se escala)
clearance   = 0.30;     // holgura entre piezas móviles (absoluta)

// --- Eje de la mandíbula (perno M3 = 3.0, filamento = 1.75) ---
axle_d      = 1.75;

// --- Servo SG90 / MG90S (absolutas) ---
servo_body_l = 22.5;    // largo del cuerpo (eje largo)
servo_body_w = 12.2;    // ancho del cuerpo
servo_body_h = 22.7;    // alto del cuerpo (de la base a la tapa)
servo_ear_gap = 15.9;   // base del cuerpo a la cara inferior de las orejas
servo_ear_t  = 2.5;     // grosor de las orejas
servo_ext    = 5.0;     // cuánto sobresalen las orejas del cuerpo
servo_shaft_off = 5.5;  // distancia del eje al extremo del cuerpo (eje largo)
servo_screw_d = 1.6;    // piloto para tornillo autorroscante 2 x 8 mm

// --- Posición del servo en el cráneo (escala absoluta, eje de salida paralelo a X) ---
slab_x      = 5;        // cara de montaje (donde se apoyan las orejas)
slab_t      = 3;        // grosor de la placa
servo_y     = -38;      // eje del servo, coordenada Y
servo_z     = 28;       // eje del servo, coordenada Z

// --- Mandíbula (absolutas) ---
pivot_y     = -3.5;     // eje de giro de la mandíbula
pivot_z     = 17.5;
jaw_open_min = 25;      // apertura mínima requerida (grados)
jaw_open_max = 30;      // tope mecánico de apertura (grados)

// --- Palanca y enlace ---
lever_dy    = -6;       // orificio de la palanca relativo al pivote (mandíbula cerrada)
lever_dz    = 16;
horn_r      = 9;        // distancia del orificio del horn al eje del servo
horn_phi0   = 105;       // dirección del orificio del horn con la mandíbula cerrada (grados desde +Y)
servo_travel = 60;      // recorrido del servo usado (grados)
link_pin_d  = 1.5;      // alfiler / clip que une horn y palanca
link_len    = 30.99;     // calculado con tools/kinematics.py

// --- Detalles adicionales del servo y los topes (absolutas) ---
servo_hole_span = 27.5;   // distancia entre tornillos de las orejas
slab_y_front = -28.5;     // borde delantero de la placa del servo
slab_y_back  = -54;       // borde trasero (se recorta con el contorno del cráneo)
stop_r       = 9;         // radio del tope circular (distancia del pivote)
stop_peg_d   = 1.75;      // perno de tope extraíble (filamento de 1.75 mm)
stop_dir     = 255;       // dirección del tope respecto al pivote (grados desde +Y hacia +Z)

// --- Tapa superior removible y accesos (absolutas) ---
cap_z      = 63;        // altura del plano de corte de la tapa (sobre las cejas)
lip_h      = 3.5;       // altura del borde de centrado
lip_clear  = 0.15;      // holgura del borde de centrado
access_d   = 6;         // diámetro de los orificios de acceso a los tornillos

// --- Pedestal (absolutas, en coordenadas del cráneo: z = 0 es la base del cráneo) ---
ped_w      = 130;       // ancho (X)
ped_y0     = -75;       // cara trasera
ped_y1     = 60;        // cara delantera
ped_bottom = -66;       // cara inferior del cuerpo (la tapa inferior va debajo)
ped_seat   = 4;         // profundidad de la ranura donde se apoya el aro de la base del cráneo
ped_top_t  = 6;         // grosor de la placa superior (la ranura se talla en ella)
ped_wall   = 1.6;       // grosor de las paredes del pedestal (las del cráneo usan `wall`)
ped_r      = 8;         // radio de las esquinas verticales
well_hw    = 29;        // medio ancho del pozo de la mandíbula
well_y0    = -40;       // cara trasera del pozo
lid_t      = 2;         // grosor de la tapa inferior
insert_d   = 4.2;       // orificio para inserto de latón M3
insert_l   = 6;         // profundidad del orificio del inserto
boss_d     = 9;         // diámetro de los pilares de los insertos
lid_screw_d = 3.4;      // paso del tornillo M3 en la tapa inferior
spk_d      = 41;        // alojamiento del altavoz de 40 mm (en la tapa, dentro del pozo)
spk_y      = -12;       // centro del altavoz
usb_w      = 10;        // ventana del conector USB-C (pared trasera)
usb_h      = 4.5;
switch_d   = 6.5;       // orificio del interruptor (pared trasera)
