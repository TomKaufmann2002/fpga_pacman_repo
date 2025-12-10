module settings_decoder (
    input  logic        clk,
    input  logic        resetN,
    input  logic        game_started,    // fix choices after game has started

    // Inputs
    input  logic        sound_choice,      // 1 = ON, 0 = OFF
    input  logic        theme_choice,      // 0 = DARK, 1 = WHITE
    input  logic [2:0]  hearts_choice,     // 1–6 hearts

    // Outputs
    output logic        sound_enable,      
    output logic        theme_mode,        
    output logic [2:0]  init_hearts_count  
);

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            sound_enable      <= 1'b0;   // default OFF
            theme_mode        <= 1'b0;   // default DARK
            init_hearts_count <= 3'd3;   // default 3 hearts
        end
        else if (!game_started) begin
            sound_enable      <= sound_choice;
            theme_mode        <= theme_choice;
            init_hearts_count <= hearts_choice;
        end
    end

endmodule
