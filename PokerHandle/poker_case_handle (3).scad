
// Poker-chip case handle (functional replacement)
// Units: millimeters

$fn = 64;

// ---- User parameters ----
outer_width = 120.50;        // overall width, outside-to-outside
depth       = 9.00;          // front-to-back thickness
grip_height = 18.00;        // vertical thickness of the grip bar
leg_thick   = 14.00;         // thickness of each side leg (left/right) in X
leg_height  = 28.00;          // height from bottom to underside of grip
bottom_pad  = 8.00;     // extra vertical thickness at bottom of legs

knob_diam   = 5.00;         // knob diameter
knob_len    = 4.50;       // knob length (protrusion)
knob_offset = 0.50;    // knob starts this far above bottom edge

// Desired center-to-center distance between knobs:
knob_cc     = 88.00;

// Rounding (set to 0 for sharp edges)
round_r     = 2.0;

pivot_leg_depth = 9.0;   // thickness at pivot waist (skinny section)
pivot_height    = 10.0;  // vertical height of the skinny section


// ---- Derived ----
inner_gap = outer_width - 2*leg_thick;  // gap between inner faces of legs
echo("inner_gap =", inner_gap);
echo("expected inner_gap (knob_cc + knob_len) =", knob_cc + knob_len);

// Basic rounded box helper (uses Minkowski; set round_r=0 for faster preview)
module rbox(size=[10,10,10], r=2) {
    if (r <= 0)
        cube(size, center=true);
    else
        minkowski() {
            cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
            sphere(r=r);
        }
}

// Main handle body: top grip + two legs
module handle_body() {
    union() {
        // Top grip bar
        translate([0,0, leg_height + grip_height/2])
            rbox([outer_width, depth, grip_height], r=round_r);

        // // Left leg
        // translate([-(outer_width/2 - leg_thick/2), 0, (leg_height+bottom_pad)/2])
        //     rbox([leg_thick, depth, leg_height+bottom_pad], r=round_r);

        // // Right leg
        // translate([+(outer_width/2 - leg_thick/2), 0, (leg_height+bottom_pad)/2])
        //     rbox([leg_thick, depth, leg_height+bottom_pad], r=round_r);

        // Left leg – upper (normal thickness)
        translate([-(outer_width/2 - leg_thick/2), 0,
                (leg_height+bottom_pad + pivot_height)/2])
            rbox([leg_thick, depth,
                leg_height + bottom_pad - pivot_height], r=round_r);

        // Left leg – lower pivot waist (skinny)
        translate([-(outer_width/2 - (leg_thick/2)), 0,
                pivot_height])
            rbox([leg_thick, pivot_leg_depth,
                pivot_height * 2], r=round_r);

        // Right leg – upper (normal thickness)
        translate([+(outer_width/2 - leg_thick/2), 0,
                (leg_height+bottom_pad + pivot_height)/2])
            rbox([leg_thick, depth,
                leg_height + bottom_pad - pivot_height], r=round_r);

        // Right leg – lower pivot waist (skinny)
        translate([+(outer_width/2 - (leg_thick/2)), 0,
                pivot_height])
            rbox([leg_thick, pivot_leg_depth,
                pivot_height * 2], r=round_r);
    }
}

// Knobs: cylinders protruding inward from the inner face of each leg,
// located ~2mm above the bottom (measured to the knob's bottom edge).
module knobs() {
    knob_z = knob_offset + knob_diam/2;
    knob_insertion_length_into_leg = 10;

    // Left knob (points +X)
    translate([-(inner_gap/2) + knob_len/2 - knob_insertion_length_into_leg / 2, 0, knob_z])
        rotate([0,90,0])
            cylinder(d=knob_diam, h=knob_len + knob_insertion_length_into_leg, center=true);

    // Right knob (points -X)
    translate([+(inner_gap/2) - knob_len/2 + knob_insertion_length_into_leg / 2, 0, knob_z])
        rotate([0,90,0])
            cylinder(d=knob_diam, h=knob_len + knob_insertion_length_into_leg, center=true);
}

union() {
    handle_body();
    knobs();
}

// ---- Notes for strength (PLA) ----
// Suggested print settings (starting point):
// - 5-6 perimeters (walls)
// - 40-60% infill (gyroid or grid)
// - 0.2mm layers or smaller
// - Consider PETG/ABS/nylon if the handle will be stored in heat or used long-term.
