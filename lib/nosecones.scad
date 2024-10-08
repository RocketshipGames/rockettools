include <shapes.scad>
include <bodytubes.scad>

use <scad-utils/transformations.scad>
use <list-comprehension-demos/skin.scad>

NC_CONIC                 = "conic";
NC_BICONIC               = "biconic";
NC_BLUNTED_CONIC         = "blunt-conic";
NC_ELLIPSOID             = "ellipsoid";
NC_PARABOLIC             = "parabolic";
NC_POWER_SERIES          = "pow-series";
NC_TANGENT_OGIVE         = "tan-ogive";
NC_BLUNTED_TANGENT_OGIVE = "blunt-tan-ogive";
NC_BLUNTED_SECANT_OGIVE  = "blunt-sec-ogive";
NC_SECANT_OGIVE          = "sec-ogive";
NC_HAACK                 = "haack";
NC_SHOULDER_ONLY         = "shoulder";

NC_ANCHOR_NONE     = "none";
NC_ANCHOR_SHELL    = "shell";
NC_ANCHOR_SOLID    = "solid";
NC_ANCHOR_PLUGGED  = "plugged";
NC_ANCHOR_BAR      = "bar";
NC_ANCHOR_TAB      = "tab";
NC_ANCHOR_SIDE     = "side";
NC_ANCHOR_EYELET   = "eyelet";
NC_ANCHOR_DROPBAR  = "dropbar";

module nc_anchor(type, od, id, plug, bar=3, tab=[3, 3, 2], buffer=2, hole=2, thickness=2, wall=1) {
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

  } else if (type == NC_ANCHOR_EYELET) {
    translate([0, 0, -plug])
      eyelet(od, id, wall, thickness, hole);

  } else if (type == NC_ANCHOR_DROPBAR) {
    translate([0, 0, -plug-bar-hole]) {
      intersection() {
        difference() {
          cylinder(d=od, h=bar+hole+1);
          translate([0, 0, -1])
            cylinder(d=id, h=bar+hole+3);
        }
        translate([-od/2-1, -bar/2, -1])
          cube([od+2, bar, bar+hole+3]);
      }

      union() {
        translate([-id/2, 0, bar/2])
          rotate([0, 90, 0])
          cylinder(h=id, d=bar);
        translate([-id/2, -bar/2, 0])
          cube([id, bar, bar/2]);
      }
    }
  }

  // end nc_anchor
}

module eyelet(od, id, wall=1, thickness=2, hole=3) {
  ring_d = hole+thickness*2;
  fillet = thickness/2;

  module ring_block() {
    intersection() {
      translate([od/2-ring_d/2, 0, -hole/2])
        rotate([90, 0, 0])
        linear_extrude(thickness, center=true)
        difference() {
        union() {
          circle(d=ring_d);
          square([ring_d/2, ring_d-wall]);
        }
        circle(d=hole);
      }
      cylinder(d=od, h=ring_d*2, center=true);
    }
  }

  module fillet() {
    function wall_fillet(od, id, oy, iy, f, precision=4) =
      let (
           or = (od/2),
           ir = (id/2),

           a1 = asin(oy/or),
           a2 = asin(oy/ir),

           a3 = asin(iy/ir)
           )
      [
       for (a = [-a1:a1/precision:a1])
         [cos(a)*or, sin(a)*or],
           for (a = [a2:-(a2-a3)/precision:a3])
             [cos(a)*ir, sin(a)*ir],
               let (
                    cx = cos(a3)*ir-f,
                    cy = sin(a3)*ir
                    )
               for (a=[0:-90/precision:-90])
                 [cx+cos(a)*f, cy+sin(a)*f],

                   let (
                        cx = cos(a3)*ir-f,
                        a4 = asin((iy/2)/cx),
                        r = sqrt(cx^2 + (iy/2)^2)
                        )
                   for (a = [a4:-a4*2/precision:-a4])
                     [cos(a)*r, sin(a)*r],
                       let (
                            cx = cos(a3)*ir-f,
                            cy = -sin(a3)*ir
                            )
                       for (a=[90:-90/precision:0])
                         [cx+cos(a)*f, cy+sin(a)*f],
                           for (a = [-a3:-(a2-a3)/precision:-a2])
                             [cos(a)*ir, sin(a)*ir],
       ];

    function f(t) = wall_fillet(od, id, thickness/2+(fillet*t), thickness/2+(fillet*t), fillet*t, precision=8);

    /*
    for (t=[0:.1:1])
      let (tt = 1-sqrt(fillet-t^2))
        translate([0, 0, fillet*t-fillet])
        outline(f(tt), d=0.25);
    */

    skin([for (t=[0.1:0.05:1])
             let (tt = 1-sqrt(fillet-t^2))
               transform(translation([0, 0, fillet*t-fillet]), f(tt))
          ]);

    skin([for (t=[0,1])
             transform(translation([0, 0, thickness*t]), f(1)) ]);

    k = (ring_d-wall)/2;
    translate([0, 0, thickness])
      mirror([0, 0, 1])
      skin([for (t=[0.1:0.05:1])
               let (tt = 1-sqrt(fillet-t^2))
                 transform(translation([0, 0, k*t-k]), f(tt))
            ]);

  }

  difference() {
    ring_block();
    translate([od/2-ring_d/2, thickness/2+fillet/2+0.5, ring_d-wall-hole/2])
    rotate([90, 0, 0])
      cylinder(d=(ring_d/2-wall)*2, h=thickness+fillet+1);
  }

  fillet();

}

