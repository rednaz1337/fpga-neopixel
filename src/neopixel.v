module neopixel #(parameter CHAIN_LEN = 3)(
    clk,
    data,
    pin
);

    input clk;
    input data;
    output pin;
    
    wire clk;
    reg data[CHAIN_LEN*24-1:0];
    wire pin;


endmodule