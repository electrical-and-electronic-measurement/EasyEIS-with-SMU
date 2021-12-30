# Electrochemical impedance spectroscopy using a source measure unit

Electrochemical impedance spectroscopy (EIS) is a powerful tool for monitoring rechargeable batteries through the state of charge and state of health estimation. In practical applications, EIS may be computed using ad-hoc electronics embedded in the final product. The accuracy of these custom impedance measurement systems must be validated against laboratory instrumentation.  

This repository contains:

- The voltage and current data acquisition measurement script with a source measure unit (SMU) instrument. [TSB Builder Project](TspBuilder)
- the post-processing [Matlab script](Matlab/load_data.m)  to compute the EIS from voltage and current data
- Some [sample data](data/) acquired during our experiment
- Project documentation [source markdown files](docs) for  [documentation companion website](https://electrical-and-electronic-measurement.github.io/EIS-with-SMU)
- [Notebook](notebook) for interactive data analysis



## Requirements

### TSP Enabled Instrument

We developed the measurement script using Keithley’s Test Script Processor (TSP) language. The TSP language is an alternative to “Standard Commands for Programmable Instrumentation” (SCPI) and other traditional instrument programming languages. The scripting engine is a Lua script interpreter extended with instrument control instructions. We tested the code on a Keithley 2450 SMU, but the TSP script should be compatible with any other TSP-enabled instrument. The measurement script can also be implemented in other languages such as SCPI, supported by different instrument manufacturers.

See also  (see "[How to Transition Code to TSP from SCPI application note](https://www.tek.com/document/application-note/how-to-transition-code-to-tsp-from-scpi)" ) on the Tektronix website.

### Matlab

We tested the Matlab post-processing scrip with Matlab 9.8 (R2020), but it should be compatible also with older versions.

## Project Documentation

See [project documentation companion website](https://electrical-and-electronic-measurement.github.io/EasyEIS-with-SMU).

## License

The content of this repository is open source and published under LICENSE).

## How To Contribute

This project was developed and maintained by the Electrical and Electronics Measurement Group. For any questions, suggestions, and contributions, please send an e-mail to emanuele.buchicchio@studenti.unipg.it 
