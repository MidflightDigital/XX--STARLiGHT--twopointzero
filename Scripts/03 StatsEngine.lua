--StatsEngine v0.91
--by tertu
--TODO for version 1.0
--1. saving data isn't supported at all
--2. some code cleanup is necessary
--3. I haven't figured out certain things
--[[
Changes since v0.9
*Massive code cleanup
Changes since v0.8
*Optimizations
*Added Offset to the judgment information
*Collect more garbage
--]]
--Cache the modules so they don't have to be loaded from disk again if they were already in memory.
local module_cache = setmetatable({}, {__mode="v"})

--StatsEngine modules are capable of depending on other StatsEngine modules, but don't require
--being pre-sorted by dependency order. So that has to be done at runtime. This is the code that
--does that, using what is apparently called topological sorting.
--The algorithm used is based on Kahn's algorithm as described on the Wikipedia article about
--topological sorting. (https://en.wikipedia.org/wiki/Topological_sorting#Kahn's_algorithm)
local run_order = {}
do

	local success, results = pcall(dofile, THEME:GetPathO("_StatsEngine","Modules"))
	if not success then
		error("StatsEngine: couldn't load modules for dependency resolution: "..results)
	end

	--This list holds all dependencies on other modules.
	local dependencies = {}
	--Free modules are modules that either have no dependencies or only have dependencies that are
	--themselves free. As the algorithm runs, more and more modules are added to this list. In fact,
	--if not every module can be placed in this list, there is a problem and thus the algorithm
	--fails.
	local free_modules = {}
	--This is the output of this algorithm, the order that the modules must be sorted in so that
	--every module has its dependencies satisfied before it is run.
	local sorted_modules = {}
	local module_count = #results
	
	--Pass 1: Find free modules. At this point the only modules we can know are free are modules that
	--don't have any dependencies. The algorithm needs at least one free module to run, so if there are no
	--free modules it fails.
	for i=1,module_count do
		local module_dependencies = results[i].Requires
		if module_dependencies == nil or #module_dependencies == 0 then
			--It doesn't matter what order these modules are run in, so they can all have the same
			--run order value.
			run_order[i] = 0
			dependencies[i] = nil
			free_modules[#free_modules+1] = i
		else
			dependencies[i] = module_dependencies
		end
	end
	
	if #free_modules == 0 then
		error "StatsEngine: at least one module must not depend on any other module"
	elseif #free_modules ~= module_count then --At least one module has a dependency.
		
		--Pass 2: strip away dependencies until there are none.
		--This is done by taking each root, checking each dependency list, and removing that root
		--from the list if it is present. If this causes the dependency list to become empty,
		--that means the module has become a root and can be added to the root list. The algorithm
		--ends when every root has been checked or every module is now a root, whichever comes
		--first.
		local current_free_module = 0
		while current_free_module < #free_modules do
			
			current_free_module = current_free_module + 1
			
			local root_name = results[free_modules[current_free_module]].Name
			sorted_modules[#sorted_modules+1] = current_free_module
			
			for i, dependency_list in pairs(dependencies) do
					
				for j=1,#dependency_list do
					if dependency_list[j] == root_name then
						table.remove(dependency_list, j)
						if #dependency_list == 0 then
							dependencies[i] = nil
							free_modules[#free_modules+1] = i
							break
						end
					end
				end
				
			end
			
		end
		
		--At this point, there should be no more non-free modules. If there are any, that means either there
		--are absent dependencies or there is at least one cycle.
		if next(dependencies) ~= nil then
			--Print every dependency that remains unresolved. Hopefully, this should allow the
			--theme's programmer to determine why the dependency resolution is failing.
			local fmt = "StatsEngine: module %s has unresolved dependencies: %s."
			local joiner = ","
			for i, dependency_list in pairs(dependencies) do
				print(fmt:format(results[i].Name, table.concat(dependency_list, joiner)))
			end
		
			error "StatsEngine: couldn't resolve dependencies. This means there is a cycle or missing dependencies."
		end

		for i=1, module_count do
			run_order[sorted_modules[i]] = i
		end
	end
end
--We don't actually need to keep the modules or anything else from the dependency resolution around
--anymore, so do a garbage collection cycle.
collectgarbage()

function StatsEngine()
	local modules = module_cache.modules

	if not modules then
		--If there is a compile error with this file, just let it happen. That would be a bug.
		modules = dofile(THEME:GetPathO("_StatsEngine","Modules"))
		--The module index is more or less arbitrary, but is sometimes useful to know.
		for i=1,#modules do modules[i].Index = i end
		table.sort(modules, function(a, b) return run_order[a.Index] < run_order[b.Index] end)
		module_cache.modules = modules
	end

	--Just use a bare Actor. The actual actor is not very important at all.
	local output = {Class='Actor'}

	--This will be filled in later.
	local song
	--This will not change during the lifetime of this Actor, so it is fine to get it now.
	local course = GAMESTATE:GetCurrentCourse()

	--This is a list of all of the modules that are currently active for each player.
	local live_modules = {}
	--This holds the per-player module data tables, which are used by the modules to share data
	--with each other and with the host theme.
	local shared_data = {}

	local function InitializeModule(module, player_number, module_index)
		local player_modules = live_modules[player_number]
		local steps = GAMESTATE:GetCurrentSteps(player_number)
		local trail = GAMESTATE:GetCurrentTrail(player_number)

		--Load and start the module.
		--Coroutines are similar to standard functions but can call coroutine.yield to suspend
		--themselves mid-call, leaving their local variables intact. This is handy for code that
		--needs to carry a lot of state, like scoring code does.
		local module_coroutine = coroutine.create(module.Code)
		local success, results = coroutine.resume(module_coroutine, player_number, song, steps, course, trail)

		if not success then
			lua.ReportScriptError("loading StatsEngine module "..module.Name..
			" for player "..ToEnumShortString(player_number).." failed: "..tostring(results))
		elseif coroutine.status(module_coroutine) ~= "dead" then
			player_modules[#player_modules+1] = 
				{name=module.Name, 
				coroutine=module_coroutine, 
				ignore_mines=module.IgnoreMines, 
				ignore_checkpoints=module.IgnoreCheckpoints, 
				course_behavior=module.CourseBehavior, 
				module_index=module_index}
				--That is, for reference:
				--[[
				name: name
				coroutine: the coroutine itself
				ignore_mines: whether to skip running the coroutine for mine hits or misses
				ignore_checkpoints: the same, but for checkpoints
				course_behavior: how the module should behave throughout a course
				module_index: the index of the module in the modules table (needed for reinitializing it)
				]]
		else
			--It's not an error for a module to decide not to load at this point. There are many
			--reasons a module might just not want to load. It could be a bug though, so log it.
			print("StatsEngine: stats module "..module.Name.." decided not to load for player "..ToEnumShortString(player_number))
		end
	end
	
	--This runs the inner loop for each different event that has to be processed.
	local function ProcessEvent(modules_to_process, player_number, event_flags, event_data, 
		module_filter, reload_module)
		local current_shared_table = shared_data[player_number]
		
		--I guess the thought is there is no reason to create the data tables
		--until they are actually needed.
		if current_shared_table == nil then
			shared_data[player_number] = {}
			current_shared_table = shared_data[player_number]
		end
			
		local message_parameters = {Player=player_number, Data=current_shared_table}
		
		if not event_data then 
			event_data = event_flags
		else
			for flag, _ in pairs(event_flags) do
				event_data[flag] = true
				message_parameters[flag] = true
			end
		end

		--This might be needed for multiple modules that run during this event,
		--but it's only needed if an error occurs. Don't bother creating it
		--until it's clearly necessary.
		local event_flag_string
		local any_modules_ran = false
	
		for idx=1,#modules_to_process do
			local module = modules_to_process[idx]
			if module then
				if (module_filter == nil) or module_filter(module, player_number, event_data) then
				
					any_modules_ran = true
					
					local success, results = coroutine.resume(module.coroutine, event_data, current_shared_table)
					if not success then
						if not event_flag_string then
							event_flag_string = ""
							for flag, _ in pairs(event_flags) do
								event_flag_string = event_flag_string .. " " .. flag
							end
						end
						lua.ReportScriptError("error in StatsEngine module "..module.name
						.." for player "..ToEnumShortString(player_number)
						.." (event flags:" .. event_flag_string .. "), unloading: "
						..tostring(results))
						table.remove(modules_to_process, idx)
					else
						if results then
							current_shared_table[module.name] = results
						end
						if reload_module then
							local module_index = module.module_index
							modules_to_process[idx] = InitializeModule(modules[module_index], player_number, module_index)
						end
					end
				end
			end
		end
		
		if any_modules_ran then
			--There is no reason to broadcast this message if there were not any modules that were updated.
			MESSAGEMAN:Broadcast("AfterStatsEngine", message_parameters)
		end
	end
	
	output.JudgmentMessageCommand=function(_, params)
		local player_number = params.Player
		local current_live_modules = live_modules[player_number]
		if current_live_modules == nil then return end

		if shared_data[player_number] == nil then
			shared_data[player_number] = {}
		end

		local module_parameters = {}
		module_parameters.Original = params
		local tns = params.TapNoteScore and ToEnumShortString(params.TapNoteScore) or nil
		local hns = params.HoldNoteScore and ToEnumShortString(params.HoldNoteScore) or nil
		module_parameters.TNS = tns
		module_parameters.HNS = hns
		module_parameters.PSS = STATSMAN:GetCurStageStats():GetPlayerStageStats(player_number)
		module_parameters.Offset = params.TapNoteOffset
		
		local filter = function(module, _, event_data)
			local tns = event_data.TNS

			if module.ignore_mines then
				if tns == 'HitMine' or tns == 'AvoidMine' then
					return false
				end
			end

			if module.ignore_checkpoints then
				if tns == 'CheckpointHit' or tns == 'CheckpointMiss' then
					return false
				end
			end

			return true
		end
		
		local flags = {Judgment=true}
		ProcessEvent(current_live_modules, player_number, flags, module_parameters, filter)
	end
	
	--this command fires off once before gameplay starts. do setup then
	local initialized = false
	output.DoneLoadingNextSongMessageCommand=function()
		song = GAMESTATE:GetCurrentSong()
		
		if not initialized then
			for _, player_number in pairs(GAMESTATE:GetEnabledPlayers()) do
				live_modules[player_number] = {}
				for idx=1,#modules do
					local module = modules[idx]
					if (not course) or module.CourseBehavior~='Disable' then
						InitializeModule(module, player_number, idx)
					end
				end
				if #live_modules[player_number] == 0 then
					live_modules[player_number] = nil
				end
			end

			initialized = true
			return
		end
		
		local next_song_flag = {NextSong=true}
		local finalize_flag = {Finalize=true}
		for player_number, process in pairs(live_modules) do
			ProcessEvent(process, player_number, next_song_flag,
			{Song=song, Steps=GAMESTATE:GetCurrentSteps(player_number)},
			function(module)
				return module.course_behavior == 'PerSong'
			end)
			ProcessEvent(process, player_number, finalize_flag, finalize_flag,
			function(module)
				local mode = module.course_behavior 
				return mode == 'Reset' or mode == 'ResetAndSave'
			end, true)
		end
	end
	
	output.OffCommand=function()
		local flags = {Finalize=true}
		for player_number, player_modules in pairs(live_modules) do
			ProcessEvent(player_modules, player_number, flags)
		end
	end
	
	return output, shared_data
end