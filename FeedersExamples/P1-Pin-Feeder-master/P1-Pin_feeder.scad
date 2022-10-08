// Arcus-3D-P1 - Buddha Tape feeder OpenSCAD source

// Licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
// http://creativecommons.org/licenses/by-sa/3.0/

// Project home
// https://hackaday.io/project/159792

// Author
// Daren Schwenke at g mail dot com

// Please like my projects if you find them useful.  Thank you.
use <./involute_gears.scad>

// You need rotate_extrude(angle) from openscad-nightly, but it was rendering wierd..  
// This just turns off those areas so you can use the older OpenSCAD, until final rendering is needed.
render_extrude=1;

//////////////////////////////////////////////////////////////
// General clearance.  Usually I do 2x this for loose fit 1.5x for slip fit, and 0x to 1x for press fit.
clearance=.20;

// Nozzle size for parts only a few widths thick.  Prints better.
nozzle_dia=.3;

// Rendering circle complexity.  Turn down while editing, up while rendering.
//$fn=90; 
$fn=60;

// Many things are a multiple of this general wall thickness.
wall_thickness=nozzle_dia*4; 

// For differencing so OpenSCAD doesn't freak out
extra=.02;
 
// Cause I'm hungry
pi=3.1415926; 



// Bearing dimensions
bearing_od=13;
bearing_id=4;
bearing_h=5;

// Cover tape spool
spool_pitch=4.0; // The tape rides the top of the teeth, so this pitch still gives extra pull.
spool_teeth=26; // even number!
spool_dia=spool_pitch*spool_teeth/pi;
spool_ratchet_dia=spool_dia/2-nozzle_dia*5-clearance*2;
spool_drive_r=spool_dia/2.25;

// Tape dimensions
tape_depth=14;
tape_width=8.1;
tape_edge_thickness=1.1;
body_length=60;
tape_window_l=4;
tape_window_w=8;
tape_window_offset=body_length/4;

body_depth=6+tape_depth;
body_width=12-clearance;


// Ratchets inlaid into body
ratchet_inset_h=wall_thickness*1.5;
ratchet_tooth_h=wall_thickness*1.5;

arm_throw_angle=360/spool_teeth*1.45; // enough to ensure the next click.
arm_h=wall_thickness*1.5;
body_h=wall_thickness*3-ratchet_inset_h+arm_h;
tape_guide_area_h=body_h;
arm_end_x=0;
arm_end_y=0;

// Useful
spool_x_offset=spool_dia*1.25;
spool_y_offset=spool_dia/1.90+tape_depth+wall_thickness*2;
spool_angle=atan(spool_y_offset/spool_x_offset);

spool_idler_x_offset=spool_x_offset+spool_dia/1.38;
spool_idler_y_offset=spool_y_offset+spool_dia/4;
spool_idler_teeth=spool_teeth/2;

spool_idler_pivot_x_offset=spool_idler_x_offset;
spool_idler_pivot_y_offset=spool_y_offset/1.23;

servo_x_offset=spool_idler_x_offset+spool_dia/1.68+clearance*2;
servo_y_offset=tape_depth+body_h/2;
servo_z_offset=body_width-body_h+arm_h/2;


//rotate([90,0,0]) assembly_view();
assembly_view();
//body();
module assembly_view() {
	if (1) body();
	if (1) translate([-spool_x_offset,spool_y_offset,body_h]) {
		spool_assembly(rotation=0);
		//spool_assembly(rotation=arm_throw_angle);
	}
	if (1) translate([-spool_idler_x_offset,spool_idler_y_offset,body_h-ratchet_inset_h+arm_h+clearance]) { 
		rotate([0,0,360/spool_teeth/.85]) spool_idler();
		translate([0,0,2.5-arm_h+ratchet_inset_h]) bearing(r2=bearing_od/2,r1=bearing_id/2,h=bearing_h);
	}
	if (1) translate([-spool_idler_pivot_x_offset,spool_idler_pivot_y_offset,0]) spool_idler_pivot(clearance=0);
	if (1) translate([-servo_x_offset,servo_y_offset,servo_z_offset]) rotate([90,0,0]) 9g_servo(display=1);
}
module spool_assembly(explode=0,width=8,cross_section=0,rotation=0) {
	intersection() {
		if (cross_section) cube([100,extra,100],center=true);
		rotate([0,0,0]) union() {
			if (1) translate([0,0,clearance]) spool(print=0);
			if (1) translate([0,0,3+explode/2]) bearing(r2=bearing_od/2,r1=bearing_id/2,h=bearing_h);
			if (1) translate([0,0,clearance]) rotate([0,0,rotation]) spool_drive(print=0);
			if (1) translate([0,0,-ratchet_inset_h+clearance/2]) spool_drive_ratchet(rotation=rotation);
			if (1) translate([0,0,-ratchet_inset_h+clearance/2]) tape_drive(rotation=rotation);
			if (1) translate([0,0,-ratchet_inset_h+clearance/4]) pin_ratchet();

		}
	}
}
// Cover drive sprocket.  Internal ratchet teeth.
// Two sources of friction can drive this.  An O-ring on the bearing against the face, or without the O-ring, the faces rubbing.

