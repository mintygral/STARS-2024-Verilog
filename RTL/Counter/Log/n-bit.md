# Tests for N-bit flexible counter
![Test 0: Power on and Reset](RTL/Counter/waveforms/counter/n-bit-counter-waveform.png)

- ### 0: Power on and reset
This was the default test case given in the testbench. It checks if outputs are reset or not when nrst is reset.

- ### 1: Continuous counting
This test case checked if the counter keeps counting to the max value when uninterrupted.

- ### 2: Discontinuous counting
This test case checked if the counter would reset to 0 and then keep counting (when enable is high AND clear is low) after the interruption. I tested it by setting clear to high (then resetting it to 0), but it can just
as easily be tested by setting enable to low (then resetting it to 1).

- ### 3: Checking clear priority
This test case checks if when clear is set to high, the output is always 0 even though enable is high.

- ### 4: Wrap = 0
This test case checks if the counter holds the maximum value when it reaches it and the wrap is set to 0.
