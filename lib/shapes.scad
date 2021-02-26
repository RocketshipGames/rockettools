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
    cylinder(r=od/2, h=h);
    translate([0, 0, -1])
      cylinder(r=id/2, h=h+2);
  }
}
