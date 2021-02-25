module s_ellipsoid(h, d) {
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

/*
module hollow_cylinder(r_inner, r_outer, ht) {
  difference() {
    cylinder(r=r_outer, h=ht);;
    translate([0, 0, -1])
      cylinder(r=r_inner, h=ht+2);
  }
}
*/
