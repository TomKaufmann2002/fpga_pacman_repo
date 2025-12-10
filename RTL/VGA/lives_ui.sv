module lives_ui(
	//inputs:
	input logic clk,
	input logic resetN,
	
	input logic [2:0] lives,
	
	input logic [10:0] pixel_x,
	input logic [10:0] pixel_y,
	
	//outputs:
	output logic lives_dr,
	output logic [7:0] lives_RGB,
	output logic [10:0] offset_x,
	output logic [10:0] offset_y
);

logic [6:0] tile_x;
logic [6:0] tile_y;
assign tile_x = pixel_x >> 4;
assign tile_y = pixel_y >> 4;

assign offset_x = pixel_x % `TILE_SIZE;
assign offset_y = pixel_y % `TILE_SIZE;

always_ff@(posedge clk or negedge resetN) begin
	if (~resetN)
		lives_RGB <= `TRNS;
	else if (tile_y == END_Y + 1) begin
		if (tile_x >= START_X && tile_x - lives < START_X)
			lives_RGB <= `YELLOW;
		else
			lives_RGB <= `TRNS;
	end
end

assign lives_dr = lives_RGB != `TRNS;


endmodule