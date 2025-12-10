
`include "include/constants.vh"
import walls_pkg::*;

module walls_generator (
//inputs:
input logic clk,
input logic resetN,

input logic [10:0] pixel_x,
input logic [10:0] pixel_y,

//outputs:
output logic wall_dr,
output logic [7:0] wall_RGB
);


logic [6:0] tile_x;
logic [6:0] tile_y;
assign tile_x = pixel_x >> 4;
assign tile_y = pixel_y >> 4;
logic [3:0] offset_x;
logic [3:0] offset_y;
assign offset_x = pixel_x % `TILE_SIZE;
assign offset_y = pixel_y % `TILE_SIZE;

localparam logic EM = 0;
localparam logic WL = 1;

localparam [0:15] [0:15] wall_tile_line_BMP = {
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM}};

localparam [0:15] [0:15] wall_tile_curve_BMP = {
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{EM, EM, WL, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM},
	{WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM}};

localparam [0:15] [0:15] wall_tile_end_BMP = {
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM}};

localparam [0:15] [0:15] wall_tile_T_BMP = {
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{EM, EM, WL, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM},
	{WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, WL},
	{WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
	{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM}};

localparam [0:15] [0:15] wall_tile_middle_BMP = {
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{EM, EM, WL, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM},
	{WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, WL},
	{WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
	{WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL},
	{WL, WL, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, WL, WL},
	{EM, EM, WL, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, WL, EM, EM},
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM},
	{EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM}};

function automatic logic [3:0] direction(
	input logic [6:0] tile_x,
	input logic [6:0] tile_y
 );
	if (tile_y > START_Y && tile_y < END_Y && 
			wall_mask[tile_y - 1][tile_x] && wall_mask[tile_y + 1][tile_x]) begin
		if (tile_x < END_X && tile_x > START_X && wall_mask[tile_y][tile_x - 1] && wall_mask[tile_y][tile_x + 1])
			direction = 13;
		else if (tile_x < END_X && wall_mask[tile_y][tile_x + 1] && wall_mask[tile_y][tile_x + 2])
			direction = 9;
		else if (tile_x > START_X && wall_mask[tile_y][tile_x - 1] && wall_mask[tile_y][tile_x - 2])
			direction = 10;
		else
			direction = 1;
	end
	else if (tile_x > START_X && tile_x < END_X && 
			wall_mask[tile_y][tile_x - 1] && wall_mask[tile_y][tile_x + 1]) begin
		if (tile_y < END_Y && wall_mask[tile_y + 1][tile_x] && wall_mask[tile_y + 2][tile_x])
			direction = 11;
		else if (tile_y > START_Y && wall_mask[tile_y - 1][tile_x] && wall_mask[tile_y - 2][tile_x])
			direction = 12;
		else
			direction = 2;
	end
	else if (tile_x > START_X && tile_y < END_Y && 
			wall_mask[tile_y][tile_x - 1] && wall_mask[tile_y + 1][tile_x])
		direction = 3;
	else if (tile_x > START_X && tile_y > START_Y &&
			wall_mask[tile_y][tile_x - 1] && wall_mask[tile_y - 1][tile_x])
		direction = 4;
	else if (tile_x < END_X && tile_y < END_Y && 
			wall_mask[tile_y][tile_x + 1] && wall_mask[tile_y + 1][tile_x])
		direction = 5;
	else if (tile_x < END_X && tile_y > START_Y && 
			wall_mask[tile_y][tile_x + 1] && wall_mask[tile_y - 1][tile_x])
		direction = 6;
	else if ((tile_x == START_X || ~wall_mask[tile_y][tile_x - 1]) && wall_mask[tile_y][tile_x + 1])
		direction = 7;
	else if ((tile_x == END_X || ~wall_mask[tile_y][tile_x + 1]) && wall_mask[tile_y][tile_x - 1])
		direction = 8;
	else
		direction = 0;
endfunction

logic [7:0] current_color;
logic has_color;

always_comb begin
	unique case(direction(tile_x, tile_y))
		1:  has_color = wall_tile_line_BMP[offset_x][offset_y];
		2:  has_color = wall_tile_line_BMP[offset_y][offset_x];
		3:  has_color = wall_tile_curve_BMP[15 - offset_y][offset_x];
		4:  has_color = wall_tile_curve_BMP[offset_y][offset_x];
		5:  has_color = wall_tile_curve_BMP[15 - offset_y][15 - offset_x];
		6:  has_color = wall_tile_curve_BMP[offset_y][15 - offset_x];
		7:  has_color = wall_tile_end_BMP[offset_y][15 - offset_x];
		8:  has_color = wall_tile_end_BMP[offset_y][offset_x];
		9:  has_color = wall_tile_T_BMP[15 - offset_x][offset_y];
		10: has_color = wall_tile_T_BMP[offset_x][offset_y];
		11: has_color = wall_tile_T_BMP[15 - offset_y][offset_x];
		12: has_color = wall_tile_T_BMP[offset_y][offset_x];
		13: has_color = wall_tile_middle_BMP[offset_y][offset_x];
		default: has_color = 0;
	endcase
	if (has_color)
		current_color = `BLUE;
	else
		current_color = `TRNS;
end

always_ff@ (posedge clk or negedge resetN) begin
	if (!resetN) begin
		wall_RGB <= `TRNS;
	end
	else begin	
		wall_RGB <= `TRNS; // default
		if (tile_y >= START_Y && tile_y <= END_Y && 
			 tile_x >= START_X && tile_x <= END_X && 
			 wall_mask[tile_y][tile_x]) begin
			 
			wall_RGB <= current_color;
		end
	end
end

assign wall_dr = (wall_RGB != `TRNS);


endmodule 