module spool(width=8) {
	c_width=width;
	difference() {
		union() {
			// rim
			// body
			gear(number_of_teeth=spool_teeth, diametral_pitch=spool_teeth/spool_dia, hub_diameter=0, hub_thickness=0, bore_diameter=6, rim_thickness=c_width, rim_width=0, gear_thickness=c_width,clearance=-nozzle_dia*3, backlash=-nozzle_dia/2, pressure_angle=5);

			//translate([0,0,c_width/2]) cylinder(r=spool_dia/2,$fnfor(j=[0,tape_depth-tape_depth/8=spool_teeth,center=true,h=c_width);
			//for (i=[0:360/spool_teeth:359]) translate([0,0,c_width/2]) rotate([0,0,i+360/spool_teeth/4]) cube([nozzle_dia*6,spool_dia+nozzle_dia*4,c_width-extra],center=true);
			//rear rim dado
		}
		// bearing cutout
		translate([0,0,c_width/2-c_width+bearing_h+0.55]) cylinder(r=bearing_od/2+clearance/2,center=true,$fn=spool_teeth*2,h=c_width);
		// bearing lip cutout
		translate([0,0,c_width/2]) cylinder(r=bearing_od/2+clearance-nozzle_dia*4,center=true,$fn=spool_teeth*2,h=c_width+extra);
		// front bevel	
		translate([0,0,c_width-nozzle_dia*4/2-extra]) cylinder(r1=bearing_od/2-nozzle_dia*4,r2=bearing_od/2+clearance,center=true,$fn=spool_teeth*2,h=nozzle_dia*4);
		// O-ring groove
		// Clutch was too good, so I made two high spots engage first here.  Done by building it as two slightly angled toruses for the O-ring groove.
		translate([0,0,ratchet_tooth_h+wall_thickness+nozzle_dia*3]) rotate([0,1,0]) rotate_extrude(convexity = 10) translate([20/2+nozzle_dia*3.25,0,0]) circle(r=2.3/2,$fn=12,center=true);
		translate([0,0,ratchet_tooth_h+wall_thickness+nozzle_dia*3]) rotate([0,-1,0]) rotate_extrude(convexity = 10) translate([20/2+nozzle_dia*3.25,0,0]) circle(r=2.3/2,$fn=12,center=true);
		//translate([0,0,c_width-ratchet_tooth_h-ratchet_inset_h-clearance]) cylinder(r=bearing_od/2+nozzle_dia*8,h=clearance*2+extra,$fn=spool_teeth*2,center=true);
		// drive sprocket cutout
		translate([0,0,(ratchet_tooth_h+wall_thickness+clearance)/2]) cylinder(r=spool_ratchet_dia+clearance*2,h=ratchet_tooth_h+wall_thickness+clearance*2,$fn=spool_teeth*2,center=true);
	}
}

module spool_drive_ratchet(h=arm_h,rotation=0) {
	rotate([0,0,rotation]) difference() {
		union() {
			tape_ratchet(h=h+ratchet_tooth_h-clearance/2,spring_h=arm_h,r=spool_ratchet_dia,drive_r=spool_drive_r,teeth=spool_teeth,tooth_clearance=0.2,pivot=1,pivot_hole=1,ratchet=1,drive=1,servo_slot=0);
		}
		slip_bearing_cutout();
	}
}

module pin_ratchet(h=arm_h,pin_socket=0) {
	rotate([0,0,360/spool_teeth*9.35]) {
		if (! pin_socket) {
			tape_ratchet(h=h+ratchet_tooth_h-clearance/2,spring_h=arm_h,r=spool_ratchet_dia,drive_r=spool_drive_r,teeth=spool_teeth,tooth_clearance=.2,pin=1,ratchet=1,drive=0);
		} else {
			tape_ratchet(h=h+ratchet_tooth_h-clearance/2,spring_h=arm_h,r=spool_ratchet_dia,drive_r=spool_drive_r,teeth=spool_teeth,tooth_clearance=.2,pin_socket=1,ratchet=0,drive=0);
		}
	}
}

module spool_idler(width=8) {
	c_width=width;
	difference() {
		union() {
			// rim
			// body
			rotate([0,0,-7.8]) gear(number_of_teeth=spool_idler_teeth, diametral_pitch=spool_teeth/spool_dia, hub_diameter=0, hub_thickness=0, bore_diameter=6, rim_thickness=c_width, rim_width=0, gear_thickness=c_width,clearance=-nozzle_dia*3, backlash=-nozzle_dia/2, pressure_angle=5);
		}
		// bearing cutout
		translate([0,0,c_width/2-c_width+bearing_h+0.55]) cylinder(r=bearing_od/2+clearance/2,center=true,$fn=spool_teeth*2,h=c_width);
		// bearing lip cutout
		translate([0,0,c_width/2]) cylinder(r=bearing_od/2+clearance-nozzle_dia*4,center=true,$fn=spool_teeth*2,h=c_width+extra*2);
		// front bevel	
		translate([0,0,c_width-nozzle_dia*4/2-extra]) cylinder(r1=bearing_od/2-nozzle_dia*4,r2=bearing_od/2+clearance,center=true,$fn=spool_teeth*2,h=nozzle_dia*4);
	}
}

