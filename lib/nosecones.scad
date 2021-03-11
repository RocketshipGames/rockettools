include <shapes.scad>
include <bodytubes.scad>

NC_ELLIPSOID    = "ellipsoid";
NC_POWER_SERIES = "power-series";

NC_ANCHOR_NONE = 0;
NC_ANCHOR_BAR = 1;

module nc_nosecone(type, bt, h, plug=-1, anchor=NC_ANCHOR_BAR, power=0.25, tol=0.125, wall=1) {
  bt_id = bt[BT_INNER];
  bt_od = bt[BT_OUTER];

  plug_h = (plug==-1) ? floor(bt_od/2) : plug;
  plug_od = bt_id - 2*tol;
  plug_id = plug_od - 2*wall;

  anchor_type = (wall > 0) ? anchor : NC_ANCHOR_NONE;

  echo("Nosecone", type=type, bt=bt, h=h, plug=plug_h, anchor=anchor_type);


  difference() {
  #union() {
    if (type == NC_ELLIPSOID) {
      s_ellipsoid(bt_od, h);
    } else if (type == NC_POWER_SERIES) {
      s_power_series(bt_od, h, power);
    }
    translate([0, 0, -plug_h])
      cylinder(d=plug_od, h=plug_h);
  }

      union() {
      translate([0, 0, -(plug_h+1)])
        cylinder(d=plug_id, h=plug_h+2);

      intersection() {
        if (type == NC_ELLIPSOID) {
          s_ellipsoid(bt_od-wall*2, h-wall);
        } else if (type == NC_POWER_SERIES) {
          s_power_series(bt_od-wall*2, h-wall, power);
        }
        translate([0, 0, -1])
          cylinder(d=plug_id, h=h+1.01);
      }
    }
  }
  nc_anchor(anchor_type, plug_od, plug_id, plug_h);

}

module nc_ellipsoid(bt, h, plug=-1, anchor=NC_ANCHOR_BAR, tol=0.25, wall=1) {

  bt_id = bt[BT_INNER];
  bt_od = bt[BT_OUTER];

  plug_h = (plug==-1) ? floor(bt_od/2) : plug;
  plug_od = bt_id - 2*tol;
  plug_id = plug_od - 2*wall;

  echo("Ellipsoid Nosecone", bt=bt, h=h, plug=plug_h, anchor=anchor);

  union() {
    difference() {
      union() {
        s_ellipsoid(bt_od, h);
        translate([0, 0, -plug_h])
          cylinder(h=plug_h+1, d=plug_od);
      }

      union() {
        intersection() {
          translate([0, 0, -1])
            s_ellipsoid(bt_od-2*wall, h);
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

//
// Shapes below adapted from Garrett Goss' Nosecone SCAD library
// https://www.thingiverse.com/thing:2004511/remixes

module nc_power(bt, h, shape, f=100, plug=-1, anchor=NC_ANCHOR_BAR, tol=0.25, wall=1) {


  bt_id = bt[BT_INNER];
  bt_od = bt[BT_OUTER];

  plug_h = (plug==-1) ? floor(bt_od/2) : plug;
  plug_od = bt_id - 2*tol;
  plug_id = plug_od - 2*wall;

  echo("Power Series Nosecone", bt=bt, h=h, shape=shape, plug=plug_h, anchor=anchor);

  module ps(od, h) {
    inc = 1/f;
    rotate_extrude()
      for (i = [1 : f]) {
        x_last = h * (i - 1) * inc;
        x = h * i * inc;

        y_last = od/2 * pow((x_last/h), shape);
        y = od/2 * pow((x/h), shape);

        rotate([0, 0, 90]) polygon(points = [[0,y_last],[0,y],[h-x,y],[h-x_last,y_last]]);
      }
  }

  difference() {
    union() {
      ps(bt_od, h);
      translate([0, 0, -plug_h])
        cylinder(d=plug_od, h=plug_h);
    }
    union() {
      translate([0, 0, -(plug_h+1)])
        cylinder(d=plug_id, h=plug_h+2);

      intersection() {
        ps(bt_od-wall*2, h-wall);
        translate([0, 0, -1])
          cylinder(d=plug_id, h=h+2);
      }
    }
  }

  nc_anchor(plug_od, plug_id, plug_h, anchor);

  // end nc_power
}

module nc_anchor(type, od, id, plug) {
  if (type == NC_ANCHOR_BAR) {
    translate([0, 0, 1.5-plug])
      union() {
      rotate([0, 90, 0])
        cylinder(h=(od+id)/2, d=3, center=true);
      translate([0, 0, -0.75])
        cube([(od+id)/2, 3, 1.5], center=true);
    }
  }
}
