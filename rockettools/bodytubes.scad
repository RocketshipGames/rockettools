// Body tube definitions
BT_LABEL = 0;
BT_INNER = 1;
BT_OUTER = 2;

//       Name     Inner  Outer      Difference
bt_tmm  = [ "T-MM",   6.45,  7.16 ]; // 0.71
bt_bt5  = [ "BT-5",  13.2,  13.8  ]; // 0.6
bt_bt20 = [ "BT-20", 18.0,  18.7  ]; // 0.7
bt_bt50 = [ "BT-50", 24.1,  24.8  ]; // 0.7
bt_bt55 = [ "BT-55", 32.6,  33.7  ]; // 1.1
bt_bt60 = [ "BT-60", 40.5,  41.6  ]; // 1.1
bt_bt80 = [ "BT-80", 65.7,  66.0  ]; // 0.3?
bt_tubes = [ bt_tmm, bt_bt5, bt_bt20, bt_bt50, bt_bt55, bt_bt60, bt_bt80 ];

function bt_get(tube) = bt_tubes[search([tube], bt_tubes)[0]];

module bt_bt(bt, h) {
  difference() {
    cylinder(r=bt[BT_OUTER]/2, h=h);
    translate([0, 0, -1])
      cylinder(r=bt[BT_INNER]/2, h=h+2);
  }
}
