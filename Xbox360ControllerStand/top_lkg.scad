// Parameterized version of top_rect_cubes_simplified_jay.scad
// Parameters (edit these):
//   width:    overall X width (right side shifts)
//   length:   overall Y depth (scales from front face)
//   arm_gap:  gap in Y between the two arms (overrides the scaled gap)
//
// Knob-centering behavior:
// - Features in the mid-band (the small "knobs" on the large planes) stay centered
//   between the arms when arm_gap changes (they shift by half the gap delta).
//
// Identity check (matches the source geometry exactly) when:
//   width  = 252.997994;
//   length = 59.644998;
//   arm_gap = 31.750000;

width   = 252.997994;
length  = 59.644998;
arm_gap = 39.750000;

// --- Reference constants (from source file) ---
_x_min      = -123.000008;
_x_split    = 94.997986;
_width_orig = 252.997994;

// Y reference landmarks (original)
// front arm ends at _y_front_end, back arm starts at _y_back_start.
// mid-band corresponds to the small "knobs" on the large planes.
_y_min           = 15.999999;
_y_front_end     = 29.946999;
_y_mid_band_start = 42.919998;
_y_mid_band_end   = 48.919998;
_y_back_start    = 61.696999;
_y_max           = 75.644997;
_length_orig     = 59.644998;
_arm_gap_orig    = 31.750000;

// --- Mapping functions ---
// X: shift the right side to hit the desired width
function map_x(x) = (x < _x_split) ? x : (x + (width - _width_orig));

// Y: first scale overall length from the front face, then shift the back-arm region
// to achieve the requested arm_gap. Mid-band features shift by half the gap delta.
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


// --- Section controls ---
// Four section templates exist (0..3). Each template is a left-to-right slice of the design
// and contains *two towers* (front + back) plus its mid-band features.
//
// To remove/reorder/repeat sections, edit these:
section_sequence = [0,1,2,3,4];           // templates per slot: 0=base-only, 1=rightmost towers, ..., 4=leftmost towers
section_show     = [true,true,true,true,true]; // per-slot visibility (same length as section_sequence)

_section_centers = [-73.682014, -18.932015, 35.817985, 90.567986];
_section_pitch   = 54.750000;

function slot_center(slot) = _section_centers[0] + slot*_section_pitch;
function template_center(idx) = _section_centers[idx];

module section_by_index(idx) {
  if (idx==0) section_0();
  else if (idx==1) section_1();
  else if (idx==2) section_2();
  else if (idx==3) section_3();
  else assert(false, str("Invalid section index: ", idx));
}

module place_section(slot, idx) {
  // Translate template idx into slot position so spacing stays consistent
  translate([slot_center(slot) - template_center(idx), 0, 0]) section_by_index(idx);
}

module sections() {
  // Base segments are defined by the right edges of the tower pairs, plus the overall base bounds.
  // Sections (slots) run from the RIGHT side toward the LEFT:
  //   slot 0: base_x_max -> right edge of rightmost towers (no towers by default)
  //   slot 1: rightmost tower edge -> next tower edge
  //   slot 2: next -> next
  //   slot 3: next -> next
  //   slot 4: leftmost tower edge -> base_x_min
  //
  // Template ids (section_sequence):
  //   0 = base-only (no towers)
  //   1 = section_3 (rightmost towers)
  //   2 = section_2
  //   3 = section_1
  //   4 = section_0 (leftmost towers)

  for (slot = [0 : len(section_sequence)-1]) {
    if (slot < len(section_show) && section_show[slot]) {
      // Base under this section
      base_segment_for_slot(slot);

      // Section content (towers/knobs/etc) for this slot
      place_template(section_sequence[slot]);
    }
  }
}

// --- Base segment clipping (per slot) ---
_base_x_max_orig = 129.997986;
_base_x_min_orig = -123.000008;
// Right edges of each tower-pair (original coordinates, before map_x())
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
  // Clip the common base planes into the slot's X-range.
  // Use mapped X coordinates so width parameterization stays consistent.
  x_hi = map_x(slot_x_hi_orig(slot));
  x_lo = map_x(slot_x_lo_orig(slot));
  x0 = min(x_lo, x_hi);
  x1 = max(x_lo, x_hi);
  w  = max(0.001, x1 - x0);

  intersection() {
    base_planes();
    // Big clip box in Y/Z; base is near y~[16..76], z~[0..~20], so this safely covers it.
    translate([x0, -1000, -1000]) cube([w, 2000, 2000], center=false);
  }
}

