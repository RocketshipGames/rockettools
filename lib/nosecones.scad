include <shapes.scad>
include <bodytubes.scad>

NC_CONIC                 = "conic";
NC_BICONIC               = "biconic";
NC_BLUNTED_CONIC         = "blunt-conic";
NC_ELLIPSOID             = "ellipsoid";
NC_PARABOLIC             = "parabolic";
NC_POWER_SERIES          = "pow-series";
NC_TANGENT_OGIVE         = "tan-ogive";
NC_BLUNTED_TANGENT_OGIVE = "blunt-tan-ogive";
NC_SECANT_OGIVE          = "sec-ogive";
NC_HAACK                 = "haack";

NC_ANCHOR_NONE     = "none";
NC_ANCHOR_SHELL    = "shell";
NC_ANCHOR_SOLID    = "solid";
NC_ANCHOR_PLUGGED  = "plugged";
NC_ANCHOR_BAR      = "bar";
NC_ANCHOR_TAB      = "tab";
NC_ANCHOR_SIDE     = "side";

module nc_anchor(type, od, id, plug, bar=3, tab=[3, 3, 2], buffer=2, hole=2) {
  if (type == NC_ANCHOR_BAR) {
    translate([0, 0, bar/2-plug])
      union() {
        rotate([0, 90, 0])
          cylinder(h=(od+id)/2, d=bar, center=true);
        translate([0, 0, -bar/4])
          cube([(od+id)/2, bar, bar/2], center=true);
      }
  } else if (type == NC_ANCHOR_TAB) {
    l = tab[0];
    w = tab[1];
    h = tab[2];

    translate([-id/2, -w/2, -plug])
      difference() {
        union() {
          cube([l-w/2, w, h]);
          translate([w/2, w/2])
            cylinder(d=w, h=h);
        }
        translate([l-hole/2-(w-hole)/2, w/2, -1])
          cylinder(d=hole, h=h+2);
      }
  } else if (type == NC_ANCHOR_SIDE) {
    intersection() {
      translate([0, 0, -plug-1])
        cylinder(d=(od+id)/2, h=bar+2);
      translate([-id/2+hole/2, 0, -plug])
        difference() {
          translate([-(hole+buffer)/2, -od/2, 0])
            cube([hole+buffer, od, bar]);
          translate([0, 0, -1])
            cylinder(d=hole, h=bar+2);
        }
    }
  }
}

function nc_plug(bt, wall_d=1, tol=0.25) =
  let (plug_od = bt[BT_INNER] - 2*tol,
       plug_id = plug_od - 2*wall_d)
  [bt[BT_LABEL] + " Plug", plug_id, plug_od];

