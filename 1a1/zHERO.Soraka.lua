require 'DamageLib'
require 'Eternal Prediction'
require "MapPosition"
local ScriptVersion = "v0.9a"
-- engine --
local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0 
end

local function OnScreen(unit)
	return unit.pos:To2D().onScreen;
end

function MinionsAround(pos, range, team)
    local Count = 0
    for i = 1, Game.MinionCount() do
        local m = Game.Minion(i)
        if m and m.team == team and not m.dead and m.pos:DistanceTo(pos,m.pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

local function HeroesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.team == team and not hero.dead and hero.pos:DistanceTo(pos, hero.pos) < range then
			Count = Count + 1
		end
	end
	return Count
end

function GetBuffs(unit)
	T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(T, Buff)
		end
	end
	return T
end

function HasBuff(unit, buffname, bufftype)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
	if buff.name == buffname and buff.type == bufftype and buff.count > 0 and buff.duration > 0 then 
		return true
	end
	end
	return false
end

local Spells = {["Fiddlesticks"] = {{Key = _W, Duration = 5, KeyName = "W" },{Key = _R,Duration = 1,KeyName = "R" }},
		["VelKoz"] = {{Key = _R, Duration = 1, KeyName = "R", Buff = "VelkozR" }},
		["Warwick"] = {{Key = _R, Duration = 1,KeyName = "R" , Buff = "warwickrsound"}},
		["MasterYi"] = {{Key = _W, Duration = 4,KeyName = "W", Buff = "Meditate" }},
		["Lux"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Janna"] = {{Key = _R, Duration = 3,KeyName = "R",Buff = "ReapTheWhirlwind" }},
		["Jhin"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Xerath"] = {{Key = _R, Duration = 3,KeyName = "R", SpellName = "XerathRMissileWrapper" }},
		["Karthus"] = {{Key = _R, Duration = 3,KeyName = "R", Buff = "karthusfallenonecastsound" }},
		["Ezreal"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Galio"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "GalioIdolOfDurand" }},
		["Caitlyn"] = {{Key = _R, Duration = 2,KeyName = "R" , Buff = "CaitlynAceintheHole"}},
		["Malzahar"] = {{Key = _R, Duration = 2,KeyName = "R" }},
		["MissFortune"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "missfortunebulletsound" }},
		["Nunu"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "AbsoluteZero"  }},
		["TwistedFate"] = {{Key = _R, Duration = 2,KeyName = "R",Buff = "Destiny" }},
		["Shen"] = {{Key = _R, Duration = 2,KeyName = "R",Buff = "shenstandunitedlock" }},
		}

function IsChannelling(unit)
	if not Spells[unit.charName] then return false end
	local result = false
	for _, spell in pairs(Spells[unit.charName]) do
		if unit:GetSpellData(spell.Key).level > 0 and (unit:GetSpellData(spell.Key).name == spell.SpellName or unit:GetSpellData(spell.Key).currentCd > unit:GetSpellData(spell.Key).cd - spell.Duration or (spell.Buff and HasBuff(unit,spell.Buff) > 0)) then
				result = true
				break
		end
	end
	return result
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

local _AllyHeroes
function GetAllyHeroes()
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

local function GetTarget(range)
	local target = nil
	if _G.EOWLoaded then
		target = EOW:GetTarget(range)
	elseif _G.SDK and _G.SDK.Orbwalker then
		target = _G.SDK.TargetSelector:GetTarget(range)
	else
		target = GOS:GetTarget(range)
	end
	return target
end

local function GetMode()
	if _G.EOWLoaded then
		if EOW.CurrentMode == 1 then
			return "Combo"
		elseif EOW.CurrentMode == 2 then
			return "Harass"
		elseif EOW.CurrentMode == 3 then
			return "Lasthit"
		elseif EOW.CurrentMode == 4 then
			return "Clear"
		end
	elseif _G.SDK and _G.SDK.Orbwalker then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			return "Combo"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"	
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			return "Clear"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			return "Lasthit"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
			return "Flee"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_NONE] then
			return "None"
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
		elseif HasBuff(unit,"recall" or "zhonyasringshield" or "willrevive",5 or 11 or 24 or 29 or 31 --[[cc]]) then
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
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
end

--[[local function CastSpell(hotkey,slot,target,predmode)
	local data = { range = myHero:GetSpellData(slot).range, delay = myHero:GetSpellData(slot).delay, speed = myHero:GetSpellData(slot).speed, width = myHero:GetSpellData(slot).width}
	local spell = Prediction:SetSpell(data, predmode, true)
	local pred = spell:GetPrediction(target,myHero.pos)
	if pred and pred.hitChance >= TRS.Pred.Chance:Value() then
		EnableOrb(false)
		Control.CastSpell(hotkey, pred.castPos)
		EnableOrb(true)
	end
end

local function CastMinimap(hotkey,slot,target,predmode)
	local data = { range = myHero:GetSpellData(slot).range, delay = myHero:GetSpellData(slot).delay, speed = myHero:GetSpellData(slot).speed}
	local spell = Prediction:SetSpell(data, predmode, true)
	local pred = spell:GetPrediction(target,myHero.pos)
	if pred and pred.hitChance >= 0.25 then
		Control.CastSpell(hotkey, pred.castPos:ToMM().x,pred.castPos:ToMM().y)
	end
end]]
-- engine --
-- Soraka -- 
class "Soraka"

local SorakaVersion = "v1.0"

function Soraka:__init()
  	self:LoadSpells()
  	self:LoadMenu()
  	Callback.Add("Tick", function() self:Tick() end)
  	Callback.Add("Draw", function() self:Draw() end)
end

function Soraka:LoadSpells()
  	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width, radius = 235 }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Soraka:LoadMenu()
  	TRS = MenuElement({type = MENU, id = "Menu", name = "Soraka"})
	--------- Combo -----------------------------------------
  	TRS:MenuElement({type = MENU, id = "Combo", name = "Combo"})
  	TRS.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true})
  	TRS.Combo:MenuElement({id = "E", name = "Use [E]", value = true})
	--------- Clear -----------------------------------------
  	TRS:MenuElement({type = MENU, id = "Clear", name = "Lane Clear"})
  	TRS.Clear:MenuElement({id = "Q", name = "Use [Q]", value = false})
    TRS.Clear:MenuElement({id = "HQ", name = "Minimum minions to hit by [Q]", value = 4, min = 1, max = 7})
    TRS.Clear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 40, min = 0, max = 100})
	--------- Harass --------------------------------------------
  	TRS:MenuElement({type = MENU, id = "Harass", name = "Harass"})
  	TRS.Harass:MenuElement({id = "Q", name = "Use [Q]", value = false})
  	TRS.Harass:MenuElement({id = "E", name = "Use [E]", value = false})
    	TRS.Harass:MenuElement({id = "Mana", name = "Min mana to Harass (%)", value = 40, min = 0, max = 100})
	--------- Flee ----------------------------------------------
  	TRS:MenuElement({type = MENU, id = "Flee", name = "Flee"})
  	TRS.Flee:MenuElement({id ="Q", name = "Use [Q]", value = false})
  	TRS.Flee:MenuElement({id ="E", name = "Use [E]", value = false})
	--------- Heal------------------------------------------------
  	TRS:MenuElement({type = MENU, id = "Heal", name = "Heal"})
  	TRS.Heal:MenuElement({id = "W", name = "Use [W]", value = true})
  	TRS.Heal:MenuElement({id = "Health", name = "Min Soraka Health (%)", value = 45, min = 5, max = 100})
	for i,ally in pairs(GetAllyHeroes()) do
	if ally.team == myHero.team and not ally.isMe then
		TRS.Heal:MenuElement({id = ally.networkID, name = ally.charName, value = true})
	end
	end
	TRS.Heal:MenuElement({type = MENU, id = "HP", name = "HP settings"})
	for i = 1,Game.HeroCount() do
	local hero = Game.Hero(i)
	if hero.team == myHero.team and not hero.isMe then
		TRS.Heal.HP:MenuElement({id = hero.networkID, name = hero.charName.." max HP (%)", value = 85, min = 0, max = 100})
	end
	end
	--------- ULT ----------------------------------------------------------------------------
  	TRS:MenuElement({type = MENU, id = "ULT", name = "Ultimate"})
  	TRS.ULT:MenuElement({id = "R", name = "Use [R]", value = false})
  	TRS.ULT:MenuElement({id = "Health", name = "Max Soraka Health (%)", value = 20, min = 0, max = 100})
	for i,ally in pairs(GetAllyHeroes()) do
	if not ally.isMe then
		TRS.ULT:MenuElement({id = ally.networkID, name = ally.charName, value = true})
	end
	end
	TRS.ULT:MenuElement({type = MENU, id = "HP", name = "HP settings"})
	for i,ally in pairs(GetAllyHeroes()) do
	if not ally.isMe then
		TRS.ULT.HP:MenuElement({id = ally.networkID, name = ally.charName.." max HP (%)", value = 15, min = 0, max = 100})
	end
	end
	--------- Killsteal -----------------------------------------------------------------------------
  	TRS:MenuElement({type = MENU, id = "Killsteal", name = "Killsteal"})
  	TRS.Killsteal:MenuElement({id = "Q", name = "Use [Q]", value = true})
  	TRS.Killsteal:MenuElement({id = "E", name = "Use [E]", value = true})                   
	--------- Misc -----------------------------------------------------------------------
  	TRS:MenuElement({type = MENU, id = "Misc", name = "Misc"})
    	TRS.Misc:MenuElement({id = "CCE", name = "Auto [E] if enemy has CC", value = true})
  	TRS.Misc:MenuElement({id = "CancelE", name = "Auto [E] Interrupter", value = true})
	--------- Drawings --------------------------------------------------------------------
  	TRS:MenuElement({type = MENU, id = "Drawings", name = "Drawings"})
  	TRS.Drawings:MenuElement({id = "Q", name = "Draw [Q] range", value = false})
  	TRS.Drawings:MenuElement({id = "E", name = "Draw [E] range", value = false})
  	TRS.Drawings:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
	TRS.Drawings:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 0, 0, 255)})