// --- Template dispatcher ---
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
  } else {
    // Unknown template id: render nothing
  }
}


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
    rect_prism_m(-119.196615,42.919998,-113.073431,48.919998,9.748000,0.002);
    rect_prism_m(-120.437410,42.919998,-114.314075,48.919998,9.750000,12.195);
    rect_prism_m(-118.738005,42.919998,-115.676272,48.919998,21.945000,1.197);
    rect_prism_m(-78.112015,15.999999,-69.252014,29.919998,9.750000,64.779);
    rect_prism_m(-78.112015,61.919998,-69.252014,75.644997,9.750000,64.779);
    rect_prism_m(-79.467536,15.999999,-69.252014,29.919998,74.529000,4.4726);
    rect_prism_m(-79.467536,61.919998,-69.252014,75.644997,74.529000,4.4726);
    rect_prism_m(-82.437039,15.999999,-70.865755,29.919998,79.001600,5.3254);
    rect_prism_m(-82.437039,61.919998,-70.865755,75.644997,79.001600,5.3254);
  }
}

module section_1() {
  union() {
    rect_prism_m(-64.446630,42.919998,-58.323427,48.919998,9.748000,0.002);
    rect_prism_m(-65.687418,42.919998,-59.564071,48.919998,9.750000,12.195);
    rect_prism_m(-63.988003,42.919998,-60.926268,48.919998,21.945000,1.197);
    rect_prism_m(-23.362015,15.999999,-14.502014,29.919998,9.750000,64.779);
    rect_prism_m(-23.362015,61.919998,-14.502014,75.644997,9.750000,64.779);
    rect_prism_m(-24.717536,15.999999,-14.502014,29.919998,74.529000,4.4726);
    rect_prism_m(-24.717536,61.919998,-14.502014,75.644997,74.529000,4.4726);
    rect_prism_m(-27.687036,15.999999,-16.115755,29.919998,79.001600,5.3254);
    rect_prism_m(-27.687036,61.919998,-16.115755,75.644997,79.001600,5.3254);
  }
}

module section_2() {
  union() {
    rect_prism_m(-9.696628,42.919998,-3.573428,48.919998,9.748000,0.002);
    rect_prism_m(-10.937418,42.919998,-4.814072,48.919998,9.750000,12.195);
    rect_prism_m(-9.238005,42.919998,-6.176269,48.919998,21.945000,1.197);
    rect_prism_m(31.387985,15.999999,40.247986,29.919998,9.750000,64.779);
    rect_prism_m(31.387985,61.919998,40.247986,75.644997,9.750000,64.779);
    rect_prism_m(30.032464,15.999999,40.247986,29.919998,74.529000,4.4726);
    rect_prism_m(30.032464,61.919998,40.247986,75.644997,74.529000,4.4726);
    rect_prism_m(27.062964,15.999999,38.634246,29.919998,79.001600,5.3254);
    rect_prism_m(27.062964,61.919998,38.634246,75.644997,79.001600,5.3254);
  }
}

module section_3() {
  union() {
    rect_prism_m(45.053381,42.919998,51.176573,48.919998,9.748000,0.002);
    rect_prism_m(43.812582,42.919998,49.935932,48.919998,9.750000,12.195);
    rect_prism_m(45.511995,42.919998,48.573739,48.919998,21.945000,1.197);
    rect_prism_m(86.137985,15.999999,94.997986,29.919998,9.750000,64.779);
    rect_prism_m(86.137985,61.919998,94.997986,75.644997,9.750000,64.779);
    rect_prism_m(84.782464,15.999999,94.997986,29.919998,74.529000,4.4726);
    rect_prism_m(84.782464,61.919998,94.997986,75.644997,74.529000,4.4726);
    rect_prism_m(81.812961,15.999999,93.384242,29.919998,79.001600,5.3254);
    rect_prism_m(81.812961,61.919998,93.384242,75.644997,79.001600,5.3254);
  }
}

// --- Final assembly ---
module top() {
  union() {
    //base_planes();
    sections();
  }
}

top();
