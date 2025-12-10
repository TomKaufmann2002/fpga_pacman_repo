`include "include/constants.vh"

module game_mode_decoder #(
    parameter int unsigned CYCLES_MAX       = 4,   // number of Scatter/Chase cycles
    parameter int unsigned CHASE_SEC        = 15,
    parameter int unsigned SCATTER_SEC      = 7,
    parameter int unsigned FRIGHTENED_SEC   = 10
)(
	 // inputs:
    input  logic clk,
    input  logic resetN,
    input  logic start_frightened,       // rising edge triggers frightened mode
	 input  logic restart_scatter,
	 input  logic game_started,
	 
	 // outputs:
    output logic [1:0] game_mode
);

    // convert seconds to clock cycles
    localparam longint unsigned CHASE_CYCLES = CHASE_SEC * `CLK_FREQ;
    localparam longint unsigned SCATTER_CYCLES = SCATTER_SEC * `CLK_FREQ;
    localparam longint unsigned FRIGHTENED_CYCLES = FRIGHTENED_SEC * `CLK_FREQ;

    // mode register + counters
    logic [1:0] mode_reg;
    longint unsigned cycle_count;
    int unsigned completed_cycles;

    // latch for frightened duration
    longint unsigned fright_count;
    logic frightened_active;
    logic start_frightened_d;
	 logic restart_scatter_d;

    // detect rising edge
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            start_frightened_d <= 0;
				restart_scatter_d   <= 0;
		  end
        else begin
            start_frightened_d <= start_frightened;
				restart_scatter_d   <= restart_scatter;
		  end
    end
	 
    logic fright_rise;
	 assign fright_rise = start_frightened && ~start_frightened_d;
	 
	 logic restart_scatter_fall;
	 assign restart_scatter_fall = ~restart_scatter && restart_scatter_d;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            mode_reg          <= `SCATTER_MODE; // start in scatter
            cycle_count       <= 0;
            completed_cycles  <= 0;
            frightened_active <= 0;
            fright_count      <= 0;
        end
		  else if (game_started) begin
				if (fright_rise) begin
                // interrupt any mode immediately
                frightened_active <= 1;
                mode_reg          <= `FRIGHTENED_MODE;
                fright_count      <= 0;
            end
            // frightened override logic
            else if (frightened_active) begin
                fright_count <= fright_count + 1;
                if (fright_count >= FRIGHTENED_CYCLES) begin
                    frightened_active <= 0;
                    fright_count      <= 0;

                    // return to Scatter if cycles remain, else Chase
                    if (completed_cycles < CYCLES_MAX)
                        mode_reg <= `SCATTER_MODE;
                    else
                        mode_reg <= `CHASE_MODE;
                    cycle_count <= 0;
                end
            end
				else if (restart_scatter_fall) begin
					mode_reg    <= `SCATTER_MODE;
					cycle_count <= 0;
				end
				else begin
                // normal Scatter/Chase cycling
                cycle_count <= cycle_count + 1;

                if (completed_cycles < CYCLES_MAX) begin
                    case (mode_reg)
                        `SCATTER_MODE: begin
                            if (cycle_count >= SCATTER_CYCLES) begin
                                mode_reg    <= `CHASE_MODE;
                                cycle_count <= 0;
                            end
                        end
                        `CHASE_MODE: begin
                            if (cycle_count >= CHASE_CYCLES) begin
                                mode_reg    <= `SCATTER_MODE;
                                cycle_count <= 0;
                                completed_cycles <= completed_cycles + 1;
                            end
                        end
                        default: begin
                            mode_reg    <= `SCATTER_MODE;
                            cycle_count <= 0;
                        end
                    endcase
                end else begin
                    // after max cycles -> only Chase mode (plus frightened interruptions)
                    mode_reg <= `CHASE_MODE;
                end
            end
        end
    end

    assign game_mode = mode_reg;

endmodule
