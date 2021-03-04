
module mb_button(stem, height) {
  translate([0, - 2.8, 0])
    difference() {
      linear_extrude(height)
        polygon([[ 0.90, 0.0],
                 [ 2.80, 1.9],
                 [ 1.45, 1.9],
                 [ 1.45, 2.8+stem],
                 [-1.45, 2.8+stem],
                 [-1.45, 1.9],
                 [-2.80, 1.9],
                 [-0.90, 0.0]]);
      union() {
        translate([2.3, 0, -1])
          cube([1, 3, height+2]);
        translate([-3.3, 0, -1])
          cube([1, 3, height+2]);
      }
  }
}
