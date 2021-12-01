reset()
defbuffer1.clear()

local sourceDelay = 0 -- [s]
local delay = 0.01 -- [s]
local nplc = 0.01 -- range from 0.01 to 10 , default 1
local fileName = "sweep_test_RC_load.csv"


-- -------------------------------------
-- SOURCE SETTIGNS

smu.source.func = smu.FUNC_DC_CURRENT
smu.source.range = 100e-3
smu.source.vlimit.level = 20

-- setting for maximum speed 
smu.source.delay=sourceDelay
smu.source.readback = smu.OFF

-- -------------------------------
-- Measure setting

smu.measure.func = smu.FUNC_DC_VOLTAGE
smu.measure.sense=smu.SENSE_4WIRE
smu.measure.range = 10

-- settings for maximum speed
smu.measure.nplc = nplc
smu.measure.autozero.enable = smu.OFF
smu.measure.autozero.once()


smu.source.sweeplog("RES", 100e-6, 10e-3, 10, delay, 1, smu.RANGE_BEST, smu.OFF)
trigger.model.initiate()
waitcomplete()
print(string.format("source delay: %g - Sweep delay: %g - NPLC: %g",sourceDelay,delay,nplc))

--Print Results
if defbuffer1.n == 0 then
	print("Buffer is empty\n")
else
	print("Time,Current,Voltage")
	for i=1,defbuffer1.n do
		print(string.format("%s,%g,%g",defbuffer1.timestamps[i],defbuffer1.sourcevalues[i], defbuffer1.readings[i]))
	end
end

-- save to file

file_num = file.open(fileName,
file.MODE_WRITE)
if file_num != nil then
	print("Time,Current,Voltage")
	for i=1,defbuffer1.n do
		file.write(file_num,string.format("%s,%g,%g",defbuffer1.timestamps[i],defbuffer1.sourcevalues[i], defbuffer1.readings[i]))
	end
	file.close(file_num)
end