local SysTime = SysTime
local debug = debug
local debug_sethook = debug.sethook
local debug_getinfo = debug.getinfo
local FuncToCheck
local FuncInfo
local InfoFunc
local IsCall = {
	["call"] = true,
	["tail call"] = true
}

local CalledTime = 0
local CallCounts = 0
local Recursive = 0
local CollectedTimes = {}
local function OnLuaCalled(event, func)
	local info2 = debug_getinfo(3, "f")
	if info2.func ~= InfoFunc then return end

	if IsCall[event] then
		Recursive = (Recursive or 0) + 1
		CallCounts = (CallCounts or 0) + 1
		if Recursive == 1 then
			CalledTime = SysTime()
		end
	else
		if Recursive == 1 then
			CollectedTimes[#CollectedTimes + 1] = SysTime() - CalledTime
		end
		Recursive = Recursive - 1
	end
end

local EventFunc = function(event)
	OnLuaCalled(event, FuncToCheck, FuncInfo)
end

local function FProfilerStart(func, info)
	FuncToCheck = func
	FuncInfo = info
	InfoName = FuncInfo.func
	debug_sethook(EventFunc, "cr")
end

local function FProfilerStop()
	debug_sethook()
	local times = #CollectedTimes
	local timetotal = 0
	for i=1, times do
		time = CollectedTimes[i]
		timetotal = timetotal + time
	end
	local avg_time = timetotal / times

	print(
		"Recursive Calls: "..CallCounts.."\n
		Calls: "..times.."\n
		Total Time: "..timetotal.."\n
		Average Time: "..avg_time.."\n
	")

	CalledTime = 0
	CallCounts = 0
	table.Empty(CollectedTimes)
end

function FProfilerRun(func, time)
	timer.Simple(time, FProfilerStop)
	local info = debug.getinfo(func)
	if not info then ErrorNoHaltWithStack("INVALID FUNCTION: "..tostring(func)) end
	FProfilerStart(func, info)
end

function FProfilerBench(time_to_bench_for, frequency, number_of_calls_per_bench, func, ...)
	timer.Create("FProfilerBench."..tostring(func), frequency, 0, function()
		CalledTime = SysTime()
		for i=1, number_of_calls_per_bench do
			func(...)
		end
		CollectedTimes[#CollectedTimes + 1] = SysTime() - CalledTime
	end)
	timer.Simple(time_to_bench_for, function()
		timer.Remove("FProfilerBench."..tostring(func))
		local times = #CollectedTimes
		local timetotal = 0
		for i=1, times do
			time = CollectedTimes[i]
			timetotal = timetotal + time
		end
		local avg_time = timetotal / times

		print("
			Calls: "..times.."\n
			Total Time: "..timetotal.."\n
			Average Time: "..avg_time.."\n
		")

		CalledTime = 0
		CallCounts = 0
		table.Empty(CollectedTimes)
	end)
end
