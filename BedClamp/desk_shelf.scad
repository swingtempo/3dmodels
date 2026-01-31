// leverages https://github.com/reiver/scad-box
use <../../scad-box/use.scad>

module desk_shelf(width = 240) {

  block_width = width; // X (6 inches) 
  block_depth = 140; // Y (14 cm)
  shelf_thickness = 15;

  leg_height = 50;
  leg_thickness = 15;

  fnValue = 50;

  // Shelf
  translate([0, 0, (leg_height - shelf_thickness) / 2])
    box([block_width, block_depth, shelf_thickness], center=true, edge_radius=3, $fn=fnValue);

  // Legs
  // Position first leg under one long edge (along X); move in Y by (block_depth - leg_thickness)/2
  translate([0, (block_depth - leg_thickness) / 2, 0])
    box([block_width, leg_thickness, leg_height], center=true, edge_radius=3, $fn=fnValue);

  // Second leg on the opposite long edge (mirror in Y)
  translate([0, -(block_depth - leg_thickness) / 2, 0])
    box([block_width, leg_thickness, leg_height], center=true, edge_radius=3, $fn=fnValue);
}

desk_shelf();
