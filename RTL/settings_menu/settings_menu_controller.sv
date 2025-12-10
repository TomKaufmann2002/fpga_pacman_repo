`include "include/constants.vh"

module settings_menu_controller (
    // Inputs
    input  logic        clk,
    input  logic        resetN,
    input  logic [3:0]  dr_title_arr,    
    input  logic [9:0]  key_is_pressed, 
	 input  logic 			enter,

    // Outputs
    output logic        dr,
    output logic [7:0]  rgb,
	 output logic [2:0]  hovered_idx,
	 output logic 			game_started
);

    localparam int unsigned MAX_IDX = 3;     
    localparam logic [7:0]  DEFAULT_RGB  = `WHITE;
    localparam logic [7:0]  SELECTED_RGB = `BLUE;

    logic [2:0] selected_idx;
    logic [9:0] key_is_pressed_d;  
	 
	 logic enter_d;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            key_is_pressed_d <= 0;
				enter_d <= 0;
        end else begin
            key_is_pressed_d <= key_is_pressed;
				enter_d <= enter;
        end
    end

    // Detect rising edges for arrows and enter keys
    logic up_press, down_press, enter_press;
    assign up_press    =  key_is_pressed[8] & ~key_is_pressed_d[8];
    assign down_press  =  key_is_pressed[2] & ~key_is_pressed_d[2];
	 assign enter_press = enter & ~enter_d;

    // Selection update
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            selected_idx <= 0;
				game_started <=0;
        end else begin
            if (up_press && selected_idx > 0)
                selected_idx <= selected_idx - 1;
            else if (down_press && selected_idx < MAX_IDX)
                selected_idx <= selected_idx + 1;
				if (selected_idx == MAX_IDX & enter_press)
					game_started <= 1;
        end
    end

    // Draw logic
    always_comb begin
        dr  = |dr_title_arr;        
        rgb = DEFAULT_RGB;

        if (dr_title_arr[selected_idx]) begin
            rgb = SELECTED_RGB;  // highlight selected text_gen
        end
    end
	 
	 assign hovered_idx = selected_idx;

endmodule
