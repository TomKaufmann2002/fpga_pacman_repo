module keyIdleDetector (
    input  logic clk,
    input  logic resetN,
    input  logic keyIsValid,
    output logic idle_flag
);

    // constants
    localparam int clkFreq   = 31_500_000; // Hz
    localparam int idleTime  = 400;       // ms
    localparam longint maxCount = (clkFreq / 1000) * idleTime;
    localparam int pulseLen = 2_100_000;         // 10-cycle pulse for state machine

    longint counter;
    int     pulse_counter;
    logic   pulse_active;
    logic   fired_once;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            counter       <= 0;
            idle_flag     <= 0;
            pulse_counter <= 0;
            pulse_active  <= 0;
            fired_once    <= 0;
        end else begin
            if (keyIsValid) begin
                // reset everything when any key is pressed
                counter       <= 0;
                idle_flag     <= 0;
                pulse_counter <= 0;
                pulse_active  <= 0;
                fired_once    <= 0;
            end else if (!pulse_active && !fired_once) begin
                // counting idle time
                if (counter < maxCount-1) begin
                    counter   <= counter + 1;
                    idle_flag <= 0;
                end else begin
                    // timeout reached -> start pulse
                    pulse_active  <= 1;
                    pulse_counter <= pulseLen-1;
                    idle_flag     <= 1;
                    fired_once    <= 1;   // prevent repeat until key press
                end
            end else if (pulse_active) begin
                // currently in pulse
                if (pulse_counter > 0) begin
                    pulse_counter <= pulse_counter - 1;
                    idle_flag     <= 1;
                end else begin
                    pulse_active  <= 0;
                    idle_flag     <= 0;
                end
            end else begin
                // after pulse has fired once, keep the flag low until next make
                idle_flag <= 0;
            end
        end
    end

endmodule
