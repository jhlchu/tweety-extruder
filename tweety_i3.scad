//
// Tweety Parametric Direct-Drive Extruder
// by Thinkyhead
//
// GPL v3 license
//
// A simple direct drive extruder for the Prusa i3
// Requires Universal or inverted mini x-carriage
//
// The "Universal" x-carriage accepts mounting from 24mm to 30mm and
// has a third hole at X=-12, Z=-36, just like the "mini" x-carriage,
// when mounted with the third hole at the top.
//
// Currently set up for an MK7 gear and 2engineers 50:1 geared stepper motor,
// but should be able to accommodate many dimensional changes.
//

include <configuration.scad>

draw_assembled = false;
draw_body = true;
draw_clamp = true;
draw_idler = true;
draw_axle = true;
draw_fan_mount = true;
endstop_bumper = 8;

carriage_pos = [16.5,0,-24]; // for the universal GT2 carriage

nozzle_tip_z = 66;
nozzle_top_z = nozzle_tip_z - hotend_length;

bt2 = block_thickness/2;
sd2 = standoff_distance/2;
mw2 = motor_width/2; mh2 = motor_height/2;
gear_r = gear_diam/2;

below_motor_height = 11;
above_motor_height = 7;
bot_lower = 16.25;
bottom_height = below_motor_height + above_motor_height;
bottom_width = 38;
bot_offset_x = mw2 - bottom_width / 2;
bottom_pos = [bot_offset_x,-sd2,-motor_height/2-bottom_height/2+above_motor_height];

motor_offset_x = -axle_center_x + gear_r + fil_r;
motor_offset_z = 49 - nozzle_top_z;
extruder_z_center = motor_offset_z - below_motor_height / 2;

block_height = motor_height + below_motor_height;
total_thickness = block_thickness + thicken_block;

filament_pos = [0,bt2+standoff_distance,0]; // center the filament in the block
block_pos = filament_pos + [motor_offset_x,0,motor_offset_z]; // move the block for the filament
hotend_hole_pos = filament_pos + [0,0,extruder_z_center-block_height/2+hole_depth];
fil_in_block_pos = [-block_pos[0],0,0];
bearing_in_block_pos = fil_in_block_pos + [-radius608zz,0];

clamp_front_depth = 8;
clamp_gap = 1.5;
clamp_flatten = 3.5;
clamp_screw_len = 25;
clamp_widen = true;
clamp_total_depth = clamp_front_depth + bt2;
clamp_pos = hotend_hole_pos + [0,bt2+clamp_total_depth/2-(bt2),-hole_depth/2];
clamp_in_block_pos = clamp_pos - block_pos;
clamp_hole_dist = false ? 25/2 : floor((hotend_r + hole_3mm + 3) * 2) / 2;
echo("Clamp Hole Distance: ", clamp_hole_dist*2);

mount_holes = [[12,36],[x_carriage_holes/2,0],[-x_carriage_holes/2,0]];

// Idler stuff
idler_bearing_clearance = 2;
idler_perimeter = 5;
idler_width = width608zz + idler_perimeter * 2;
idler_base_height = (radius608zz + idler_bearing_clearance + idler_perimeter - 2) * 2 - 2.5;
idler_height = idler_base_height + 12.5;
idler_depth = radius8mm*2 + idler_perimeter;
idler_uses_groove = idler_axle_offset > 0;
idler_axle_length = idler_width + (idler_uses_groove ? -3 : 0.1);
hinge_width = 10;
hinge_length = idler_depth - 4;
hinge_depth = idler_depth - 4;
hinge_offset = 0;
hw = hinge_width + 0.5;

fan_mount_thickness = 4.0;

//
// Assembled and printable rendering
//

