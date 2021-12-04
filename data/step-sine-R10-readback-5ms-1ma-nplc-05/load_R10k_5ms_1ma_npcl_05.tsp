

--[[ ============================================================================================================
 __ __  ______  ____  _      ____  ______  __ __      _____  __ __  ____     __ ______  ____  ___   ____   _____
|  |  ||      ||    || |    |    ||      ||  |  |    |     ||  |  ||    \   /  ]      ||    |/   \ |    \ / ___/
|  |  ||      | |  | | |     |  | |      ||  |  |    |   __||  |  ||  _  | /  /|      | |  ||     ||  _  (   \_ 
|  |  ||_|  |_| |  | | |___  |  | |_|  |_||  ~  |    |  |_  |  |  ||  |  |/  / |_|  |_| |  ||  O  ||  |  |\__  |
|  :  |  |  |   |  | |     | |  |   |  |  |___, |    |   _] |  :  ||  |  /   \_  |  |   |  ||     ||  |  |/  \ |
|     |  |  |   |  | |     | |  |   |  |  |     |    |  |   |     ||  |  \     | |  |   |  ||     ||  |  |\    |
 \__,_|  |__|  |____||_____||____|  |__|  |____/     |__|    \__,_||__|__|\____| |__|  |____|\___/ |__|__| \___|
                                                                                                                
--]]

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

--[[  ==========================================================
save table content to file
-- ]]
function saveToFile(dataFileName, samples)
	file_num = file.open(dataFileName,file.MODE_WRITE)
	if file_num != nil then
		i=1
		while samples[i] do
			value = samples[i]
			file.write(file_num,string.format("%g;%g \r\n",i,value))
			i=i+1
		end		
		file.close(file_num)
	end
end

--[[  ===========================================================
print buffer content to console
-- ]]
function printBuffer(sourceLabel,readingLabel)
 if defbuffer1.n == 0 then
	print("Buffer is empty\n")
 else
	print(string.format("Timestamp,%s,%s",sourceLabel,readingLabel))
	for i=1,defbuffer1.n do
		print(string.format("%s,%g,%g",defbuffer1.timestamps[i],defbuffer1.sourcevalues[i], defbuffer1.readings[i]))
	end
 end
end

--[[  ===========================================================
exportBufferToFile content to file
-- ]]
function exportBufferToFile(fileName,sourceLabel,readingLabel)
 file_num = file.open(fileName,file.MODE_WRITE)
 if file_num != nil then
	file.write(file_num,string.format("Timestamp;%s;%s\r\n",sourceLabel,readingLabel))
	
	for i=1,defbuffer1.n do
		file.write(file_num,string.format("%s;%g;%g\r\n",defbuffer1.timestamps[i],defbuffer1.sourcevalues[i], defbuffer1.readings[i]))
	end
	file.close(file_num)
 end
end

--[[  ========================================================================================
Source current and measure voltage.
Current source signal generated from list of values using sweeplist
-- ]]
function doSourceCurrentSweepMeasureVoltage(currentLevels,sourceDelay,nplc,delay,repetition,measureRange,sourceRange)
 reset()
 defbuffer1.clear()

 print("start programming instrument")

--
--Source Settings
--
 smu.source.func = smu.FUNC_DC_CURRENT
 smu.source.readback = smu.ON
 smu.source.vlimit.level = 21
 smu.source.autorange = smu.OFF
 smu.source.range = sourceRange
 smu.source.delay = sourceDelay


--
--Measure Settings
--
 smu.measure.func = smu.FUNC_DC_VOLTAGE
 smu.measure.autorange = smu.OFF
 smu.measure.range = measureRange
 smu.measure.nplc = nplc
 smu.measure.sense=smu.SENSE_4WIRE
 smu.measure.autozero.once()
 
 --
 -- source config list
 --
 smu.source.configlist.create("CurrentListSweep")
 
 for index = 1, table.getn(currentLevels) do
  smu.source.level = currentLevels[index]
  smu.source.configlist.store("CurrentListSweep")
 end

--
-- source sweep on configlist
--
 print(string.format("configure sweeplist current Sweep delay: %g , repetition: %g",delay, repetition))
 smu.source.sweeplist("CurrentListSweep", 1,delay,repetition)

 print("running trigger model ...")

 --Run trigger model and wait for it to complete
 trigger.model.initiate()
 waitcomplete()
 print("trigger model completed")
end



