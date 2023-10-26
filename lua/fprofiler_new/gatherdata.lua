local SysTime = SysTime
local debug = debug
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
		if Recursive <= 0 then return end
	end
end

local EventFunc = function(event)
	OnLuaCalled(event, FuncToCheck, FuncInfo)
end

local function FProfilerStart(func, info)
	FuncToCheck = func
	FuncInfo = info
	InfoName = FuncInfo.func
	debug.sethook(EventFunc, "cr")
end

local function FProfilerStop()
	debug.sethook()

	--ADD NETWORKING HERE

	CalledTime = 0
	CallCounts = 0
end

function FProfilerRun(func, time)
	timer.Simple(time, FProfilerStop)
	local info = debug.getinfo(func)
	FProfilerStart(func, info)
end
