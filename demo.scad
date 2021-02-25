$fn=64;

include <rockettools/bodytubes.scad>
include <rockettools/nosecones.scad>
include <rockettools/shapes.scad>

bt = bt_get("BT-5");
h = 40;

echo(bt=bt, h=h);

for (i = [0:3])
  rotate([0, 0, i*90])
    translate([bt[BT_OUTER]/2, 0, 0])
    s_right_triangle(10, 20, 2);

translate([0, 0, h])
  nc_ellipsoid(bt, 22);

#bt_bt(bt, h);
