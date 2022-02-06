TORAD = PI/180;
TODEG = 180/PI;

module s_right_triangle(t) {
  x = t[0];
  y = t[2];
  t = t[1];

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
// https://www.thingiverse.com/thing:2004511
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
module s_power_series(d, h, power, f=$fn) {
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
// https://www.thingiverse.com/thing:2004511
//
// Parameters:
// f = approximation facets
module s_tangent_ogive(d, h, f=$fn) {
  inc = 1/f;

  r = d/2;
  rho = (pow(r, 2) + pow(h, 2)) / d;

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
// https://www.thingiverse.com/thing:2004511
//
// Formula: y = R * ((2 * (x / L)) - (K * pow((x / L),2)) / (2 - K);
//
// Parameters:
// k = 0 for cone
// k = 0.5 for 1/2 parabola
// k = 0.75 for 3/4 parabola
// k = 1 for full parabola
//
// f = approximation facets
module s_parabolic(d, h, k, f=$fn) {
  inc = 1/f;
  r = d/2;

  rotate_extrude()
    for (i = [1 : f]){

      x_last = h * (i - 1) * inc;
      x = h * i * inc;

      y_last = r * ((2 * ((x_last)/h)) - (k * pow(((x_last)/h), 2))) / (2 - k);
      y = r * ((2 * (x/h)) - (k * pow((x/h), 2))) / (2 - k);

      polygon(points = [[y_last, 0], [y, 0], [y, h - x], [y_last, h - x_last]]);
    }

}

// Blunted Conic revolution
//
// Parameters:
// b = diameter of the tip sphere
//
// f = approximation facets
module s_blunted_conic(d, h, b, f=$fn) {

  inc = 1/f;
  r = d/2;
  r_nose = b/2;

  x_t = (pow(h, 2) / r) * sqrt(pow(r_nose, 2) / (pow(r, 2) + pow(h, 2)));
  y_t = x_t * r / h;

  x_o = x_t + sqrt(pow(r_nose, 2) - pow(y_t, 2));

  union() {
    difference() {
      cylinder(d1=d, d2=0, h=h);
      translate([-d/2, -d/2, h-x_t])
        cube([d, d, x_t+1]);
    }
    translate([0, 0, h-x_o])
      sphere(d=b);
  }

}

// Sears-Haack revolution
// Implementation adapted from Garrett Goss' Nosecone SCAD library
// https://www.thingiverse.com/thing:2004511
//
// Formulae (radians):
// theta = acos(1 - (2 * x / L));
// y = (R / sqrt(PI)) * sqrt(theta - (sin(2 * theta) / 2) + C * pow(sin(theta),3));
//
// Parameters:
// c = 1/3: LV-Haack (minimizes supersonic drag for a given L & V)
// c = 0: LD-Haack (minimizes supersonic drag for a given L & D), also referred to as Von Kármán
//
// f = approximation facets
module s_haack(d, h, c=0, f=$fn) {
  inc = 1/f;
  r = d/2;

  rotate_extrude()
    for (i = [1 : f]){
      x_last = h * (i - 1) * inc;
      x = h * i * inc;

      theta_last = TORAD * acos((1 - (2 * x_last/h)));
      y_last = (r/sqrt(PI)) * sqrt(theta_last - (sin(TODEG * (2*theta_last))/2) + c * pow(sin(TODEG * theta_last), 3));

      theta = TORAD * acos(1 - (2 * x/h));
      y = (r/sqrt(PI)) * sqrt(theta - (sin(TODEG * (2 * theta)) / 2) + c * pow(sin(TODEG * theta), 3));

      rotate([0, 0, -90])
        polygon(points = [[x_last - h, 0], [x - h, 0], [x - h, y], [x_last - h, y_last]]);
    }

}

// Secant Ogive revolution
// Implementation adapted from Garrett Goss' Nosecone SCAD library
// https://www.thingiverse.com/thing:2004511
//
// Formulae (radians):
// alpha = TORAD * atan(R/L) - TORAD * acos(sqrt(pow(L,2) + pow(R,2)) / (2 * rho));
// y = sqrt(pow(rho,2) - pow((rho * cos(TODEG * alpha) - x),2)) + (rho * sin(TODEG * alpha));
//
// Parameters:
// For a bulging cone (e.g. Honest John): L/2 < rho < (R^2 + L^2)/(2R)
// Otherwise: rho > (R^2 + L^2)/(2R)
//
// f = approximation facets
module s_secant_ogive(d, h, rho, f=$fn) {
  inc = 1/f;
  r = d/2;

  alpha = TORAD * atan(r/h) - TORAD * acos(sqrt(pow(h,2) + pow(r,2)) / (2*rho));

  rotate_extrude()
    for (i = [1 : f]) {

      x_last = h * (i - 1) * inc;
      x = h * i * inc;

      y_last = sqrt(pow(rho,2) - pow((rho * cos(TODEG*alpha) - x_last), 2)) + (rho * sin(TODEG*alpha));

      y = sqrt(pow(rho,2) - pow((rho * cos(TODEG*alpha) - x), 2)) + (rho * sin(TODEG*alpha));

      rotate([0, 0, -90])
        polygon(points = [[x_last - h, 0], [x - h, 0], [x - h, y], [x_last - h, y_last]]);
    }
}

// Blunted Tangent Ogive revolution
//
// Parameters:
// b = diameter of the tip sphere
//
// f = approximation facets
module s_blunted_tangent_ogive(d, h, b, f=$fn) {

  r = d/2;
  r_nose = b/2;

  rho = (pow(r,2) + pow(h,2)) / (2*r);

  x_o = h - sqrt(pow((rho - r_nose), 2) - pow((rho - r), 2));
  y_t = (r_nose * (rho - r)) / (rho - r_nose);
  x_t = x_o - sqrt(pow(r_nose, 2) - pow(y_t, 2));

  union() {
    difference() {
      s_tangent_ogive(d, h, f=$fn);
      translate([-d/2, -d/2, h-x_t])
        cube([d, d, x_t+1]);
    }
    translate([0, 0, h-x_o])
      sphere(d=b);
  }

}

module s_blunted_secant_ogive(d, h, rho, b, f=$fn) {

  r = d/2;
  br = b/2;

  l = sqrt(r*r + h*h);

  dx = h/l;
  dy = r/l;

  mx = h/2;
  my = r/2;

  k = sqrt(pow(rho, 2) - pow(l/2, 2));

  cx = mx+dy*k;
  cy = my-dx*k;

  alpha = TORAD * atan(r/h) - TORAD * acos(sqrt(pow(h,2) + pow(r,2)) / (2*rho));

  rx = rho*cos(TODEG*alpha) - sqrt(rho*rho - pow(br - rho*sin(TODEG*alpha), 2));
  ry = br;

  run = cx-rx;
  rise = cy-ry;
  dl = sqrt(run*run + rise*rise);
  dtx = run/dl;
  dty = rise/dl;

  t = -ry/(dty);
  zx = rx + dtx*t;

  kd = sqrt(pow(zx-rx, 2) + pow(0-ry, 2)) * 2;

  difference() {
    s_secant_ogive(d, h, rho);

    translate([0, 0, h-rx])
      linear_extrude(rx+1)
      square([d+2, d+2], center=true);
  }

  translate([0, 0, h-zx])
    sphere(d=kd);

}