if (draw_assembled) {
  //reference_points();
  difference() {
    union() {
      // position the carriage with its holes at [0,0]
      %translate(carriage_pos) rotate([90,0,0]) import("x-carriage-24to30-gt2.stl");

      // the structure between the extruder and carriage is static
      extruder_standoffs();

      // The body follows the filament path
      translate(filament_pos) {
        // the filament
        %translate([0,0,extruder_z_center]) the_filament();
        translate([0,0,-nozzle_top_z/2]) %the_nozzle(); // the nozzle is fixed to the bottom
      }
      translate(block_pos) { // motor and body move around the filament & gear, nozzle top
        extruder_body();
        translate(clamp_in_block_pos) extruder_clamp();
        if (draw_fan_mount)
          translate(clamp_in_block_pos + [0,clamp_front_depth + fan_mount_thickness + 0.5,0])
            rotate([180,-90,-90])
              fan_mount();
        translate(bearing_in_block_pos) idler_body();
        %translate([0,bt2]) motor_dummy();
      }
    }
    // Carriage holes and motor holes
    carriage_holes();
    translate(block_pos) {
      motor_holes();
      translate(bearing_in_block_pos) idler_holes();
    }

    // Clamp Holes
    translate(clamp_pos) clamp_holes();
  }
} else {
  // Draw everything ready-to-print
  translate([-40,-10]) {

    if (draw_body)
      translate([0,0,total_thickness/2+sd2]) rotate([90,0]) {
        difference() {
          union() {
            extruder_body();
            translate(-block_pos) extruder_standoffs();
          }
          translate(-block_pos) carriage_holes();
          motor_holes();
          translate(bearing_in_block_pos) idler_holes();
          translate(clamp_in_block_pos) clamp_holes();
        }
        translate(bearing_in_block_pos) idler_support();
      }

    if (draw_clamp)
      translate([50,0,clamp_total_depth/2]) rotate([-90,0]) {
        difference() {
          union() { extruder_clamp(); }
          clamp_holes();
        }
      }

    if (draw_idler)
      translate([52,20,idler_axle_offset+idler_depth/2]) rotate([0,-90]) {
        difference() {
          idler_body();
          idler_holes();
        }
      }

    if (draw_fan_mount) translate([50,-25,fan_mount_thickness/2]) {
      rotate([0,0,90]) {
        rotate([0,180,180]) difference() {
          fan_mount(mode=1);
          rotate([90,180,90]) clamp_holes();
        }
        translate([hole_depth+1,0,0]) rotate([0,-35,0]) fan_mount(mode=2);
      }
    }
  }
}

//
// Extruder Body
//

module extruder_body() {
  gear_clearance = 2;
  check_window = 16;
  cube_reduce = 20;
  offs = thicken_block / 2;
  thik = total_thickness;

  difference() {
    union() {
      // The "upper block" - motor mount, filament drive
      translate([cube_reduce/2,-offs,-below_motor_height/2]) // the middle point of the upper block
        rotate([90,0]) rounded_cube([motor_width-cube_reduce,block_height,thik], r=4, center=true);

      // The "lower block" - symmetrical around the nozzle, based on a bottom width
      translate(bottom_pos) // bottom-justify
        rotate([90,0]) rounded_cube([bottom_width,bottom_height,thik], r=4, center=true);

      // An endstop bumper
      if (endstop_bumper > 0)
        translate(bottom_pos + [bottom_width/2,-total_thickness/2+10/2,0])
          rotate([90,0]) rounded_cube([endstop_bumper*2,15,10], r=4, center=true);
    }

    // Opening for the gear
    translate([axle_center_x,-offs,0.15]) rotate([90,0,0]) cylinder(r=gear_r+gear_clearance,h=thik+0.1,center=true,$fn=18);

    // Cleanup nearby
    translate([axle_center_x-(gear_r+gear_clearance),-offs,0.15]) cube([(gear_r+gear_clearance)*2,thik+0.1,(gear_r+gear_clearance)*2],center=true);

    // 608 bearing and its clearance
    translate(bearing_in_block_pos)
      rotate([90,0,0]) {
        if (draw_assembled) %bearing608();
        // %hollow_cylinder(r1=radius608zz,r2=radius8mm,h=8,center=true,$fn=36);
        translate([0,0,offs]) cylinder(r=radius608zz+gear_clearance,h=thik+0.1,center=true,$fn=18);
      }

    // Idler Hinge Space
    translate(bearing_in_block_pos)
      rotate([90,0,90])
        translate([-hinge_offset,-idler_base_height/2-hinge_length/2,-idler_axle_offset-1])
          translate([0,0,-idler_depth/2+hinge_depth/2])
            cube([hw,hinge_length+0.25,hinge_depth+3.5],center=true);

    // Gear Check
    translate([mw2,0,0]) rotate([0,90,0]) rounded_cube([check_window,10,100], r=4, center=true);

    // Filament Through Hole
    assign(rad=filament_hole,funnel_size=10)
    translate(fil_in_block_pos) {
      cylinder(r=rad, h=block_height, center=true);
      translate([0,0,motor_height/2-funnel_size/2]) cylinder(r1=rad, r2=rad+0.75, h=funnel_size, center=true);
      translate([0,0,-funnel_size/2-check_window/2+0.5]) cylinder(r1=rad, r2=rad+1.5, h=funnel_size, center=true);
    }

    // Nozzle Hole
    translate([bot_offset_x+fil_r/2,0,-bottom_height-bot_lower+hole_depth])
      groovemount_cutouts();

  } // difference
}

