
`include "include/constants.vh"

module	vga_input_mux

(
	// inputs:
	input	logic	clk,
	input	logic	resetN,
	
	input logic [`PRIO_COUNT-1:0] dr_prio_reg,
	input logic [`PRIO_COUNT-1:0][7:0] RGB_in_prio_reg,
	input logic [7:0] default_RGB,
					      
	// outputs:
	output logic [7:0] RGB_out,
	
	
	// debug in/out:
	input logic dev_mode,
	input logic debug_flag,
	input logic [10:0] pixel_x,
	input logic [10:0] pixel_y
);

assign in_debug_tile = (((pixel_x-1) / `TILE_SIZE == `DEBUG_TILE_X) &&
								(pixel_y / `TILE_SIZE == `DEBUG_TILE_Y));


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		RGB_out <= default_RGB;
	end else begin
	//----- debug tile - appears in dev mode while debug flag on
		if (dev_mode && debug_flag && in_debug_tile) begin
			RGB_out <= 8'hFC;
		end else begin
	//---------------------------------------------
			RGB_out <= default_RGB; // defult
			for (int i = `PRIO_COUNT-1; i >= 0; i--) begin
				if (dr_prio_reg[i])
					RGB_out <= RGB_in_prio_reg[i];
			end
		end
	end
end


endmodule


