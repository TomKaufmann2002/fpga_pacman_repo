
`include "include/constants.vh"

module coalition_detector	(
	// inputs:
	input	logic clk,
	input	logic resetN,
	
	input	logic [`PRIO_COUNT-1:0] dr_prio_reg,
	
	// outputs:
	output pm_rg_col,
	output pm_pg_col,
	output pm_cg_col,
	output pm_og_col,
	
	output pm_pdot_col,
	output pm_edot_col
);

assign pm_rg_col = (dr_prio_reg[`PM_PRIO] && dr_prio_reg[`RG_PRIO]);
assign pm_pg_col = (dr_prio_reg[`PM_PRIO] && dr_prio_reg[`PG_PRIO]);
assign pm_cg_col = (dr_prio_reg[`PM_PRIO] && dr_prio_reg[`CG_PRIO]);
assign pm_og_col = (dr_prio_reg[`PM_PRIO] && dr_prio_reg[`OG_PRIO]);

assign pm_pdot_col = (dr_prio_reg[`PM_PRIO] && dr_prio_reg[`PDOT_PRIO]);
assign pm_edot_col = (dr_prio_reg[`PM_PRIO] && dr_prio_reg[`EDOT_PRIO]);

endmodule

