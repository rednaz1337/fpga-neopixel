`default_nettype none

/*
module main #(parameter NUM_LEDS=7) (input clk, output leds);
    // Neopixel state machine.
    reg [2:0] state;
    reg [1:0] npxc;
    reg [12:0] lpxc;
    reg [7:0] bits;
    reg [7:0] led_num;
    reg [24:0] led_colors[NUM_LEDS-1:0];
    
    reg pin_reg;
    
    reg div;
    
    initial begin
        div <= 0;

        pin_reg <= 0;
        state <= 0;
        npxc <= 0;
        lpxc <= 0;
        bits <= 0;
        led_num <= 0;

        $readmemh("src/pixeldata.mem", led_colors);
    end
    
    always @(posedge clk) begin
        div <= !div;
    end
    
    // Process the state machine at each 12MHz clock edge.
    always@(posedge div)
    begin
        // Process the state machine; states 0-3 are the four WS2812B 'ticks',
        // each consisting of 83.33 * 4 ~ = 333.33 nanoseconds. Four of those
        // ticks are then ~1333.33 nanoseconds long, and we can get close to
        // the ideal 1250ns period.
        // A '1' is 3 high periods followed by 1 low period (999.99/333.33 ns)
        // A '0' is 1 high period followed by 3 low periods (333.33/999.99 ns)
        if (state == 0 || state == 1 || state == 2 || state == 3)
        begin
            npxc = npxc + 1;
            if (npxc == 0)
            begin
                state = state + 1;
            end
        end
        if (state == 4)
        begin
            bits = bits + 1;
            if (bits == 24)
            begin
                bits  = 0;
                state = state + 1;
            end
            else
            begin
                state = 0;
            end

        end
        if (state == 5)
        begin
            led_num = led_num + 1;
            if (led_num == NUM_LEDS)
            begin
                led_num = 0;
                state   = state + 1;
            end
            else
            begin
                state = 0;
            end
        end
        if (state == 6)
        begin
            lpxc = lpxc + 1;
            if (lpxc == 0)
            begin
                state = 0;
            end
        end
        // Set the correct pin state.
        if (led_colors[led_num] & (1 << bits))
        begin
            if (state == 0 || state == 1 || state == 2)
            begin
                pin_reg <= 1;
            end
            else if (state == 3 || state == 6)
            begin
                pin_reg <= 0;
            end
        end
        else begin
            if (state == 0)
            begin
                pin_reg <= 1;
            end
            else if (state == 1 || state == 2 || state == 3 || state == 6)
            begin
                pin_reg <= 0;
            end
        end
    end
                    
    assign leds = pin_reg;
endmodule
*/


// clk needs to be about 25MHz
module main #(parameter NUM_LEDS=7)(input clk, output leds);

    reg[4:0] counter;
    reg[10:0] counter_show;
    reg[23:0] color_data[NUM_LEDS-1:0];
    reg led;
    reg bit;
    reg[4:0] bit_idx;
    reg[7:0] color_idx;
    reg[1:0] state;
    
    wire pin;
    wire clk;

    initial begin
        led <= 0;
        bit <= 0;
        counter <= 0;
        bit_idx <= 'hFF;
        color_idx <= 0;
        state <= 1;
        counter_show = 0;
        $readmemb("src/pixeldata.mem", color_data);
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
            if (color_data[color_idx] & (1 << bit_idx))
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
            if (color_data[color_idx] & (1 << 0))
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

    assign leds = led;

endmodule