module spool_idler_pivot(clearance=0) {
	translate([spool_idler_pivot_x_offset,-spool_idler_pivot_y_offset,0]) difference() {
		union() {
			hull() {
				translate([-spool_idler_x_offset,spool_idler_y_offset,body_h/4+body_h/2]) cylinder(r=spool_dia/5+clearance*2,h=body_h/2+extra/2,center=true);
				translate([-spool_idler_pivot_x_offset,spool_idler_pivot_y_offset,body_h/4+body_h/2]) cylinder(r=spool_dia/5+clearance*2,h=body_h/2+extra/2,center=true);
			}
			hull() {
				translate([-spool_idler_pivot_x_offset,spool_y_offset+spool_dia/2-wall_thickness,body_h/2]) cylinder(r=spool_dia/9+clearance*2,h=body_h+extra/2,center=true);
				translate([-spool_idler_x_offset,spool_idler_y_offset,body_h/2]) cylinder(r=spool_dia/5+clearance*2,h=body_h+extra/2,center=true);
			}
			hull() {
				translate([-spool_idler_pivot_x_offset,spool_y_offset+spool_dia/2-wall_thickness,body_h/2]) cylinder(r=spool_dia/9+clearance*2,h=body_h+extra/2,center=true);
				translate([-spool_idler_pivot_x_offset+spool_dia/15,spool_y_offset+spool_dia/2+spool_dia/8,body_h/2]) cylinder(r=spool_dia/30+clearance*2,h=body_h+extra/2,center=true);
			}
		}
		translate([-spool_idler_pivot_x_offset,spool_idler_pivot_y_offset,body_h/2-nozzle_dia*2]) cylinder(r=spool_dia/8-clearance*1.5,h=body_h+extra,center=true);
		translate([-spool_idler_pivot_x_offset,spool_idler_y_offset,body_h/2]) cylinder(r=3/2,h=body_h+extra*2,center=true);
		translate([-spool_idler_pivot_x_offset,spool_idler_y_offset,2.3/2]) cylinder(r=3,h=2.3+extra*2,center=true);
		translate([-spool_idler_pivot_x_offset,spool_idler_pivot_y_offset,body_h/2]) cylinder(r=3/2-clearance*2,h=body_h+extra*2,center=true);
		translate([-spool_idler_pivot_x_offset+wall_thickness/8,spool_y_offset+spool_dia/2-wall_thickness*1.25,body_h/4.5]) rotate([0,0,180]) band_mount(cutout=1);
	}
}

