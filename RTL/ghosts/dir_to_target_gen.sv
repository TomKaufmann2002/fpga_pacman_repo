`include "include/constants.vh"
import walls_pkg::*;

module dir_to_target_gen(
	 // inputs:
    input logic clk,
    input logic resetN,
	 
	 input logic signed [10:0] target_x,
	 input logic signed [10:0] target_y,
    input logic [10:0] gst_top_left_x,
    input logic [10:0] gst_top_left_y,
    input logic [1:0] cur_dir,
    input logic [3:0] legal_dir_array, 
	 
	 // outputs:
    output logic [1:0] req_dir           // registered, sync with clk
);


    // candidate dirs and distances
    logic [2:0][1:0]   cand_dirs;   // 3 directions to check, can never packtrack
    logic [2:0][15:0]  cand_dist;   // unsigned distances
    logic [1:0]        best_dir;
	 logic [1:0]        chosen_dir;

    // Manhattan distance helper
    function automatic logic [15:0] dist_to_target(
        input logic [10:0] gx,
        input logic [10:0] gy,
        input logic [1:0]  dir
    );
        logic signed [12:0] new_x, new_y;
        begin
            new_x = gx;
            new_y = gy;
            case (dir)
                `RIGHT: new_x = gx + `TILE_SIZE;
                `LEFT:  new_x = gx - `TILE_SIZE;
                `UP:    new_y = gy - `TILE_SIZE;
                `DOWN:  new_y = gy + `TILE_SIZE;
            endcase
				if (new_x < START_X * `TILE_SIZE)
					new_x = new_x + END_X * `TILE_SIZE;
				else if (new_x >= END_X * `TILE_SIZE)
					new_x = new_x - END_X * `TILE_SIZE;
            dist_to_target = (target_x > new_x ? target_x - new_x : new_x - target_x) +
                             (target_y > new_y ? target_y - new_y : new_y - target_y);
        end
    endfunction

    // combinational decision logic
    always_comb begin
        // default candidates, move straight
        cand_dirs[0] = cur_dir;

        // add perpendicular options (no backtracking)
        unique case (cur_dir)
            `RIGHT, `LEFT: begin
                cand_dirs[1] = `UP;
                cand_dirs[2] = `DOWN;
            end
            `UP, `DOWN: begin
                cand_dirs[1] = `LEFT;
                cand_dirs[2] = `RIGHT;
            end
        endcase

        // compute distances (invalid dirs → infinity)
        for (int i=0; i<3; i++) begin
            if (legal_dir_array[cand_dirs[i]])
                cand_dist[i] = dist_to_target(gst_top_left_x, gst_top_left_y, cand_dirs[i]);
            else
                cand_dist[i] = `INFTY;
        end

        // pick best
        best_dir = cand_dirs[0];
		  chosen_dir = 0;
        if (cand_dist[1] < cand_dist[0] && cand_dist[1] <= cand_dist[2]) begin
            best_dir = cand_dirs[1];
				chosen_dir = 1;
		  end
        else if (cand_dist[2] < cand_dist[0] && cand_dist[2] <= cand_dist[1]) begin
            best_dir = cand_dirs[2];
				chosen_dir = 2;
		  end
		  
		  if (cand_dist[chosen_dir] == {16{1'b1}}) begin
		      best_dir[0] = ~best_dir[0];
		  end
		  
    end

    // in sync output
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            req_dir <= `RIGHT;   // safe default
        else
            req_dir <= best_dir;
    end

endmodule
