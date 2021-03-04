include <bodytubes.scad>
include <shapes.scad>
include <makerbeam.scad>

module ll_conformal(bt, rod=25.4/16, h=-1, pad=4, wall=0.5, wall2=-1, sweep=45, tol=0.25, rod_tol=-1) {

  tol2 = (rod_tol < 0) ? tol : rod_tol;

  ir = bt[BT_OUTER]/2+tol;
  or = ir+wall;
  w2 = (wall2 <= 0) ? wall : wall2;

  a = 360*(pad/2)/(2*PI*ir);
  x = cos(a)*ir*2;
  y = sin(a)*ir*2;
  echo(a=a);

  rri = rod/2 + tol2;
  rro = rri + w2;

  cxi = cos(a)*ir-1;
  cxo = or+rri*2+w2+1;
  cl = cxo-cxi;

  cy = sin(a)*ir+1;
  cz = tan(sweep)*cl;
  cza = tan(sweep)*(cl-2);

  ht = (h <= 0) ? cza+floor(bt[BT_OUTER]) : cza+h;

  echo("Conformal Launch Lug", bt=bt, rod=rod, h=ht, pad=pad, wall=wall, wall2=w2,
       sweep=sweep, sweep_l=cl-2, sweep_z=cza, tol=tol, tol2=tol2);

  // translate([-cxi-1, 0, 0])
  difference() {
    union() {
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

      difference() {
        difference() {
          union() {
            translate([ir, -rro, 0])
              cube([rri+wall, rro*2, ht]);

            translate([or+rri, 0, 0])
              cylinder(r=rro, h=ht);
          }

          union() {
            translate([ir-1, -rri, -1])
              cube([rri+wall+1, rri*2, ht+2]);

            translate([or+rri, 0, -1])
              cylinder(r=rri, h=ht+2);
          }
        }
      }
    }

    if (sweep && cz)
      translate([0, cy, 0])
        rotate([90, 0, 0])
        linear_extrude(cy*2)
        polygon([[cxi, ht+1], [cxi, ht], [cxo, ht-cz], [cxo, ht+1]]);
  }

}

module ll_makerbeam(bt, h=-1, pad=4, wall=0.5, sweep=45, stem=1, tol=0.25) {

  ir = bt[BT_OUTER]/2+tol;
  or = ir+wall;

  a = 360*(pad/2)/(2*PI*ir);
  x = cos(a)*ir*2;
  y = sin(a)*ir*2;
  echo(a=a);

  st = stem+wall;

  cxi = cos(a)*ir-1;
  cxo = or+stem+2.8+1;
  cl = cxo-cxi;

  cy = sin(a)*ir+1;
  cz = tan(sweep)*cl;
  cza = tan(sweep)*(cl-2);

  ht = (h <= 0) ? cza+floor(bt[BT_OUTER]) : cza+h;

  echo("Conformal MakerBeam Button", bt=bt, h=ht, pad=pad, wall=wall,
       sweep=sweep, sweep_l=cl-2, sweep_z=cza, tol=tol);

  translate([-cxi-1, 0, 0])
  difference() {
    union() {
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

      translate([(ir+or)/2+st, 0, 0])
        rotate([0, 0, 90])
        mb_button(st, ht);
    }

    if (sweep && cz)
      translate([0, cy, 0])
        rotate([90, 0, 0])
        linear_extrude(cy*2)
        polygon([[cxi, ht+1], [cxi, ht], [cxo, ht-cz], [cxo, ht+1]]);
  }

}