module body() {
	length=body_length;
	difference() {
		// Solids start here.
		union() {
			// tape guide area rails
			translate([-length/4-tape_depth/4,body_depth-nozzle_dia*2-tape_edge_thickness,0]) {
				if (render_extrude) translate([0,-body_depth*3,0]) rotate([0,0,90]) rotate_extrude(angle=15,$fn=100) {
					translate([body_depth*3+tape_edge_thickness/2+nozzle_dia*3,body_width/2]) square([nozzle_dia*8+extra*2,body_width],center=true);
					translate([body_depth*3-nozzle_dia*3,(body_width-tape_width+2.75)/2]) square([nozzle_dia*8+tape_edge_thickness+extra*2,body_width-tape_width+2.75],center=true);
				}
				translate([length/4+tape_depth/4,tape_edge_thickness/2+nozzle_dia*3,body_width/2]) cube([length/2+tape_depth/2,nozzle_dia*8,body_width],center=true);
				translate([length/4+tape_depth/4,-nozzle_dia*3,(body_width-tape_width+2.75)/2]) cube([length/2+tape_depth/2,nozzle_dia*8+tape_edge_thickness+extra*2,body_width-tape_width+2.75],center=true);
				if (render_extrude) translate([length/2+tape_depth/2,-body_depth*2.5,0]) rotate([0,0,90-15]) rotate_extrude(angle=15,$fn=100) {
					translate([body_depth*2.5+tape_edge_thickness/2+nozzle_dia*3,body_width/2]) square([nozzle_dia*8+extra*2,body_width],center=true);
					translate([body_depth*2.5-nozzle_dia*3,(body_width-tape_width+2.75)/2]) square([nozzle_dia*8+tape_edge_thickness+extra*2,body_width-tape_width+2.75],center=true);
				}
			}
			// Lego mounting block
			translate([0,(nozzle_dia*10+2)/2,body_width/2]) cube([length,nozzle_dia*10+2,body_width],center=true);
			//translate([-servo_x_offset+1.2+1.6*5,body_h/2,body_width/2]) cube([1.6*5*1,body_h,body_width],center=true);
			// guide area back plate
			difference() {
				union() {
					// tape area plate
					translate([0,body_depth/2-tape_edge_thickness*1.5,tape_guide_area_h/2]) cube([length,body_depth-tape_edge_thickness*3,tape_guide_area_h],center=true);
					// spool plate
					hull() {
						intersection() {
							translate([-spool_x_offset,spool_y_offset,(body_h)/2]) cylinder(r=spool_dia/2+nozzle_dia*3,h=body_h,center=true);
							translate([-spool_x_offset,spool_y_offset+spool_dia/4+nozzle_dia*3/2,(body_h)/2]) cube([spool_dia+nozzle_dia*6,spool_dia/2+nozzle_dia*3,body_h],center=true);
						}
						translate([-length/4,body_depth/2,(body_h)/2]) cube([length/6,body_depth,body_h],center=true);
					}
				}
				difference() {
					// drive band cutout
					translate([0,body_depth/2.25,body_h*1.5-ratchet_inset_h]) hull() {
						translate([-length/2-wall_thickness,0,0]) cylinder(r=7/2,h=body_h,center=true);
						translate([length/4-wall_thickness*3,0,0]) cylinder(r=7/2,h=body_h,center=true);
					}
				}
			}
			// servo support
			hull() {
				translate([-servo_x_offset+6.2+body_h,spool_y_offset-spool_dia/2+body_h/2+nozzle_dia*3,body_width/2]) cylinder(r=nozzle_dia*3,h=body_width,center=true);
				translate([-spool_x_offset-spool_dia/2-body_h,spool_y_offset-spool_dia/2+body_h/2+nozzle_dia*3,body_h/2]) cylinder(r=nozzle_dia*3,h=body_h,center=true);
			}
					
			// peel slot support
			translate([-length/6-nozzle_dia*4,body_depth-tape_edge_thickness+nozzle_dia*4,body_width/2]) rotate([0,0,35]) scale([1,1.5,1])  cylinder(r=2/2,h=body_width,center=true);
			// drive band mount
			translate([length/4-wall_thickness*5.5,body_depth/2.25,tape_guide_area_h-body_h/2]) band_mount();
			// servo mount
			translate([-servo_x_offset+6.2+6/2,spool_y_offset-spool_dia/4,body_width/2]) cube([6,spool_dia/2-body_h,body_width],center=true);
			if (0) {
				hull() {
					translate([-servo_x_offset+1.2+1.6*5,spool_y_offset-spool_dia/4,body_width/2]) cube([wall_thickness,extra,body_width],center=true);
					translate([-servo_x_offset+1.2+1.6*5,extra/2,body_width/2]) cube([wall_thickness,extra,body_width],center=true);
				}
				hull() {
					translate([-servo_x_offset+1.2+1.6*5,spool_y_offset-spool_dia/4,wall_thickness/2]) cube([3.1,extra,wall_thickness],center=true);
					translate([-servo_x_offset+1.2+1.6*5,5/2,wall_thickness/2]) cube([1.6*5*1,5,wall_thickness],center=true);
				}
			}
			// servo and idler plate	
			hull() {
				translate([-servo_x_offset+6*2,spool_y_offset-spool_dia/4,body_h/2]) cube([extra,spool_dia/2-body_h,body_h],center=true);
				translate([-spool_x_offset,spool_y_offset-spool_dia/6+body_h/2,body_h/2]) cylinder(r=spool_dia/3,h=body_h,center=true);
			}
			// spool mounting post, shaped in tape_drive as a cutout!
			translate([-spool_x_offset,spool_y_offset,body_h/2+arm_h/1.8-extra]) cylinder(r=bearing_od/2,h=arm_h+body_h,center=true);
		}
		// Cutouts start here.
		// tape lifting spring cutouts
		translate([tape_window_offset-6.5,body_depth-nozzle_dia*4.5-tape_edge_thickness,body_width/2]) {
			difference() {
				union() {
					hull() {
						translate([0,0,0]) cylinder(r=tape_edge_thickness/2+nozzle_dia,h=body_width+extra,center=true);
						translate([9,nozzle_dia*1.5,0]) scale([3,1,1]) cylinder(r=tape_edge_thickness/2+nozzle_dia,h=body_width+extra,center=true);
					}
				}
				hull() {
					translate([5,0,-body_width/2+(body_width-tape_width+.75*2)/2]) cube([extra,4,1.9],center=true);
					translate([14,0,-body_width/2+(body_width-tape_width+.75*2)/2]) cube([extra,4,4.5],center=true);
				}
			}
			rotate([0,0,50]) {
				hull() {
					translate([0,0,0]) cylinder(r=tape_edge_thickness/2+nozzle_dia,h=body_width+extra,center=true);
					translate([-6.5,0,0]) cylinder(r=nozzle_dia*2,h=body_width+extra,center=true);
				}
				translate([-6.5,0,0]) hull() {
					cylinder(r=nozzle_dia*2,h=body_width+extra,center=true);
					rotate([0,0,-50]) translate([-4,0,0]) cylinder(r=nozzle_dia*2,h=body_width+extra,center=true);
				}
			}
		}
		// socket for idler pin
		translate([-spool_x_offset,spool_y_offset,nozzle_dia]) pin_ratchet(pin_socket=1);
		// bolt holes
		translate([-spool_x_offset,spool_y_offset,2.9/8]) cylinder(r2=4,r1=4+2.9/4,h=2.9/4+extra,center=true);
		translate([-spool_x_offset,spool_y_offset,2.9/2]) cylinder(r=4,h=2.9+extra,center=true);
		translate([-spool_x_offset,spool_y_offset,4/2]) cylinder(r=4/2,h=30,center=true);
		// servo cutout
		translate([-servo_x_offset,servo_y_offset,servo_z_offset]) rotate([90,0,0]) 9g_servo(display=0);
		// idler spool band mount
		translate([-spool_x_offset+wall_thickness,spool_y_offset+spool_dia/2-wall_thickness*1.25,body_h/4.5]) band_mount(cutout=1);
		// spool idler screw hole
		translate([-spool_idler_pivot_x_offset,spool_idler_pivot_y_offset,body_h]) cylinder(r=2.7/2,h=body_h*2+extra,center=true);
		// spool idler pivot cutout
		translate([-spool_idler_pivot_x_offset,spool_idler_pivot_y_offset,0]) for (i=[-3,10]) rotate([0,0,i]) spool_idler_pivot(clearance=.2);
		// tape drive cutouts 
		translate([-spool_x_offset,spool_y_offset,body_h-ratchet_inset_h]) for(i=[0,arm_throw_angle/2,arm_throw_angle]) tape_drive(rotation=i,part_clearance=clearance*3,spring_h=body_width,cutout=1);
		// lego base cutout
		translate([-1.6*5*4,2*1.6-extra,6]) {
			rotate([90,0,0]) lego_body(length=16,width=1);
		}
		// tape part window cutout
		for (i=[0,1]) translate([tape_window_offset,body_depth-nozzle_dia*2,body_width-tape_width/2+.75*2]) mirror([0,i,0]) hull() {
			translate([0,-nozzle_dia*6,0]) cube([extra,extra,tape_window_w],center=true);
			translate([0,nozzle_dia*6,0]) cube([tape_window_l*2,extra,tape_window_w],center=true);
		}
		// ratchet cutouts
		difference() {
			translate([-spool_x_offset,spool_y_offset,body_h-ratchet_inset_h]) {
				for (i=[-2,arm_throw_angle/2,arm_throw_angle+1]) rotate([0,0,i]) tape_ratchet(h=arm_h+ratchet_tooth_h,spring_h=body_width,r=spool_ratchet_dia,drive_r=spool_drive_r,teeth=spool_teeth,part_clearance=.2,cutout=1);
			}
			hull() {
				translate([-spool_x_offset,spool_y_offset,body_h-ratchet_inset_h]) cylinder(r=bearing_od/2-clearance,h=4,center=true);
				translate([-spool_x_offset,spool_y_offset,body_h-ratchet_inset_h]) cylinder(r=bearing_od/3,h=4.5,center=true);
			}
		}
		// tape path cutouts
		translate([0,0,0]) {
			for (i=[0,body_width]) translate([-length/4-tape_depth/4,body_depth-nozzle_dia*2-tape_edge_thickness,-tape_width/2+.75+i]) {
				if (render_extrude) translate([0,-body_depth*3,0]) rotate([0,0,90]) rotate_extrude(angle=15,$fn=100) translate([body_depth*3,0]) square([tape_edge_thickness,tape_width],center=true);
				difference() {
					translate([length/4+tape_depth/4,0,0]) cube([length/2+tape_depth/2,tape_edge_thickness,tape_width],center=true);
					hull() {
						translate([length/4-tape_window_l/2,body_depth-tape_edge_thickness*2,tape_guide_area_h/2]) cylinder(r=nozzle_dia,h=tape_guide_area_h+extra*2,center=true);
						translate([wall_thickness*4,body_depth-tape_edge_thickness*2-wall_thickness*2,tape_guide_area_h/2]) cylinder(r=nozzle_dia,h=tape_guide_area_h+extra*2,center=true);
					}
					hull() {
						translate([length/4-tape_window_l/2,body_depth-tape_edge_thickness*2-nozzle_dia,tape_guide_area_h/2]) cylinder(r=nozzle_dia*2,h=tape_guide_area_h+extra*2,center=true);
						translate([length/4+tape_window_l/2,body_depth-tape_edge_thickness*2-nozzle_dia,tape_guide_area_h/2]) cylinder(r=nozzle_dia*2,h=tape_guide_area_h+extra*2,center=true);
					}
				}
				translate([0,-body_depth*3,0]) rotate([0,0,15]) translate([0,body_depth*3,0]) hull() for (j=[5,-5]) rotate([0,0,j]) translate([-length/4-tape_depth/4,0,0]) cube([length/2+tape_depth/2,tape_edge_thickness,tape_width],center=true);
				if (render_extrude) translate([length/2+tape_depth/2,-body_depth*2.5,0]) rotate([0,0,90-24]) rotate_extrude(angle=24,$fn=100) translate([body_depth*2.5,0]) square([tape_edge_thickness,tape_width],center=true);
			}
		}
		// cover tape peel slot cutout
		for (i=[-.75,12]) translate([-length/6+1.5,body_depth+nozzle_dia*3-tape_edge_thickness-1-clearance,-tape_width/2+.75*2 + i]) hull() {
			cube([1.5,extra,tape_width],center=true);
			translate([-5.9,8,0]) cube([extra,extra,tape_width],center=true);
		}
	}
}
// The arm that pushes the tape
module tape_drive(drive_r=spool_drive_r,spring_h=arm_h,r=spool_ratchet_dia,rotation=0,c_rotation=0, part_clearance=0,servo_slot=1,cutout=0) {
	offset_angle=8.15;
	bias_angle=21;
	offset_spacing=drive_r*1.75;
	arm_length=spool_x_offset*.75;
	rotate([0,0,180+rotation]) translate([0,drive_r,spring_h/2]) rotate([0,0,-rotation+bias_angle+c_rotation]) { 
		// arm
		union() {
			translate([0,-drive_r+offset_spacing,0]) rotate([0,0,-offset_angle]) {
				hull() {
					translate([-1,part_clearance,0]) cylinder(r=r/4+part_clearance*2,h=spring_h,center=true);
					translate([-arm_length+1+part_clearance*2,1+part_clearance*2,0]) cylinder(r=2+part_clearance*3,h=spring_h,center=true);
				}
			}
		}
		// bogey
		translate([0,-drive_r+offset_spacing,0]) rotate([0,0,-offset_angle-rotation/12]) difference() {
			union() {
				hull() {
					translate([-arm_length,-.6,0]) {
						translate([0,0,0]) cylinder(r=1.5+part_clearance,h=spring_h,center=true);
						rotate([0,0,-bias_angle+offset_angle+rotation/12]) translate([3,0,0]) cylinder(r=1.5+part_clearance,h=spring_h,center=true);
					}
					translate([-arm_length,-1+part_clearance,(body_width-tape_width+2.75-1)/2]) {
						cylinder(r=1.5+part_clearance/2,h=2,center=true);
						rotate([0,0,-bias_angle+offset_angle+rotation/12]) translate([3,0,0]) cylinder(r=1.5+part_clearance/2,h=2,center=true);
					}
				}
				hull() {
					translate([-arm_length,-.6,0]) translate([0,0,0]) cylinder(r=1.5+part_clearance,h=spring_h,center=true);
					translate([-arm_length+1+part_clearance*2,1+part_clearance*2,0]) cylinder(r=2+part_clearance*3,h=spring_h,center=true);
				}
			}
			translate([-arm_length+2,-.6,(body_width-tape_width+1.75)/2]) rotate([0,90,40]) cylinder(r=1/2,h=10,center=true);
		}
		// lever linkage
		cylinder(r=r/4.5+part_clearance,h=spring_h,center=true);
		hull() {
			cylinder(r=r/9+part_clearance,h=spring_h+extra,center=true);
			translate([0,-drive_r+offset_spacing,0]) rotate([0,0,0]) cylinder(r=r/5+part_clearance,h=spring_h,center=true);
		}
		if (! cutout) translate([0,-drive_r+offset_spacing+.5,0]) rotate([0,0,-offset_angle]) translate([-spool_x_offset*.1,0,-spring_h/2+body_h/2]) rotate([0,0,-bias_angle+offset_angle]) band_mount();
	}
}



