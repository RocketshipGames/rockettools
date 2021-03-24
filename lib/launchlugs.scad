include <bodytubes.scad>
include <shapes.scad>

module ll_conformal(bt, rod, h=10, wall=0.5, tol=0.25) {

  pad_ir = bt[BT_OUTER]/2 + tol;        // Inner radius of the pad segment
  pad_or = pad_ir + wall;                   // Outer radius of the pad segment

  guide_ir = rod/2 + tol;               // Inner radius of the guide
  guide_or = guide_ir + wall;           // Outer radius of the guide

  echo("Conformal Launch Lug", bt=bt, rod=rod, h=h, wall=wall, tol=tol,
       guide=[guide_ir*2, guide_or*2]);

  union() {
    // Cut the body tube sleeve down to make the pad arc segment
    intersection() {
      translate([pad_ir-1, -guide_or, -1])
        cube([pad_or-pad_ir+2, guide_or*2, h+2]);

      difference() {
        cylinder(r=pad_or, h=h);
        translate([0, 0, -1])
          cylinder(r=pad_ir, h=h+2);
      }
    }


    // Drill the hole through the guide
    difference() {
      // Positive guide shape
      union() {
        translate([pad_ir, -guide_or, 0])
          cube([guide_ir+wall, guide_or*2, h]);

            translate([pad_or+guide_ir, 0, 0])
              cylinder(r=guide_or, h=h);
          }

          // Negative guide shape
          union() {
            *translate([pad_ir-1, -guide_ir, -1])
              cube([guide_ir+wall+1, guide_ir*2, h+2]);

            #translate([pad_or+guide_ir, 0, -1])
              cylinder(r=guide_ir, h=h+2);
          }
        }
  }
}

module ll_padded(bt, rod, h=10, pad=4, wall=0.5, wall2=-1, tol=0.25, rod_tol=-1) {

  tol2 = (rod_tol < 0) ? tol : rod_tol; // Tolerance for the rod shaft
  w2 = (wall2 <= 0) ? wall : wall2;     // Thickness of the guide wall (vs pad)

  ir = bt[BT_OUTER]/2+tol;    // Inner radius of the pad segment
  or = ir+wall;               // Outer radius of the pad segment

  a = 360*(pad/2)/(2*PI*ir);  // Angle arc of the pad
  x = cos(a)*ir*2;            // Point of the bounding triangle for pad
  y = sin(a)*ir*2;

  rri = rod/2 + tol2;         // Inner radius of the guide
  rro = rri + w2;             // Outer radius of the guide

  cxi = cos(a)*ir;            // Inner point of the pad

  ht = h;

  echo("Conformal Launch Lug", bt=bt, rod=rod, h=ht, pad=pad, wall=wall, wall2=w2,
       tol=tol, tol2=tol2);

  translate([-cxi, 0, 0])
      union() {
        // Cut the body tube sleeve down to make the pad arc segment
        intersection() {
          translate([0, 0, -1])
            linear_extrude(ht+2)
              polygon([[0, 0], [x, y], [x, -y]]);

          difference() {
            cylinder(r=or, h=ht);
            translate([0, 0, -1])
              cylinder(r=ir, h=ht+2);
          }
        }


        // Drill the hole through the guide
        difference() {
          // Positive guide shape
          union() {
            translate([ir, -rro, 0])
              cube([rri+wall, rro*2, ht]);

            translate([or+rri, 0, 0])
              cylinder(r=rro, h=ht);
          }

          // Negative guide shape
          union() {
            translate([ir-1, -rri, -1])
              cube([rri+wall+1, rri*2, ht+2]);

            translate([or+rri, 0, -1])
              cylinder(r=rri, h=ht+2);
          }
        }
  }
}
