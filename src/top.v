`default_nettype none
`include "src/neopixel.v"
// clk needs to be about 25MHz
module main #(parameter NUM_LEDS=64)(input clk, output leds, output led);

    wire clk;
    wire leds;
    wire led;

    reg led_reg;

    reg[23:0] color;
    reg[15:0] address; 
    reg color_clock;

    reg [16:0] anim_reg;
    reg anim_clock;

    initial begin
        color <= 'hFF0000;
        address <= 0;
        color_clock <= 0;
        anim_reg <= 0;
        anim_clock <= 0;
        led_reg <= 0;
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
        if (color_clock == 1) begin
           address = address + 1;
           if (address == NUM_LEDS) begin
               address <= 0;
               if (color == 'hFF0000) begin
                   color <= 'h00FF00;
               end else if (color == 'h00FF00) begin
                   color <= 'h0000FF;
               end else if (color == 'h0000FF) begin
                   color <= 'hFFFF00;
               end else if (color == 'hFFFF00) begin
                   color <= 'h00FFFF;
               end else if (color == 'h00FFFF) begin
                   color <= 'hFF00FF;
               end else if (color == 'hFF00FF) begin
                   color <= 'hFFFFFF;
               end else if (color == 'hFFFFFF) begin
                   color <= 'hFF0000;
               end
           end
        end
    end

    assign led = led_reg;
endmodule