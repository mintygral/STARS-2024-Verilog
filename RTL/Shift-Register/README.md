# Shift Register

This design implements a parallel-to-parallel or serial-to-parallel (MSB or LSB) shift register. The behavior of the shift register is determined by the mode_i input of the module.

## Clone Repository
Please DO NOT download as a .zip file.  
You should run the following command to *clone* the *repository* onto
your remote computer, replacing `<URL>` with the URL of this repository.

```bash
git clone <URL>
```

## Instructions
1. Clone the repo from GitHub.
2. Run `make setup` to configure directory for the project.
3. Make an RTL-diagram for the shift register and have the design approved by a TA. Use [draw.io](https://app.diagrams.net/) **Make sure your design is located in the docs directory.**
4. Code your design in SystemVerilog.
5. Write a test bench to verify your design.
6. Run `make help`/`make` to see the make file targets.
7. Have a TA review your test cases and simulation waveforms.

## Pre-Code Tasks
Every student will be required to create a block diagram of their design 
**BEFORE** coding their design. Use wavedrom to make a timing diagram. Only once a TA signs off on both of these diagrams may a student proceed to their implementation.

## Source Files
- shift_reg.sv : This is where the design code should be located.
- tb_shift_reg.sv : This is where the test bench code should be located.

## Specifations
### Module Name 
- shift_reg
### Inputs
- `clk` | System clock (Max Operating Frequency: 400 Mhz)
- `nrst` | Asyncronous active low reset
- `D` | Serial Input to the shift register
- `mode_i [1:0]` |
  - HOLD : when mode_i = 2’b00, value in shift register doesn’t change
  - LOAD : when mode_i = 2’b01, store value of par_i in the register
  - LEFT : when mode_i = 2’b10, shift register contents to the left
  - RIGHT : when mode_i  = 2’b11, shift register contents to the right
- `par_i [7:0]` | Parallel input to the shift register
### Outputs
- `P [7:0]` | Parallel output of the shift register

## Verification Requirements
A starter test bench file `tb_shift_reg.sv` has been provided. It contains data-streaming tasks that will be useful as you create your test cases. Feel free to create your own tasks or modify the ones provided. In order to be checked off by a TA, you must add the following minimum test cases to the test bench code:
- Power-on-reset
- Correct operation during HOLD mode
- Correct operation during LOAD mode
- Correct operation during LEFT mode using 2 different data streams
- Correct operation during RIGHT mode using 2 different data streams

## Submitting your design
Once you've completed and tested your design, you need to commit your code.
This can be done in one of many ways, the primary one is through the Source Control
VS Code Tool (Ctrl + Shift + G). You will need to stage your changes, then you
can commit them, then you hit the sync button to sync your local repository with
the remote repository.
You can also use `git` commands on the terminal.