// This is the shape for all the ratchety things 
module tape_ratchet(h=wall_thickness+ratchet_tooth_h-clearance,spring_h=arm_h,teeth=spool_teeth,r=spool_ratchet_dia,tooth_clearance=0,part_clearance=0,pivot=0,pin=0,ratchet=0,drive_r=spool_drive_r,pin_socket=0,drive=0,cutout=0,servo_slot=0) {
	tooth_angle=360/teeth;
	inset=r/teeth+nozzle_dia*7+clearance;
	offset_spacing=drive_r*1.7;
	offset_angle=9.0;
	bias_angle=20;
	rotate([0,0,180]) translate([0,0,h/2]) {
		difference() {
			union() {
				if (ratchet) {
					difference() {
						union() {
							intersection() {
								cylinder(r=r-inset,h=h,center=true);
								hull() {
									rotate([0,0,tooth_angle*5]) translate([0,r*2,0]) cube([extra,r*4,h],center=true);
									rotate([0,0,tooth_angle*12]) translate([0,r*2,0]) cube([extra,r*4,h],center=true);
								}
							}
							rotate([0,0,tooth_angle*18]) ratchet_teeth(r=r,teeth=teeth,h=h,count=1,tooth_clearance=tooth_clearance,solid=0);
						}
						cylinder(r=r-inset-nozzle_dia*3,h=h+extra*2,center=true);
					}
					rotate([0,0,tooth_angle*5]) hull() {
						rotate([0,0,tooth_angle*2]) translate([0,r-inset-nozzle_dia*1.5,0]) cylinder(r=nozzle_dia*1.5,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16,center=true,h=h);
					}
				}
				if (pivot) {
					hull() {
						cylinder(r=bearing_od/2+clearance*2+nozzle_dia*8,center=true,h=h);
						rotate([0,0,tooth_angle*5]) translate([0,r-inset-r/10,0]) scale([1.5,1,1]) cylinder(r=r/10,center=true,h=h);
					}

				}
				if (pin_socket) {
					rotate([0,0,tooth_angle*5]) hull() {
						rotate([0,0,tooth_angle*1]) translate([0,r-inset-nozzle_dia*1.5,0]) cylinder(r=nozzle_dia*1.5+clearance/2,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16+clearance/2,center=true,h=h);
					}
				}
				if (pin) {
					rotate([0,0,tooth_angle*5]) hull() {
						rotate([0,0,tooth_angle*1]) translate([0,r-inset-nozzle_dia*1.5,0]) cylinder(r=nozzle_dia*1.5,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16,center=true,h=h);
					}
				}
				if (drive || cutout == 1 ) {
					rotate([0,0,0]) translate([0,0,-h/2]) {
						difference() {
							union() {
								hull() {
									translate([4,0,0]) {
										rotate([0,0,-25]) translate([0,drive_r+r/6,spring_h/2]) scale([1,1,1]) cylinder(r=r/4+part_clearance,center=true,h=spring_h);
										rotate([0,0,-25+arm_throw_angle+2]) translate([0,drive_r+r/6,spring_h/2]) scale([1,1,1]) cylinder(r=r/4+part_clearance,center=true,h=spring_h);
									}
									translate([0,0,spring_h/2]) cylinder(r=r/5+part_clearance,center=true,h=spring_h);
								}
								hull() {
									translate([0,drive_r,spring_h/2]) rotate([0,0,0]) scale([1.8,1,1]) cylinder(r=r/3.5+part_clearance,center=true,h=spring_h);
									translate([0,0,spring_h/2]) cylinder(r=bearing_od/2+part_clearance*2+nozzle_dia*4,center=true,h=spring_h);
								}
							}
							if (! cutout) for (i=[-arm_throw_angle,-3]) rotate([0,0,180]) tape_drive(spring_h=spring_h+extra*4,cutout=1,c_rotation=i,part_clearance=.2);
							if (! cutout) translate([4.5,0,0]) hull() {
								rotate([0,0,-25]) translate([0,drive_r+r/6,spring_h/2]) scale([1,1,1]) cylinder(r=1/2+part_clearance,center=true,h=spring_h+extra*2);
								rotate([0,0,-25+arm_throw_angle+3]) translate([0,drive_r+r/6,spring_h/2]) scale([1,1,1]) cylinder(r=1/2+part_clearance,center=true,h=spring_h+extra*2);
							}
						}
					}
					rotate([0,0,-22.5]) translate([0,0,-h/2+spring_h/2]) {
						hull() {
							translate([-bearing_od/2,bearing_od/3,0]) cube([extra,bearing_od/3*2,spring_h],center=true);
							translate([-spool_dia/1.5,0,0]) cylinder(r=bearing_od/4+part_clearance,h=spring_h,center=true);
						}
						hull() {
							translate([-spool_dia/1.5,0,0]) cylinder(r=bearing_od/4+part_clearance,h=spring_h,center=true);
							rotate([0,0,10]) translate([-spool_x_offset+arm_end_x,arm_end_y,0]) cylinder(r=body_h/2+part_clearance,h=spring_h,center=true);
						}
						if ( ! cutout ) {
							hull() {
								translate([-spool_dia*.95,-spool_dia/10,0]) cylinder(r=wall_thickness/2,h=spring_h,center=true);
								rotate([0,0,10]) translate([-spool_x_offset+arm_end_x,arm_end_y,-spring_h/2+body_width/2-body_h/2+ratchet_inset_h/2]) cylinder(r=wall_thickness/2,h=body_width-body_h+ratchet_inset_h,center=true);
							}
							// lever end
							hull() for (i=[0,-body_h/3]) rotate([0,0,10]) translate([-spool_x_offset+arm_end_x+i/8,i+arm_end_y,-spring_h/2+body_width/2-body_h/2+ratchet_inset_h/2]) cylinder(r=body_h/2,h=body_width-body_h+ratchet_inset_h,center=true);
						}
					}
							
				}
				if (cutout) cylinder(r=r,h=h,center=true);
			}
		}
	
	}
}

