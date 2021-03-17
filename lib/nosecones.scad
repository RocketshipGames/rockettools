include <shapes.scad>
include <bodytubes.scad>

NC_CONIC         = "conic";
NC_BICONIC       = "biconic";
NC_ELLIPSOID     = "ellipsoid";
NC_PARABOLIC     = "parabolic";
NC_POWER_SERIES  = "power-series";
NC_TANGENT_OGIVE = "tangent-ogive";
NC_BLUNTED_CONIC = "blunted-conic";

NC_ANCHOR_NONE  = "none";
NC_ANCHOR_SOLID = "solid";
NC_ANCHOR_BAR   = "bar";

module nc_anchor(type, od, id, plug, bar=3) {
  if (type == NC_ANCHOR_BAR) {
    translate([0, 0, bar/2-plug])
      union() {
      rotate([0, 90, 0])
        cylinder(h=(od+id)/2, d=bar, center=true);
      translate([0, 0, -bar/4])
        cube([(od+id)/2, bar, bar/2], center=true);
    }
  }
}

module nc_nosecone(type, bt, h,
                   power=0.25,                  // Power series parameters
                   d2=-1, h2=-1,                // Biconic parameters
                   k=1,                         // Parabolic parameters
                   b=-1,                         // Blunted conic parameters
                   anchor=NC_ANCHOR_BAR, bar=3,
                   plug=-1,
                   wall=1,
                   tol=0.125) {

  bt_id = bt[BT_INNER];
  bt_od = bt[BT_OUTER];

  plug_h = (plug==-1) ? floor(bt_od/2) : plug;
  plug_od = bt_id - 2*tol;
  plug_id = plug_od - 2*wall;

  anchor_type = (wall > 0) ? anchor : NC_ANCHOR_NONE;

  // Values for biconic
  d2_ = (d2 <= 0) ? 2*bt_od/3 : d2;
  h2_ = (h2 <= 0) ? 2*h/3 : h2;

  // Values for blunted conic
  b_ = (b > 0) ? b : bt_od/3;

  // Generate
  echo("Nosecone", type=type, bt=bt, h=h, plug=plug_h, anchor=anchor_type);

  difference() {
    union() {
      if (type == NC_ELLIPSOID) {
        s_ellipsoid(bt_od, h);
      } else if (type == NC_CONIC) {
        cylinder(d1=bt_od, d2=0, h=h);
      } else if (type == NC_BICONIC) {
          translate([0, 0, h2_])
            cylinder(d1=d2_, d2=0, h=h-h2_);
        cylinder(d1=bt_od, d2=d2_, h=h2_);
      } else if (type == NC_POWER_SERIES) {
        s_power_series(bt_od, h, power);
      } else if (type == NC_TANGENT_OGIVE) {
        s_tangent_ogive(bt_od, h);
      } else if (type == NC_PARABOLIC) {
        s_parabolic(bt_od, h, k);
      } else if (type == NC_BLUNTED_CONIC) {
        s_blunted_conic(bt_od, h, b_);
      }

      translate([0, 0, -plug_h])
        cylinder(d=plug_od, h=plug_h);
    }

    if (wall > 0)
      union() {
        if (anchor_type != NC_ANCHOR_SOLID)
          translate([0, 0, -(plug_h+1)])
            cylinder(d=plug_id, h=plug_h+2);

        intersection() {
          if (type == NC_ELLIPSOID) {
            s_ellipsoid(bt_od-wall*2, h-wall);
          } else if (type == NC_CONIC) {
            cylinder(d1=bt_od-wall*2, d2=0, h=h-wall);
          } else if (type == NC_BICONIC) {
            translate([0, 0, h2_-wall])
              cylinder(d1=d2_-wall*2, d2=0, h=h-h2_-wall);
            cylinder(d1=bt_od-wall*2, d2=d2_-wall*2, h=h2_-wall);
          } else if (type == NC_POWER_SERIES) {
            s_power_series(bt_od-wall*2, h-wall, power);
          } else if (type == NC_TANGENT_OGIVE) {
            s_tangent_ogive(bt_od-wall*2, h-wall);
          } else if (type == NC_PARABOLIC) {
            s_parabolic(bt_od-wall*2, h-wall, k);
          } else if (type == NC_BLUNTED_CONIC) {
            s_blunted_conic(bt_od-wall*2, h-wall, b_);
          }
          translate([0, 0, -1])
            cylinder(d=plug_id, h=h+1.01);
        }
      }
  }
  nc_anchor(anchor_type, plug_od, plug_id, plug_h, bar=bar);

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
