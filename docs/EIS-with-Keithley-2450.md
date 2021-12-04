# Electrochemical impedance spectroscopy (EIS) on batteries with Keithley 2450

This project aims to perform Electrochemical impedance spectroscopy (EIS) on a Li-Ion rechargeable battery using the Keithley 2450 Source Measure Unit (SMU) Instrument. Even though the EIS is not among the applications listed in the official documentation,  the instrument's features should allow the impedance measurement (in theory) up to 100Hz.

See also [Voltage and Current Measurement Script with Keithley 2450 Video](https://youtu.be/1LU2z2Eqs3A)

## Programming Keithley 2450

Keithley  2450 can be operated using one the supported remote command interface, loading and running a script locally with the  _Script Manager_ or from the front panel interface. The Script Manager can save, load and execute script files from an external storage unit connected to the USB port or from the internal memory.

We developed the measurement script using the Test Script Processor (TSP) language by Tectronix because it was the most effective and convenient option, given the instruments available in our laboratory. The TSP scripting engine is a Lua script interpreter extended with instrument control instructions. We tested the code on a Keithley 2450 SMU, but the TSP script should be compatible with any other TSP-enabled instrument. The measurement script can also be implemented in other languages such as SCPI, supported by different instrument manufacturers.

## The Test Script Processor (TSP®)

The Test Script Processor (TSP®) scripting engine is a Lua interpreter. In TSP-enabled instruments, the Lua programming language has been extended with Keithley-specific instrument control commands.

Lua is an efficient general-purpose scripting language with simple syntax and a complete functionality set supported by an active developer community and a rich ecosystem of open-source libraries.

TSP controls every instrument's features while using standard programming commands to control script execution such as variables, functions, conditional branching, and loop control.

The main limit of TSP is that all code should reside in a single file named `*.tsp`. File with extension. `.lua` can not be executed from _Script Manager,_ and external files can not be loaded at runtime using the `import <module name>` syntax. There is no easy way to add functionality loading external modules from one of the many Lua open source repositories.

## How To Perform an EIS on Keithley 2450 with TSP

Single-Sine [EIS measurements](docs/electrochemical-Impedance-spectroscopy.md) involve applying a sinusoidal perturbation (voltage or current) at different frequencies and measuring the response (current or voltage, respectively). A sinusoidal source current signal has been used for this experiment, and the voltage across DUT has been measured with a four-wire measurement configuration.

See also [Getting Stated](getting_started.md)

## Experiments parameters

Source parameters must be set before the creation of the source configuration list.

For impedance estimation, a current input signal is sourced, and a voltage on DUT terminals is measured. To achieve the maximum speed, the auto range is turned off.

### Source settings

```lua
 smu.source.func = smu.FUNC_DC_CURRENT
 smu.source.readback = smu.ON
 smu.source.vlimit.level = 21 -- [V]
 smu.source.autorange = smu.OFF
 smu.source.range = 0.1 --[A]
 smu.source.delay = 0 -- [s]
```

`smu.source.readback = smu.ON` mean that the output of the measure will include the measured source signal levels while with `smu.source.readback = smu.OFF` the programmed value is used. The source signal measure is executed immediately before the measure signal measurement. This additional measure requires some time and increase the overall time needed for each measurement.

`smu.source.autorange = smu.OFF` disables the auto-range function to avoid delay during range changes. A fixed `smu.source.range = 0.010` is therefore used.

`smu.source.delay=0` allow controlling the delay between two measures only with `delay` parameter `function`.

### Measure settings

The minimum nplc value is chosen, the auto range is turned off, and autozero is executed only once to achieve the maximum speed.

```lua
 smu.measure.func = smu.FUNC_DC_VOLTAGE
 smu.measure.autorange = smu.OFF
 smu.measure.range = 5 -- [V]
 smu.measure.nplc = 0.01 -- from 0.01 to 10
 smu.measure.sense=smu.SENSE_4WIRE
 smu.measure.autozero.once()
```

#### Source and Measure Range

Source and measurement range should match the output signal range to obtain the best SNC. The instrument will use the next range from the list of available ranges.
For Keithly 2450 feature the following ranges:

- current ranges: 10 nA, 100 nA, 1 microA, 10 microA, 100 microA, 1 mA, 10 mA, 100 mA, and 1 A
- voltage ranges: 20 mV, 200 mV, 2 V, 20 V, and 200 V

## Generate Sinusoidal current source signal

The programmable current source API lacks a native function for a sinusoidal signal generation, so we had to approximate the waveform defining configuration list with current values from a sampled sinusoidal signal generated with `math.sin()` function available in TSP.

The _sweeplist_ function allows to iterate over a list of source configurations and perform a measure for each item of the list.

```Lua

--[[  Generate discrete time sine wave
 sampleTime: Specify the sample period in seconds 
 signalFrequency: frequency of sine wave
 A is the amplitude of the sine wave.
 N sample number
 b is the signal bias
 po is the offset (phase shift) of the signal.

 reference: https://it.mathworks.com/help/simulink/slref/sinewavefunction.html
--]]
function generateSinusoidalSignalSampleBased(sampleTime,signalFrequency,N,A,po,b)
 print(string.format("signal frequency %g",signalFrequency))
 local signal = {}    -- new array
 for k=0,N-1 do 
  signal[k]=A*math.sin(2*math.pi*k*signalFrequency*sampleTime+po)+b
 end
 return signal
end

```

## Init configuration List

A configuration list is a list of stored settings for the source or measure function. On Keintly 2450, a _Configuration list_ can hold a up to 300,000 _configuration indexes_  

Each _configuration index_ contains a copy of all instrument source and measure settings such as:

- source/measure function setting
- NPLC
- source range
- measure range
- autorange
- autozero
- display digit

The current `smu.source.level` value is replaced with the value from generated sinusoidal current signal.

```Lua
 smu.source.configlist.create("CurrentListSweep")
 
 for index = 1, table.getn(currentLevels) do
  smu.source.level = currentLevels[index]
  smu.source.configlist.store("CurrentListSweep")
 end

 smu.source.sweeplist("CurrentListSweep", 1,delay,repetition)
```

## Data acquisition sampling frequency

The time interval between two consecutive measures is the sum of four elements:

 1. Trigger Latency
 2. Explicit source delay or implicit source auto delay
 3. Measure time
 4. Sweep delay

User-configurable parameters can influence all but trigger latency.

### Source Delay and Autodelay

The programmable current source will take time to reach the next set point. The amount of delay is controlled by the `smu. source.delay` parameter.

If no explicit source delay is set (`smu.source.delay=0`), the firmware will insert an auto delay based on the target value end load type. (see table on page 4-46 in the reference manual([3](./references.md).

#### Sweep Delay

The `smu.source.sweeplist()` function has many parameters to customise the sweep. The sweep delay parameter can insert a delay between measurement points. See page 14-196 in the reference manual([3](./references.md)).

![sweeplist function parameters from reference manual](media/manual_sweeplist.png)

### Measure Time and NPLC

The `NPLC` parameter set the amount of time that the input signal is measured. Lower NPLC settings result in faster reading rates, but increased noise. Higher NPLC settings result in lower reading noise, but slower reading rates.

The amount of time is specified in parameters that are based on the number of power line cycles (NPLCs). Each power line cycle for 60 Hz is 16.67 ms (1/60); for 50 Hz, it is 20 ms (1/50).

NPLC can be set to any value from 0.01 to 10, then minimum  measure time for NPLC 0.01 is 200 microseconds (with 50Hz power line) and 167 microseconds (with 60Hz power line)

When source readback is active, two different measurements on current and voltage are performed for each element of the configuration list.

### Sampling Frequency

Running the experiment with NPLC = 0.01 and a source signal with 100mA amplitude, the resulting sampling interval is between 1 and 2 ms with mean value 1.46ms.