end

function Soraka:Tick()
	local Mode = GetMode()
	if Mode == "Combo" then
		self:Combo()
	elseif Mode == "Harass" then
		self:Harass()
	elseif Mode == "Clear" then
		self:Clear()
    elseif Mode == "Flee" then
    	self:Flee()
    end
	self:AutoR()
	self:Killsteal()
    self:Heal()
  	self:Misc()
end

function Soraka:CastQ(target)
            local pos = GetPred(target, Q.Speed, 0.25 + (Game.Latency()/1000))
			CustomCast(HK_Q, pos, 250)
end

function Soraka:CastE(target)
            local pos = GetPred(target, E.Speed, 0.25 + (Game.Latency()/1000))
			CustomCast(HK_E, pos, 250)
end
	
function Soraka:Combo()
    local target = GetTarget(900)
    if not target then return end
    if myHero.pos:DistanceTo(target.pos) < 800 and TRS.Combo.Q:Value() and Ready(_Q) then
        self.CastQ(target)
    end
    if myHero.pos:DistanceTo(target.pos) < 900  and TRS.Combo.E:Value() and Ready(_E) then
        self.CastE(target)
    end
end

function Soraka:Clear()
	if TRS.Clear.Q:Value() == false then return end
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
      	if myHero.pos:DistanceTo(minion.pos) < 800 and Ready(_Q) and myHero.mana/myHero.maxMana > TRS.Clear.Mana:Value() then
		if MinionsAround(minion.pos,235,200 or 300) >= TRS.Clear.HQ:Value() and Ready(_Q) then
			Control.CastSpell(HK_Q,minion.pos)
			return
		end
	end
	end
