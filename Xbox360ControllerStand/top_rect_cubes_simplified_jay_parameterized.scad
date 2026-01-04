// Parameterized version of top_rect_cubes_simplified_jay.scad
// Parameters:
//   width: overall X width (in the same units as the original model)
//   arm_gap: gap in Y between the two arms
//
// Implementation notes:
// - Geometry is identical to the source when width=252.997994 and arm_gap=31.750000
// - All X coordinates >= _x_split are shifted by (width - _width_orig)
// - All Y coordinates >= _y_back_start are shifted by (arm_gap - _arm_gap_orig)

width = 252.997994;
arm_gap = 31.750000;

// --- Reference constants (from source file) ---
_x_min = -123.000008;
_x_split = 94.997986;
_width_orig = 252.997994;

_y_back_start = 61.696999;
_arm_gap_orig = 31.750000;

function map_x(x) = (x < _x_split) ? x : (x + (width - _width_orig));
function map_y(y) = (y < _y_back_start) ? y : (y + (arm_gap - _arm_gap_orig));

module rect_prism_m(x1,y1,x2,y2,z0,h){
  translate([map_x(x1), map_y(y1), z0])
    cube([map_x(x2)-map_x(x1), map_y(y2)-map_y(y1), h], center=false);
}


// Rewritten from layered polygon rebuild into rectilinear cubes
// Each slab is decomposed into axis-aligned rectangles and emitted as cubes.
// Note: This preserves orthogonal geometry; curved/diagonal features (if any) are approximated.

//module rect_prism_m(x1,y1,x2,y2,z0,h){
//  translate([x1,y1,z0]) cube([x2-x1, y2-y1, h], //center=false);
//}

module slab_1() {
  union() {
    rect_prism_m(94.997986,15.999999,129.997986,29.946999,0,9.747);
    rect_prism_m(-123.000008,15.999999,94.997986,75.644997,0,9.747);
    rect_prism_m(94.997986,61.696999,129.997986,75.644997,0,9.747);
  }
}

module slab_2() {
  union() {
    rect_prism_m(-123.000008,15.999999,129.997986,29.946999,9.748,0.002);
    rect_prism_m(-119.196615,42.919998,-113.073431,48.919998,9.748,0.002);
    rect_prism_m(-64.44663,42.919998,-58.323427,48.919998,9.748,0.002);
    rect_prism_m(-9.696628,42.919998,-3.573428,48.919998,9.748,0.002);
    rect_prism_m(45.053381,42.919998,51.176573,48.919998,9.748,0.002);
    rect_prism_m(-123.000008,61.696999,129.997986,75.644997,9.748,0.002);
  }
}

module slab_3_4_5() {
  // Consolidated: slabs 3, 4, and 5 were contiguous in Z and largely repeated.
  // This version merges the eight vertical posts into single prisms and keeps the two brace bands.
  union() {
    // Vertical posts (merged height: 64.779)
    rect_prism_m(-78.112015,15.999999,-69.252014,29.919998,9.750000,64.779000);
    rect_prism_m(-23.362015,15.999999,-14.502014,29.919998,9.750000,64.779000);
    rect_prism_m(31.387985,15.999999,40.247986,29.919998,9.750000,64.779000);
    rect_prism_m(86.137985,15.999999,94.997986,29.919998,9.750000,64.779000);
    rect_prism_m(-78.112015,61.919998,-69.252014,75.644997,9.750000,64.779000);
    rect_prism_m(-23.362015,61.919998,-14.502014,75.644997,9.750000,64.779000);
    rect_prism_m(31.387985,61.919998,40.247986,75.644997,9.750000,64.779000);
    rect_prism_m(86.137985,61.919998,94.997986,75.644997,9.750000,64.779000);

    // Lower brace band (wider)
    rect_prism_m(-120.437410,42.919998,-114.314075,48.919998,9.750000,12.195000);
    rect_prism_m(-65.687418,42.919998,-59.564071,48.919998,9.750000,12.195000);
    rect_prism_m(-10.937418,42.919998,-4.814072,48.919998,9.750000,12.195000);
    rect_prism_m(43.812582,42.919998,49.935932,48.919998,9.750000,12.195000);

    // Upper thin brace band (narrower)
    rect_prism_m(-118.738005,42.919998,-115.676272,48.919998,21.945000,1.197000);
    rect_prism_m(-63.988003,42.919998,-60.926268,48.919998,21.945000,1.197000);
    rect_prism_m(-9.238005,42.919998,-6.176269,48.919998,21.945000,1.197000);
    rect_prism_m(45.511995,42.919998,48.573739,48.919998,21.945000,1.197000);
  }
}




module slab_6() {
  union() {
    rect_prism_m(-79.467536,15.999999,-69.252014,29.919998,74.529,4.4726);
    rect_prism_m(-24.717536,15.999999,-14.502014,29.919998,74.529,4.4726);
    rect_prism_m(30.032464,15.999999,40.247986,29.919998,74.529,4.4726);
    rect_prism_m(84.782464,15.999999,94.997986,29.919998,74.529,4.4726);
    rect_prism_m(-79.467536,61.919998,-69.252014,75.644997,74.529,4.4726);
    rect_prism_m(-24.717536,61.919998,-14.502014,75.644997,74.529,4.4726);
    rect_prism_m(30.032464,61.919998,40.247986,75.644997,74.529,4.4726);
    rect_prism_m(84.782464,61.919998,94.997986,75.644997,74.529,4.4726);
  }
}

module slab_7() {
  union() {
    rect_prism_m(-82.437039,15.999999,-70.865755,29.919998,79.0016,5.3254);
    rect_prism_m(-27.687036,15.999999,-16.115755,29.919998,79.0016,5.3254);
    rect_prism_m(27.062964,15.999999,38.634246,29.919998,79.0016,5.3254);
    rect_prism_m(81.812961,15.999999,93.384242,29.919998,79.0016,5.3254);
    rect_prism_m(-82.437039,61.919998,-70.865755,75.644997,79.0016,5.3254);
    rect_prism_m(-27.687036,61.919998,-16.115755,75.644997,79.0016,5.3254);
    rect_prism_m(27.062964,61.919998,38.634246,75.644997,79.0016,5.3254);
    rect_prism_m(81.812961,61.919998,93.384242,75.644997,79.0016,5.3254);
  }
}

module top() {
  union() {
    slab_1();
    slab_2();  
    slab_3_4_5();
    slab_6();
    slab_7();
  }
}

top();
