# Counter

This assignment revisits the basic flexible counter. 
This implementation will be similar to the one presented in lecture, 
but you will need to account for a few more signals. 
Additionally, your module must be dynamic based on an input parameter. 

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
3. Make an RTL-diagram for the counter and have the design approved by a TA. Use [draw.io](https://app.diagrams.net/) **Make sure your design is located in the docs directory.**
4. Code your design in SystemVerilog.
5. Write a test bench to verify your design.
6. Run `make help`/`make` to see the make file targets.
7. Have a TA review your test cases and simulation waveforms.

## Pre-Code Tasks
Every student will be required to create a block diagram of their design 
**BEFORE** coding their design. The parameter N should be used in the 
diagram, and wavedrom should be used to make a timing diagram. Only once
a TA signs off on both of these diagrams may a student proceed to their 
implementation.

## Source Files
- counter.sv : This is where the design code should be located.
- tb_counter.sv : This is where the test bench code should be located.
- counter_8.sv : 8-bit counter (wrapper of counter module)
- tb_counter_8.sv : Test bench for counter_8 module

## Specifications
### Module Name 
- counter

### Required Parameters
- `N` | width of counter (default value of 4)

### Required Signals

- `clk` | System Clock
- `nrst` | Asyncronous active low reset to 0
- `enable` | Enable counter
- `clear` | Synchronous active high clear to 0
- `wrap` | 0: no wrap at max, 1: wrap to 0 at max
- `max` | Max number of count (inclusive)
- `count` | Current count
- `at_max` | 1 when counter is at max, otherwise 0

## Verification Requirements
A starter test bench file `tb_counter.sv` has been provided. In order to be checked off by a TA, you must add the following minimum test cases to the test bench code:

- Power-on-reset
- Wrap around for `max` value that is not a power of 2
- Continuous counting
- Discontinuous counting
- Reaching maximum value when `wrap = 0`
- Clearing while counting to check `clear` vs `enable` priority

We recommend you use the following verification tasks in the test bench:

- DUT Reset Task
- DUT Output Check (for both `count` and `at_max`)
- Clear Task (pulses `clear` for 1 cycle)

Once you finish verifying your `counter` module, complete the `counter_8` module and its test bench using the tb_counter code as reference. The same minimum test cases apply for your `counter_8` test bench.

## Submitting your design
Once you've completed and tested your design, you need to commit your code.
This can be done in one of many ways, the primary one is through the Source Control
VS Code Tool (Ctrl + Shift + G). You will need to stage your changes, then you
can commit them, then you hit the sync button to sync your local repository with
the remote repository.
You can also use `git` commands on the terminal.
