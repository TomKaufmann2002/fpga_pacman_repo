module life_manager(
	input logic clk,
	input logic resetN,
	
	input logic collision_with_ghost,
	input logic [3:0] hundreds,
	input logic is_frightened,
	input logic start_of_frame,
	input logic [2:0] init_live_count,
	input logic game_started,
	input logic [3:0] thousands,
	
	output logic [2:0] lives,
	output logic lost_life,
	output logic is_pm_alive
);

assign is_pm_alive = |lives;

logic allow_dying;
logic [3:0] hundreds_d;
logic [3:0] thousands_d;

always_ff@(posedge clk or negedge resetN) begin
	if (~resetN) begin
		lives       <= init_live_count;
		lost_life   <= 0;
		allow_dying <= 0;
		hundreds_d  <= 0;
		thousands_d <= 0;
	end
	else begin
		hundreds_d  <= hundreds;
		thousands_d <= thousands;
		
		if (!game_started)
			lives <= init_live_count;
		else begin
			if (start_of_frame)
				allow_dying <= 1;
				
			lost_life <= 0;
			
			if (allow_dying && ~is_frightened && collision_with_ghost && lives != 0) begin
				lives <= lives - 1;
				lost_life <= 1;
				allow_dying <= 0;
			end
			
			else if ((hundreds >= 5 && hundreds_d < 500) || thousands > thousands_d)
				lives <= lives + 1;
		end
	end
end

endmodule