// Generate the ratchet teeth
module ratchet_teeth(h=ratchet_tooth_h,r=spool_dia/2,teeth=spool_teeth,count=spool_teeth,tooth_clearance=0,solid=1) {
	inset=r/teeth+nozzle_dia*7+clearance;
	union() {
		for (i=[0:(360/teeth):(360/teeth*count)-1]) rotate([0,0,i]) translate([r-r/5-nozzle_dia*2.5,0]) rotate([0,0,40]) scale([1.3,1,1]) cylinder(r=r/5-tooth_clearance/2,$fn=3,h=h,center=true);
		if (solid) cylinder(r=r-inset,h=h,center=true);
	}
}


module band_mount(length=body_length/2,cutout=0) {
	difference() {
		if (! cutout) hull() {
			translate([-wall_thickness*2,0,0]) cylinder(r=wall_thickness*2,h=body_h,center=true);
			translate([wall_thickness*2,0,0]) cylinder(r=wall_thickness*2,h=body_h,center=true);
		}
		union() {
			if (render_extrude) translate([wall_thickness*2,0,0]) rotate([0,0,-90]) rotate_extrude(angle=180) translate([wall_thickness*2,0,0]) scale([1,1]) circle(r=wall_thickness/1.25,center=true);
			for (i=[-wall_thickness*2,wall_thickness*2]) translate([wall_thickness*2-length/2+extra,i,0]) scale([1,1,1]) rotate([0,90,0]) cylinder(r=wall_thickness/1.25,h=length,center=true);
		}
	}
}

