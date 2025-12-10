package walls_pkg;

	// Maze dimensions in tiles
	parameter int TILE_WIDTH  = 40;
	parameter int TILE_HEIGHT = 30;
	parameter int START_X = 5;
	parameter int END_X = START_X + 27;
	parameter int START_Y = 0;
	parameter int END_Y = START_Y + 28;
	localparam logic WL = 1'b1;
	localparam logic EM = 1'b0;

	localparam [START_Y:END_Y][START_X:END_X] wall_mask = {
		{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL},
		{WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL},
		{WL, EM, WL, WL, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, WL, WL, EM, WL},
		{WL, EM, WL, EM, EM, WL, EM, WL, EM, EM, EM, WL, EM, WL, WL, EM, WL, EM, EM, EM, WL, EM, WL, EM, EM, WL, EM, WL},
		{WL, EM, WL, WL, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, WL, WL, EM, WL},
		{WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL},
		{WL, EM, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, EM, WL},
		{WL, EM, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, EM, WL},
		{WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL},
		{WL, WL, WL, WL, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, WL, WL, WL, WL},
		{EM, EM, EM, EM, EM, WL, EM, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, WL, EM, EM, EM, EM, EM},
		{EM, EM, EM, EM, EM, WL, EM, WL, WL, EM, WL, WL, WL, EM, EM, WL, WL, WL, EM, WL, WL, EM, WL, EM, EM, EM, EM, EM},
		{WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, EM, EM, EM, EM, EM, EM, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL},
		{EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, EM, EM, EM, EM, EM, EM, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM},
		{WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, EM, EM, EM, EM, EM, EM, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL},
		{EM, EM, EM, EM, EM, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, EM, EM, EM, EM, EM},
		{EM, EM, EM, EM, EM, WL, EM, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, WL, EM, EM, EM, EM, EM},
		{WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL},
		{WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL},
		{WL, EM, WL, WL, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, WL, WL, EM, WL},
		{WL, EM, WL, WL, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, EM, WL, WL, WL, WL, EM, WL},
		{WL, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, WL},
		{WL, WL, WL, EM, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, EM, WL, WL, WL},
		{WL, WL, WL, EM, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, EM, WL, WL, WL},
		{WL, EM, EM, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, WL, WL, EM, EM, EM, EM, EM, EM, WL},
		{WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL},
		{WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL, WL, EM, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, EM, WL},
		{WL, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, EM, WL},
		{WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL, WL}
	};


endpackage : walls_pkg
