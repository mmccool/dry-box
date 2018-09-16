// Dry Box
// Developed by: Michael McCool
// Depends on: 
//   https://github.com/mmccool/openscad-library (put in OPENSCADPATH)

include <tols.scad>
include <smooth.scad>

echo("Smoothing: ",sm_base);

// Dependencies
use <bolts.scad>
include <bolt_params.scad>

// Parameters
rod_r = 25/2; // rod radius
case_a = 2.7; // case angle (from vertical)

rod_tol = 0.2;
rod_c = 2;
rod_R = rod_r + rod_tol;
rod_sm = 15*sm_base;

// P-75 O-ring
oring_r = 5.7/2;
oring_ir = 74.6/2;
oring_R = oring_ir + oring_r;
oring_sm = 4*sm_base;
oring_SM = 20*sm_base;
oring_h = 1.5*oring_r;

bolt_r = m4_hole_radius;
bolt_cap_r = m4_cap_radius;
bolt_nut_r = m4_nut_radius;
bolt_nut_h = m4_nut_height;
bolt_sm = 5*sm_base;

support_t = 3;
support_b = 12;
support_h = support_b + 15;
support_q = 5;
support_i = 1;
support_B = support_b + support_q;
support_r = rod_R + support_t;
support_T = 15;
//support_bR = support_r + support_T;
support_bR = oring_ir - bolt_cap_r;
support_R = oring_R + oring_r + support_t;
support_sm = 20*sm_base;



rod_h = 100; // testing only

lock_tol = 0.05; // tight enough so polygons interlock
lock_sm = 32;
lock_detent_r = 1.5/2; // extra insurance against slipping
lock_detent_sm = 12;
lock_detent_a = 59;

clamp_r = 4;
clamp_sm = 20*sm_base;
clamp_h = 50;
clamp_s = 2 + 1;
clamp_w = 22;
clamp_e = 2;
clamp_q = 33.5 + clamp_e + 2*clamp_r;
clamp_q1 = 21 + clamp_r;
clamp_p = 14;
clamp_d = 5;
clamp_f = 2;
clamp_i = 8.5;
clamp_i2 = 16;
clamp_j = 4;
clamp_k = 3;

plate_t1 = 2;
plate_t2 = 1;
plate_t = plate_t1 + plate_t2;
plate_r1 = 8/2 - 0.1;
plate_r2 = 18/2 + 1;
plate_h = 82.35/2;
plate_hr = 2/2;
plate_cr = 4/2;
plate_sm = 50;
plate_hsm = 20;

dm_r = 16/2;
dm_ro = 17/2;
dm_br = 4.2/2;
dm_R = 20/2;
dm_R1 = dm_br + 2;
dm_R2 = 6;
dm_t = 8;
dm_T = 5;
dm_o = 9;
dm_w = 51.3;

dm_bsm = 4*sm_base;
dm_sm = 10*sm_base;

module oring(h=0,re=0) {
  //color([0.2,0.2,0.2,1.0]) 
  rotate_extrude($fn=oring_SM) {
    translate([oring_R,0,0]) hull() {
      circle(r=oring_r+re,$fn=oring_sm);
      rotate([0,-case_a,0]) translate([0,h,0]) circle(r=oring_r+re,$fn=oring_sm);
    }
  }
}

module support() {
  difference() {
    union() {
      cylinder(r=support_R,h=support_b,$fn=support_sm);
      cylinder(r=support_r-support_i,h=support_h,$fn=lock_sm);
      translate([0,0,support_B-eps]) 
        cylinder(r1=support_r-support_i,r2=support_r,h=support_i+2*eps,$fn=lock_sm);
      translate([0,0,support_B+support_i]) 
        cylinder(r=support_r,h=support_h-support_B-support_i,$fn=lock_sm);
    }
    rotate([0,case_a,0]) oring(h=oring_h,re=0.2);
    translate([0,0,support_B])
      cylinder(r=rod_R,h=support_h,$fn=rod_sm);
    rotate(180) translate([-1.1*support_R,-1.1*support_R,0]) 
      rotate([0,-case_a,0])
      translate([0,0,-20])
        cube([2.2*support_R,2.2*support_R,20]);
    for (i=[0:5]) {
      rotate([0,case_a,0]) rotate(60*i) {
        translate([support_bR - bolt_r - support_t - 1,0,-tol]) 
          cylinder(r=bolt_r,h=support_b+2*tol,$fn=bolt_sm);
        translate([support_bR - bolt_r - support_t - 1,0,support_b-bolt_nut_h]) 
          rotate(30) cylinder(r=bolt_nut_r,h=support_b+tol,$fn=6);
      }
    }
  }
}

