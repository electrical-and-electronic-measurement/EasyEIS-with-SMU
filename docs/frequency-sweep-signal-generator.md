# Frequency Sweep generator

Frequency sweep step calculation function

```lua
function generateFreqSweep(freqSweepStart,freqSweepStop,freqSweepStep)
 local freqSweep = {}
 local next = freqSweepStart
 local fIndex = 0
 
 while next <= freqSweepStop do
   freqSweep[fIndex] = next
   next = next+freqSweepStep
   fIndex = fIndex+1
 end
 return freqSweep
end
```

Frequency sweep generation sample:

```lua

local freqSweepStart = 0.1
local freqSweepStop = 0.2
local freqSweepStep = 0.1

local currentLevels = {}
local signalSampleIndex=0

local stepN = math.floor((freqSweepStop - freqSweepStart)/freqSweepStep)
print("Frequency sweep. start: %g, stop: %g , step: %g",freqSweepStart,freqSweepStop,freqSweepStep)
local sweep = generateFreqSweep(freqSweepStart,freqSweepStop,freqSweepStep)

for sweepIndex=0,stepN do
 local freq = sweep[sweepIndex]
 local generatedSignal = generateSinusoidalSignal(sampleTime,freq,A,po,b)
 for i, value in generatedSignal do
   currentLevels[signalSampleIndex]= value
   signalSampleIndex = signalSampleIndex+1
  end
end
```