end

function Soraka:Harass()
	local target = GetTarget(925)
	if not target then return end
    if myHero.pos:DistanceTo(target.pos) < 800 and (myHero.mana/myHero.maxMana > TRS.Harass.Mana:Value() / 100) and TRS.Harass.Q:Value() and Ready(_Q) then
        self.CastQ(target)
    end
    if myHero.pos:DistanceTo(target.pos) < 925 and (myHero.mana/myHero.maxMana > TRS.Harass.Mana:Value() / 100) and TRS.Harass.E:Value() and Ready(_E) then
        self.CastE(target)
    end
end

function Soraka:Flee()
	local target = GetTarget(925)
  	if not target then return end
    if myHero.pos:DistanceTo(target.pos) < 800 and TRS.Flee.Q:Value() and Ready(_Q) then
        self.CastQ(target)
    end
    if myHero.pos:DistanceTo(target.pos) < 925  and TRS.Flee.E:Value() and Ready(_E) then
        self.CastE(target)
    end
	for i,ally in pairs(GetAllyHeroes()) do
		if not ally.isMe then
			if HeroesAround(myHero.pos,550,100) > 0 then
				if myHero.pos:DistanceTo(ally.pos) < 550 and HasBuff(myHero, "sorakaqregen") and Ready(_W) and (myHero.helth/myHero.maxHealth >= 60 / 100 ) then
					if	(self:CountEnemies(ally.pos,500) > 0) and not ally.isMe then
						Control.CastSpell(HK_W,ally)
					end
				end
			end
		end
	end
