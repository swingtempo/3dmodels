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


pair_spacing = 54.750000;   // X spacing between tower *pairs* (right-edge to right-edge)
tower_width  = 8.860001;    // X width of a tower (main body width at the base)
tower_length = [14, 14]; // [front, back] Y length of each tower
tower_height = 74.577000;   // Overall Z height of a tower (from z=9.75 to the top)

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

// --- Tower parameterization helpers ---
// The original towers are made from 3 stacked prisms. We build the raw geometry
// in "original coordinates" (pre map_x/map_y), then scale it to match the user
// parameters while keeping the tower's right edge, front/back start, and base Z fixed.

_tower_z0_orig = 9.750000;
_tower_h_orig  = 74.577000;  // (79.001600+5.325400) - 9.750000

_tower_main_w_orig = 8.860001; // 94.997986 - 86.137985

_tower_front_y0_orig = 15.999999;
_tower_front_len_orig = 13.919999; // 29.919998 - 15.999999

_tower_back_y0_orig = 61.919998;
_tower_back_len_orig = 13.724999;  // 75.644997 - 61.919998

// X offsets from a tower's right edge (x_right) that define the 3 stacked prisms
_tower_main_dx0 = _tower_main_w_orig;         // main: x_right - dx0 .. x_right
_tower_mid_dx0  = 10.215522;                  // mid:  x_right - dx0 .. x_right
_tower_top_dx0  = 13.185022;                  // top:  x_right - dx0 .. (x_right - dx1)
_tower_top_dx1  = 1.613744;

module _tower_raw(x_right, y0, y_len) {
  union() {
    // main body
    rect_prism_m(x_right - _tower_main_dx0, y0, x_right, y0 + y_len, _tower_z0_orig, 64.779);
    // mid cap
    rect_prism_m(x_right - _tower_mid_dx0,  y0, x_right, y0 + y_len, 74.529000, 4.4726);
    // top cap (slightly inset on the right)
    rect_prism_m(x_right - _tower_top_dx0,  y0, x_right - _tower_top_dx1, y0 + y_len, 79.001600, 5.3254);
  }
}

module tower_scaled(x_right, y0, y_len_orig, y_len_target) {
  // Scale about (x_right, y0, _tower_z0_orig) so the tower stays "attached"
  // to the same base and its right edge stays aligned.
  sx = tower_width / _tower_main_w_orig;
  sy = y_len_target / y_len_orig;
  sz = tower_height / _tower_h_orig;

  translate([x_right, y0, _tower_z0_orig])
    scale([sx, sy, sz])
      translate([-x_right, -y0, -_tower_z0_orig])
        _tower_raw(x_right, y0, y_len_orig);
}

module tower_pair(x_right) {
  // Front tower (uses tower_length[0])
  tower_scaled(x_right, _tower_front_y0_orig, _tower_front_len_orig, tower_length[0]);
  // Back tower (uses tower_length[1])
  tower_scaled(x_right, _tower_back_y0_orig,  _tower_back_len_orig,  tower_length[1]);
}



// --- Section controls ---
// Four section templates exist (0..3). Each template is a left-to-right slice of the design
// and contains *two towers* (front + back) plus its mid-band features.
//
// To remove/reorder/repeat sections, edit these:
section_sequence = [0,1,2,3,4];           // templates per slot: 0=base-only, 1=rightmost towers, ..., 4=leftmost towers
section_show     = [true,true,true,true,true]; // per-slot visibility (same length as section_sequence)

_section_centers = [-73.682014, -18.932015, 35.817985, 90.567986];
_section_pitch_orig = 54.750000;
_section_pitch = pair_spacing;

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
      translate([template_shift_x(section_sequence[slot]), 0, 0]) place_template(section_sequence[slot]);
    }
  }
}

// --- Base segment clipping (per slot) ---
_base_x_max_orig = 129.997986;
_base_x_min_orig = -123.000008;
// Right edges of each tower-pair.
// Keep the *template* geometry at the original pitch, then move whole templates
// by template_shift_x() so changing pair_spacing doesn't double-apply.
_tower_right_edge0_orig = 94.997986;
_tower_right_edges_template = [
  _tower_right_edge0_orig,
  _tower_right_edge0_orig - 1*_section_pitch_orig,
  _tower_right_edge0_orig - 2*_section_pitch_orig,
  _tower_right_edge0_orig - 3*_section_pitch_orig
];

// Actual (placed) right-edges after spacing adjustment.
function tower_right_edge_placed(i) = _tower_right_edge0_orig - i*pair_spacing;

// Compute how far left the towers extend (so the base can stretch under them).
_tower_dx_max_orig = _tower_top_dx0; // widest left overhang in the source tower stack
function _tower_dx_max_scaled() = _tower_dx_max_orig * (tower_width / _tower_main_w_orig);
function _base_x_min_dyn() =
  min(
    _base_x_min_orig,
    min([ for (i=[0:3]) tower_right_edge_placed(i) - _tower_dx_max_scaled() ])
  );

function slot_x_hi_orig(slot) =
  (slot == 0) ? _base_x_max_orig :
  (slot == 1) ? tower_right_edge_placed(0) :
  (slot == 2) ? tower_right_edge_placed(1) :
  (slot == 3) ? tower_right_edge_placed(2) :
  (slot == 4) ? tower_right_edge_placed(3) :
  _base_x_min_dyn();

function slot_x_lo_orig(slot) =
  (slot == 0) ? tower_right_edge_placed(0) :
  (slot == 1) ? tower_right_edge_placed(1) :
  (slot == 2) ? tower_right_edge_placed(2) :
  (slot == 3) ? tower_right_edge_placed(3) :
  (slot == 4) ? _base_x_min_dyn() :
  _base_x_min_dyn();

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


// --- X spacing adjustment for tower pairs ---
// pair_spacing changes the X distance between tower pairs. The rightmost pair stays fixed;
// pairs to the left shift by multiples of (pair_spacing - _section_pitch_orig).
function pair_index_from_tid(tid) =
  (tid == 1) ? 0 :
  (tid == 2) ? 1 :
  (tid == 3) ? 2 :
  (tid == 4) ? 3 :
  0;

function template_shift_x(tid) =
  -pair_index_from_tid(tid) * (pair_spacing - _section_pitch_orig);


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
  bxmin = _base_x_min_dyn();
  union() {
    rect_prism_m(94.997986,15.999999,129.997986,29.946999,0.000000,9.747);
    // Main slab stretches in X so it always stays under the (moved) towers.
    rect_prism_m(bxmin,15.999999,94.997986,75.644997,0.000000,9.747);
    rect_prism_m(94.997986,61.696999,129.997986,75.644997,0.000000,9.747);
    rect_prism_m(bxmin,15.999999,129.997986,29.946999,9.748000,0.002);
    rect_prism_m(bxmin,61.696999,129.997986,75.644997,9.748000,0.002);
  }
}

module section_0() {
  tower_pair(_tower_right_edges_template[3]);
}

module section_1() {
  tower_pair(_tower_right_edges_template[2]);
}

module section_2() {
  tower_pair(_tower_right_edges_template[1]);
}

module section_3() {
  tower_pair(_tower_right_edges_template[0]);
}

// --- Final assembly ---
module top() {
  union() {
    //base_planes();
    sections();
  }
}

top();
