// leverages https://github.com/reiver/scad-box
use <../../scad-box/use.scad>

module lower_edge(width = 152.4) {
  //
  // Block with centered rectangular cutout
  // Dimensions:
  //   Block: 152.4 mm × 140 mm × 76.2 mm
  //   Hole:  38.1 mm × 12 mm (through‑cut)
  //

  block_width = width; // X (6 inches) 
  block_depth = 140; // Y (14 cm)
  block_height = 55.2;

  hole_x = block_width + 2;
  hole_y = 118;
  hole_z = 24;

  fnValue = 50;

  difference() {
    // Main block
    box(
      [block_width, block_depth, block_height], center=true, edge_radius=3,
      $fn=fnValue
    );

    // Centered cutout
    cube([hole_x, hole_y, hole_z], center=true);

    // Extend cutout downward to ensure through-cut
    z_translate = 30;
    translate([0, 0, -z_translate])
      // Centered cutout
      cube([hole_x, hole_y - 25.4, hole_z + z_translate], center=true);
  }
}
