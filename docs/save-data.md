# Save Data

Write buffer data to CSV file in USB drive

```lua
--[[  ==============================
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
```