// Lego!
module lego_body(length=8,width=1) {
	// width 1 is actually 2 posts, because I added a third fitting between.
	u=1.6;
	pin=3*u;
	w=width;
	h=2;
	l=length;
	for (i=[0:1:l]) {
		for (j=[0:1:w*2]) translate([-l*u*5/2+5*u*i,u*5*j/2-2.5*u,h*u/2]) rotate([0,0,22.5]) cylinder(r1=3.25*u/2+clearance,r2=3.25*u/2+clearance/6,h=h*u,$fn=8,center=true);
		translate([-l*u*5/2-2.5*u+5*u*i,0,h*u/2]) cube([.75*u,10*u,h*u],center=true);	
	}
}

// Tuned for a moving, slip fit
module slip_bearing_cutout() {
	// bearing outer slip joint
	// Low facet count decreases the contact area.
	// However this also reduces the effective ID, so an inner slip ring like this is actually 10% larger than the OD because of it.
	translate([0,0,20/2-extra]) cylinder(r=bearing_od/1.91,$fn=12,center=true,h=25);
	// bearing bevel
	translate([0,0,nozzle_dia*3/2]) cylinder(r2=bearing_od/2-nozzle_dia*1,r1=bearing_od/2+nozzle_dia*2,center=true,h=nozzle_dia*3+extra*2);
}

