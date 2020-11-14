`include "src/top.v"
`timescale 1ns/1ns
module tb_neopixel;

    reg clk;
    wire leds;

    main neopixels (.clk(clk), .leds(leds));
    //defparam neopixels.NUM_LEDS = 4;

    always #20 clk = ~clk; // 25 MHz clock

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,tb_neopixel);
        clk <= 0;

        #6000000 $finish;
    end

endmodule