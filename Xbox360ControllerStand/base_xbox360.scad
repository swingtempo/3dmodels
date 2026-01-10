// Parametric cube-mesh reconstruction from base_voxels.scad (merged cubes, not voxels)
pitch = 2.5;

// tower_spacing is measured between the *inner edges* of the rectangular holes
// (i.e., from the hole face closest to the center gap on tower A to the corresponding face on tower B).
// Increasing tower_spacing also lengthens the base in the tower_dir direction.
tower_dir = [0, 1, 0];                 // direction from tower0 -> tower1
hole_dims = [9.8, 13.5, 35];           // (x,y,z) size of the cutout inside each tower
hole_offset = [0,0,0];                 // additional offset applied to the hole center (world axes)

// --- derived constants from the original imported geometry ---
base_gap_hole_centers = 45.0;          // original (tower1 hole center Y - tower0 hole center Y), along tower_dir
orig_hole_edge_spacing = base_gap_hole_centers - hole_dims[1];

// user-facing parameter (inner-edge-to-inner-edge spacing)
tower_spacing = 38;//orig_hole_edge_spacing;

base_boxes = [
  [-55, -82.5, 0, 112.5, 77.5, 2.5],
  [-55, -82.5, 2.5, 112.5, 2.5, 12.5],
  [-55, -80, 2.5, 2.5, 75, 12.5],
  [55, -80, 2.5, 2.5, 75, 12.5],
  [50, -50, 2.5, 5, 7.5, 12.5],
  [47.5, -47.5, 2.5, 2.5, 5, 12.5],
  [-52.5, -7.5, 2.5, 107.5, 2.5, 12.5],
  [-52.5, -80, 12.5, 107.5, 10, 2.5],
  [-52.5, -70, 12.5, 2.5, 62.5, 2.5],
  [-47.5, -70, 12.5, 102.5, 20, 2.5],
  [-50, -57.5, 12.5, 2.5, 27.5, 2.5],
  [-47.5, -50, 12.5, 97.5, 2.5, 2.5],
  [-47.5, -47.5, 12.5, 95, 40, 2.5],
  [47.5, -42.5, 12.5, 7.5, 35, 2.5],
  [-50, -17.5, 12.5, 2.5, 10, 2.5],
];
orig_base_min_y = -82.5;
orig_base_max_y = -5.0;
eps = 0.01;

// Extend base boxes along tower_dir (Y) when tower spacing increases.
// Boxes that touch the original min/max Y get extended by half on that side.
// Boxes that touch both ends get extended by the full amount.
function extend_base_box(b, ext) =
    let(y0=b[1], dy=b[4], y1=y0+dy,
        touch_min = abs(y0 - orig_base_min_y) < eps,
        touch_max = abs(y1 - orig_base_max_y) < eps)
    touch_min && touch_max ? [b[0], y0 - ext/2, b[2], b[3], dy + ext,   b[5]] :
    touch_min            ? [b[0], y0 - ext/2, b[2], b[3], dy + ext/2, b[5]] :
    touch_max            ? [b[0], y0,         b[2], b[3], dy + ext/2, b[5]] :
                             b;

tower0_boxes = [
  [-52.5, -72.5, 15, 7.5, 2.5, 30],
  [-37.5, -72.5, 15, 5, 17.5, 30],
  [-52.5, -70, 15, 2.5, 15, 30],
  [-47.5, -70, 15, 2.5, 15, 30],
  [-45, -60, 15, 7.5, 5, 30],
  [-50, -57.5, 15, 2.5, 2.5, 30],
  [-50, -67.5, 20, 2.5, 7.5, 5],
  [-50, -67.5, 35, 2.5, 7.5, 5],
  [-50, -65, 40, 2.5, 2.5, 5],
  [-50, -70, 42.5, 2.5, 5, 2.5],
  [-50, -62.5, 42.5, 2.5, 5, 2.5],
];
tower1_boxes = [
  [-52.5, -32.5, 15, 20, 2.5, 30],
  [-52.5, -30, 15, 2.5, 15, 30],
  [-47.5, -30, 15, 15, 2.5, 30],
  [-47.5, -27.5, 15, 2.5, 12.5, 30],
  [-37.5, -27.5, 15, 5, 12.5, 30],
  [-50, -17.5, 15, 2.5, 2.5, 30],
  [-50, -27.5, 20, 2.5, 7.5, 5],
  [-50, -27.5, 35, 2.5, 7.5, 5],
  [-50, -25, 40, 2.5, 2.5, 5],
  [-50, -30, 42.5, 2.5, 5, 2.5],
  [-50, -22.5, 42.5, 2.5, 5, 2.5],
];
tower0_center = [-42.417, -62.750, 30.178];
tower1_center = [-42.417, -24.750, 30.178];
tower0_hole_rel = [1.167, -3.500, 0.000];
tower1_hole_rel = [1.167, 3.500, 0.000];


module draw_boxes(B) {
  for (b = B) {
    translate([b[0], b[1], b[2]]) cube([b[3], b[4], b[5]], center=false);
  }
}

module tower(B, tower_center, hole_rel) {
  difference() {
    draw_boxes(B);
    translate(tower_center + hole_rel + hole_offset)
      cube(hole_dims, center=true);
  }
}

module model() {
  // Compute how much to separate the towers (and extend the base) to achieve the requested
  // inner-edge-to-inner-edge hole spacing.
  sep_needed = (tower_spacing + hole_dims[1]) - base_gap_hole_centers;  // additional separation between hole centers
  shift_amt = sep_needed / 2;
  shift = [tower_dir[0]*shift_amt, tower_dir[1]*shift_amt, tower_dir[2]*shift_amt];

  // Extend the base along Y by the same total additional separation (sep_needed).
  base_boxes_ext = [for (b = base_boxes) extend_base_box(b, sep_needed)];
  draw_boxes(base_boxes_ext);


  translate(-shift) tower(tower0_boxes, tower0_center, tower0_hole_rel);
  translate( shift) tower(tower1_boxes, tower1_center, tower1_hole_rel);
}

model();