// Accurate bearing model, so I could get that right.
module bearing(r1=2/2,r2=6/2,h=2.5){
	intersection() {
		difference() {
			union() {
				color("grey") difference() {
					cylinder(r=r2,h=h,center=true);
					cylinder(r=r2/1.15,h=h+extra,center=true);
				}
				color("grey") difference() {
					cylinder(r=r1/.7,h=h,center=true);
					cylinder(r=r1/2,h=h+extra,center=true);
				}
				color("orange") cylinder(r=r2-extra,h=h*.9,center=true);
			}
			color("grey") cylinder(r=r1,h=h+extra*2,center=true);
			translate([0,0,h/2.2]) color("grey") cylinder(r1=0,r2=r1*2,h=h,center=true);
			translate([0,0,-h/2.2]) color("grey") cylinder(r2=0,r1=r1*2,h=h,center=true);
		}
		translate([0,0,h/2.2]) color("grey") cylinder(r2=0,r1=r2*2,h=h*2,center=true);
		translate([0,0,-h/2.2]) color("grey") cylinder(r1=0,r2=r2*2,h=h*2,center=true);
	}
}

module 9g_servo(display=0){
	translate([-5.5,0,-29.25/2-3.65]) difference() {
		union() {
			if (display) {
				color("grey") translate([0,0,2.5*2+2.5/2-3/2]) cube([32,12.5,2.5], center=true);
			} else {
				translate([0,0,2.5*2+2.5/2-3/2]) cube([32+clearance,22.5+clearance,2.5+clearance], center=true);
			}
			union() {	
				color("grey") cube([23+clearance*2,12.5+clearance*2,23+clearance*2], center=true);
				color("grey") translate([-1,0,2.75+clearance]) cube([5+clearance,5.6+clearance,25.75], center=true);
				if (display) {
					color("grey") translate([5.5,0,2.75+clearance]) cylinder(r=6+clearance, h=25.75, $fn=20, center=true);
				} else {
					translate([5.5,0,7.75+clearance]) cube([12,12.5,30.75],center=true);
				}

			}		
			color("grey") translate([-.5,0,1.75]) cylinder(r=1, h=25.75, $fn=20, center=true);
			color("white") translate([5.5,0,3.65]) cylinder(r=2.35, h=29.25, $fn=20, center=true);				
			if (! display) for ( hole = [14,-14] ){
				translate([hole,0,4]) cylinder(r=1.75/2, h=18, $fn=20, center=true);
			}
		}	
		if (display) for ( hole = [14,-14] ){
			translate([hole,0,4]) cylinder(r=2.1/2, h=12, $fn=20, center=true);
		}
	}
}