module base() {
  difference() {
    support();
    hull() {
      translate([0,0,support_B])
        cylinder(r=rod_R,h=support_h+1,$fn=rod_sm);
      translate([support_R,0,support_B])
        cylinder(r=rod_R-rod_c,h=support_h+1,$fn=rod_sm);
    }
    translate([0.16*support_R,-support_R,support_B])
      cube([support_R,2*support_R,support_h+1]);
    // detents
    rotate(lock_detent_a) translate([-support_r-lock_tol,0,support_b+tol])
      cylinder(r=lock_detent_r+tol,h=support_h-support_b-2*tol+1,$fn=lock_detent_sm);
    rotate(-lock_detent_a) translate([-support_r-lock_tol,0,support_b+tol])
      cylinder(r=lock_detent_r+tol,h=support_h-support_b-2*tol+1,$fn=lock_detent_sm);
  }
}

module lock() {
  rotate(lock_detent_a) translate([-support_r-lock_tol,0,support_b+tol])
    cylinder(r=lock_detent_r,h=support_h-support_b-2*tol,$fn=lock_detent_sm);
  rotate(-lock_detent_a) translate([-support_r-lock_tol,0,support_b+tol])
    cylinder(r=lock_detent_r,h=support_h-support_b-2*tol,$fn=lock_detent_sm);
  difference() {
    union() {
      translate([0,0,support_b+support_t-1+tol]) 
        cylinder(r=support_r+support_t,h=support_h-support_b-support_t+1-2*tol,$fn=support_sm);
      translate([0,0,support_b+tol]) 
        cylinder(r1=support_r+1,r2=support_r+support_t,h=support_t-1,$fn=support_sm);
    }
    translate([0,0,support_b-1]) 
      cylinder(r=support_r-support_i+lock_tol,h=support_h+2,$fn=lock_sm);
    hull() {
      translate([0,0,support_B-2*tol]) 
        cylinder(r1=support_r-support_i+lock_tol,r2=support_r+lock_tol,
                 h=support_i+2*tol,$fn=lock_sm);
      translate([0,0,support_B+support_i]) 
        cylinder(r=support_r+lock_tol,h=support_h,$fn=lock_sm);
    }
    hull() {
      translate([0,0,-1])
        cylinder(r=rod_R,h=support_h+2,$fn=lock_sm);
      translate([support_R,0,support_B])
        cylinder(r=rod_R-rod_c,h=support_h+2,$fn=lock_sm);
    }
  }
}

