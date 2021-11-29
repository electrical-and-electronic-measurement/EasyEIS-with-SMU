# Electrochemical impedance spectroscopy (EIS) on batteries with Keithley 2450

This project aims to perform a Electrochemical impedance spectroscopy (EIS) on a Li-Ion rechargeable battery using the Keithley 2450 Source Measure Unit (SMU) Instrument. Even the EIS is not among the applications listed in the official documentation,  the features of the instrument allow to perform the impedance measurement up to 100Hz.

The measurement of battery impedance is crucial for online monitoring of State of Charge and State of Health [(1)](docs/references.md#1). Lab measurements with Keithley 2450 can be used as benchmark to validate data from custom build impedance monitoring system such as [(2)](docs/references.md#2)

## Programming Keithley 2450

Keithley  2450 can be operated using one the supported remote command interface, loading and running a script locally with the  _Script Manager_ or from the front panel interface. The Script Manager can save, load and execute script files from an external storage unit connected to the USB port or from the internal memory.

## The Test Script Processor (TSP®)

The Test Script Processor (TSP®) scripting engine is a Lua interpreter. In TSP-enabled instruments, the Lua programming language has been extended with Keithley-specific instrument control commands.

Lua is an efficient general purpose scripting language with simple syntax and a complete functionality set supported by an active community of developer and with a rich ecosystem of open source libraries.

TSP allows to control every features of the instrument while using standard while using standard programming commands to control script execution such as variables, functions, conditional branching, and loop control.

The main limit of TSP is that all code should reside in a single file named `*.tsp`. File with extension. `.lua` can not be executed form _Script Manager_ and external file can not be loaded at runtime using the `import <module name>` syntax. There is no easy way to add functionality loading external module from one of the many Lua open source repositories.

## How To Perform an EIS on Keithley 2450 with TSP

Single-Sine [EIS measurements](docs/electrochemical-Impedance-spectroscopy.md) involve applying a sinusoidal perturbation (voltage or current) at different frequencies and measuring the response (current or voltage respectively). A 50mA sinusoidal source current signal has been used for this experiment and voltage across DUT has been meaured with a four wire measurement configuration.

The TSP script that get the data to perform EIS computation include four main steps

1. set experiment parameters values (such as measure and source range, delay, signal amplitude, nplc)
2. generate discrete time source signal samples
3. init configuration list with generaterd source current and measurement settings
4. perform the source sweep and measure current and voltage for every configuration of the list
5. export data to file

### Step1: Experiments parameters

Source parameters must be set before the creation of the source configuration list.

For impedence estimation a current imput signal is sourced and a voltage on DUT terminals is measured. In order to achive the maximum speed autorange is turned off.

**source settings**:

```lua
 smu.source.func = smu.FUNC_DC_CURRENT
 smu.source.readback = smu.ON
 smu.source.vlimit.level = 21 -- [V]
 smu.source.autorange = smu.OFF
 smu.source.range = 0.1 --[A]
 smu.source.delay = 0 -- [s]
```

`smu.source.readback = smu.ON` mean that the output of the measure will include the measured source singal levels while with `smu.source.readback = smu.OFF` the programmed value is used. The source signal measure is executed immidiatly before the measure signal measuremnt. This additional measure require some time and increase the overall time required for each messuremt.

`smu.source.autorange = smu.OFF` disables the autorange function to avoid delay during range changes. A fixed `smu.source.range = 0.010` is therfore used.

`smu.source.delay=0` allow to control the delay between two measures only with `delay` paramer `function`.

**Measure settings:**

In order to achive the maximum speed the minimum nplc value is chosen, autorange is turned off  and autozero executed only once.

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

### Step2: Generate Sinusoidal current source signal

The programmable current source API lack a native function for sinusoidal signal generation so we had to approximate the waveform defining configuration list with current values from a sampled sinusoidal signal generated with `math.sin()` function available in TSP.

The _sweeplist_ function allow to iterate over a list of source configuration and perform a measure for each item of the list.

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

### Step3: Init configuration List

A configuration list is a list of stored settings for the source or measure function. On Keintly 2450 a _Configuration list_ can store a up to of 300,000 _configuration indexes_  

Each _configuration index_ contains a copy of all instrument source and measure settings such as:

- source/measure function setting
- NPLC
- source range
- measure range
- autorange
- autozero
- display digit

The current `smu.source.level` value is replaced with value from generated sinusoidal current signal.

```Lua
 smu.source.configlist.create("CurrentListSweep")
 
 for index = 1, table.getn(currentLevels) do
  smu.source.level = currentLevels[index]
  smu.source.configlist.store("CurrentListSweep")
 end

 smu.source.sweeplist("CurrentListSweep", 1,delay,repetition)
```

### Step4: perform measure

After configuration list is creared a new trigger is fired and wait for completation. 

```Lua
 trigger.model.initiate()
 waitcomplete()

```

Data aquired during sweep operation are saved to a memory buffer

### Step5: export data to file

All data in memory buffer are formatted in CSV and exported in file in the storage device conneted to USB port.

## Data acquisition sampling frequency

The time interval between two consecutive measure is the sum of four element:

 1. Trigger Latency
 2. Explict source delay or implicit source autodelay
 3. Measure time
 4. Sweep delay

All but trigger latency can be influenced by user configurable parameters.

![Source delay - time diagram from Reference Manual p.4-46](../media/manual_source_delay.png)

### Source Delay and Autodelay

The programmable current source will tak some time to reach next set point. The ammount of delay is controllerd by `smu.source.delay` parameter.

If no explict source delay is set (`smu.source.delay=0`) an autodelay will be inserted by the firmware, based on target value end load type. (see table on page 4-46 in the reference manual([3](./references.md)).

#### Sweep Delay

The `smu.source.sweeplist()` function has many parameters to customize the sweep. The sweep delay paramer can be used to insert a delay beetween measurement points. See page 14-196 iun the reference manual([3](./references.md)).

![sweeplist function parameters from reference manual](../media/manual_sweeplist.png)

### Measure Time and NPLC

The `NPLC` parameter set the amount of time that the input signal is measured. Lower NPLC settings result in faster reading rates, but increased noise. Higher NPLC settings result in lower reading noise, but slower reading rates.

The amount of time is specified in parameters that are based on the number of power line cycles (NPLCs). Each power line cycle for 60 Hz is 16.67 ms (1/60); for 50 Hz, it is 20 ms (1/50).

NPLC can be set to any value form 0.01 to 10 then minimimin measure time for NPLC 0.01 is 200 microseconds (with 50Hz power line) and 167 microsencods (with 60Hz power line)

When source readback active two different measurement both on current and voltage are performed for each element of the configuration list.

### Samplig Frequency

Running the experiment with NPLC = 0.01 and a source signal with 50mA amplitude, the resulting sampling interval is beetween 1 and 2 ms with mean value 1.46ms.