module nc_nosecone(type, bt, h,
                   b=-1,               // Blunted Conic and Blunted Tangent Ogive parameters
                   d2=-1, h2=-1,       // Biconic parameters
                   power=0.25,         // Power Series parameters
                   k=0.75,             // Parabolic parameters
                   c=0,                // Sears-Haack parameters
                   rho=-1,             // Secant Ogive parameters
                   anchor=NC_ANCHOR_BAR, bar=3, tab=[3, 3, 3], buffer=2, hole=2,
                   plug=-1,
                   wall=1,
                   tol=0.25) {

  bt_id = bt[BT_INNER];
  bt_od = bt[BT_OUTER];

  wall_d = (wall > 0 && anchor != NC_ANCHOR_SOLID) ? wall : 0;
  anchor_type = (wall_d > 0) ? anchor : NC_ANCHOR_SOLID;

  plug_h = (plug==-1) ? floor(bt_od/2) : plug;
  plug_bt = nc_plug(bt, wall_d, tol);
  plug_id = plug_bt[BT_INNER];
  plug_od = plug_bt[BT_OUTER];

  // Values for biconic
  d2_ = (d2 <= 0) ? 2*bt_od/3 : d2;
  h2_ = (h2 <= 0) ? 2*h/3 : h2;

  // Values for blunted conic and blunted tangent ogive
  b_ = (b > 0) ? b : bt_od/3;

  // Values for secant ogive
  rho_ = (rho < 0) ? ((h/2)+((pow(bt_od/2, 2)+pow(h, 2))/bt_od))/2 : rho;

  // Generate
  echo("Nosecone", type=type, bt=bt, h=h,
       plug=plug_h, plug_od=plug_od, plug_id=plug_id,
       anchor=anchor_type, wall=wall_d);

  difference() {

    // Generate the bulb shape and the plug/shoulder
    union() {
      // Bulb
      if (type == NC_ELLIPSOID) {
        s_ellipsoid(bt_od, h);
      } else if (type == NC_CONIC) {
        cylinder(d1=bt_od, d2=0, h=h);
      } else if (type == NC_BICONIC) {
          translate([0, 0, h2_])
            cylinder(d1=d2_, d2=0, h=h-h2_);
        cylinder(d1=bt_od, d2=d2_, h=h2_);
      } else if (type == NC_BLUNTED_CONIC) {
        s_blunted_conic(bt_od, h, b_);
      } else if (type == NC_PARABOLIC) {
        s_parabolic(bt_od, h, k);
      } else if (type == NC_POWER_SERIES) {
        s_power_series(bt_od, h, power);
      } else if (type == NC_TANGENT_OGIVE) {
        s_tangent_ogive(bt_od, h);
      } else if (type == NC_BLUNTED_TANGENT_OGIVE) {
        s_blunted_tangent_ogive(bt_od, h, b_);
      } else if (type == NC_SECANT_OGIVE) {
        s_secant_ogive(bt_od, h, rho_);
      } else if (type == NC_HAACK) {
        s_haack(bt_od, h, c);
      }

      // Plug/shoulder
      translate([0, 0, -plug_h])
        cylinder(d=plug_od, h=plug_h);
    }

    // Subtract the interior of the bulb and plug/shoulder unless solid
    if (wall_d > 0)
      union() {
        // Plug/shoulder interior, if not filled
        if (anchor_type != NC_ANCHOR_SOLID && anchor_type != NC_ANCHOR_PLUGGED)
          translate([0, 0, -(plug_h+1)])
            cylinder(d=plug_id, h=plug_h+2);

        // Bulb interior, kept inside plug interior wall so there's no ledge
        intersection() {
          if (type == NC_ELLIPSOID) {
            s_ellipsoid(bt_od-wall_d*2, h-wall_d);
          } else if (type == NC_CONIC) {
            cylinder(d1=bt_od-wall_d*2, d2=0, h=h-wall_d);
          } else if (type == NC_BICONIC) {
            translate([0, 0, h2_-wall_d])
              cylinder(d1=d2_-wall_d*2, d2=0, h=h-h2_-wall_d);
            cylinder(d1=bt_od-wall_d*2, d2=d2_-wall_d*2, h=h2_-wall_d);
          } else if (type == NC_BLUNTED_CONIC) {
            s_blunted_conic(bt_od-wall_d*2, h-wall_d, b_);
          } else if (type == NC_PARABOLIC) {
            s_parabolic(bt_od-wall_d*2, h-wall_d, k);
          } else if (type == NC_POWER_SERIES) {
            s_power_series(bt_od-wall_d*2, h-wall_d, power);
          } else if (type == NC_TANGENT_OGIVE) {
            s_tangent_ogive(bt_od-wall_d*2, h-wall_d);
          } else if (type == NC_BLUNTED_TANGENT_OGIVE) {
            s_blunted_tangent_ogive(bt_od-wall_d*2, h-wall_d, b_);
          } else if (type == NC_SECANT_OGIVE) {
            s_secant_ogive(bt_od-wall_d*2, h-wall_d, rho_);
          } else if (type == NC_HAACK) {
            s_haack(bt_od-wall_d*2, h-wall_d, c);
          }

          translate([0, 0, -1])
            cylinder(d=plug_id, h=h+1.01);
        }
      }
  }

  // Add the anchor, if any
  nc_anchor(anchor_type, plug_od, plug_id, plug_h, bar=bar, tab=tab, buffer=buffer, hole=hole);

}