module clamp() {
  hull() {
    translate([-clamp_k,clamp_i,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
    translate([-clamp_k,0,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
  }  
/*
  hull() {
    translate([-clamp_k,clamp_i2,0]) cylinder(r=clamp_r,h=clamp_h/4,$fn=clamp_sm);
    translate([-clamp_k,clamp_i,0]) cylinder(r=clamp_r,h=clamp_h/2-clamp_s/2,$fn=clamp_sm);
  }
  hull() {
    translate([-clamp_k,clamp_i2,3*clamp_h/4]) cylinder(r=clamp_r,h=clamp_h/4,$fn=clamp_sm);
    translate([-clamp_k,clamp_i,clamp_h/2+clamp_s/2]) cylinder(r=clamp_r,h=clamp_h/2-clamp_s/2,$fn=clamp_sm);
  }
*/
  hull() {
    translate([-clamp_k,0,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
    translate([2*clamp_r+clamp_s,0,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
  }
  hull() {
    translate([2*clamp_r+clamp_s,0,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
    translate([2*clamp_r+clamp_s,clamp_q1,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
  }
  hull() {
    translate([2*clamp_r+clamp_s,clamp_q1,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
    translate([2*clamp_r+clamp_s-clamp_j,clamp_q+clamp_f,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
  }
  hull() {
    translate([2*clamp_r+clamp_s-clamp_j,clamp_q+clamp_f,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
    translate([clamp_s-clamp_j-clamp_p,clamp_q,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
  }
  hull() {
    translate([clamp_s-clamp_j-clamp_p,clamp_q,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
    translate([clamp_s-clamp_j-clamp_p,clamp_q-clamp_d,0]) cylinder(r=clamp_r,h=clamp_h,$fn=clamp_sm);
  }
}

module plate1() {
  difference() {
    union() {
      cylinder(r=plate_r1,h=plate_t,$fn=plate_sm);
      cylinder(r=plate_r2,h=plate_t2,$fn=plate_sm);
    }
    translate([0,0,-1]) cylinder(r=plate_cr,h=plate_t+2,$fn=plate_sm);
  }
}

module plate2() {
  difference() {
    union() {
      cylinder(r=plate_r1,h=plate_t,$fn=plate_sm);
      hull() {
        translate([plate_h,0,0]) cylinder(r=plate_r1 + 1,h=plate_t2,$fn=plate_sm);
        translate([-plate_h,0,0]) cylinder(r=plate_r1 + 1,h=plate_t2,$fn=plate_sm);
      }
      rotate(90) hull() {
        translate([plate_h,0,0]) cylinder(r=plate_r1 + 1,h=plate_t2,$fn=plate_sm);
        translate([-plate_h,0,0]) cylinder(r=plate_r1 + 1,h=plate_t2,$fn=plate_sm);
      }
    }
    union () {
      translate([plate_h,0,-1]) cylinder(r=plate_hr,h=plate_t2+2,$fn=plate_hsm);
      translate([-plate_h,0,-1]) cylinder(r=plate_hr,h=plate_t2+2,$fn=plate_hsm);
    }
    rotate(90) union () {
      translate([plate_h,0,-1]) cylinder(r=plate_hr,h=plate_t2+2,$fn=plate_hsm);
      translate([-plate_h,0,-1]) cylinder(r=plate_hr,h=plate_t2+2,$fn=plate_hsm);
    }
    translate([0,0,-1]) cylinder(r=plate_cr,h=plate_t+2,$fn=plate_sm);
  }
}

module dm() {
  difference() {
    hull() {
      translate([-dm_w/2,0,0]) cylinder(r1=dm_R1,r2=dm_R2,h=dm_t,$fn=dm_sm);
      translate([ dm_w/2,0,0]) cylinder(r1=dm_R1,r2=dm_R2,h=dm_t,$fn=dm_sm);
      translate([ 0,dm_br+dm_o+dm_r,0]) cylinder(r=dm_r+dm_T,h=dm_t,$fn=dm_sm);
    }
    translate([-dm_w/2,0,-1]) cylinder(r=dm_br,h=dm_t+2,$fn=dm_bsm);
    translate([ dm_w/2,0,-1]) cylinder(r=dm_br,h=dm_t+2,$fn=dm_bsm);
    translate([ 0,dm_br+dm_o+dm_r,-1]) cylinder(r=dm_r,h=dm_t+2,$fn=dm_sm);
    translate([ 0,dm_br+dm_o+dm_r,-1]) cylinder(r1=dm_ro+1,r2=0,h=dm_ro+1,$fn=dm_sm);
    translate([ 0,dm_br+dm_o+dm_r,dm_t-dm_ro]) cylinder(r1=0,r2=dm_ro+1,h=dm_ro+1,$fn=dm_sm);
  }
}

module assembly() {
  color([0.2,0.2,0.2,1.0]) rotate([0,case_a,0]) translate([0,0,oring_h]) oring();
  //support();
  color([0.5,0,0,1]) 
    translate([0,0,support_b+6]) 
      cylinder(r=rod_r,h=rod_h-2*support_b-12,$fn=rod_sm);
  base();
  //color([0,0.5,0,1]) lock();
  translate([0,0,100]) rotate([180,0,0]) {
    color([0.2,0.2,0.2,1.0]) rotate([0,case_a,0]) translate([0,0,oring_h]) oring();
    base();
    rotate(180) 
      color([0,0.5,0,1]) lock();
  }
}

difference() {
  assembly();
  translate([0,0,-100]) cube([200,200,600]);
}
//assembly();
//oring();
//rotate(180) lock();
//base();
//support(); // better to just print two base/lock combos

//clamp();

//plate1();
//plate2();

//dm();
