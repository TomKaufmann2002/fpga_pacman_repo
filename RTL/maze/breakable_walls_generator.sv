
`include "include/constants.vh"

module breakable_walls_generator (
	//inputs:
	input logic clk,
	input logic resetN,
	
	input logic [10:0] pixel_x,
	input logic [10:0] pixel_y,
	input logic [10:0] pm_pixel_x,
	input logic [10:0] pm_pixel_y,
	input logic [1:0] pm_direction,
	input logic enter,
	input logic start_of_frame,
	input logic should_generate,
	input logic is_valid,
	
	//outputs:
	output logic bwalls_dr,
	output logic [7:0] bwalls_RGB,
	output logic [3:0][6:0] bwall_tile_x,
	output logic [3:0][6:0] bwall_tile_y,
	output logic [3:0] bwall_alive,
	output logic [1:0][6:0] generate_at
);

// localparam logic [3:0][6:0] INIT_BWALL_TILE_X = '{7'd1,  7'd6,  7'd31, 7'd31};
// localparam logic [3:0][6:0] INIT_BWALL_TILE_Y = '{7'd1,  7'd21, 7'd3,  7'd21};
// localparam logic [3:0][1:0] INIT_BWALL_STATE  = '{2'b11, 2'b11, 2'b11, 2'b11};
localparam logic [3:0][4:0] OFFSET_X = '{5'd6, 5'd25, 5'd6, 5'd25};
localparam logic [3:0][4:0] OFFSET_Y = '{5'd1, 5'd1, 5'd21, 5'd21};


localparam logic [0:15] [0:15] [7:0] BMP1 = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h2c,8'h2c,8'h2c,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h2c,8'h2c,8'h00,8'h00,8'hbc,8'h2c,8'hff},
	{8'hff,8'hff,8'h2c,8'h2c,8'h2c,8'hff,8'hff,8'hff,8'h2c,8'h00,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'h2c},
	{8'hff,8'h2c,8'hbc,8'hbc,8'h00,8'h2c,8'h2c,8'hff,8'h2c,8'h2c,8'h00,8'h00,8'hbc,8'hbc,8'hbc,8'h2c},
	{8'h2c,8'hbc,8'hbc,8'h00,8'h00,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h00,8'h00,8'h00,8'hbc,8'h00,8'h2c},
	{8'h2c,8'hbc,8'h00,8'hbc,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h00,8'h2c,8'h00,8'h00,8'h00,8'h2c,8'hff},
	{8'hff,8'h2c,8'h00,8'h00,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h00,8'h00,8'h00,8'h2c},
	{8'h2c,8'h00,8'h00,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h6c,8'h6c,8'h2c,8'h2c,8'h2c,8'h2c,8'hff},
	{8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h6c,8'h6c,8'h2c,8'h6c,8'h6c,8'h2c,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h6c,8'h2c,8'h6c,8'h2c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h2c,8'h2c,8'hff,8'h2c,8'hd4,8'h6c,8'h2c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h2c,8'hd4,8'h6c,8'h2c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h2c,8'h2c,8'h6c,8'hd4,8'h6c,8'h2c,8'h00,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h2c,8'h8d,8'hd4,8'h6c,8'hd4,8'hd4,8'h6c,8'h2c,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h2c,8'h2c,8'h8d,8'hd4,8'h6c,8'hd4,8'h2c,8'h2c,8'h00,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h2c,8'h00,8'hff,8'hff,8'hff,8'hff}};

localparam logic [0:15] [0:15] [7:0] BMP2 = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h34,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h34,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h34,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h34,8'hff,8'h34,8'h34,8'h00,8'hff,8'hff,8'h00,8'h34,8'hbc,8'h34,8'hff,8'hff},
	{8'hff,8'h34,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'h34,8'hbc,8'hbc,8'h00,8'hff,8'hff},
	{8'h00,8'hbc,8'h34,8'hff,8'h34,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h34,8'h00,8'hff,8'hff,8'hff},
	{8'h00,8'hbc,8'h34,8'hff,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h34,8'h00,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h34,8'h34,8'h00},
	{8'hff,8'h34,8'h34,8'hff,8'hff,8'h00,8'h6c,8'h6c,8'hff,8'hff,8'h6c,8'h6c,8'h00,8'h00,8'h00,8'hff},
	{8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hd4,8'hff,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'hd4,8'h6c,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h34,8'hfe,8'hfe,8'hfe,8'hd4,8'h6c,8'h00,8'h34,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h8d,8'hd4,8'h6c,8'hfe,8'hfe,8'hfe,8'h00,8'hfe,8'hff,8'h34,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h34,8'h00,8'h8d,8'hd4,8'h6c,8'hd4,8'h00,8'h34,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h34,8'h34,8'h34,8'h34,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

localparam logic [0:15] [0:15] [7:0] BMP3 = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h34,8'h2c,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h34,8'h34,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h2c,8'h2c,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h34,8'h34,8'hff,8'hff,8'h6c,8'h6c,8'hd4,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'h34,8'hff,8'hff,8'h34,8'h2c,8'h6c,8'hd4,8'hd4,8'hd4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h6c,8'hff,8'h2c,8'h2c,8'hff,8'hd4,8'hd4,8'hff,8'h34,8'h34,8'h2c,8'hff,8'h34,8'hff},
	{8'hff,8'h6c,8'hd4,8'hd4,8'hff,8'hff,8'h6c,8'hff,8'hff,8'hff,8'h2c,8'h2c,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'h6c,8'h6c,8'hff,8'h6c,8'hd4,8'hd4,8'hd4,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'h6c,8'hd4,8'h6c,8'hff,8'hff,8'h34,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};





logic [6:0] tile_x;
logic [6:0] tile_y;
assign tile_x = pixel_x >> 4;
assign tile_y = pixel_y >> 4;

logic [6:0] pm_tile_x;
logic [6:0] pm_tile_y;
assign pm_tile_x = pm_pixel_x >> 4;
assign pm_tile_y = pm_pixel_y >> 4;

logic [3:0] tile_offset_x;
logic [3:0] tile_offset_y;
assign tile_offset_x = pixel_x[3:0];
assign tile_offset_y = pixel_y[3:0];

logic [3:0][1:0] bwall_state;
logic enter_d;

function automatic logic is_pm_facing_bwall(
	input logic [1:0] current_bwall
);
	if (bwall_state[current_bwall] == 0)
		is_pm_facing_bwall = 0;
	else begin
		logic [6:0] block_x = pm_tile_x;
		logic [6:0] block_y = pm_tile_y;
		unique case (pm_direction)
			`RIGHT: block_x = pm_tile_x + 1;
			`LEFT:  block_x = pm_tile_x - 1;
			`UP:    block_y = pm_tile_y - 1;
			`DOWN:  block_y = pm_tile_y + 1;
		endcase
		is_pm_facing_bwall = (block_x == bwall_tile_x[current_bwall] && block_y == bwall_tile_y[current_bwall]);
	end
endfunction

enum logic [2:0] {
IDLE_ST,
WAIT_ST,
GENERATE_ST,
CHECK_VALID_ST,
GENERATED_ST,
FINISHED_ST
//--------------
} SM_randomizer;
logic [1:0] generated;
logic [3:0][7:0] randomizers_x;
logic [3:0][7:0] randomizers_y;

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		bwall_tile_x   <= 0;
		bwall_tile_y   <= 0;
		bwall_state    <= 0;
		bwalls_RGB     <= `TRNS;
		enter_d        <= 0;
		generated      <= 0;
		randomizers_x  <= {4{8'd255}};
		randomizers_y  <= {4{8'd255}};
		SM_randomizer  <= IDLE_ST;
	end else begin
		// default outputs
		bwalls_RGB       <= `TRNS;
		enter_d          <= enter;
		randomizers_x[0] <= randomizers_x[0] - 7;
		randomizers_x[1] <= randomizers_x[1] - 11;
		randomizers_x[2] <= randomizers_x[2] - 13;
		randomizers_x[3] <= randomizers_x[3] - 17;
		
		randomizers_y[0] <= randomizers_y[0] - 11;
		randomizers_y[1] <= randomizers_y[1] - 13;
		randomizers_y[2] <= randomizers_y[2] - 17;
		randomizers_y[3] <= randomizers_y[3] - 23;

		if (SM_randomizer == FINISHED_ST) begin
			for (int i = 0; i < 4; i++) begin
				// removal
				if (~enter_d && enter && is_pm_facing_bwall(i)) begin
					bwall_state[i] <= bwall_state[i] - 1;
				end
				
				if (bwall_state[i] != 0 &&
					tile_x == bwall_tile_x[i] &&
					tile_y == bwall_tile_y[i]) begin

					// drawing
					if (bwall_state[i] == 2'b11)
						bwalls_RGB <= BMP1[tile_offset_y][tile_offset_x];
					else if (bwall_state[i] == 2'b10)
						bwalls_RGB <= BMP2[tile_offset_y][tile_offset_x];
					else
						bwalls_RGB <= BMP3[tile_offset_y][tile_offset_x];
				end
			end
		end
		
		unique case (SM_randomizer)
			IDLE_ST: begin
				bwall_tile_x   <= 0;
				bwall_tile_y   <= 0;
				bwall_state    <= 0;
				bwalls_RGB     <= `TRNS;
				enter_d        <= 0;
				generated      <= 0;
				SM_randomizer  <= WAIT_ST;
			end
			
			WAIT_ST: begin
				if (should_generate)
					SM_randomizer <= GENERATE_ST;
			end
			
			GENERATE_ST: begin
				bwall_tile_x[generated] <= OFFSET_X[generated] + randomizers_x[generated][2:0];
				bwall_tile_y[generated] <= OFFSET_Y[generated] + randomizers_y[generated][2:0];
				SM_randomizer <= CHECK_VALID_ST;
			end
			
			CHECK_VALID_ST: begin
				if (is_valid)
					SM_randomizer <= GENERATED_ST;
				else
					SM_randomizer <= GENERATE_ST;
			end
			
			GENERATED_ST: begin
				generated <= generated + 1;
				bwall_state[generated] <= 2'b11;
				if (generated == 3)
					SM_randomizer <= FINISHED_ST;
				else
					SM_randomizer <= GENERATE_ST;
			end
			
			FINISHED_ST: begin
			end
		endcase
	end
end

assign bwall_alive[0] = bwall_state[0] != 0;
assign bwall_alive[1] = bwall_state[1] != 0;
assign bwall_alive[2] = bwall_state[2] != 0;
assign bwall_alive[3] = bwall_state[3] != 0;
assign generate_at[0] = bwall_tile_x[generated];
assign generate_at[1] = bwall_tile_y[generated];
assign bwalls_dr      = bwalls_RGB != `TRNS;

endmodule