module extruder_standoffs() {
  frac = 3;
  h = standoff_distance / frac;
  z = (standoff_distance - h) / 2;
  rotate([90,0,0]) {
    translate([0,0,-sd2]) {
      hull() { // top-left to bottom-left
        translate(mount_holes[0]) cylinder(r=hole_3mm+2, h=standoff_distance, center=true);
        translate(mount_holes[1]) translate([0,0,z])
          cylinder(r=hole_3mm+2.5, h=h, center=true);
      }
      hull() { // top-right to bottom-right [-4.5,60,sd2]
        translate([0,36-2]) cylinder(r=hole_3mm+2, h=standoff_distance, center=true);
        translate(mount_holes[2]) translate([0,0,z])
          cylinder(r=hole_3mm+2.5, h=h, center=true);
      }
      if (thicken_block < standoff_distance) hull() { // top-left to top-right
        translate(mount_holes[0]) cylinder(r=hole_3mm+2, h=standoff_distance, center=true);
        translate([0,36]) cylinder(r=hole_3mm+2, h=standoff_distance, center=true);
      }
    }
  }
}

module carriage_holes() {
  // Carriage-aligned holes and nut traps
  translate([0,bt2+sd2,0]) // center on the bulk mass
  rotate([90,0,0]) {
    for (v=mount_holes) translate(v) cylinder(r=hole_3mm, h=100, center=true);
    for (p=[[0,-10,6],[1,-1.5,18],[2,-1.5,18]]) assign(q=mount_holes[p[0]])
      translate([q[0],q[1],p[1]]) rotate([0,0,30]) cylinder(r=nut_3mm, h=block_thickness+standoff_distance+0.1, center=true, $fn=p[2]);
  }
}

module motor_holes() {
  // Motor Holes
  translate([0,bt2]) rotate([90,-90,0]) // center on the front surface of the block
  for (x=[-1,1])
    translate([x*motor_hole_dist/2,-motor_hole_dist/2,bt2-10+10])
      rotate([0,180,0]) {
        hole_with_trap(r=hole_3mm, h=100);
      }
}


//
// Idler
//

module idler_body() {
  // The idler is centered on the bearing
  rotate([90,0,90]) {
    difference() {
      union() {

        translate([0,0,-idler_axle_offset]) {

          rotate([0,90]) {
            translate([-2,0]) {
              assign(hubr=radius608zz-4)
              intersection() {
                cylinder(r=hubr,h=idler_width,center=true);
                translate([-hubr,0]) cube([hubr*2,hubr*2,idler_width], center=true);
              }
            }
          }

          difference() {
            union() {
              // Idler base body
              rounded_cube([idler_width,idler_base_height,idler_depth],r=2,center=true);
              // Idler extended top
              translate([0,idler_height/2-11/2]) rounded_cube([idler_width,11,idler_depth],r=2,center=true);
            }
            union() {
              for(v=[[1,2.5],[-1,1.33]])
                translate([0,v[0]*(idler_base_height/2-2),idler_depth-v[1]]) rotate([v[0]*-22,0,0]) cube([idler_width+1,25,idler_depth],center=true);
            }
          }

          // Idler Hinge structure
          translate([-hinge_offset,-idler_base_height/2, -(idler_depth-hinge_depth)/2]) {
            // Square part
            translate([0,-(hinge_length/2)/2]) cube([hinge_width,hinge_length/2,hinge_depth],center=true);
            // Round part
            translate([0,-hinge_length+hinge_depth/2]) rotate([0,90,0]) cylinder(r=hinge_depth/2,h=hinge_width,center=true);
          }
        }
      }

      // Bearing and axle cutouts
      rotate([0,90]) {
        // Cut a cylinder around the bearing
        cylinder(r=radius608zz+idler_bearing_clearance, h=width608zz+idler_bearing_clearance, center=true);
        // Cube to remove a little extra
        cube([radius608zz*2, (radius608zz-1)*2, width608zz+idler_bearing_clearance], center=true);
        // Axle cutout
        idler_axle_cutout();
      }
    }

    // 
    rotate([0,90]) {
      difference() {
        union() {
          translate([0,0,(width608zz+idler_bearing_clearance)/2-idler_bearing_clearance/4]) cylinder(r1=hole_8mm+1.5, r2=hole_8mm+3.2, h=idler_bearing_clearance/2, center=true);
          translate([0,0,-((width608zz+idler_bearing_clearance)/2-idler_bearing_clearance/4)]) cylinder(r2=hole_8mm+1.5, r1=hole_8mm+3.2, h=idler_bearing_clearance/2, center=true);
        }
        idler_axle_cutout();
      }
    }
  }

