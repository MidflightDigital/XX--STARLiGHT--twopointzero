-- Get the actual Timing Window itself.
local TimingMode = LoadModule( "Options.OverwriteTiming.lua" )()
-- Obtain the names of the judgments available from the current TIming window set from the machine.
local Names = LoadModule( "Options.SmartTapNoteScore.lua" )()
-- Sort them up alphabetically, given it could be in the wrong order,
table.sort(Names)
-- Misses are a special kind, given they don't have an actual timing window,
-- so they need to be added manually to the table if you want to perform something with it.
Names[#Names+1] = "Miss"

return { Names = Names, TimingMode = TimingMode }