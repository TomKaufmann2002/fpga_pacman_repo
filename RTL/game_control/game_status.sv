module game_status(
	input logic pdots_exist,
	input logic edots_exist,
	input logic [2:0] life_count,
	
	output logic game_status
);

assign game_status = (pdots_exist || edots_exist) && (life_count != 0);

endmodule