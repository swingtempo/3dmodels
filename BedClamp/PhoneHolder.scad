use <BedClamp.scad>
use <../../scad-box/use.scad>

//
// iPhone 16 Plus open-top container + phone preview
// Units: mm
//

// ---- Phone dimensions (approx) ----
phone_length = 160.9; // Y
phone_width = 77.8; // X
phone_thick = 7.8; // Z

// ---- Design parameters ----
clearance_xy = 1.0; // side/length clearance
clearance_z = 10.0; // vertical clearance above phone
wall_thickness = 2.5;
floor_thick = 2.5;
extra_wall_z = 4; // wall above top of phone

add_thumb_cutout = true;
thumb_cutout_depth = 10; // in Y
thumb_cutout_height = 0.6 * phone_thick; // in Z

// ---- Derived ----
//inner_x = phone_width + 2 * clearance_xy;
inner_y = phone_length + 20 * clearance_xy;
inner_z = phone_thick + clearance_z;

outer_x = 140; // inner_x + 2 * wall_thickness;
inner_x = outer_x - 2 * wall_thickness;

outer_y = inner_y + 2 * wall_thickness;
outer_z = floor_thick + inner_z + extra_wall_z;

// ---- Modules ----
module container() {
  difference() {
    // Outer shell
    translate([-outer_x / 2, -outer_y / 2, 0])
      box([outer_x, outer_y, outer_z], center=false, edge_radius=3);

    // Inner cavity (this is what makes it not solid)
    translate([-inner_x / 2, -inner_y / 2, floor_thick])
      cube([inner_x, inner_y, inner_z + extra_wall_z + 0.1], center=false);

    // remove a wall
    translate([-inner_x / 2, 0, floor_thick])
      cube([inner_x, inner_y, inner_z + extra_wall_z + 0.1], center=false);

    // Thumb cutout
    if (add_thumb_cutout) {
      translate(
        [
          -inner_x / 2,
          -inner_y / 2 - 0.2, // extend slightly outside
          floor_thick,
        ]
      )
        cube(
          [inner_x, thumb_cutout_depth, thumb_cutout_height],
          center=false
        );
    }
  }
}

module phone_dummy() {
  // Simple block to visualize phone inside
  color("red", 0.5)
    translate([-phone_width / 2, -phone_length / 2, floor_thick])
      cube([phone_width, phone_length, phone_thick], center=false);
}

// ---- Preview ----
$fn = 64;

// Show container
container();
phone_dummy();

rotate([0, 0, 90])
  translate([0, 0, -10]) lower_edge(width=outer_y);