end

function Soraka:Heal()
  if TRS.Heal.W:Value() == false then return end
	for i,ally in pairs(GetAllyHeroes()) do
	if Ready(_W) and not ally.isMe and not ally.dead then
	if myHero.pos:DistanceTo(ally.pos) < 550 and TRS.Heal[ally.networkID]:Value() --[[and not MapPosition:inBase(ally.pos)]] then
	if (ally.health/ally.maxHealth <= TRS.Heal.HP[ally.networkID]:Value() / 100) and (myHero.health/myHero.maxHealth >= TRS.Heal.Health:Value() / 100) --[[and (ally.health + 50 + myHero:GetSpellData(_W).level * 30 + 0.6 * myHero.ap > ally.maxHealth) and not HasBuff(myHero,"recall")]] and not ally.dead then -- thanks Raine
		Control.CastSpell(HK_W,ally.pos)
		return
	end
	end
	end
	end
end

function Soraka:AutoR()
  	if TRS.ULT.R:Value() == false then return end
	for i,ally in pairs(GetAllyHeroes()) do
		if not ally.isMe and not ally.dead then
			if TRS.ULT[ally.networkID]:Value() and Ready(_R) and (ally.health/ally.maxHealth <= TRS.ULT.HP[ally.networkID]:Value() / 100) --[[and not MapPosition:inBase(hero.pos)]] then
			if (HeroesAround(ally.pos,800,200) > 0) then
			Control.CastSpell(HK_R)	
--			return
			end
			end
		else if (myHero.health/myHero.maxHealth <= TRS.ULT.Health:Value() / 100) and Ready(_R) and (HeroesAround(myHero.pos,800,200) > 0) and not myHero.dead then
			Control.CastSpell(HK_R)
--			return
			end
		end
		end
end
  
function Soraka:Misc()
	for i = 1, Game.HeroCount() do
	local hero = Game.Hero(i)
		if hero and hero.isEnemy and myHero.pos:DistanceTo(hero.pos) < 925 then
			if Ready(_E) and hero.isChanneling--[[IsChannelling(hero)]] and TRS.Misc.CancelE:Value() then
				  self.CastE(hero)
			end
			if Ready(_E) and HasBuff(hero,"recall" or "zhonyasringshield" or "willrevive",5 or 11 or 24 or 29 or 31 --[[cc]]) and TRS.Misc.CCE:Value() then
				  self.CastE(hero)
			end
		end
	end
end

function Soraka:Killsteal()
	local target = GetTarget(925)
    if not target then return end 
  	if myHero.pos:DistanceTo(target.pos) < 925 and TRS.Killsteal.E:Value() and Ready(_E) then
    	local Edamage = CalcMagicalDamage(myHero, target, (30 + 40 * myHero:GetSpellData(_E).level + 0.4 * myHero.ap))
	if Edamage > target.health then
		CastSpell(HK_E,_E,target,TYPE_CIRCULAR)
		return
	end
	end
	if myHero.pos:DistanceTo(target.pos) < 800 and TRS.Killsteal.Q:Value() and Ready(_Q) then
    	local Qdamage = CalcMagicalDamage(myHero, target, (30 + 40 * myHero:GetSpellData(_Q).level + 0.35 * myHero.ap))
	if 	Qdamage > target.health then
  		CastSpell(HK_Q,_Q,target,TYPE_CIRCULAR)
		return
	end
    end
end

function Soraka:Draw()
	if myHero.dead then return end
	if TRS.Drawings.Q:Value() then Draw.Circle(myHero.pos, 800, TRS.Drawings.Width:Value(), TRS.Drawings.Color:Value())
	end
	if TRS.Drawings.E:Value() then Draw.Circle(myHero.pos, 925, TRS.Drawings.Width:Value(), TRS.Drawings.Color:Value())	
	end	
end
    
Callback.Add("Load", function()
	if not _G.Prediction_Loaded then return end
	if _G[myHero.charName] then
		_G[myHero.charName]()
		print("")
	else print ("") return
	end
end)
