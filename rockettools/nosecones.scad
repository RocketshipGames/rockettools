include <shapes.scad>
include <bodytubes.scad>

NC_ANCHOR_NONE = 0;
NC_ANCHOR_BAR = 1;

module nc_ellipsoid(bt, h, plug=-1, anchor=NC_ANCHOR_BAR, tol=0.25, wall=1) {

  bt_id = bt[BT_INNER];
  bt_od = bt[BT_OUTER];

  plug_h = (plug==-1) ? floor(bt_od/2) : plug;
  plug_od = bt_id - 2*tol;
  plug_id = plug_od - 2*wall;

  union() {
    difference() {
      union() {
        s_ellipsoid(h, bt_od);
        translate([0, 0, -plug_h])
          cylinder(h=plug_h+1, d=plug_od);
      }

      union() {
        intersection() {
          translate([0, 0, -1])
            s_ellipsoid(h, bt_od-2*wall);
          translate([0, 0, -2])
            cylinder(h=h+2, d=plug_id);
        }
        translate([0, 0, -(plug_h+1)])
          cylinder(h=plug_h+2, d=plug_id);
      }
    }

    if (anchor == NC_ANCHOR_BAR) {
      translate([0, 0, 1.5-plug_h])
        union() {
        rotate([0, 90, 0])
          cylinder(h=(plug_od+plug_id)/2, d=3, center=true);
        translate([0, 0, -0.75])
          cube([(plug_od+plug_id)/2, 3, 1.5], center=true);
      }
    }
  }

  // end nc_ellipsoid
}