  if (!draw_assembled && draw_axle) {
    rotate([0,90]) translate([0,20,-idler_depth/2-idler_axle_offset+idler_axle_length/2]) assign(cros=radius8mm*2+2) {
      cylinder(r=radius8mm, h=idler_axle_length, center=true);
      translate([0,0,-idler_axle_length/2]) {
        hollow_cylinder(r1=radius8mm+5, r2=radius8mm+0.5, h=0.3);
        translate([0,0,0.15]) {
          cube([1,cros,0.3], center=true);
          cube([cros,1,0.3], center=true);
        }
      }
    }
  }
}

module idler_axle_cutout() {
  // Axle cutout
  cylinder(r=hole_8mm, h=idler_axle_length, center=true);
  // Axle groove cutout, if used
  if (idler_uses_groove) translate([-radius8mm-2,0]) cube([radius8mm*2+4,hole_8mm*2,idler_axle_length], center=true);
}

module idler_holes() {

  // Axle hole+trap with added recess
  rotate([90,0,90])
    translate([0,0,-idler_axle_offset - (idler_depth-hinge_depth)/2])
      translate([0,-idler_base_height/2+0.4] + [0,-(hinge_length-idler_depth/4-1.25)] + [-thicken_block/2,0])
        rotate([0,90,0]) {
          translate([0,0,-total_thickness/2+5]) rotate([0,0,30]) hole_with_trap(r1=hole_3mm, r2=nut_3mm, h=45);
          translate([0,0,total_thickness/2-2.5/2]) cylinder(r=nut_3mm, h=2.55, center=true);
        }

  // Idler top grooves and nut traps
  rotate([0,90,0]) assign(hh=draw_assembled?6.05:5.5) {
    for (y=[-1,1]) translate([-(idler_base_height + 2.5)/2,(fil_r+radius3mm+2.5)*y]) {
      cylinder(r=hole_3mm, h=45, center=true);
      translate([-hh/2,0]) cube([hh,hole_3mm*2,36], center=true);
      translate([0,0,17]) {
        cylinder(r=nut_3mm, h=3, center=true, $fn=6);
        assign(q=nut_3mm*0.86) translate([-q,0]) cube([q*2,q*2,3], center=true);
      }
    }
  }
}

module idler_support() {
  ihp = [-hinge_offset,-idler_base_height/2-hinge_length/2-2,-idler_axle_offset-2];

  rotate([90,0,90])
    translate([-hinge_offset,-idler_base_height/2-hinge_length/2-0.25,-idler_axle_offset-1.75])
      rotate([0,90]) {
        translate([0,0,hw/2+0.3/2])
          cylinder(r=hole_3mm+2, h=0.3, center=true);
      }

  // A partial curve to support the back wall of the idler hinge gap
  rotate([90,0,90])
    translate(ihp + [(hw+0.3)/2,-0.6,1.25])
      rotate([0,90])
        translate([bottom_width-35.15,above_motor_height/2-0.7,-hw/2]) // x moves with bottom_width, y with above_bottom
          intersection() {
            hollow_cylinder(r1=4,r2=4-0.7,h=hw+0.5,center=true);
            translate([4,4]) cube([8,8,hw+0.5],center=true);
          }
}


//
// Extruder Clamp
//

