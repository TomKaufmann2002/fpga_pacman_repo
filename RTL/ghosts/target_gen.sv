`include "include/constants.vh"

module target_gen #(
	 parameter logic [1:0] GHOSTNUM = 0
)(
    // inputs:
    input  logic        clk,
    input  logic        resetN,
    input  logic [10:0] pm_top_left_x,
    input  logic [10:0] pm_top_left_y,
    input  logic [1:0]  game_mode,   // one of: CHASE_MODE, SCATTER_MODE, FRIGHTENED_MODE

    // outputs:
    output logic signed [10:0] target_x,
    output logic signed [10:0] target_y,

    // debug in/out:
    input  logic dev_mode
);

	int signed chase_offset_x;
	int signed chase_offset_y;
	logic [1:0] scatter_corner;
	assign scatter_corner = GHOSTNUM;
	logic [1:0] corner_idx;

	always_ff @(posedge clk or negedge resetN) begin
		 if (!resetN) 
			corner_idx <= scatter_corner; // insures different random pattern for each ghost
		 else
			corner_idx <= corner_idx + 1;
	end

	logic signed [10:0] scatter_corner_x;
	logic signed [10:0] scatter_corner_y;
	assign scatter_corner_x = scatter_corner[0] ? `SCREEN_WIDTH-1 : 0;
	assign scatter_corner_y = scatter_corner[1] ? `SCREEN_HEIGHT-1 : 0;

    // frightened target
    logic signed [10:0] fright_x, fright_y;
    always_comb begin
		  unique case (GHOSTNUM)
			  0: begin
				  // ghost-specific chase offset relative to Pac-Man
				  chase_offset_x   = 0;
				  chase_offset_y   = 0;
			  end
			  // Arbitraty numbers
			  1: begin
				  // ghost-specific chase offset relative to Pac-Man
				  chase_offset_x   = 4;
				  chase_offset_y   = 4;
			  end
			  2: begin
				  // ghost-specific chase offset relative to Pac-Man
				  chase_offset_x   = 8;
				  chase_offset_y   = 0;
			  end
			  3: begin
				  // ghost-specific chase offset relative to Pac-Man
				  chase_offset_x   = 0;
				  chase_offset_y   = 8;
			  end
		  endcase
        unique case (corner_idx)
            2'b00: begin 
                fright_x = 0; 
                fright_y = 0; 
            end
            2'b01: begin 
                fright_x = `SCREEN_WIDTH-1; 
                fright_y = 0; 
            end
            2'b10: begin 
                fright_x = `SCREEN_WIDTH-1; 
                fright_y = `SCREEN_HEIGHT-1; 
            end
            2'b11: begin 
                fright_x = 0; 
                fright_y = `SCREEN_HEIGHT-1; 
            end
        endcase
    end



    // main target logic
    always_comb begin
        if (dev_mode) begin
            target_x = 0;
            target_y = 0;
        end
		  else begin
            case (game_mode)
                `CHASE_MODE: begin
                    target_x = pm_top_left_x + chase_offset_x;
                    target_y = pm_top_left_y + chase_offset_y;
                end
                `SCATTER_MODE: begin
                    target_x = scatter_corner_x;
                    target_y = scatter_corner_y;
                end
                `FRIGHTENED_MODE: begin
                    target_x = fright_x;
                    target_y = fright_y;
                end
                default: begin
                    target_x = 0;
                    target_y = 0;
                end
            endcase
        end
    end

endmodule
