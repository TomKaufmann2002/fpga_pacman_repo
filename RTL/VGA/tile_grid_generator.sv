
`include "include/constants.vh"

module tile_grid_generator (
// inputs:
input logic clk,
input logic resetN,

input logic [10:0] pixel_x,
input logic [10:0] pixel_y,

//outputs:
output logic [7:0] RGB_out
);

always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		RGB_out <= `TRNS;
	end else begin
		if (is_grid_line)
			RGB_out <= `WHITE;
		else
			RGB_out <= `BLACK;
	end
end

assign is_grid_line = ((pixel_x % `TILE_SIZE) == 0) || ((pixel_y % `TILE_SIZE) == 0);

endmodule