--[[ ===========================================================================================================
  ______                      _                      _     _____                               _                
 |  ____|                    (_)                    | |   |  __ \                             | |               
 | |__  __  ___ __   ___ _ __ _ _ __ ___   ___ _ __ | |_  | |__) |_ _ _ __ __ _ _ __ ___   ___| |_ ___ _ __ ___ 
 |  __| \ \/ / '_ \ / _ \ '__| | '_ ` _ \ / _ \ '_ \| __| |  ___/ _` | '__/ _` | '_ ` _ \ / _ \ __/ _ \ '__/ __|
 | |____ >  <| |_) |  __/ |  | | | | | | |  __/ | | | |_  | |  | (_| | | | (_| | | | | | |  __/ ||  __/ |  \__ \
 |______/_/\_\ .__/ \___|_|  |_|_| |_| |_|\___|_| |_|\__| |_|   \__,_|_|  \__,_|_| |_| |_|\___|\__\___|_|  |___/
             | |                                                                                                
             |_|                                                                                                
--]]


-- experiment parameters
local sourceDelay = 0 -- [s]
local delay = 0.005 -- [s]
local nplc = 0.05 -- range from 0.01 to 10 , default 1
local resultFileNamePrefix = "test_load_R10K_readback_5ms_1ma_autoOFF_nplc_05"
local sourceFilenamePrefix = "generatedCurrent_battery_5ms_1ma_autoOFF_nplc_05"
local sourceLabel = "Current"
local readingLabel = "Voltage"
local repetition = 1
local measureRange = 10 --[V]  The fixed voltage source ranges are  20 mV, 200 mV, 2 V, 20 V, and 200 V.
local sourceRange = 0.001 --[A] The fixed current source ranges are 10 nA, 100 nA, 1 microA, 10 microA, 100 microA, 1 mA, 10 mA, 100 mA, and 1 A

--  sinusoidal waveform parameters
local sampleTime = delay -- output signal sampling period [s]
local A = 0.001 -- current signal amplitude [A]
local po=0.01 -- phase offset
local b = 0 -- DC bias
local signalDuration = 100 -- seconds 100

-- frequency sweep
local sweep = {0.05,0.1,0.2,0.4,1,2,4,10,20,40}

--[[ =========================================================================================================
  __  __          _____ _   _ 
 |  \/  |   /\   |_   _| \ | |
 | \  / |  /  \    | | |  \| |
 | |\/| | / /\ \   | | | . ` |
 | |  | |/ ____ \ _| |_| |\  |
 |_|  |_/_/    \_\_____|_| \_|
                              
--]]

local N= math.floor(signalDuration/sampleTime)
print(string.format("For signal duration %g seconds must be generated %g sample",signalDuration,N))

local sweepIndex =1 -- in lua indexes start from 1
while sweep[sweepIndex] do	
	local freq = sweep[sweepIndex]
	print("generate signal")
	print(string.format("frequency sweep index: %g - freq: %g", sweepIndex,freq))
	
    local currentLevels = generateSinusoidalSignalSampleBased(sampleTime,freq,N,A,po,b)
    
    print("Save current signal  to file")
    local sourceFilename = string.format("%s_%g.csv",sourceFilenamePrefix,freq)
	saveToFile(sourceFilename,currentLevels)
	
	print("doSourceCurrentSweepMeasureVoltage ...")
	doSourceCurrentSweepMeasureVoltage(currentLevels,sourceDelay,nplc,delay,repetition,measureRange,sourceRange)
	print(" doSourceCurrentSweepMeasureVoltage completed")
	sweepIndex=sweepIndex+1	
	
	printBuffer(sourceLabel,readingLabel)
	
	print("saving data to file ...")
	local resultFileName = string.format("%s_%g.csv",resultFileNamePrefix,freq)
    exportBufferToFile(resultFileName,sourceLabel,readingLabel)
    print("saving completed")
end



print(" ______  __ __    ___        ___  ____   ___   ")
print("|      ||  |  |  /  _]      /  _]|    \ |   \  ")
print("|      ||  |  | /  [_      /  [_ |  _  ||    \ ")
print("|_|  |_||  _  ||    _]    |    _]|  |  ||  D  |")
print("  |  |  |  |  ||   [_     |   [_ |  |  ||     |")
print("  |  |  |  |  ||     |    |     ||  |  ||     |")
print("  |__|  |__|__||_____|    |_____||__|__||_____|")
print("                                               ")





