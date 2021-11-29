# Documentation Index 

Electrochemical impedance spectroscopy (EIS) is a powerful tool for rechargeable batteries’ monitoring through state of charge and state of health estimation. In practical applications, EIS may be computed using ad-hoc electronics embedded in the final product. The accuracy of these custom impedance measurement systems must be validated against laboratory instrumentation.  

This repository contains the measurement script and the post-processing script we developed to perform EIS using a standard commercial source measure unit on a lithium-ion battery to validate results from a custom impedance measurement system.

We developed the measurement script using the Test Script Processor (TSP) language by Tectronix because it was the most effective and convenient option, given the instruments available in our laboratory. The TSP scripting engine is a Lua script interpreter extended with instrument control instructions. We tested the code on a Keithley 2450 SMU, but the TSP script should be compatible with any other TSP-enabled instrument. The measurement script can also be implemented in other languages such as SCPI, supported by different instrument manufacturers.

[Getting started](getting_started.md)

[Electrochemical Impedance Spectroscopy (EIS)](electrochemical-Impedance-spectroscopy.md)

[EIS on Li-On battery with Keithley 2450](EIS-for-batteries.md)

[current sweep speed test](current-sweep-speed-test.md)

Limitation of Keithley 2450 for EIS - TBD 

EIS with Impedency.py

[sinusoidal signal generator](docs/sinusoidal-signal-generator.md)

[frequency sweep signal generator](docs/frequency-sweep-signal-generator.md)

[Keithley 2450 remote operations](docs/keithley-2450-remote.md)

[Save data](docs/save-data.md)

Data from Resistive load

Data from RC load

Data from Li-On Battery

Impedency.py software package