
`include "include/constants.vh"

module pacman_bit_map	(
	// inputs:
	input	logic	clk,
	input	logic	resetN,
	
	input logic	[10:0] offset_x,
	input logic	[10:0] offset_y,
	input	logic	in_container,
	input logic [1:0] orientation, // 00-up, 01-down, 10-left, 11-right
	input logic close_mouth,
	
	// outputs:
	output logic dr_pm, // pacman's drawing request
	output logic [7:0] RGB_out,

	// debug in/outs:
	input logic dev_mode
 );

 
localparam logic YLLW = 1;
localparam logic TRNS = 0;


// NOTE: pacman has dirty clack edges - FIX!
localparam logic [0:15] [0:15] PACMAN_BMP = '{
	{TRNS, TRNS, TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS},
	{TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS},
	{TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS, TRNS},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS},
	{TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS},
	{TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS},
	{TRNS, TRNS, TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS}
};

localparam logic [0:15] [0:15] MOUTH_CLOSED_BMP = '{
	{TRNS, TRNS, TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS},
	{TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS},
	{TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS},
	{TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS},
	{TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW},
	{TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS},
	{TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS},
	{TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS},
	{TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS},
	{TRNS, TRNS, TRNS, TRNS, TRNS, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, YLLW, TRNS, TRNS, TRNS, TRNS}
};


logic has_color;
logic [7:0] color;
always_comb begin
	has_color = TRNS;
	color = `TRNS;
	if (in_container) begin
		if (~close_mouth) begin
			unique case (orientation)
				`UP:
					has_color = PACMAN_BMP[offset_x][15 - offset_y];
				`DOWN:
					has_color = PACMAN_BMP[offset_x][offset_y];
				`LEFT:
					has_color = PACMAN_BMP[offset_y][15 - offset_x];
				`RIGHT:
					has_color = PACMAN_BMP[offset_y][offset_x];
			endcase
		end
		else
			has_color = MOUTH_CLOSED_BMP[offset_y][offset_x];
	end
		
	if (dev_mode || has_color)
		color = `YELLOW;
end
 

//////////--------------------------------------------------------------------------------------------------------------=

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGB_out        <= `TRNS;
	end

	else begin
		// DEFUALT outputs
		RGB_out <= `TRNS;

		if (in_container)
			RGB_out <= color;
	end
end

//////////--------------------------------------------------------------------------------------------------------------=

assign dr_pm = RGB_out != `TRNS;


endmodule