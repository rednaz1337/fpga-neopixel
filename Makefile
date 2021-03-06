BUILD := build
SRC := src

TARGET := src/top.v

SOURCE_FILES := src/top.v \
				src/pixeldata.mem \
				src/neopixel.v \
				src/testbench.v

all: $(BUILD)/top.bit

$(BUILD)/top.json: $(SOURCE_FILES)
	yosys -p "synth_ecp5" "$(TARGET)" -o "$(BUILD)/top.json"

$(BUILD)/top.config: $(BUILD)/top.json $(SRC)/top.lpf
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $(BUILD)/top.json --lpf $(SRC)/top.lpf --write $(BUILD)/top-post-route.json --textcfg $(BUILD)/top.config

$(BUILD)/top.bit: $(BUILD)/top.config
	ecppack $(BUILD)/top.config $(BUILD)/top.bit

run: $(BUILD)/top.bit
	openFPGALoader -c ft2232 $(BUILD)/top.bit

flash: $(BUILD)/top.bit
	ecpprog $(BUILD)/top.bit

clean:
	rm $(BUILD)/*

test.vcd: $(SOURCE_FILES)
	iverilog -o testbench src/testbench.v && vvp testbench

gui: test.vcd
	gtkwave test.vcd
