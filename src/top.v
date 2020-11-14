`default_nettype none
`include "src/neopixel.v"
// clk needs to be about 25MHz
module main #(parameter NUM_LEDS=128)(input clk, output leds, output led);

    wire clk;
    wire leds;
    wire led;

    reg led_reg;

    reg[23:0] color;
    reg[15:0] address; 
    reg color_clock;

    reg [16:0] anim_reg;
    reg anim_clock;
    reg [7:0] color_index;

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
                color_index <= color_index + 1;
                case (color_index)
                    0: color <= 'h100000;
                    1: color <= 'h001000;
                    2: color <= 'h000011;
                    3: color <= 'h100010;
                    4: color <= 'h101000;
                    5: color <= 'h001010;
                    6: color <= 'h101010;
                    default: begin
                        color <= 0;
                        color_index <= 0;
                    end
                endcase
            end
        end
    end

    assign led = led_reg;
endmodule