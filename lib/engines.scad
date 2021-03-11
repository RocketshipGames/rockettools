// Engine definitions

include <shapes.scad>
include <bodytubes.scad>

E_LABEL = 0;
E_OUTER  = 1;
E_LEN   = 2;

//        Name    D   Len
e_6mm  = [ "6mm",  6.3, 26]; // "MicroMaxx"
e_13mm = ["13mm", 13,   45]; // "Mini"
e_18mm = ["18mm", 18,   70]; // "Standard"

e_mmx = e_6mm;
e_mini = e_13mm;
e_std = e_18mm;

e_engines = [ e_6mm, e_13mm, e_18mm ];

function e_get(engine) = e_engines[search([engine], e_engines)[0]];

module e_block(bt, w=2, h=2, tol=0.25) {
  d = bt[BT_INNER]-tol;
  s_hollow_cylinder(d, d-w, h);
}

module e_engine(e) {
  color("DarkGoldenrod")
    cylinder(r=e[E_OUTER]/2, h=e[E_LEN]);
}
