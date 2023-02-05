PROJ = icesugar-6502

PACKAGE = sg48
DEVICE = up5k
SERIES = synth_ice40
YOSYS_ARG = -dsp -abc2
ROUTE_ARG = --seed 10
PROGRAMMER = icesprog

# ----------------------------------------------------------------------------------

FPGA_SRC = ./src
PIN_DEF = ./icesugar.pcf
SDC = ./clock.sdc
TOP_FILE = $(shell echo $(FPGA_SRC)/top.v)
TB_FILE :=  $(shell echo $(FPGA_SRC)/*_tb.v)

# ----------------------------------------------------------------------------------

FW_DIR = firmware
FW_INCLUDE = $(FW_DIR)/include
FW_SRC = $(FW_DIR)/src
FW_SRC_FILE = $(shell echo $(FW_SRC)/*.c)
FW_ASM_FILE = $(shell echo $(FW_DIR)/*.s)
FW_LIB_FILE = $(shell echo $(FW_DIR)/lib/*.lib)
FW_CFG_FILE = $(shell echo $(FW_DIR)/sbc.cfg)
CLFLAGS  = -t none -O --cpu 6502 -C $(FW_CFG_FILE)
HEXDUMP_ARGS = -v -e '1/1 "%02x " "\n"'

# ----------------------------------------------------------------------------------

FORMAT = "verilog-format"
TOOLCHAIN_PATH = /opt/fpga
BUILD_DIR = build
#Creates a temporary PATH.
TOOLCHAIN_PATH := $(shell echo $$(readlink -f $(TOOLCHAIN_PATH)))
PATH := $(shell echo $(TOOLCHAIN_PATH)/*/bin | sed 's/ /:/g'):$(PATH)

all:  synthesis

synthesis: $(BUILD_DIR)/$(PROJ).bin
# rules for building the blif file
$(BUILD_DIR)/%.json: $(TOP_FILE) build_fw $(FPGA_SRC)/*.v $(FPGA_SRC)/6502/*.v
# FIXME:	
	yosys -q  -f "verilog -D__def_fw_img=\"$(BUILD_DIR)/$(PROJ)_fw.hex\"" -l $(BUILD_DIR)/build.log -p '$(SERIES) $(YOSYS_ARG) -top top -json $@; show -format dot -prefix $(BUILD_DIR)/$(PROJ)' $< 
# asc
$(BUILD_DIR)/%.asc: $(BUILD_DIR)/%.json $(PIN_DEF)
	nextpnr-ice40 -l $(BUILD_DIR)/nextpnr.log $(ROUTE_ARG) --package $(PACKAGE) --$(DEVICE) --asc $@  --pre-pack $(SDC) --pcf $(PIN_DEF) --json $<
# bin, for programming
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.asc
	icepack $< $@
# timing
$(BUILD_DIR)/%.rpt: $(BUILD_DIR)/%.asc
	icetime -d $(DEVICE) -mtr $@ $<

sim: build_fw $(BUILD_DIR)/%.vcd  
$(BUILD_DIR)/%.vcd: $(BUILD_DIR)/$(PROJ).out 
	vvp -v -M $(TOOLCHAIN_PATH)/tools-oss-cad-suite/lib/ivl $< 
	mv ./*.vcd $(BUILD_DIR)

#$(FPGA_SRC)/tv80/*.v
$(BUILD_DIR)/%.out: $(FPGA_SRC)/*.v $(FPGA_SRC)/6502/*.v
	iverilog -o $@ -DNO_ICE40_DEFAULT_ASSIGNMENTS -D__def_fw_img=\"$(BUILD_DIR)/$(PROJ)_fb.hex\" -B $(TOOLCHAIN_PATH)/tools-oss-cad-suite/lib/ivl $(TOOLCHAIN_PATH)/tools-oss-cad-suite/share/yosys/ice40/cells_sim.v $(TOP_FILE) $(TB_FILE)

# Flash memory firmware
flash: $(BUILD_DIR)/$(PROJ).bin
	$(PROGRAMMER) $<

# Flash in SRAM
prog: $(BUILD_DIR)/$(PROJ).bin
	$(PROGRAMMER) -S $<

formatter:
	if [ $(FORMAT) == "istyle" ]; then istyle-verilog-formatter  -t4 -b -o --pad=block $(FPGA_SRC)/*.v; fi
	if [ $(FORMAT) == "verilog-format" ]; then find ./src/*.v | xargs -t -L1 java -jar ${TOOLCHAIN_PATH}/utils/bin/verilog-format.jar -s .verilog-format -f ; fi

build_fw: $(BUILD_DIR)/$(PROJ)_fw.hex
# build tools & options
$(BUILD_DIR)/$(PROJ)_fw.hex: $(BUILD_DIR)/$(PROJ)_fw.bin
	hexdump $(HEXDUMP_ARGS) $< > $@

$(BUILD_DIR)/$(PROJ)_fw.bin: $(FW_SRC_FILE) $(FW_ASM_FILE) $(FW_INCLUDE)/*.h
	cl65 $(CLFLAGS) -o $@ -m $(BUILD_DIR)/$(PROJ)_fw.map -I $(FW_INCLUDE) $(FW_SRC_FILE) $(FW_ASM_FILE) $(FW_LIB_FILE)

clean:
	rm -f $(BUILD_DIR)/*

toolchain:
	curl https://raw.githubusercontent.com/MuratovAS/FPGACode-toolchain/main/toolchain.sh > ./toolchain.sh
	chmod +x ./toolchain.sh
	sudo ./toolchain.sh $(TOOLCHAIN_PATH)

#secondary needed or make will remove useful intermediate files
.SECONDARY:
.PHONY: all synthesis sim flash prog formatter build_fw clean toolchain

# $@ The file name of the target of the rule.rule
# $< first pre requisite
# $^ names of all preerquisites
