// Parametric cube-mesh reconstruction from base_voxels.scad (merged cubes, not voxels)
pitch = 2.5;
orig_tower_spacing = 38.0;
tower_spacing = orig_tower_spacing; // center-to-center spacing between the two towers
tower_dir = [0, 1, 0];
hole_dims = [7.5, 12.5, 35]; // (x,y,z) cutout size inside each tower
hole_offset = [0,0,0]; // additional offset applied to the hole center (in world axes)

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
  // Base stays fixed
  draw_boxes(base_boxes);

  // Move towers symmetrically along tower_dir to achieve tower_spacing
  delta = (tower_spacing - orig_tower_spacing) / 2;
  shift = [tower_dir[0]*delta, tower_dir[1]*delta, tower_dir[2]*delta];

  translate(-shift) tower(tower0_boxes, tower0_center, tower0_hole_rel);
  translate( shift) tower(tower1_boxes, tower1_center, tower1_hole_rel);
}

model();
