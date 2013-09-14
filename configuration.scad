$fn=24;

// Standard screws with slightly wider holes
hole_slop = 0.25;
radius3mm = 1.5;
radius4mm = 2.0;
radius8mm = 4.0;
hole_3mm = radius3mm + hole_slop;
hole_4mm = radius4mm + hole_slop;
hole_8mm = radius8mm + hole_slop;
nut_3mm = radius3mm * 2 + hole_slop + 0.1;
nut_4mm = radius4mm * 2 + hole_slop;
nut_8mm = radius8mm * 2 + hole_slop;

radius608zz = 11;
width608zz = 7;

// The filament gear on the motor
gear_diam = 10.5;
gear_height = 11;

// The hot end
hotend_length = 65;
hotend_diam = 15.9 + 0.2;
hotend_r = hotend_diam / 2;

// Hot end top
hotend_groove_depth = 1;
hotend_above = 4.7;
hotend_groove = 3;
hole_depth = hotend_above + hotend_groove + 2;

// Extruder Block
block_thickness = 20;
standoff_distance = 6;
thicken_block = standoff_distance;
total_thickness = block_thickness + thicken_block;

// Idler
idler_axle_offset = 1;

// Filament
filament_diam = 2.75;
fil_r = filament_diam/2;
filament_hole = fil_r + 0.25 + hole_slop;

// Motor
motor_width = 44;
motor_hole_dist = 36;
motor_height = motor_width;
axle_center_x = 10.25;
motor_axle_x_offset = motor_width/2-axle_center_x;

// X Carriage
x_carriage_holes = 24;
