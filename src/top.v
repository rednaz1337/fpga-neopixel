`default_nettype none
`include "src/neopixel.v"
// clk needs to be about 25MHz
module main #(parameter NUM_LEDS=150, parameter STEP_SIZE=17, ANIM_REG_SIZE=9)(input clk, output leds, output led);

    wire clk;
    wire leds;
    wire led;

    reg led_reg;

    reg[23:0] color;
    reg[7:0] red;
    reg[7:0] green;
    reg[7:0] blue;

    reg[7:0] start_red;
    reg[7:0] start_green;
    reg[7:0] start_blue;

    reg[15:0] address; 
    reg color_clock;

    reg [ANIM_REG_SIZE:0] anim_reg;
    reg anim_clock;

    initial begin
        color <= 'hFF0000;
        address <= NUM_LEDS;
        color_clock <= 0;
        anim_reg <= 0;
        anim_clock <= 0;
        led_reg <= 0;
        
        red <= 255;
        green <= 0;
        blue <= 0;

        start_red <= 255;
        start_green <= 0;
        start_blue <= 0;
    end

    neopixel np(.clk(clk), .leds(leds), .color(color), .address(address), .color_clock(color_clock));
    defparam np.NUM_LEDS = NUM_LEDS;

    always @(posedge clk) begin
        anim_reg <= anim_reg + 1;
        if (anim_reg == 0) begin
            anim_clock = ~anim_clock;
        end

    end

    always @(posedge anim_clock) begin
        led_reg <= ~led_reg;
        color_clock <= ~color_clock;
        if (color_clock == 0) begin
            address <= address - 1;
            if(address == 0) begin
                address <= NUM_LEDS;
                
                if (start_red == 255 && start_blue == 0 && start_green < 255) begin
                    start_green <= start_green + STEP_SIZE;
                end
                else if (start_green == 255 && start_blue == 0 && start_red > 0) begin
                    start_red <= start_red - STEP_SIZE;
                end
                else if (start_red == 0 && start_green == 255 && start_blue < 255) begin
                    start_blue <= start_blue + STEP_SIZE;
                end
                else if (start_red == 0 && start_blue == 255 && start_green > 0) begin
                    start_green <= start_green - STEP_SIZE;
                end
                else if (start_blue == 255 && start_green == 0 && start_red < 255) begin
                    start_red <= start_red + STEP_SIZE;
                end
                else if (start_red == 255 && start_green == 0 && start_blue > 0) begin
                    start_blue <= start_blue - STEP_SIZE;
                end
                
                red <= start_red;
                green <= start_green;
                blue <= start_blue;

            end else begin

                // modeled after this graphic: https://de.wikipedia.org/wiki/HSV-Farbraum#/media/Datei:HSV-RGB-comparison.svg
                if (red == 255 && blue == 0 && green < 255) begin
                    green <= green + STEP_SIZE;
                end
                else if (green == 255 && blue == 0 && red > 0) begin
                    red <= red - STEP_SIZE;
                end
                else if (red == 0 && green == 255 && blue < 255) begin
                    blue <= blue + STEP_SIZE;
                end
                else if (red == 0 && blue == 255 && green > 0) begin
                    green <= green - STEP_SIZE;
                end
                else if (blue == 255 && green == 0 && red < 255) begin
                    red <= red + STEP_SIZE;
                end
                else if (red == 255 && green == 0 && blue > 0) begin
                    blue <= blue - STEP_SIZE;
                end
                color <= (green << 16) | (red << 8) | blue;
                
            end
        end
    end

    assign led = led_reg;
endmodule