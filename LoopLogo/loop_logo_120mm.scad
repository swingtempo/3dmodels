// Microsoft Loop logo desk sculpture (floating loop only)
// Generated from SVG gradients -> heightmap and tube-style rounded top.
// Units: millimeters

$fn = 64;

module loop_logo() {
  // Heightmap defines overall thickness, bottom is flat.
  intersection() {
    // heightmap is grayscale PNG; pixel values map to Z
    scale([0.236220, 0.236220, 0.031875])
      surface(file="loop_heightmap.png", center=true, invert=false);

    // Clip footprint to the Loop silhouette
    translate([0,0,0])
      linear_extrude(height=10.13)
        import("loop_mask.svg");
  }
}

loop_logo();