function nc_plug(bt, wall=1, tol=0.1875) =
  let (plug_od = bt[BT_INNER] - 2*tol,
       plug_id = plug_od - 2*wall)
  [str(bt[BT_LABEL], " Plug"), plug_id, plug_od];

module nc_nosecone(type, bt, h,
                   b=-1,               // Blunted Conic, Tangent Ogive, and Secant Ogive parameter
                   d2=-1, h2=-1,       // Biconic parameters
                   power=0.25,         // Power Series parameters
                   k=0.75,             // Parabolic parameters
                   c=0,                // Sears-Haack parameters
                   alpha=-1, rho=-1,   // Secant Ogive parameters
                   anchor=NC_ANCHOR_BAR, bar=3, tab=[3, 3, 3], buffer=2, hole=2, thickness=2,
                   sidecut=0,
                   plug=-1,
                   wall=1,
                   tol=0.1875,
                   fn=$fn) {

  bt_id = bt[BT_INNER];
  bt_od = bt[BT_OUTER];

  wall_d = (wall > 0 && anchor != NC_ANCHOR_SOLID) ? wall : 0;
  anchor_type = (wall_d > 0) ? anchor : NC_ANCHOR_SOLID;

  plug_h = (plug==-1) ? floor(2*bt_od/3) : plug;
  plug_bt = nc_plug(bt, wall_d, tol);
  plug_id = plug_bt[BT_INNER];
  plug_od = plug_bt[BT_OUTER];

  // Values for biconic
  d2_ = (d2 <= 0) ? 2*bt_od/3 : d2;
  h2_ = (h2 <= 0) ? 2*h/3 : h2;

  // Values for blunted conic, tangent ogive, and secant ogive
  b_ = (b > 0) ? b : bt_od/3;

  // Values for secant ogive
  rho_t = (pow(bt_od/2, 2) + pow(h, 2)) / bt_od;   // rho for tangent ogive
  rho_ = (rho <= 0)
    ? ((alpha <= 0)
       ? ((h/2)+((pow(bt_od/2, 2)+pow(h, 2))/bt_od))/2 // default secant ogive rho
       : (rho_t / alpha))
    : rho;

  // Generate
  echo("Nosecone", type=type, bt=bt, h=h,
       plug=plug_h, plug_od=plug_od, plug_id=plug_id,
       anchor=anchor_type,
       wall=wall_d,
       tol=tol,
       rho=rho_,
       fn=fn);

  difference() {

    // Generate the bulb shape and the plug/shoulder
    difference() {
      union() {
        // Bulb
        if (type == NC_ELLIPSOID) {
          s_ellipsoid(bt_od, h, fn=fn);
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
        } else if (type == NC_BLUNTED_SECANT_OGIVE) {
          s_blunted_secant_ogive(bt_od, h, rho_, b_);
        } else if (type == NC_HAACK) {
          s_haack(bt_od, h, c, fn);
        }

        // Plug/shoulder
        if (plug_h > 0)
          translate([0, 0, -plug_h])
            cylinder(d=plug_od, h=plug_h);
      }

      // Side cut to make it easier to run string across bar
      if (plug_h > 0 && bar && sidecut) {
        translate([-sidecut/2, -bt_od/2-1, -plug_h-1])
          cube([sidecut, bt_od+2, bar+sidecut/2+1]);
        translate([0, bt_od/2+1, -plug_h+bar+sidecut/2]) {
          rotate([90, 0, 0])
            cylinder(d=sidecut, h=bt_od+2);
        }
        // Round the bottom corners
        translate([-sidecut/2-1, -bt_od/2-1, -plug_h-1]) {
          difference() {
            cube([sidecut+2, bt_od+2, 2]);
            translate([0, bt_od+2, 2])
              rotate([90, 0, 0])
              cylinder(d=2, h=bt_od+2);
            translate([sidecut+2, bt_od+2, 2])
              rotate([90, 0, 0])
              cylinder(d=2, h=bt_od+2);
          }
        }
      }
    }

    // Subtract the interior of the bulb and plug/shoulder unless solid
    if (wall_d > 0)
      union() {
        // Plug/shoulder interior, if not filled
        if (plug_h > 0 && anchor_type != NC_ANCHOR_SOLID && anchor_type != NC_ANCHOR_PLUGGED)
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
          } else if (type == NC_BLUNTED_SECANT_OGIVE) {
            s_blunted_secant_ogive(bt_od-wall_d*2, h-wall_d, rho_, b_);
          } else if (type == NC_HAACK) {
            s_haack(bt_od-wall_d*2, h-wall_d, c, fn);
          }

          translate([0, 0, -1])
            cylinder(d=(plug_h > 0) ? plug_id : bt_od-wall_d*2, h=h+1.01);
        }
      }
  }

  // Add the anchor, if any
  if (plug_h > 0)
    nc_anchor(anchor_type, plug_od, plug_id, plug_h,
              bar=bar,
              tab=tab,
              buffer=buffer,
              hole=hole,
              thickness=thickness,
              wall=wall);

}


function nc_zipper(a, b, z, t) =
  let (
       steps = max(len(a), len(b), len(z), len(t)) - 1
       )
  [ for (step=[0:steps])
      let (
           a_ = a[min(step, len(a)-1)],
           b_ = b[min(step, len(b)-1)],
           z_ = z[min(step, len(z)-1)],
           t_ = t[min(step, len(t)-1)]
           )
        transform(translation([0, 0, z_]), poly_interpolate(a_, b_, t_))
    ];
