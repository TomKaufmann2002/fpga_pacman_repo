
`include "include/constants.vh"
import walls_pkg::*;

module ghost_motion	#(
parameter logic [1:0] GHOSTNUM = 0 // value from 0 to 3. determines the witch of the 4 spawning slots to choose
)(
	// inputs:
	input	logic clk,
	input	logic resetN,
	
	input	logic start_of_frame,      //short pulse every start of frame 30Hz	
	input logic [1:0] req_dir,
	input logic is_alive,
	input logic pm_lost_life,
	input logic is_pm_alive,
	input logic [3:0][6:0] bwall_x,
	input logic [3:0][6:0] bwall_y,
	input logic [3:0] bwall_alive,
	input logic game_started,
	
	// outputs:
	output logic signed 	[10:0] top_left_x, // output the top left corner 
	output logic signed	[10:0] top_left_y,  // can be negative , if the object is partliy outside	
	output logic [1:0] cur_dir,
	output logic [3:0] legal_dir_array,
	
	// debug in/out:
	input  logic dev_mode
);


localparam [0:7][15:0] step_pattern = {

    16'b0000_0000_0000_000, // speed_inc 0 → 16 steps
    16'b0000_0010_0000_00,  // speed_inc 1 → 15 valid steps
    16'b0001_0000_0010_0,   // speed_inc 2 → 14 valid steps
    16'b0010_0010_0010,     // speed_inc 3 → 13 valid steps
    16'b0100_1001_010,      // speed_inc 4 → 12 valid steps
    16'b1010_1010_10,       // speed_inc 5 → 11 valid steps
    16'b1101_1011_0,        // speed_inc 6 → 10 valid steps
    16'b1111_111            // speed_inc 7 →  8 valid steps
};


localparam SPN_TILE_X = `LEFT_GST_INIT_TILE_X + GHOSTNUM;
localparam SPN_TILE_Y = `ALL_GST_INIT_TILE_Y;
localparam INIT_X = `TILE_SIZE * SPN_TILE_X;
localparam INIT_Y = `TILE_SIZE * SPN_TILE_Y;


logic [0:7] speed_inc = 0;  // speed increment 0–7 (0->100%, ...,  7->200%)
logic [10:0] motion_counter;
logic [4:0] step_pattern_counter;
logic [2:0] step_size;
assign step_size = step_pattern[speed_inc][step_pattern_counter] + 1;

logic [1:0] spawn_slot;


logic [6:0] gst_tile_x;
logic [6:0] gst_tile_y;
assign gst_tile_x = (top_left_x + (`TILE_SIZE / 2)) >> 4;
assign gst_tile_y = (top_left_y + (`TILE_SIZE / 2)) >> 4;



logic probe_RIGHT;
logic probe_LEFT;
logic probe_DOWN;
logic probe_UP;

assign legal_dir_array[`RIGHT] = !probe_RIGHT;
assign legal_dir_array[`LEFT] = !probe_LEFT;
assign legal_dir_array[`UP] = !probe_UP;
assign legal_dir_array[`DOWN] = !probe_DOWN;


always_comb begin
	probe_RIGHT = gst_tile_x + 1 <= END_X && wall_mask[gst_tile_y][gst_tile_x + 1];
	probe_LEFT  = gst_tile_x - 1 >= START_X && wall_mask[gst_tile_y][gst_tile_x - 1];
	// blocking ghost chamber as well
	probe_DOWN  = (gst_tile_y + 1 <= END_Y && wall_mask[gst_tile_y + 1][gst_tile_x]) ||
					  (gst_tile_x == `BLOCK_TILE1_X && gst_tile_y + 1 == `BLOCK_TILE1_Y) ||
					  (gst_tile_x == `BLOCK_TILE2_X && gst_tile_y + 1 == `BLOCK_TILE2_Y);
	probe_UP    = gst_tile_y - 1 >= START_Y && wall_mask[gst_tile_y - 1][gst_tile_x];

	
	for (int i = 0; i < 4; ++i) begin
		if (bwall_alive[i]) begin
			probe_RIGHT = probe_RIGHT || gst_tile_x + 1 == bwall_x[i] && gst_tile_y == bwall_y[i];
			probe_LEFT  = probe_LEFT  || gst_tile_x - 1 == bwall_x[i] && gst_tile_y == bwall_y[i];
			probe_DOWN  = probe_DOWN  || gst_tile_x == bwall_x[i] && gst_tile_y + 1 == bwall_y[i];
			probe_UP    = probe_UP    || gst_tile_x == bwall_x[i] && gst_tile_y - 1 == bwall_y[i];
		end
	end
end


// states:

enum  logic [3:0] {
//-------------- states:
IDLE_ST,
MOVE_TILE_ST,
UPDATE_CUR_DIR_ST,
DEAD_ST,
START_SPAWN_SEQ_ST,
MOVE_TILE_RIGHT_ST,
MOVE_2TILE_LEFT_ST,
MOVE_3TILES_UP_ST,
FIRST_SPAWN_ST,
LOL_HE_DED_ST
//--------------
}  SM_motion;
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		top_left_x <= INIT_X;
		top_left_y <= INIT_Y;
		motion_counter <= 0;
		step_pattern_counter <= 0;
		cur_dir <= `RIGHT;
		SM_motion <= IDLE_ST; 
	end 	
	
	else if (pm_lost_life)
		SM_motion <= IDLE_ST;
	else if (~is_pm_alive)
		SM_motion <= LOL_HE_DED_ST;
	
	else begin
	
		case(SM_motion)
		
		//------------
			IDLE_ST: begin
		//------------
				top_left_x <= INIT_X;
				top_left_y <= INIT_Y;
				motion_counter <= 0;
				step_pattern_counter <= 0;
				cur_dir <= `RIGHT;
				if (game_started)
					SM_motion <= FIRST_SPAWN_ST;
			end
		//------------
			MOVE_TILE_ST:  begin
		//------------
				if (!is_alive) begin
					top_left_x <= INIT_X;
					top_left_y <= INIT_Y;
					motion_counter <= 0;
					step_pattern_counter <= 0;
					SM_motion <= DEAD_ST;
				end else
				if (start_of_frame) begin
					if (motion_counter < 16) begin
						case (cur_dir)
							`RIGHT: 	top_left_x <= top_left_x + step_size >= END_X * `TILE_SIZE ? START_X * `TILE_SIZE + step_size : top_left_x + step_size;
							`LEFT: 	top_left_x <= signed'(top_left_x - step_size) < START_X * `TILE_SIZE ? END_X * `TILE_SIZE - step_size : top_left_x - step_size;
							`DOWN: 	top_left_y <= top_left_y + step_size;
							`UP: 		top_left_y <= top_left_y - step_size;
						endcase
						motion_counter <= motion_counter + step_size;
						step_pattern_counter <= step_pattern_counter + 1;
					end else begin
						motion_counter <= 0;
						step_pattern_counter <= 0;
		
						top_left_x <= (top_left_x >> 4) << 4; // safety, forces exit in tile grid
						top_left_y <= (top_left_y >> 4) << 4;
						
						SM_motion <= UPDATE_CUR_DIR_ST;
					end
				end
			end
		//------------
			UPDATE_CUR_DIR_ST: begin
		//------------
				cur_dir <= req_dir;
				SM_motion <= MOVE_TILE_ST;
			end
		//------------
			DEAD_ST: begin
		//------------
				if (is_alive)
					SM_motion <= FIRST_SPAWN_ST;
			end
		//------------
			START_SPAWN_SEQ_ST: begin
		//------------
				top_left_x <= INIT_X;
				top_left_y <= INIT_Y;
				motion_counter <= 0;
				unique case (SPN_TILE_X)
					`SPN_TILE_MIDLEFT_X, `SPN_TILE_LEFT_X:
						SM_motion <= MOVE_3TILES_UP_ST;
					`SPN_TILE_MIDRIGHT_X, `SPN_TILE_RIGHT_X:
						SM_motion <= MOVE_2TILE_LEFT_ST;
				endcase
			end
		//------------
			MOVE_TILE_RIGHT_ST: begin
		//------------
				if(start_of_frame) begin
					if (motion_counter < 16) begin
						top_left_x <= top_left_x + 1;
						motion_counter <= motion_counter + 1;
					end else begin
						motion_counter <= 0;
						SM_motion <= MOVE_3TILES_UP_ST;
					end
				end
			end
		//------------
			MOVE_2TILE_LEFT_ST: begin
		//------------
				if(start_of_frame) begin
					if (motion_counter < 32) begin
						top_left_x <= top_left_x - 1;
						motion_counter <= motion_counter + 1;
					end else begin
						motion_counter <= 0;
						SM_motion <= MOVE_3TILES_UP_ST;
					end
				end
			end
		//------------
			MOVE_3TILES_UP_ST: begin
		//------------
				if(start_of_frame) begin
					if (motion_counter < 48) begin
						top_left_y <= top_left_y - 1;
						motion_counter <= motion_counter + 1;
					end else begin
						motion_counter <= 0;
						SM_motion <= UPDATE_CUR_DIR_ST;
					end
				end
			end
		//------------
			FIRST_SPAWN_ST: begin
		//------------
				if(start_of_frame) begin
					if (motion_counter < 64) begin
						if (motion_counter < 16)
							top_left_x <= top_left_x - 1;
						else if (motion_counter < 32)
							top_left_x <= top_left_x + 1;
						else if (motion_counter < 48)
							top_left_x <= top_left_x - 1;
						else
							top_left_x <= top_left_x + 1;
						motion_counter <= motion_counter + 1;
					end
					else begin
						motion_counter <= 0;
						SM_motion <= START_SPAWN_SEQ_ST;
					end
				end
			end
		//------------
			LOL_HE_DED_ST: begin
		//------------
			end
		endcase
	end 
end


endmodule	
//---------------
 
