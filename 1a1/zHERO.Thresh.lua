local ScriptVersion = "v2.0"

local Q = { Range = 1050, Delay = 0.50, Speed = 1200, Width = 70}
local W = { Range = 950, Delay = 0.25}
local E = { Range = 400, Delay = 0.25, Speed = 1100}
local R = { Range = 320, Delay = 0.25}
local Qicon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/d/d5/Death_Sentence.png"
local Wicon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/4/44/Dark_Passage.png"
local Eicon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/7/71/Flay.png"
local Ricon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/c/c1/The_Box.png"

local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0 
end

local function EnemiesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local m = Game.Hero(i)
		if m and m.team == 200 and not m.dead and m.pos:DistanceTo(pos, m.pos) < 125 then
			Count = Count + 1
		end
	end
	return Count
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local sqrt = math.sqrt

local function GetDistanceSqr(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    return (dx * dx + dz * dz)
end

local function GetDistance(p1, p2)
    return sqrt(GetDistanceSqr(p1, p2))
end

local function GetDistance2D(p1,p2)
    return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end

local function ClosestToMouse(p1, p2) 
	if GetDistance(mousePos, p1) > GetDistance(mousePos, p2) then return p2 else return p1 end
end

local function AlliesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local m = Game.Hero(i)
		if m and m.team == 100 and not m.dead and m.pos:DistanceTo(pos, m.pos) < 600 then
			Count = Count + 1
		end
	end
	return Count
end

local function GetTarget(range)
	local target = nil
	if Orb == 1 then
		target = EOW:GetTarget(range)
	elseif Orb == 2 then
		target = _G.SDK.TargetSelector:GetTarget(range)
	elseif Orb == 3 then
		target = GOS:GetTarget(range)
	end
	return target
end

local intToMode = {
   	[0] = "",
   	[1] = "Combo",
   	[2] = "Harass",
   	[3] = "LastHit",
   	[4] = "Clear"
}

local function GetMode()
	if Orb == 1 then
		return intToMode[EOW.CurrentMode]
	elseif Orb == 2 then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "LastHit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		end
	else
		return GOS.GetMode()
	end
end

local _OnVision = {}
function OnVision(unit)
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end

local visionTick = GetTickCount()
function OnVisionF()
	if GetTickCount() - visionTick > 100 then
		for i,v in pairs(GetEnemyHeroes()) do
			OnVision(v)
		end
	end
end

local _OnWaypoint = {}
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

local function GetPred(unit, speed, delay)
	local speed = speed or math.huge
	local delay = delay or 0.25
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
		local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
		local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
		if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	else
		if unitSpeed > unit.ms then
			local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		elseif IsImmobileTarget(unit) then
			return unit.pos
		else
			return unit:GetPrediction(speed,delay)
		end
	end
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}

local function CustomCast(spell, pos, delay)
	if pos == nil then return end
	if _G.EOWLoaded or _G.SDK then
		Control.CastSpell(spell, pos)
	elseif _G.GOS then
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
		end
		if castSpell.state == 1 then
			if ticker - castSpell.tick < Game.Latency() then
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				castSpell.casting = ticker + delay
				DelayAction(function()
					if castSpell.state == 1 then
						Control.SetCursorPos(castSpell.mouse)
						castSpell.state = 0
					end
				end, Game.Latency()/1000)
			end
			if ticker - castSpell.casting > Game.Latency() then
				Control.SetCursorPos(castSpell.mouse)
				castSpell.state = 0
			end
		end
	end
end

local function EnableOrb(bool)
	if Orb == 1 then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif Orb == 2 then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
end

local function EnableAttack(bool)
	if Orb == 1 then
		EOW:SetAttacks(bool)
	elseif Orb == 2 then
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockAttack = not bool
	end
end

class "Thresh"

function Thresh:__init()
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	end
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Thresh:LoadMenu()
	Tocsin = MenuElement({type = MENU, id = "ThreshTocsin", name = "Thresh"})
	Tocsin:MenuElement({name = "Thresh", drop = {ScriptVersion}})
	
	--Combo

	Tocsin:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	Tocsin.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true})
	Tocsin.Combo:MenuElement({id = "W", name = "Use [W]", value = true})
	Tocsin.Combo:MenuElement({id = "E", name = "Use [E]", value = true})
	Tocsin.Combo:MenuElement({id = "Key", name = "Toggle: E Push-Pull Key", key = string.byte("T"), toggle = true})
	Tocsin.Combo:MenuElement({id = "R", name = "Use [R]", value = true})
	Tocsin.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})

	--Harass

	Tocsin:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	Tocsin.Harass:MenuElement({id = "Q", name = "Use [Q]", value = false})
	Tocsin.Harass:MenuElement({id = "E", name = "Use [E]", value = false})
	Tocsin.Harass:MenuElement({id = "Mana", name = "Min Mana to Harass [%]", value = 0.30, min = 0.05, max = 1, step = 0.01})

	--Flee
	Tocsin:MenuElement({type = MENU, id = "Flee", name = "Flee or YOLO"})
	Tocsin.Flee:MenuElement({id = "E", name = "Use [E]", value = false})
	Tocsin.Flee:MenuElement({id = "W", name = "Use [W]", value = false})

	--Draw

	Tocsin:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	Tocsin.Draw:MenuElement({id = "Q", name = "Draw [Q] Range", value = false})
	Tocsin.Draw:MenuElement({id = "Push", name = "Push Toggle", value = false})
