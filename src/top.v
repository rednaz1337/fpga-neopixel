`default_nettype none

module blink (osc25m, led);

    input wire osc25m;
    output wire led;

    reg [7:0] brightness;
    reg [7:0] pwm_counter;
    reg [31:0] brightness_change_counter;
    reg LED_status;
    reg fade_direction;

    initial begin
        pwm_counter <= 8'b0;
        LED_status <= 1'b0;
        brightness <= 8'd254;
        brightness_change_counter <= 0;
        fade_direction <= 0;
    end

    always @ (posedge osc25m) 
    begin
        pwm_counter <= pwm_counter + 1;
        if (pwm_counter > brightness)
        begin
            LED_status <= 0;
        end
        else begin
            LED_status <= 1;
        end

        brightness_change_counter <= brightness_change_counter + 1;
        if (brightness_change_counter > 15_000) begin
            brightness_change_counter <= 0;
            if(fade_direction) begin
                brightness <= brightness + 1;
            end else begin
                brightness <= brightness - 1;
            end
        end

        if (brightness == 255)
            fade_direction <= 0;
        else if (brightness == 0) begin
            fade_direction <= 1;
        end
    end


    assign led = LED_status;

endmodule 