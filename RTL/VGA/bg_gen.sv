
`include "include/constants.vh"

module bg_gen (
// inputs:
input logic clk,
input logic resetN,

input logic [10:0] pixel_x,
input logic [10:0] pixel_y,

input logic theme,

//outputs:
output logic [7:0] RGB_out
);

logic in_maze;
assign in_maze = (pixel_x > 5* `TILE_SIZE && pixel_x < 33*`TILE_SIZE) 
						&& (pixel_y < 29*`TILE_SIZE);

always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		RGB_out <= `TRNS;
	end else begin
		if (in_maze) begin
			if (theme == 0) // dark mode
				RGB_out <= `BLACK;
			else // light mode
				RGB_out <= `WHITE;
		end else begin // outside maze color
			RGB_out <= `GREY;
		end
	end
end


endmodule