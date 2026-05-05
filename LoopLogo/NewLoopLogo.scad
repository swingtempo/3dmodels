
//
// Loop Desk Sculpture (Heightmap → flat base, rounded top)
// Source heightmap: loop_heightmap.png (grayscale; lighter = higher)
// Scale: longest XY = 120 mm; Max height = 14 mm
// Use case: desk sculpture; FDM-friendly
//

square_size = 256; // source heightmap size in pixels (assumed square)

img_file = str("./newloop_mask_", square_size, "x", square_size, ".png"); // preprocessed mask+height
max_xy_mm = 60; // longest XY dimension
max_height_mm = 5; // peak height (tune 10–16 mm as desired)
base_clip_mm = 0.5; // ensures perfectly flat base
round_mm = 0.8; // optional top rounding via minkowski
epsilon_mm = 0.01;

// Load heightmap centered. OpenSCAD's surface: lighter pixels = taller (invert=false)
module loop_surface_raw() {
  surface(file=img_file, center=true, invert=false, convexity=10);
}

// Uniform scale: assume source heightmap square_size units square
uniform_scale = max_xy_mm / square_size;

module loop_heightmap_body() {
  scale([uniform_scale, uniform_scale, max_height_mm / 100]) loop_surface_raw();
}

// Flatten base at z=0
module loop_flat_base() {
  intersection() {
    loop_heightmap_body();
    translate([0, 0, -base_clip_mm])
      cube([max_xy_mm * 2, max_xy_mm * 2, max_height_mm * 2], center=true);
  }
}


// === NEW ===
// Clip out any triangles/voxels at z <= 0 by enforcing z >= epsilon_mm
// We intersect the already-flattened body with a cube that starts above 0.
module loop_no_z0() {
  intersection() {
    //loop_flat_base();
    loop_heightmap_body();
    // Axis-aligned clip: bottom at epsilon_mm, so z in [epsilon_mm, +∞)
    // Use a big cube that covers XY entirely and a Z span > model height.
    translate([-max_xy_mm, -max_xy_mm, epsilon_mm])
      cube([max_xy_mm * 2, max_xy_mm * 2, max_height_mm * 2], center=false);
  }
}

// Optional gentle rounding on top via Minkowski (comment out if preview is slow)
//minkowski() {
//  loop_no_z0();            // use the/ /z>0-clipped body
// sphere(r=round_mm, $fn=36);
//}
// Use case: desk sculpture; FDM-friendly
//

// Optional gentle rounding on top (comment out minkowski if preview is slow)
// minkowski() {
//   //    loop_flat_base();
//   //loop_surface_raw();
//   loop_no_z0(); // use the z>0-clipped body
//   sphere(r=round_mm, $fn=36);
// }
//loop_heightmap_body();
loop_no_z0(); // use the z>0-clipped body
//cube([max_xy_mm * 2, max_xy_mm * 2, max_height_mm * 2], center=true);
