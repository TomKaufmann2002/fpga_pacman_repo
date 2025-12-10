
`include "include/constants.vh"

module pdots_generator (
	//inputs:
	input logic clk,
	input logic resetN,
	
	input logic [10:0] pixel_x,
	input logic [10:0] pixel_y,
	input logic remove_cur_pdot,
	input logic [1:0][6:0] generate_bwall_at,
	
	//outputs:
	output logic pdots_dr,
	output logic [7:0] pdots_RGB,
	output logic pdots_exist,
	output logic is_bwall_valid
);

logic [6:0] tile_x;
logic [6:0] tile_y;
assign tile_x = pixel_x >> 4;
assign tile_y = pixel_y >> 4;

logic [3:0] tile_offset_x;
logic [3:0] tile_offset_y;
assign tile_offset_x = pixel_x[3:0];
assign tile_offset_y = pixel_y[3:0];

logic inside_dot;
assign inside_pdot = (tile_offset_x >= 6 && tile_offset_x <= 9 &&
						  tile_offset_y >= 6 && tile_offset_y <= 9);

localparam WL = 1'b0;
localparam PD = 1'b1;

// constant initial mask (localparam)
localparam logic [START_Y:END_Y][START_X:END_X] INIT_MASK = '{
		{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
		{WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL},
		{WL, PD, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, PD, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, PD, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, PD, WL},
		{WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL},
		{WL, PD, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, PD, WL},
		{WL, PD, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, PD, WL},
		{WL, PD, PD, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, PD, PD, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, PD, PD, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, PD, PD, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, PD, PD, PD, PD, WL, PD, PD, PD, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL},
		{WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL},
		{WL, PD, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, PD, WL},
		{WL, PD, WL, WL, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, PD, WL, WL, WL, WL, PD, WL},
		{WL, WL, PD, PD, WL, WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL, WL, PD, PD, WL, WL},
		{WL, WL, WL, PD, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, PD, WL, WL, WL},
		{WL, WL, WL, PD, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, PD, WL, WL, WL},
		{WL, PD, PD, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, WL, WL, PD, PD, PD, PD, PD, PD, WL},
		{WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL},
		{WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL, WL, PD, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, PD, WL},
		{WL, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, PD, WL},
		{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL}
};

// mutable copy
logic [START_Y:END_Y][START_X:END_X] pac_dot_mask;


always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        pac_dot_mask <= INIT_MASK;
        pdots_dr     <= 1'b0;
        pdots_RGB    <= `TRNS;
    end else begin
        // default outputs
        pdots_dr  <= 1'b0;
        pdots_RGB <= `TRNS;

        // dot removal
        if (remove_cur_pdot)
            pac_dot_mask[tile_y][tile_x] <= WL;
		  if (is_bwall_valid)
				pac_dot_mask[generate_bwall_at[1]][generate_bwall_at[0]] <= WL;

        // draw current pixel
        if (tile_y >= START_Y && tile_y <= END_Y && 
				tile_x >= START_X && tile_x <= END_X && 
				pac_dot_mask[tile_y][tile_x] && inside_pdot) begin
				
            pdots_dr  <= 1'b1;
            pdots_RGB <= `MAGENTA;
        end
    end
end

assign pdots_exist = pac_dot_mask != 0;
assign is_bwall_valid = INIT_MASK[generate_bwall_at[1]][generate_bwall_at[0]] == PD;

endmodule
