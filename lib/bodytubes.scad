// Body tube definitions

BT_LABEL = 0;
BT_INNER = 1;
BT_OUTER = 2;

//       Name     Inner  Outer      Difference
bt_mm = [ "T-MM",   6.45,  7.16 ]; // 0.71
bt_5  = [ "BT-5",  13.2,  13.8  ]; // 0.6
bt_20 = [ "BT-20", 18.0,  18.7  ]; // 0.7
bt_50 = [ "BT-50", 24.1,  24.8  ]; // 0.7
bt_55 = [ "BT-55", 32.6,  33.7  ]; // 1.1
bt_60 = [ "BT-60", 40.5,  41.6  ]; // 1.1
bt_80 = [ "BT-80", 65.7,  66.0  ]; // 0.3?
bt_tubes = [ bt_mm, bt_5, bt_20, bt_50, bt_55, bt_60, bt_80 ];

function bt_get(tube) = bt_tubes[search([tube], bt_tubes)[0]];

module bt_bt(bt, h) {
  echo("Body Tube", bt=bt, h=h);
  color("Tan")
  difference() {
    cylinder(r=bt[BT_OUTER]/2, h=h);
    translate([0, 0, -1])
      cylinder(r=bt[BT_INNER]/2, h=h+2);
  }
}

module bt_coupler(bt, h=-1, wall=1.0, tol=0.25) {

  ht = (h <= 0) ? floor(2*bt[BT_OUTER]) : h;
  or = bt[BT_INNER]/2-tol;
  ir = or-wall;
  echo("Coupler", bt=bt, id=ir*2, od=or*2, h=ht, wall=wall, tol=tol);

  color("Peru")
  difference() {
    cylinder(r=or, h=ht);
    translate([0, 0, -1])
      cylinder(r=ir, h=ht+2);
  }
}

module bt_plug(bt, h=-1, tol=0.25) {
  ht = (h <= 0) ? floor(2*bt[BT_OUTER]) : h;
  or = bt[BT_INNER]/2-tol;
  echo("Plug", bt=bt, od=or*2, h=ht, tol=tol);
  cylinder(r=or, h=ht);
}

module bt_disc(bt, tol=0.25) {
  or = bt[BT_INNER]/2-tol;
  echo("Disc", bt=bt, od=or*2, tol=tol);
  circle(r=or);
}

module bt_ring(bt, it, hook=false, tol=0.25) {
  or = bt[BT_INNER]/2-tol;
  ir = it[BT_OUTER]/2+tol;
  echo("Ring", bt=bt, it=it, od=or*2, id=ir*2, tol=tol);
  difference() {
    difference() {
      circle(r=or);
      circle(r=ir);
    }
    if (hook) {
      translate([ir-1, -2])
        square([2, 4]);
    }
  }
}

/*
module bt_disc(bt, notch=false, tol=0.25) {
  or = bt[BT_INNER]/2-tol;
  echo("Disc", bt=bt, od=or*2, tol=tol);
  difference() {
    circle(r=or);
    if (notch){
      translate([-or, -1.5])
        square([3, 3]);
      translate([or-3, -1.5])
        square([3, 3]);
    }
  }
}
*/
