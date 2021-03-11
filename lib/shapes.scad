module s_ellipsoid(d, h) {
  rotate_extrude() {
    intersection() {
      rotate([0, 0, 90])
        resize([h*2, d])
        circle(d=20);

      square([d+1, h+1]);
    }
  }
}

module s_right_triangle(x, y, t) {
  translate([0, t/2, 0])
    rotate([90, 0, 0])
      linear_extrude(height=t)
        polygon(points=[[0,0],[x,0],[0,y]]);
}

module s_hollow_cylinder(od, id, h) {
  difference() {
    cylinder(d=od, h=h);
    translate([0, 0, -1])
      cylinder(d=id, h=h+2);
  }
}


// Power Series revolution
// Implementation adapted from Garrett Goss' Nosecone SCAD library
// https://www.thingiverse.com/thing:2004511/remixes
//
// Formula: y = R * pow((x / L), n) for 0 <= n <= 1
//
// Parameters:
// power = 1 for a cone
// power = 0.75 for a 3/4 power
// power = 0.5 for a 1/2 power (parabola)
// power = 0 for a cylinder
//
// f = approximation facets
module s_power_series(d, h, power, f=100) {
  inc = 1/f;
  rotate_extrude()
    for (i = [1 : f]) {
      x_last = h * (i - 1) * inc;
      x = h * i * inc;

      y_last = d/2 * pow((x_last/h), power);
      y = d/2 * pow((x/h), power);

      rotate([0, 0, 90])
        polygon(points=[[0,y_last], [0,y], [h-x,y], [h-x_last,y_last]]);
    }
}
