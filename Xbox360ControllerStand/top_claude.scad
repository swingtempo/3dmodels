// Parameterized version with tower spacing and dimensions control
// Parameters (edit these):
//   width:    overall X width (right side shifts)
//   length:   overall Y depth (scales from front face)
//   arm_gap:  gap in Y between the two arms (overrides the scaled gap)
//   tower_spacing: spacing between tower pairs along X axis
//   tower_width: X dimension of each tower
//   tower_depth: Y dimension of each tower
//   tower_height: Z height of each tower (from base top to tower top)

width   = 252.997994;
length  = 59.644998;
arm_gap = 39.750000;
tower_spacing = 54.750000;  // Original spacing between tower pairs
tower_width = 8.860001;     // Original: ~78.112015 - 69.252014
tower_depth = 13.920001;    // Original: ~29.919998 - 15.999999
tower_height = 64.779;      // Original tower height

// --- Reference constants (from source file) ---
_x_min      = -123.000008;
_x_split    = 94.997986;
_width_orig = 252.997994;

// Y reference landmarks (original)
_y_min           = 15.999999;
_y_front_end     = 29.946999;
_y_mid_band_start = 42.919998;
_y_mid_band_end   = 48.919998;
_y_back_start    = 61.696999;
_y_max           = 75.644997;
_length_orig     = 59.644998;
_arm_gap_orig    = 31.750000;

// --- Original tower dimensions and spacing ---
_tower_width_orig = 8.860001;
_tower_depth_orig = 13.920001;
_tower_height_orig = 64.779;
_tower_spacing_orig = 54.750000;

// --- Original tower centers ---
_section_centers = [-73.682014, -18.932015, 35.817985, 90.567986];

// Calculate spacing scale factor
_spacing_scale = tower_spacing / _tower_spacing_orig;

// --- Mapping functions ---
// X: Apply tower spacing transformation, then width adjustment
function map_x_spacing(x) = 
  let(
    // Find which tower region this X coordinate is in
    ref_center = _section_centers[0],
    offset_from_ref = x - ref_center
  )
  ref_center + offset_from_ref * _spacing_scale;

function map_x(x) = 
  let(x_spaced = map_x_spacing(x))
  (x_spaced < _x_split) ? x_spaced : (x_spaced + (width - _width_orig));

// Y: first scale overall length from the front face, then shift the back-arm region
function scale_y(y) = _y_min + (y - _y_min) * (length / _length_orig);

function _front_end_s() = scale_y(_y_front_end);
function _back_start_s() = scale_y(_y_back_start);
function _mid_start_s() = scale_y(_y_mid_band_start);
function _mid_end_s()   = scale_y(_y_mid_band_end);

function _gap_scaled() = _back_start_s() - _front_end_s();
function _gap_delta()  = arm_gap - _gap_scaled();

function map_y(y) =
  let(
    y0 = scale_y(y),
    bs = _back_start_s(),
    ms = _mid_start_s(),
    me = _mid_end_s(),
    dg = _gap_delta()
  )
  (y0 < bs)
    ? ((y0 >= ms && y0 <= me) ? (y0 + dg/2) : y0)
    : (y0 + dg);

module rect_prism_m(x1,y1,x2,y2,z0,h){
  translate([map_x(x1), map_y(y1), z0])
    cube([map_x(x2)-map_x(x1), map_y(y2)-map_y(y1), h], center=false);
}

// --- Tower dimension scaling ---
module tower_prism(x1_orig, y1_orig, x2_orig, y2_orig, z0, h_orig) {
  // Calculate original dimensions
  w_orig = x2_orig - x1_orig;
  d_orig = y2_orig - y1_orig;
  
  // Calculate center point
  x_center = (x1_orig + x2_orig) / 2;
  y_center = (y1_orig + y2_orig) / 2;
  
  // Apply tower dimension scaling
  w_scale = tower_width / _tower_width_orig;
  d_scale = tower_depth / _tower_depth_orig;
  h_scale = tower_height / _tower_height_orig;
  
  w_new = w_orig * w_scale;
  d_new = d_orig * d_scale;
  h_new = h_orig * h_scale;
  
  // New corners
  x1_new = x_center - w_new/2;
  x2_new = x_center + w_new/2;
  y1_new = y_center - d_new/2;
  y2_new = y_center + d_new/2;
  
  translate([map_x(x1_new), map_y(y1_new), z0])
    cube([map_x(x2_new)-map_x(x1_new), map_y(y2_new)-map_y(y1_new), h_new], center=false);
}

// --- Section controls ---
section_sequence = [0,1,2,3,4];
section_show     = [true,true,true,true,true];

function slot_center(slot) = _section_centers[0] + slot*tower_spacing;
function template_center(idx) = _section_centers[idx];

