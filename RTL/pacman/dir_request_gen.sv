
`include "include/constants.vh"

module dir_request_gen (
	//inputs:
	input  logic        clk,
	input  logic        reset_n,

	input  logic [9:0]  key_is_pressed,
	input  logic        game_started,
	input  logic        lost_life,

	//outputs:
	output logic [1:0]  req_dir
);

logic [9:0] prev_key_is_pressed;

always_ff @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		prev_key_is_pressed <= '0;
		req_dir <= `LEFT;   // default
	end
	else if (game_started) begin
		if (lost_life)
			req_dir <= `LEFT;
		else begin
			prev_key_is_pressed <= key_is_pressed;

			// Rising edge detection: last new press wins
			if ( key_is_pressed[4] & ~prev_key_is_pressed[4] )
				req_dir <= `LEFT;
			else if ( key_is_pressed[6] & ~prev_key_is_pressed[6] )
				req_dir <= `RIGHT;
			else if ( key_is_pressed[8] & ~prev_key_is_pressed[8] )
				req_dir <= `UP;
			else if ( key_is_pressed[2] & ~prev_key_is_pressed[2] )
				req_dir <= `DOWN;
		end
	end
end

endmodule
