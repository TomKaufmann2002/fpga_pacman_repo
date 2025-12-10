
`include "include/constants.vh"

module ghost_bit_map #(parameter logic [1:0] GHOSTNUM = 0) (
	// inputs:
	input	logic	clk,
	input	logic	resetN,
	
	input logic	[10:0] offset_x,
	input logic	[10:0] offset_y,
	input	logic	in_container,
	input logic [1:0] orientation, // 00-up, 01-down, 10-left, 11-right
	input logic [1:0] game_mode,
	
	// outputs:
	output logic dr_gh, // ghost's drawing request
	output logic [7:0] RGB_out,

	// debug in/outs:
	input logic dev_mode
 );
 
localparam logic [1:0] TRNS = 2'b00;
localparam logic [1:0] WHTE = 2'b01;
localparam logic [1:0] BLUE = 2'b10;
localparam logic [1:0] COLR = 2'b11;
 
 
localparam logic [0:15] [0:15] [1:0] RED_GHOST_BMP = {
	{TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS},
	{TRNS, TRNS, TRNS, TRNS, TRNS, COLR, COLR, COLR, COLR, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS},
	{TRNS, TRNS, TRNS, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, TRNS, TRNS, TRNS, TRNS, TRNS},
	{TRNS, TRNS, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, TRNS, TRNS, TRNS, TRNS},
	{TRNS, COLR, COLR, COLR, WHTE, WHTE, COLR, COLR, COLR, COLR, WHTE, WHTE, COLR, TRNS, TRNS, TRNS},
	{TRNS, COLR, COLR, WHTE, WHTE, WHTE, WHTE, COLR, COLR, WHTE, WHTE, WHTE, WHTE, TRNS, TRNS, TRNS},
	{TRNS, COLR, COLR, WHTE, WHTE, BLUE, BLUE, COLR, COLR, WHTE, WHTE, BLUE, BLUE, TRNS, TRNS, TRNS},
	{COLR, COLR, COLR, WHTE, WHTE, BLUE, BLUE, COLR, COLR, WHTE, WHTE, BLUE, BLUE, COLR, TRNS, TRNS},
	{COLR, COLR, COLR, COLR, WHTE, WHTE, COLR, COLR, COLR, COLR, WHTE, WHTE, COLR, COLR, TRNS, TRNS},
	{COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, TRNS, TRNS},
	{COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, TRNS, TRNS},
	{COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, TRNS, TRNS},
	{COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, TRNS, TRNS},
	{COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, COLR, TRNS, TRNS},
	{COLR, COLR, TRNS, COLR, COLR, COLR, TRNS, TRNS, COLR, COLR, COLR, TRNS, COLR, COLR, TRNS, TRNS},
	{COLR, TRNS, TRNS, TRNS, COLR, COLR, TRNS, TRNS, COLR, COLR, TRNS, TRNS, TRNS, COLR, TRNS, TRNS}};




logic is_in_eyes;
assign is_in_eyes = offset_y >= 4 && offset_y <= 8 && ((offset_x <= 12 && offset_x >= 9) || (offset_x <= 6 && offset_x >= 3));

logic [7:0] color;
logic [1:0][10:0] current_pixel;
always_comb begin
	unique case (GHOSTNUM)
		0:			color = `RED   ;
		1:			color = `PINK  ;
		2:			color = `CYAN  ;
		default:	color = `ORANGE;
	endcase
	if (game_mode == `FRIGHTENED_MODE)
		color = `GREEN;
		
	current_pixel[1] = offset_x;
	current_pixel[0] = offset_y;
	
	if (is_in_eyes) begin
		case (orientation)
			`UP:		current_pixel[0] = signed'(current_pixel[0] - 6) * -1 + 6;
			`LEFT:	current_pixel[1] = 15 - current_pixel[1];
			`DOWN, `RIGHT: begin
				current_pixel[1] = offset_x;
				current_pixel[0] = offset_y;
			end
		endcase
	end
end
 

//////////--------------------------------------------------------------------------------------------------------------=

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGB_out <=	`TRNS;
	end

	else begin
		// DEFUALT outputs
		RGB_out <= `TRNS;

		if (in_container) 
		begin
			if (dev_mode) begin
				RGB_out <= 8'h3B;
			end
			else begin
				unique case (RED_GHOST_BMP[current_pixel[0]][current_pixel[1]])
					TRNS: RGB_out <= `TRNS;
					WHTE: RGB_out <= `WHITE;
					BLUE: RGB_out <= `BLUE;
					COLR: RGB_out <= color;
				endcase
			end
		end  	
	end
end

//////////--------------------------------------------------------------------------------------------------------------=

assign dr_gh = RGB_out != `TRNS;


endmodule