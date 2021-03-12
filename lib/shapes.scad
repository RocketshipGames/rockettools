
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

// Elliptical revolution
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

// Tangent Ogive revolution
// Implementation adapted from Garrett Goss' Nosecone SCAD library
// https://www.thingiverse.com/thing:2004511/remixes
//
// Parameters:
// f = approximation facets
module s_tangent_ogive(d, h, f=100) {

  r = d/2;
  rho = (pow(r, 2) + pow(h, 2)) / d;

  inc = 1/f;

  rotate_extrude()
    for (i = [1 : f]){
      x_last = h * (i - 1) * inc;
      x = h * i * inc;

      y_last = sqrt(pow(rho, 2) - pow((h - x_last), 2)) + r - rho;
      y = sqrt(pow(rho, 2) - pow((h - x), 2)) + r - rho;

      rotate([0, 0, -90])
        polygon(points = [[x_last - h, 0], [x - h, 0], [x - h, y], [x_last - h, y_last]]);
    }

}

// Parabolic revolution
// Implementation adapted from Garrett Goss' Nosecone SCAD library
// https://www.thingiverse.com/thing:2004511/remixes
//
// Formula: y = R * ((2 * (x / L)) - (K * pow((x / L),2)) / (2 - K);
//
// Parameters:
// K = 0 for cone
// K = 0.5 for 1/2 parabola
// K = 0.75 for 3/4 parabola
// K = 1 for full parabola
//
// f = approximation facets
module s_parabolic(d, h, k, f=100) {
  r = d/2;
  inc = 1/f;

  rotate_extrude()
    for (i = [1 : f]){

      x_last = h * (i - 1) * inc;
      x = h * i * inc;

      y_last = r * ((2 * ((x_last)/h)) - (k * pow(((x_last)/h), 2))) / (2 - k);
      y = r * ((2 * (x/h)) - (k * pow((x/h), 2))) / (2 - k);

      polygon(points = [[y_last, 0], [y, 0], [y, h - x], [y_last, h - x_last]]);
    }

}
