TimingWindow = {}

TimingWindow[#TimingWindow+1] = function()
	return {
		Name = "StepMania",
		Timings= {
			['TapNoteScore_W1']=0.0225,
			['TapNoteScore_W2']=0.0450,
			['TapNoteScore_W3']=0.0900,
			['TapNoteScore_W4']=0.1350,
			['TapNoteScore_W5']=0.1800,
			['TapNoteScore_HitMine']=0.0900,
			['TapNoteScore_Attack']=0.1350,
			['TapNoteScore_Hold']=0.2500,
			['TapNoteScore_Roll']=0.5000,
			['TapNoteScore_Checkpoint']=0.1664,
		}
	}
end

TimingWindow[#TimingWindow+1] = function()
	return {
		Name = "DDR Modern",
		Timings = {
			['TapNoteScore_W1']=0.0170, -- Marvelous
			['TapNoteScore_W2']=0.0340, -- Perfect
			['TapNoteScore_W3']=0.0840, -- Great
			['TapNoteScore_W4']=0.1240, -- Good
			['TapNoteScore_HitMine']=0.0900, -- Dunno this value, use Original.
			['TapNoteScore_Attack']=0.1350, -- Dunno this value, use Original.
			['TapNoteScore_Hold']=0.2500, -- Dunno this value, use Original.
			['TapNoteScore_Roll']=0.5000, -- Dunno this value, use Original.
			['TapNoteScore_Checkpoint']=0.1664, -- Dunno this value, use Original.
		}
	}
end

TimingWindow[#TimingWindow+1] = function()
	return {
		Name = "DDR Extreme",
		Timings = {
			['TapNoteScore_W1']=0.0133, -- Marvelous
			['TapNoteScore_W2']=0.0266, -- Perfect
			['TapNoteScore_W3']=0.0800, -- Great
			['TapNoteScore_W4']=0.1200, -- Good
			['TapNoteScore_W5']=0.1666, -- Boo
			['TapNoteScore_HitMine']=0.0900, -- Dunno this value, use Original.
			['TapNoteScore_Attack']=0.1350, -- Dunno this value, use Original.
			['TapNoteScore_Hold']=0.2500, -- Dunno this value, use Original.
			['TapNoteScore_Roll']=0.5000, -- Dunno this value, use Original.
			['TapNoteScore_Checkpoint']=0.1664, -- Dunno this value, use Original.
		}
	}
end

function GetWindowSeconds(TimingWindow, Scale, Add)
	local fSecs = TimingWindow
	fSecs = fSecs * (Scale or 1.0) -- Timing Window Scale
	fSecs = fSecs + (Add or 0) --Timing Window Add
	return fSecs
end

------------------------------------------------------------------------------
-- Timing Call Definitions. -- Dont edit below this line - Jous
------------------------------------------------------------------------------

TimingModes = {}
for i,v in ipairs(TimingWindow) do
	local TW = TimingWindow[i]()
	table.insert(TimingModes,TW.Name)
end

function TimingOrder(TimTab)
	local con = {}
	local availableJudgments = {
		"ProW1","ProW2","ProW3","ProW4","ProW5",
		"W1","W2","W3","W4","W5",
		"HitMine","Attack","Hold","Roll","Checkpoint"
	}
	
	-- Iterate all judgments that are available.
	for k,v in pairs(TimTab) do
		for a,s in pairs( availableJudgments ) do
			if k == ('TapNoteScore_' .. s)  then
				con[ #con+1 ] = {k,v,a}
				break
			end
		end
	end
	
	-- Sort for later use.
	table.sort( con, function(a,b) return a[3] < b[3] end )
	return con
end