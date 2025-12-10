
module	object_container	
#(parameter int OBJECT_WIDTH_X = 16, 
parameter  int OBJECT_HEIGHT_Y = 16)
(
	// inputs:
	input logic signed [10:0] pixel_x,
	input logic signed [10:0] pixel_y,
	input logic signed [10:0] top_left_x,
	input logic	signed [10:0] top_left_y,
	
	// outputs:
	output logic [10:0] offset_x,
	output logic [10:0] offset_y,
	output logic in_container
);
 
int right_x;
int bottom_y;

assign right_x	= (top_left_x + OBJECT_WIDTH_X);
assign bottom_y	= (top_left_y + OBJECT_HEIGHT_Y);
assign	in_container  = 	 ( (pixel_x  >= top_left_x) &&  (pixel_x < right_x) // math is made with SIGNED variables  
						   && (pixel_y  >= top_left_y) &&  (pixel_y < bottom_y) )  ; // as the top left position can be negative
		
assign offset_x = pixel_x - top_left_x;
assign offset_y = pixel_y - top_left_y;


endmodule 