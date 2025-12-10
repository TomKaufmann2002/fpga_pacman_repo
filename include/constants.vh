// constants.vh

// Orientation

`define UP     2'b00
`define DOWN   2'b01
`define LEFT   2'b10
`define RIGHT  2'b11


// Tile / Screen sizes

`define TILE_SIZE      16
`define SCREEN_WIDTH   640
`define SCREEN_HEIGHT  480
`define MAZE_W  40
`define MAZE_H  30

// Colors (8-bit RGB: RRR_GGG_BB)

`define TRNS		8'hFF
`define BLACK    	8'h00
`define WHITE    	8'hFE
`define RED      	8'hE0
`define GREEN    	8'h1C
`define BLUE     	8'h03
`define YELLOW   	8'hFC
`define CYAN     	8'h1F
`define MAGENTA  	8'hE3
`define BROWN		8'hAC
`define PINK		8'hF7
`define ORANGE		8'hF4
`define GREY      8'h92


// Arithmetic

`define INFTY 32'hFFFF_FFFF

// Drwaing request prioreties

`define PRIO_COUNT 		 	20 // not tight, chage for final project

`define OVERRIDE_ALL_PRIO	0
`define SETTINGS_MENU_PRIO	1
`define WON_SCREEN_PRIO		2
`define LOST_SCREEN_PRIO	3
`define WALL_PRIO				4
`define BREAKBLE_BOX_PRIO	5
`define PM_PRIO				6
`define RG_PRIO				7
`define PG_PRIO				8
`define CG_PRIO				9
`define OG_PRIO				10
`define HEARTS_PRIO			11
`define EDOT_PRIO				12
`define SCORE_BOARD_PRIO	13
`define PDOT_PRIO				14


`define PRIO_COUNT_SETTINGS 8 // for the seperate mux of the settings screen

// Clock frequency in Hz

`define CLK_FREQ 31500000


// Special tiles

`define BLOCK_TILE1_X 18
`define BLOCK_TILE1_Y 11
`define BLOCK_TILE2_X 19
`define BLOCK_TILE2_Y 11

`define DEBUG_TILE_X 19
`define DEBUG_TILE_Y	28

// Ghosts initial positions


`define  LEFT_GST_INIT_TILE_X		18
`define  ALL_GST_INIT_TILE_Y 		13

`define  SPN_TILE_LEFT_X  		18
`define  SPN_TILE_MIDLEFT_X  	19
`define  SPN_TILE_MIDRIGHT_X  20
`define  SPN_TILE_RIGHT_X  	21


// game modes

`define CHASE_MODE      2'b00
`define SCATTER_MODE    2'b01
`define FRIGHTENED_MODE 2'b10




