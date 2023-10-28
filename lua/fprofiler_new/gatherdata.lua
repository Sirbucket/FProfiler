local SysTime = SysTime
local tostring = tostring
local ErrorNoHaltWithStack = ErrorNoHaltWithStack
local print = print
local table = table
local table_Empty = table.Empty

local timer = timer
local timer_Simple = timer.Simple
local timer_Create = timer.Create
local timer_Remove = timer.Remove

local debug = debug
local debug_getinfo = debug.getinfo

local CalledTime = 0
local CallCounts = 0
local Recursive = 0
local CollectedTimes = {}

local ToCallFunc
local BenchStart = function()
	CalledTime = SysTime()
	for i=1, number_of_calls_per_bench do
		func()
	end
	CollectedTimes[#CollectedTimes + 1] = SysTime() - CalledTime
	CallCounts = CallCounts + number_of_calls_per_bench
end

local BenchEnd = function()
	timer_Remove("FProfilerBench."..tostring(ToCallFunc))
	local times = #CollectedTimes
	local timetotal = 0
	for i=1, times do
		time = CollectedTimes[i]
		timetotal = timetotal + time
	end
	local avg_time = timetotal / times

	print("Calls: "..CallCounts.."\nTotal Time: "..timetotal.."\nAverage Time: "..avg_time)

	CalledTime = 0
	CallCounts = 0
	table_Empty(CollectedTimes)
end

function FProfilerBench(time_to_bench_for, frequency, number_of_calls_per_bench, func)
	local info = debug_getinfo(func)
	if not info then
		ErrorNoHaltWithStack("INVALID FUNCTION: "..tostring(func))
		return
	end
	ToCallFunc = func
	timer_Create("FProfilerBench."..tostring(ToCallFunc), frequency, 0, BenchStart)
	timer_Simple(time_to_bench_for, BenchEnd)
end