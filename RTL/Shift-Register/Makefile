###########################################################################################
# STARS 2024 General Makefile
# Synopsys Tools - VCS and DVE
###########################################################################################

# Specify the name of the top level file
# (do not include the source folder in the name)
TOP_FILE		:= shift_reg.sv

# Specify the name of component or sub-module files
# (do not include the source folder in the name)
COMPONENT_FILES	:= 

# Specify the top level testbench to be simulated
# (do not include the source folder in the name)
TB 				:= tb_shift_reg.sv

# Directories where source code is located
SRC 			:= source

# Simulation target
SIM_SOURCE		:= sim_source

# Location of executables and files created during source compilation
BUILD            := sim_build

# Specifies the VCD file
# Does not need to be configured unless your TB dumps to another file name.
VCD 			:= dump

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

# Designate targets that do not correspond directly to files
.PHONY: all help clean
.PHONY: $(SRC)
.PHONY: $(SIM_SOURCE)