module extruder_clamp() {
  head_width = hotend_diam - hole_slop * 2 - (clamp_widen ? 0 : hotend_groove_depth);
  rotate([90,0]) {
    // %cube([hotend_diam+(hole_3mm+8)*2, hole_depth-hole_slop, clamp_front_depth+bt2], center=true);
    difference() {
      union() {
        translate([0,0,-(clamp_total_depth-(clamp_front_depth-clamp_gap))/2])
          rounded_cube([(hotend_r+hole_3mm+8)*2, hole_depth-hole_slop, clamp_front_depth-clamp_gap], r=hole_depth/2-1, center=true);
        cube([head_width, hole_depth-hole_slop, clamp_total_depth+0.1], center=true);
      }
      translate([0,0,clamp_total_depth/2]) {
        // Cut out the nozzle groove
        rotate([90,0,180]) translate([0,0,hole_depth/2]) groovemount_cutouts();
        // Chop off the pointy ends on the cutout
        translate([0,0,hotend_r-clamp_flatten]) cube([hotend_diam, hole_depth+0.05, hotend_diam], center=true);
      }
    }
  }
}

module clamp_holes() {
  trap_thickness = clamp_screw_len - clamp_front_depth - fan_mount_thickness - 1;
  rotate([90,0])
    translate([0,0,-clamp_total_depth/2+clamp_front_depth+trap_thickness])
      for(x=[-1,1]) translate([clamp_hole_dist*x,0])
        hole_with_trap(r1=hole_3mm, r2=nut_3mm, h=60, flip=true);
}

module groovemount_cutouts() {
  for (v=[[0,0,hotend_above],[hotend_above,hotend_groove_depth,hotend_groove],[hotend_above+hotend_groove,0,hole_depth-hotend_above-hotend_groove]]) {
    if (v[2] > 0)
      translate([0,0,-v[0]-v[2]/2]) {
        cylinder(r=hotend_r-v[1], h=v[2]+0.05, center=true);
        translate([0,hotend_r,0]) cube([hotend_diam-v[1]*2,hotend_diam-v[1]*2,v[2]+0.05],center=true);
      }
  }
  if (clamp_widen)
    translate([0,hotend_r+clamp_flatten-clamp_gap,-hole_depth/2]) cube([hotend_diam,hotend_diam,hole_depth], center=true);
}

//
// Hinged fan mount
//
module fan_mount(mode=3) {
  wide = clamp_hole_dist*2 + 6;
  cylr = hole_3mm + 2.5;
  ht2 = 3.1;
  cylw = 16 - (ht2 + 1) * 2;
  do_part1 = mode % 2 > 0;
  do_part2 = mode > 1;
  mid = (hole_depth-fan_mount_thickness)/2;

  // Hinge for the Prusa
  if (do_part1) difference() {
    union() {
      // part that connects to the bolts
      rounded_cube([hole_depth-hole_slop, wide + 2, fan_mount_thickness], r=hole_depth/2-1, center=true);

      // Extender
      translate([-mid+0.1,0,-2.3]) rotate([0,-90,0]) {
        cube([6.2, cylw, fan_mount_thickness], center=true);
        rotate([0,10,0]) cube([6.2, cylw, fan_mount_thickness], center=true);
      }
      translate([-mid-1.3,0,-4.4]) rotate([0,-72+32,0]) cube([2, cylw, 2.5], center=true);
      translate([-mid-0.3,0,-4.4]) rotate([0,-20,0]) cube([2, cylw, 2], center=true);
      translate([-mid-1.5,0,-8]) rotate([90,0,0]) hollow_cylinder(r2=hole_3mm, r1=cylr, h=cylw-0.2, center=true);
    }
  }

  // Connect to the fan
  if (do_part2) translate(draw_assembled ? [-mid-7,0,-12.4] : [0,0,0]) {
    rotate([0,35,0]) {
      difference() {
        union() {
          rounded_cube([cylr*2,40+4.1*2,fan_mount_thickness], r=4.1, center=true);
          for (x=[-1,1]) {
            // translate([0,x*20,0]) cylinder(r=cylr, h=fan_mount_thickness, center=true);
            translate([2,x*(cylw+ht2+0.4)/2,cylr+fan_mount_thickness/2+0.5]) {
              rotate([90,0,0]) cylinder(r=cylr, h=ht2, center=true);
              translate([-1,0,-cylr/2-1]) cube([cylr*2-2,ht2,cylr+2], center=true);
            }
          }
        }
        for (x=[-1,1]) {
          translate([0,x*20,0]) cylinder(r=hole_3mm, h=ht2+0.1, center=true);
          translate([2,x*(cylw+ht2+0.4)/2,cylr+fan_mount_thickness/2+0.5]) rotate([90,0,0]) {
            cylinder(r=hole_3mm, h=ht2+0.1, center=true);
            if (x==1 && ht2 > 3) translate([0,0,-ht2/2-0.1]) rotate([0,0,22.5]) cylinder(r=hole_3mm+1.5, h=1.5, $fn=6);
          }
        }
      }
      // Dummy fan
      if (draw_assembled) translate([-20,0,-(12+fan_mount_thickness)/2]) %fan_dummy();
    }
  }

}