end

function Thresh:Tick()
	if myHero.dead then return end
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Flee" then
		self:Flee()
	end
end

function Thresh:Combo()
	local target = GetTarget(1150, "AD")
	if not target then return end
	if Tocsin.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < 1075 and myHero.pos:DistanceTo(target.pos) > 300 then
		self:CastQ(target)
	end
	if Tocsin.Combo.R:Value() and Ready(_R) and myHero.pos:DistanceTo(target.pos) < 320 then
		self:CastR(target)
	end
	if Tocsin.Combo.W:Value() and Ready(_W) then
		self:CastW(target)
	end
	if Tocsin.Combo.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 420 then
		self:CastE(target)
	end
	
end

function Thresh:Harass()
	local target = GetTarget(950, "AD")
	if myHero.mana/myHero.maxMana < Tocsin.Harass.Mana:Value() then return end
	if not target then return end
	if Tocsin.Harass.E:Value() and Ready(_E) and myHero.pos:DistanceTo(target.pos) < 420 then
		self:CastE(target)
	end
	if Tocsin.Harass.Q:Value() and Ready(_Q) and not Ready(_E) and myHero.pos:DistanceTo(target.pos) > 300 then
		self:CastQ(target)
	end
	if Tocsin.Combo.W:Value() and Ready(_W) and not Ready(_Q) and not Ready(_E) then
		self:CastW(target)
	end
end

function Thresh:Flee()
	local target = GetTarget(650, "AD")
	if not target then return end
	if myHero.pos:DistanceTo(target.pos) < 550 then
		EnableAttack(false)
		if Tocsin.Flee.E:Value() and Ready(_E) then
			if myHero.pos:DistanceTo(target.pos) < 480 then
				local pos = GetPred(target, E.Speed, 0.25 + (Game.Latency()/1000))
				CustomCast(HK_E, pos, 250)
			end
		end
		if Tocsin.Flee.W:Value() and Ready(_W) then
			Control.CastSpell(HK_W)
		end
		EnableAttack(true)
	end
end

function Thresh:CastQ(target)
	if  myHero.pos:DistanceTo(target.pos) < 1075 then
		if Ready(_Q) and ValidTarget(target, 1050) then
        	if target:GetCollision(Q.Width, Q.Speed, Q.Delay) == 0 then
            local pos = GetPred(target, Q.Speed, 0.25 + (Game.Latency()/1000))
			CustomCast(HK_Q, pos, 250)
        	end
    	end
	end
end

function Thresh:CastW(target)
	for i,ally in pairs(self.GetAllyHeroes()) do
		if self:IsValidTarget(ally,950) and myHero.pos:DistanceTo(ally.pos) < 950 then
			if not ally.isMe then
				for i = 1, Game.HeroCount() do
				local hero = Game.Hero(i)
					if hero.team == myHero.team and not hero.isMe and myHero.pos:DistanceTo(target.pos) < 250 then
						if Tocsin.Combo.W:Value() and Ready(_W) and not Ready(_Q) and not ally.isMe then
							EnableOrb(false)
							Control.CastSpell(HK_W,ally)
							EnableOrb(true)
							Control.Attack(target)
						end
					end
				end
			end
		end
	end
end

function Thresh:CastE(target)
	if  myHero.pos:DistanceTo(target.pos) < 420 then
		if Tocsin.Combo.Key:Value() == false then
			local pos = GetPred(target, E.Speed, 0.25 + (Game.Latency()/1000))
			CustomCast(HK_E, myHero.pos:Extended(target.pos, -100), 250)
		end
	end
	if  myHero.pos:DistanceTo(target.pos) < 420 then
		if Tocsin.Combo.Key:Value() == true then
			local pos = GetPred(target, E.Speed, 0.25 + (Game.Latency()/1000))
			CustomCast(HK_E, pos, 250)
		end
	end
end

function Thresh:CastR(target)
	local target = GetTarget(420)
	if self:CountEnemys(420) >= Tocsin.Combo.ER:Value() then
		if not target.dead and not target.isImmune then
			if target.distance <= 320 then
				Control.CastSpell(HK_R)
			end
		end
	end
end

function Thresh:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 400 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function Thresh:GetAllyHeroes()
	local _AllyHeroes
	if _AllyHeroes then return _AllyHeroes end
	_AllyHeroes = {}
	for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly then
      table.insert(_AllyHeroes, unit)
    end
	end
	return _AllyHeroes
end

function Thresh:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 1000 
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function Thresh:Draw()
	if Tocsin.Draw.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, 1050, 3,  Draw.Color(255,255, 162, 000)) end
	if Tocsin.Draw.Push:Value() then
		local textPos = myHero.pos:To2D()
		if Tocsin.Combo.Key:Value() then
			Draw.Text(".", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 000, 255, 000)) 
		else
			Draw.Text("", 20, textPos.x - 33, textPos.y + 60, Draw.Color(255, 225, 000, 000)) 
		end
	end
end

Callback.Add("Load", function()
	if myHero.charName ~= "Thresh" then return end
	if _G[myHero.charName] then
		_G[myHero.charName]()
		print("Tocsin "..myHero.charName.." "..ScriptVersion.." Loaded")
		print("Combo = Q R W aa E aa, Harass = E aa Q W aa")
	else print ("Tocsin doesn't support "..myHero.charName.." shutting down...") return
	end
end)
