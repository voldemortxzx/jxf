IncludeLib("FILESYS")
IncludeLib("TITLE")
IncludeLib("ITEM")
IncludeLib("NPCINFO")
IncludeLib("TIMER")
IncludeLib("SETTING")
IncludeLib("TASKSYS")
IncludeLib("PARTNER")
IncludeLib("BATTLE")
IncludeLib("RELAYLADDER")
IncludeLib("TONG")
IncludeLib("LEAGUE")

Include("\\script\\lib\\remoteexc.lua")
Include("\\script\\lib\\common.lua")
Include("\\script\\lib\\string.lua")
Include("\\script\\lib\\log.lua")
Include("\\script\\lib\\awardtemplet.lua")
--Include("\\script\\lib\\droptemplet.lua")

Include("\\script\\activitysys\\playerfunlib.lua")
Include("\\script\\misc\\eventsys\\type\\npc.lua")
Include("\\script\\dailogsys\\dailogsay.lua")
Include("\\script\\activitysys\\functionlib.lua")
Include("\\script\\activitysys\\npcdailog.lua")
Include("\\script\\global\\titlefuncs.lua")
Include("\\script\\lib\\string.lua")


-- Common Helpers
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\config.lua")
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\libs\\index.lua")

-- Load components FIRST (before sim.core.lua) so they're available in global scope
-- Use dofile directly to ensure files are loaded in global scope
print("[head.lua] Loading components with dofile...")

local ok, err = pcall(dofile, "\\script\\global\\nobitaxd\\vdk\\simcity\\components\\sim.movement.lua")
if not ok then
    print("[head.lua] ERROR loading sim.movement.lua: " .. tostring(err))
else
    print("[head.lua] After sim.movement.lua: SimMovement=" .. tostring(SimMovement))
    print("[head.lua]   SimMovementSys=" .. tostring(SimMovementSys))
end

ok, err = pcall(dofile, "\\script\\global\\nobitaxd\\vdk\\simcity\\components\\sim.fun.lua")
if not ok then
    print("[head.lua] ERROR loading sim.fun.lua: " .. tostring(err))
else
    print("[head.lua] After sim.fun.lua: SimFun=" .. tostring(SimFun))
    print("[head.lua]   SimFunSys=" .. tostring(SimFunSys))
end

ok, err = pcall(dofile, "\\script\\global\\nobitaxd\\vdk\\simcity\\components\\sim.entity.lua")
if not ok then
    print("[head.lua] ERROR loading sim.entity.lua: " .. tostring(err))
else
    print("[head.lua] After sim.entity.lua: SimEntity=" .. tostring(SimEntity))
    print("[head.lua]   SimEntitySys=" .. tostring(SimEntitySys))
end

ok, err = pcall(dofile, "\\script\\global\\nobitaxd\\vdk\\simcity\\components\\sim.fight.lua")
if not ok then
    print("[head.lua] ERROR loading sim.fight.lua: " .. tostring(err))
else
    print("[head.lua] After sim.fight.lua: SimFight=" .. tostring(SimFight))
    print("[head.lua]   SimFightSys=" .. tostring(SimFightSys))
end

-- Plugins first
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\plugins\\index.lua")

-- Data load
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\libs\\data.lua")

-- Now main class (sim_citizen.lua includes sim.core.lua which expects components to be loaded)
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\class\\sim_theosau.lua")
Include("\\script\\global\\nobitaxd\\vdk\\simcity\\class\\sim_citizen.lua")

-- Kick start all plugins if needed
SimCityNgoaiTrang:init()
SimCityNPCInfo:init()
