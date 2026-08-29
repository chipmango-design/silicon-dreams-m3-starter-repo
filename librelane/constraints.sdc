# =============================================================================
# Silicon Dreams · Module 3 · constraints.sdc
#
# Honest SDC for the tt_um_silicon_dreams top. See SG-M3-04 and SG-M3-07.
# =============================================================================

# -----------------------------------------------------------------------------
# Primary clock
# -----------------------------------------------------------------------------
create_clock -name clk_ext -period 10.0 [get_ports clk]

# -----------------------------------------------------------------------------
# Generated clock from the ICG output (drives AXIOM only)
# -----------------------------------------------------------------------------
create_generated_clock -name gclk_axiom \
    -source [get_ports clk] \
    -divide_by 1 \
    -add \
    [get_pins u_axiom_gate/u_icg/GCLK]

# CRITICAL: tell STA that clk_ext and gclk_axiom are never simultaneously
# active on a combinational path. Without this line, STA invents phantom
# setup paths between the two domains and the WNS report lies.
set_clock_groups -physically_exclusive \
    -group {clk_ext} \
    -group {gclk_axiom}

# -----------------------------------------------------------------------------
# Input/output delays — model real pad external setup/hold
# -----------------------------------------------------------------------------
set_input_delay  -clock clk_ext -max 2.0 [get_ports {ui_in[*] uio_in[*] ena rst_n}]
set_output_delay -clock clk_ext -max 2.0 [get_ports {uo_out[*] uio_out[*] uio_oe[*]}]

# -----------------------------------------------------------------------------
# False paths on the reset synchronisers' async assertion
# -----------------------------------------------------------------------------
set_false_path -from [get_ports rst_n] -to [get_pins */sync_ff1/D]

# -----------------------------------------------------------------------------
# Max transition + max capacitance (SKY130 defaults, explicit)
# -----------------------------------------------------------------------------
set_max_transition 0.75 [current_design]
set_max_capacitance 0.2 [current_design]
