`include "include/constants.vh"
import font_pkg::*;

module text_gen #(
    parameter int unsigned LEN = 13,
    parameter logic [8*LEN-1:0] TEXT = "Hello World !",
    parameter int TOP_LEFT_TILE_X = 0,
    parameter int TOP_LEFT_TILE_Y = 0,
    parameter int unsigned SCALING_EXP = 0,
    parameter logic [7:0] BACKGROAND_COLOR = `BLACK,
    parameter logic [7:0] TEXT_COLOR = `WHITE
)(
	// inputs:
	input  logic clk,
	input  logic resetN,

	input  logic [10:0] pixel_x,
	input  logic [10:0] pixel_y,
	input  logic enable_background,
	
	// outputs:
	output logic dr,
	output logic [7:0] RGB
);

localparam int CHAR_TILE_W = 8;
localparam int CHAR_TILE_H = 16;

localparam int FIRST_CHAR_TILE_X = (TOP_LEFT_TILE_X * 2) >> SCALING_EXP;
localparam int TEXT_TILE_Y = TOP_LEFT_TILE_Y >> SCALING_EXP;

// tile positions (scaled grid)
logic [10:0] char_tile_x, char_tile_y;
logic [10:0] offset_x, offset_y;

assign char_tile_x = pixel_x / (CHAR_TILE_W << SCALING_EXP);
assign char_tile_y = pixel_y / (CHAR_TILE_H << SCALING_EXP);
assign offset_x = pixel_x % (CHAR_TILE_W << SCALING_EXP);
assign offset_y = pixel_y % (CHAR_TILE_H << SCALING_EXP);

// next-state signals
logic next_dr;
logic [7:0] next_RGB;

// character index + current character
integer idx;
logic [7:0] car;

// bitmap coordinate (scaled down)
logic [3:0] font_x;
logic [3:0] font_y;

// combinational "next state"
always_comb begin
    // defaults
    next_dr  = 0;
    next_RGB = `TRNS;
    car = 0;
    idx = 0;
    font_x = 0;
    font_y = 0;

    if (char_tile_y == TEXT_TILE_Y) begin
        idx = char_tile_x - FIRST_CHAR_TILE_X;

        if (idx >= 0 && idx < LEN) begin
            // extract ASCII character
            car = TEXT[(8*(LEN-1-idx)) +: 8];

            // scale down offsets to map to original font cells
            font_x = offset_x >> SCALING_EXP;
            font_y = offset_y >> SCALING_EXP;

            // check bitmap
            if (FONT[car][font_y][font_x]) begin
                next_dr  = 1;
                next_RGB = TEXT_COLOR;
            end else if (enable_background) begin
                next_dr  = 1;
                next_RGB = BACKGROAND_COLOR;
            end
        end
    end
end

// sequential update (registered outputs)
always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        dr  <= 0;
        RGB <= `TRNS;
    end else begin
        dr  <= next_dr;
        RGB <= next_RGB;
    end
end

endmodule
