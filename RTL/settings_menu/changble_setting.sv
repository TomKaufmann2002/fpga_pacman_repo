`include "include/constants.vh"

module changble_setting #(
    parameter int unsigned OPTION_IDX = 0, 		// option index
    parameter int unsigned NUM_CHOICES = 2      // number of possible choices for that option
)(
    // Inputs
    input  logic                  clk,
    input  logic                  resetN,
    input  logic [2:0]            hovered_idx,
    input  logic [9:0]            key_is_pressed,
    input  logic [NUM_CHOICES-1:0] dr_choices,

    // Outputs
    output logic                  dr,
    output logic [7:0]            rgb,
    output integer                choice_idx     // use integer for compatibility
);

    localparam logic [7:0] RGB_DEFAULT = `WHITE;
    localparam logic [7:0] RGB_HOVERED = `BLUE;
	 
	 logic is_hovered;
	 assign is_hovered = (hovered_idx == OPTION_IDX);
	 
    logic [9:0] key_is_pressed_d;
    logic left_press, right_press;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            key_is_pressed_d <= '0;
        else
            key_is_pressed_d <= key_is_pressed;
    end

    assign left_press  = key_is_pressed[4] & ~key_is_pressed_d[4];
    assign right_press = key_is_pressed[6] & ~key_is_pressed_d[6];

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            choice_idx <= 0;
        else if (is_hovered) begin
            if (left_press) begin
                if (choice_idx == 0)
                    choice_idx <= NUM_CHOICES - 1;  // wrap to last
                else
                    choice_idx <= choice_idx - 1;
            end
            else if (right_press) begin
                if (choice_idx == NUM_CHOICES - 1)
                    choice_idx <= 0;                // wrap to first
                else
                    choice_idx <= choice_idx + 1;
            end
        end
    end


    assign dr  = dr_choices[choice_idx];
    assign rgb = is_hovered ? RGB_HOVERED : RGB_DEFAULT;

endmodule