// --- Base planes (common to all sections) ---
module base_planes() {
  union() {
    rect_prism_m(94.997986,15.999999,129.997986,29.946999,0.000000,9.747);
    rect_prism_m(-123.000008,15.999999,94.997986,75.644997,0.000000,9.747);
    rect_prism_m(94.997986,61.696999,129.997986,75.644997,0.000000,9.747);
    rect_prism_m(-123.000008,15.999999,129.997986,29.946999,9.748000,0.002);
    rect_prism_m(-123.000008,61.696999,129.997986,75.644997,9.748000,0.002);
  }
}

module section_0() {
  union() {
    tower_prism(-78.112015,15.999999,-69.252014,29.919998,9.750000,64.779);
    tower_prism(-78.112015,61.919998,-69.252014,75.644997,9.750000,64.779);
    tower_prism(-79.467536,15.999999,-69.252014,29.919998,74.529000,4.4726);
    tower_prism(-79.467536,61.919998,-69.252014,75.644997,74.529000,4.4726);
    tower_prism(-82.437039,15.999999,-70.865755,29.919998,79.001600,5.3254);
    tower_prism(-82.437039,61.919998,-70.865755,75.644997,79.001600,5.3254);
  }
}

module section_1() {
  union() {
    tower_prism(-23.362015,15.999999,-14.502014,29.919998,9.750000,64.779);
    tower_prism(-23.362015,61.919998,-14.502014,75.644997,9.750000,64.779);
    tower_prism(-24.717536,15.999999,-14.502014,29.919998,74.529000,4.4726);
    tower_prism(-24.717536,61.919998,-14.502014,75.644997,74.529000,4.4726);
    tower_prism(-27.687036,15.999999,-16.115755,29.919998,79.001600,5.3254);
    tower_prism(-27.687036,61.919998,-16.115755,75.644997,79.001600,5.3254);
  }
}

module section_2() {
  union() {
    tower_prism(31.387985,15.999999,40.247986,29.919998,9.750000,64.779);
    tower_prism(31.387985,61.919998,40.247986,75.644997,9.750000,64.779);
    tower_prism(30.032464,15.999999,40.247986,29.919998,74.529000,4.4726);
    tower_prism(30.032464,61.919998,40.247986,75.644997,74.529000,4.4726);
    tower_prism(27.062964,15.999999,38.634246,29.919998,79.001600,5.3254);
    tower_prism(27.062964,61.919998,38.634246,75.644997,79.001600,5.3254);
  }
}

module section_3() {
  union() {
    tower_prism(86.137985,15.999999,94.997986,29.919998,9.750000,64.779);
    tower_prism(86.137985,61.919998,94.997986,75.644997,9.750000,64.779);
    tower_prism(84.782464,15.999999,94.997986,29.919998,74.529000,4.4726);
    tower_prism(84.782464,61.919998,94.997986,75.644997,74.529000,4.4726);
    tower_prism(81.812961,15.999999,93.384242,29.919998,79.001600,5.3254);
    tower_prism(81.812961,61.919998,93.384242,75.644997,79.001600,5.3254);
  }
}

// --- Base segment clipping (per slot) ---
_base_x_max_orig = 129.997986;
_base_x_min_orig = -123.000008;
_tower_right_edges_orig = [94.997986, 40.247986, -14.502014, -69.252014];

function slot_x_hi_orig(slot) =
  (slot == 0) ? _base_x_max_orig :
  (slot == 1) ? _tower_right_edges_orig[0] :
  (slot == 2) ? _tower_right_edges_orig[1] :
  (slot == 3) ? _tower_right_edges_orig[2] :
  (slot == 4) ? _tower_right_edges_orig[3] :
  _base_x_min_orig;

function slot_x_lo_orig(slot) =
  (slot == 0) ? _tower_right_edges_orig[0] :
  (slot == 1) ? _tower_right_edges_orig[1] :
  (slot == 2) ? _tower_right_edges_orig[2] :
  (slot == 3) ? _tower_right_edges_orig[3] :
  (slot == 4) ? _base_x_min_orig :
  _base_x_min_orig;

module base_segment_for_slot(slot) {
  x_hi = map_x(slot_x_hi_orig(slot));
  x_lo = map_x(slot_x_lo_orig(slot));
  x0 = min(x_lo, x_hi);
  x1 = max(x_lo, x_hi);
  w  = max(0.001, x1 - x0);

  intersection() {
    base_planes();
    translate([x0, -1000, -1000]) cube([w, 2000, 2000], center=false);
  }
}

module place_template(tid) {
  if (tid == 0) {
    // base-only
  } else if (tid == 1) {
    section_3();
  } else if (tid == 2) {
    section_2();
  } else if (tid == 3) {
    section_1();
  } else if (tid == 4) {
    section_0();
  }
}

module sections() {
  for (slot = [0 : len(section_sequence)-1]) {
    if (slot < len(section_show) && section_show[slot]) {
      base_segment_for_slot(slot);
      place_template(section_sequence[slot]);
    }
  }
}

module top() {
  union() {
    sections();
  }
}

top();