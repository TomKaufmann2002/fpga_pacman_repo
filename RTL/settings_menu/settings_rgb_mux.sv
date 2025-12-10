
`include "include/constants.vh"

module	settings_rgb_mux

(
	// inputs:
	input	logic	clk,
	input	logic	resetN,
	
	input logic [`PRIO_COUNT_SETTINGS-1:0] dr_prio_reg,
	input logic [`PRIO_COUNT_SETTINGS-1:0][7:0] rgb_prio_reg,
	input logic [7:0] bg_rgb,
					      
	// outputs:
	output logic [7:0] rgb
);

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		rgb <= bg_rgb;
	end else begin
		rgb <= bg_rgb; // defult
		for (int i = `PRIO_COUNT_SETTINGS-1; i >= 0; i--) begin
			if (dr_prio_reg[i])
				rgb <= rgb_prio_reg[i];
		end
	end
end

endmodule


