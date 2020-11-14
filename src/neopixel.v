// clk needs to be about 25MHz
module neopixel #(parameter NUM_LEDS=16)(input clk, output leds, input[23:0] color, input[15:0] address, input color_clock);

    reg[4:0] counter;
    reg[10:0] counter_show;
    reg[23:0] color_data[NUM_LEDS-1:0];
    reg led;
    reg bit;
    reg[4:0] bit_idx;
    reg[15:0] color_idx;
    reg[1:0] state;
    
    wire pin;
    wire clk;

    wire[23:0] color;
    wire[15:0] address;
    wire color_clock;

    initial begin
        led <= 0;
        bit <= 0;
        counter <= 0;
        bit_idx <= 'hFF;
        color_idx <= 0;
        state <= 1;
        counter_show = 0;
        $readmemh("src/pixeldata.mem", color_data);
    end

    /*
        State 0: create signal
        State 1: load next bit
        State 2: load next color
        State 3: Show colors
    */

    always @(posedge clk) begin
        if (state == 0) begin // create signal
            counter <= counter + 1;
            if (!bit) // Is the bit to send one?
                if (counter < 'h0A) // Low bit = 400ns high, 850 low
                    led <= 1;
                else begin
                    led <= 0;
                end 
            else begin
                if (counter < 'h14) // High bit = 800ns high, 450 low.
                    led <= 1;
                else begin
                    led <= 0;
                end 
            end
            if (counter == 'h1F) begin
                state = state + 1;
            end
        end

        if (state == 1) begin // load next bit
            bit_idx = bit_idx + 1;
            if (color_data[color_idx] & ('b100000000000000000000000 >> bit_idx))
                bit <= 1;
            else begin
                bit <= 0;
            end

            if (bit_idx == 24) begin 
                bit_idx <= 0;
                state = 2;
            end else begin
                state <= 0;
            end
        end

        if (state == 2) begin // load next color
            color_idx = color_idx + 1;
            if (color_data[color_idx] & ('b100000000000000000000000 >> 0))
                bit <= 1;
            else begin
                bit <= 0;
            end
            
            if (color_idx == NUM_LEDS) begin
                color_idx <= 0;
                state = 3;
            end else begin
                state = 0;
            end
        end

        if (state == 3) begin // delay to show colors
            counter_show = counter_show + 1;
            if (counter_show == 0) begin
                state <= 0;
            end
        end

    end


    always @(posedge color_clock) begin
        color_data[address] <= color;
    end

    assign leds = led;

endmodule