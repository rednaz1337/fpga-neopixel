`include "src/top.v"
`timescale 1ns/1ns
module tb_neopixel;

    reg clk;
    wire leds;

    main neopixels (.clk(clk), .leds(leds));
    defparam neopixels.NUM_LEDS = 4;
    defparam neopixels.ANIM_REG_SIZE=1;

    always #20 clk = ~clk; // 25 MHz clock

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,tb_neopixel);
        clk <= 0;

        #10000000 $finish;
    end

endmodule