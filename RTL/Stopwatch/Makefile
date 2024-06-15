###########################################################################################
# STARS 2024 General Makefile
# Synopsys Tools - VCS and DVE
# iCE40 FPGA Targets
###########################################################################################

export PATH            := /home/shay/a/ece270/bin:$(PATH)
export LD_LIBRARY_PATH := /home/shay/a/ece270/lib:$(LD_LIBRARY_PATH)

# Specify the name of the top level file
# (do not include the source folder in the name)
TOP_FILE		:=  stop_watch.sv

# Specify the name of component or sub-module files
# (do not include the source folder in the name)
COMPONENT_FILES	:=  fsm.sv, clock_divider.sv, counter.sv

# Specify the top level testbench to be simulated
# (do not include the source folder in the name)
TB 				:= tb_stop_watch.sv

# Directories where source code is located
SRC 			:= source

# Simulation target
SIM_SOURCE		:= sim_source

# Location of executables and files created during source compilation
BUILD            := sim_build

# Specifies the VCD file
# Does not need to be configured unless your TB dumps to another file name.
VCD 			:= dump

# FPGA project vars and filenames
PROJ	         := ice40
PINMAP 	         := $(PROJ)/pinmap.pcf
ICE   	         := $(PROJ)/ice40hx8k.sv
UART	         := $(addprefix $(PROJ)/uart/, uart.v uart_tx.v uart_rx.v)
FILES            := $(ICE) $(SRC)/top.sv $(addprefix $(SRC)/, $(TOP_FILE) $(COMPONENT_FILES)) $(UART)
FPGA_BUILD       := ./$(PROJ)/build

# FPGA specific configuration
FPGA_DC		     := yosys
DEVICE           := 8k
TIMEDEV          := hx8k
FOOTPRINT        := ct256

# Binary names
NEXTPNR          := nextpnr-ice40
SHELL            := bash

##############################################################################
# Administrative Targets
##############################################################################

# Make the default target (the one called when no specific one is invoked) to
# output the proper usage of this makefile
help:
	@echo "----------------------------------------------------------------"
	@echo "|                       Makefile Targets                       |"
	@echo "----------------------------------------------------------------"
	@echo "Administrative targets:"
	@echo "  all           - compiles the source version of a full"
	@echo "                  design including its top level test bench"
	@echo "  help          - Makefile targets explanation"
	@echo "  setup         - Setups the directory for work"
	@echo "  clean         - removes the temporary files"
	@echo
	@echo "Compilation targets:"
	@echo "  source       - compiles the source version of a full"
	@echo "                 design including its top level test bench"
	@echo
	@echo "Simulation targets:"
	@echo "  sim_source   - compiles the source version of a full design"
	@echo "                 and simulates its test bench in DVE, where"
	@echo "                 the waveforms can be opened for debugging"
	@echo
	@echo "FPGA targets:"
	@echo "  ice          - synthesizes the source files along with the"
	@echo "                 ice40 files to make and netlist and then"
	@echo "                 place and route to program ice40 FPGA as per"
	@echo "                 the given design"
	@echo "----------------------------------------------------------------"

# Compiles design and runs simulation
all: $(SIM_SOURCE)

# Removes all non essential files that were made during the building process
clean:
	@echo "Removing temporary files, build files and log files"
	@rm -rf $(BUILD)/*
	@rm -f *.vcd
	@rm -f *.vpd
	@rm -f *.key
	@rm -f *.log
	@rm -f .restartSimSession.tcl.old
	@rm -rf DVEfiles/
	@rm -rf $(PROJ)/build
	@echo -e "Done\n\n"

# A target that sets up the working directory structure
# (A mapped directory can be added later on)
setup:
	@mkdir -p ./docs
	@mkdir -p ./$(BUILD)
	@mkdir -p ./$(SRC)

##############################################################################
# Compilation Targets
##############################################################################

# Rule to compile design without running simulation
$(SRC): $(addprefix $(SRC)/, $(TB) $(TOP_FILE) $(COMPONENT_FILES))
	@echo "----------------------------------------------------------------"
	@echo "Creating executable for source compilation ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@mkdir -p ./$(BUILD)
	@vcs -sverilog -lca -debug_access+all -Mdir=$(BUILD)/csrc -o $(BUILD)/simv $^

##############################################################################
# Simulation Targets
##############################################################################

# Rule to compile design and open simulation in DVE
$(SIM_SOURCE): $(SRC)
	@echo "----------------------------------------------------------------"
	@echo "Simulating source ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@./$(BUILD)/simv -gui -suppress=ASLR_DETECTED_INFO &

##############################################################################
# FPGA Targets
##############################################################################

# this target checks your code and synthesizes it into a netlist
$(FPGA_BUILD)/$(PROJ).json : $(ICE) $(addprefix $(SRC)/, $(COMPONENT_FILES) $(TOP_FILE)) $(PINMAP) $(SRC)/top.sv
	@mkdir -p $(FPGA_BUILD)
	@echo "----------------------------------------------------------------"
	@echo "Synthesizing to ice40 ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@$(FPGA_DC) -p "read_verilog -sv -noblackbox $(FILES); synth_ice40 -top ice40hx8k -json $(FPGA_BUILD)/$(PROJ).json" > $(PROJ).log
	@echo -e "\n\n"
	@echo -e "Synthesis Complete \n\n"
	
# Place and route using nextpnr
$(FPGA_BUILD)/$(PROJ).asc : $(FPGA_BUILD)/$(PROJ).json
	@echo "----------------------------------------------------------------"
	@echo "Mapping to ice40 ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@$(NEXTPNR) --hx8k --package ct256 --pcf $(PINMAP) --asc $(FPGA_BUILD)/$(PROJ).asc --json $(FPGA_BUILD)/$(PROJ).json 2> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2) >> $(PROJ).log
	@echo -e "\n\n"
	@echo -e "Place and Route Complete \n\n" 

# Convert to bitstream using IcePack
$(FPGA_BUILD)/$(PROJ).bin : $(FPGA_BUILD)/$(PROJ).asc
	@icepack $(FPGA_BUILD)/$(PROJ).asc $(FPGA_BUILD)/$(PROJ).bin >> $(PROJ).log
	@echo -e "\n\n"
	@echo -e "Converted to Bitstream for FPGA \n\n" 
	
# synthesize and flash the FPGA
ice : $(FPGA_BUILD)/$(PROJ).bin
	@echo "----------------------------------------------------------------"
	@echo "Flashing onto FPGA ....."
	@echo -e "----------------------------------------------------------------\n\n"
	@iceprog -S $(FPGA_BUILD)/$(PROJ).bin

# Designate targets that do not correspond directly to files
.PHONY: all help clean
.PHONY: $(SRC)
.PHONY: $(SIM_SOURCE)