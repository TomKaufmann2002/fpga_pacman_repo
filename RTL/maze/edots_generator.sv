
`include "include/constants.vh"

module edots_generator (
	//inputs:
	input logic clk,
	input logic resetN,
	
	input logic [10:0] pixel_x,
	input logic [10:0] pixel_y,
	input logic remove_cur_edot,
	
	//outputs:
	output logic edots_dr,
	output logic [7:0] edots_RGB,
	output logic edots_exist
);

localparam logic [3:0][6:0] INIT_EDOT_TILE_X = '{7'd6,  7'd6,  7'd31, 7'd31};
localparam logic [3:0][6:0] INIT_EDOT_TILE_Y = '{7'd3,  7'd21, 7'd3,  7'd21};
localparam logic [3:0]      INIT_EDOT_ALIVE  = 4'b1111;


localparam logic [0:15] [0:15] [7:0] BMP = {
	{`TRNS,`TRNS,`TRNS, `TRNS, `TRNS, `CYAN,`CYAN,`CYAN,`CYAN,`CYAN,`CYAN,`TRNS,`TRNS,`TRNS,`TRNS,`TRNS},
	{`TRNS,`TRNS,`TRNS, `CYAN, `CYAN, 8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,`CYAN,`CYAN,`TRNS,`TRNS,`TRNS},
	{`TRNS,`TRNS,`CYAN, 8'hfb, 8'hfb, 8'he7,8'he7,8'he7,8'he7,8'he7,8'he7,8'hfb,8'hfb,`CYAN,`TRNS,`TRNS},
	{`TRNS,`CYAN,8'hfb, 8'hfb,`WHITE, 8'hfb,8'he7,8'hc7,8'hc7,8'hc7,8'he7,8'he7,8'he7,8'hfb,`CYAN,`TRNS},
	{`TRNS,`CYAN,8'hfb,`WHITE,`WHITE,`WHITE,8'hc7,8'hc7,8'hc7,8'hc7,8'hc7,8'hc7,8'he7,8'hfb,`CYAN,`TRNS},
	{`CYAN,8'hfb,8'he7, 8'hfb,`WHITE, 8'hfb,8'he7,8'hf1,8'hf1,8'he7,8'hc7,8'hc7,8'he7,8'he7,8'hfb,`CYAN},
	{`CYAN,8'hfb,8'he7, 8'he7, 8'hc7, 8'he7,8'hf1,8'hc7,8'hc7,8'hf1,8'he7,8'hc7,8'hc7,8'he7,8'hfb,`CYAN},
	{`CYAN,8'hfb,8'he7, 8'hc7, 8'hc7, 8'hf1,8'hc7,8'hc7,8'hc7,8'hc7,8'hf1,8'hc7,8'hc7,8'he7,8'hfb,`CYAN},
	{`CYAN,8'hfb,8'he7, 8'hc7, 8'hc7, 8'hf1,8'hc7,8'hc7,8'hc7,8'hc7,8'hf1,8'hc7,8'hc7,8'he7,8'hfb,`CYAN},
	{`CYAN,8'hfb,8'he7, 8'hc7, 8'hc7, 8'he7,8'hf1,8'hc7,8'hc7,8'hf1,8'he7,8'hc7,8'hc7,8'he7,8'hfb,`CYAN},
	{`CYAN,8'hfb,8'he7, 8'hc7, 8'hc7, 8'hc7,8'he7,8'hf1,8'hf1,8'he7,8'hc7,8'hc7,8'he7,8'he7,8'hfb,`CYAN},
	{`TRNS,`CYAN,8'hfb, 8'he7, 8'hc7, 8'hc7,8'hc7,8'hc7,8'hc7,8'hc7,8'hc7,8'hc7,8'he7,8'hfb,`CYAN,`TRNS},
	{`TRNS,`CYAN,8'hfb, 8'he7, 8'he7, 8'hc7,8'hc7,8'hc7,8'hc7,8'hc7,8'he7,8'he7,8'he7,8'hfb,`CYAN,`TRNS},
	{`TRNS,`TRNS,`CYAN, 8'hfb, 8'hfb, 8'he7,8'he7,8'he7,8'he7,8'he7,8'he7,8'hfb,8'hfb,`CYAN,`TRNS,`TRNS},
	{`TRNS,`TRNS,`TRNS, `CYAN, `CYAN, 8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,8'hfb,`CYAN,`CYAN,`TRNS,`TRNS,`TRNS},
	{`TRNS,`TRNS,`TRNS, `TRNS, `TRNS, `CYAN,`CYAN,`CYAN,`CYAN,`CYAN,`CYAN,`TRNS,`TRNS,`TRNS,`TRNS,`TRNS}};



logic [6:0] tile_x;
logic [6:0] tile_y;
assign tile_x = pixel_x >> 4;
assign tile_y = pixel_y >> 4;

logic [3:0] tile_offset_x;
logic [3:0] tile_offset_y;
assign tile_offset_x = pixel_x[3:0];
assign tile_offset_y = pixel_y[3:0];

logic [3:0][6:0] edot_tile_x;
logic [3:0][6:0] edot_tile_y;
logic [3:0] edot_alive;


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		edot_tile_x <= INIT_EDOT_TILE_X;
		edot_tile_y <= INIT_EDOT_TILE_Y;
		edot_alive  <= INIT_EDOT_ALIVE;
		edots_RGB <= `TRNS;
	end else begin
		// default outputs
		edots_RGB <= `TRNS;


	  for (int i = 0; i < 4; i++) begin
			if (edot_alive[i] &&
				tile_x == edot_tile_x[i] &&
				tile_y == edot_tile_y[i]) begin

				 // removal
				if (remove_cur_edot)
					edot_alive[i] <= 1'b0;

				// drawing
				else
					edots_RGB <= BMP[tile_offset_y][tile_offset_x];
			end
	   end
	end
end

assign edots_exist = edot_alive != 0;
assign edots_dr    = edots_RGB  != `TRNS;

endmodule
