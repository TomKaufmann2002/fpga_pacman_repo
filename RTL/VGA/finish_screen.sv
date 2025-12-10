`include "include/constants.vh"

module finish_screen (
    // inputs:
    input  logic clk,
    input  logic resetN,

    input  logic [10:0] pixel_x,
    input  logic [10:0] pixel_y,

    input  logic game_started,
    input  logic pdot_exist,
    input  logic edot_exist,
    input  logic [2:0] lives,

    // outputs:
    output logic        dr_out,
    output logic [7:0]  RGB_out
);

    // maze boundaries
    logic in_maze;
    assign in_maze = (pixel_x > 5 * `TILE_SIZE && pixel_x < 33 * `TILE_SIZE);

    //  win/loss detection
    logic game_won, game_lost;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            game_won  <= 1'b0;
            game_lost <= 1'b0;
        end 
        else if (game_started) begin
            // once game_won is true, keep it locked high (priority over lost)
            if (!game_won) begin
                if (~pdot_exist && ~edot_exist)
                    game_won <= 1'b1;
                else if (lives == 3'b000)
                    game_lost <= 1'b1;
            end
        end
    end

    // text_gen for GAME WON
    logic dr_won;
    logic [7:0] rgb_won;
    text_gen #(
        .LEN(9),
        .TEXT("GAME WON!"),
        .TOP_LEFT_TILE_X(10),
        .TOP_LEFT_TILE_Y(14),
        .SCALING_EXP(2),
        .BACKGROAND_COLOR(`GREY),
        .TEXT_COLOR(`GREEN)
    ) won_text (
        .clk(clk),
        .resetN(resetN),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .enable_background(1'b0),
        .dr(dr_won),
        .RGB(rgb_won)
    );

    // text_gen for GAME LOST
    logic dr_lost;
    logic [7:0] rgb_lost;
    text_gen #(
        .LEN(9),
        .TEXT("GAME LOST"),
        .TOP_LEFT_TILE_X(10),
        .TOP_LEFT_TILE_Y(14),
        .SCALING_EXP(2),
        .BACKGROAND_COLOR(`GREY),
        .TEXT_COLOR(`RED)
    ) lost_text (
        .clk(clk),
        .resetN(resetN),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .enable_background(1'b0),
        .dr(dr_lost),
        .RGB(rgb_lost)
    );

    // display logic
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            RGB_out <= `TRNS;
            dr_out  <= 1'b0;
        end else begin
            if (in_maze && (game_won || game_lost)) begin
                dr_out <= 1'b1;

                if (game_won) begin
                    RGB_out <= dr_won ? rgb_won : `GREY;
                end else if (game_lost) begin
                    RGB_out <= dr_lost ? rgb_lost : `GREY;
                end
            end else begin
                dr_out  <= 1'b0;
                RGB_out <= `TRNS;
            end
        end
    end

endmodule