//
// Placeholder Objects
//

module motor_dummy() {
  hd = motor_hole_dist;
  rotate([90,-90,0]) {
    // Flat Part
    translate([0,0,-0.5]) difference() {
      rounded_cube([motor_width,motor_height,1], r=3, center=true);
      for (x=[-1,1],y=[-1,1]) translate([x*hd/2,y*hd/2]) cylinder(r=hole_3mm, h=2.1, center=true);
    }
    // M3 Bolts
    for (x=[-1,1]) translate([x*hd/2,-hd/2,-1])
      rotate([0,180,0]) bolt(h=15);

    // Motor body cylinders
    for (p=[[42.6,15.5],[42,36],[10,37],[2,37.5]])
      translate([0,0,-p[1]/2]) cylinder(r=p[0]/2, h=p[1], $fn=0, $fa=2, $fs=2, center=true);

    // Axle and Gear
    translate([0,-axle_center_x]) {
      // Axle
      translate([0,0,7]) cylinder(r=2.5, h=14, center=true);
      // Gear
      translate([0,0,14-gear_height/2]) cylinder(r=gear_r, h=gear_height, $fn=36, center=true);
    }

  }
}

module fan_dummy() {
  difference() {
    rounded_cube([50, 50, 12], r=2, center=true);
    cylinder(r=22, h=12.1, center=true);
    for(x=[-1,1],y=[-1,1],z=[-1,1]) translate([x*20,y*20,z*2-1]) cylinder(r=hole_3mm-z+1, h=12.1, center=true);
  }
}

module the_nozzle() {
  head_height = 10;
  hollow_cylinder(r1=hotend_r, r2=fil_r, h=hotend_length-head_height, center=true);
  translate([1,0,-hotend_length/2]) cube([hotend_diam+2,hotend_diam,head_height], center=true);
}

module the_filament() {
  color([1,0,0,0.5]) cylinder(r=fil_r, h=block_height+88, center=true);
}


//
// Utility Functions
//

module hollow_cylinder(r1=1,r2=1,h=1,center=false) {
  difference() {
    cylinder(r=r1,h=h,center=center);
    cylinder(r=r2,h=h+0.05,center=center);
  }
}

module rounded_cube(size=[1,1,1], r=0, center=false) {
  d = r * 2;
  w = d > size[0] ? 1 : size[0]-d;
  h = d > size[1] ? 1 : size[1]-d;
  // cube(size, center=center);
  minkowski() {
    cube([w,h,size[2]], center=center);
    cylinder(r=r, h=0.01, center=true);
  }
}

module bolt(r=1.5, h=15) {
  translate([0,0,-h/2]) {
    cylinder(r=r, h=h, center=true);
    translate([0,0,h/2+0.5]) cylinder(r1=r+1,r2=r+0.5, h=1, center=true);
  }
}

module bearing608() {
  hollow_cylinder(r1=radius608zz,r2=radius8mm,h=width608zz,center=true,$fn=36);
}

module hole_with_trap(r1=hole_3mm, r2=nut_3mm, h=100, gap=0.3, flip=false) {
  g = draw_assembled ? -0.1 : gap;
  part = (h-g)/2;
  rotate([flip?180:0,0]) {
    translate([0,0,(part+g)/2]) cylinder(r=r1, h=part, center=true);
    translate([0,0,-(part+g)/2]) cylinder(r=r2, h=part, center=true, $fn=6);
  }
}

module axes(h=100, color=[0,0,0]) {
  t = 0.5;
  color(color) {
    cube([t,t,h], center=true);
    cube([t,h,t], center=true);
    cube([h,t,t], center=true);
  }
}

module reference_points() {
  translate(filament_pos) axes(color=[0,0,0]);
  translate(block_pos) axes(color=[0,0,1]);
  translate(clamp_pos) axes(color=[0,1,1]);
}
