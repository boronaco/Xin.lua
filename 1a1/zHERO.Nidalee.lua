if myHero.charName ~= "Nidalee" then return end


--require Nah!!


local Q = { Range = 1500, Delay = 0.25, Speed = 1300, Width = 60}
local W = { Range = 900, Delay = 0.25, Speed = 1400, Width = 40}
local E = { Range = 600, Delay = 0.25}
local QC = { Range = 200, Delay = 0.25}
local WC = { Range = 700, Delay = 0.25} -- extended prey range aka spear or trap
local EC = { Range = 300, Delay = 0.25} --180 cone


local _EnemyHeroes
local function GetEnemyHeroes()
	if _EnemyHeroes then return _EnemyHeroes end
	_EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isEnemy then
			table.insert(_EnemyHeroes, unit)
		end
	end
	return _EnemyHeroes
end

local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0 
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

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
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

function PercentHP(target)
    return 100 * target.health / target.maxHealth
end

function PercentMP(target)
    return 100 * target.mana / target.maxMana
end

local function OnScreen(unit)
	return unit.pos:To2D().onScreen;
end

local function GetTarget(range)
	local target = nil
	if _G.SDK and _G.SDK.Orbwalker then
		target = _G.SDK.TargetSelector:GetTarget(range)
	else
		target = GOS:GetTarget(range)
	end
	return target
end

local function GetMode()
	if _G.SDK and _G.SDK.Orbwalker then
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
		end
	else
		return GOS.GetMode()
	end
end

function HeroesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local minion = Game.Hero(i)
		if minion and minion.team == team and not minion.dead and pos:DistanceTo(minion.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

function MinionsAround(pos, range, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion and minion.team == team and not minion.dead and pos:DistanceTo(minion.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

local HKITEM = {
	[ITEM_1] = HK_ITEM_1,
	[ITEM_2] = HK_ITEM_2,
	[ITEM_3] = HK_ITEM_3,
	[ITEM_4] = HK_ITEM_4,
	[ITEM_5] = HK_ITEM_5,
	[ITEM_6] = HK_ITEM_6,
	[ITEM_7] = HK_ITEM_7,
}


local function Qdmg(target)  --210 / 255 / 300 / 345 / 390 (+ 120% AP) max range dmg
    local level = myHero:GetSpellData(_Q).level
	if Ready(_Q) and myHero:GetSpellData(_Q).name == "JavelinToss" then
    	return CalcMagicalDamage(myHero, target, (165 + 45 * level + 0.60 * myHero.ap))
	end
	return 0
end

local function Wdmg(target)  -- 40 / 80 / 120 / 160 / 200 (+ 20% AP) 」
    local level = myHero:GetSpellData(_W).level
	if Ready(_W) and myHero:GetSpellData(_W).name == "Bushwhack" then
    	return CalcMagicalDamage(myHero, target, (0 + 40 * level + 0.2 * myHero.ap))
	end
	return 0
end

local function QQdmg(target)   -- 
    local level = myHero:GetSpellData(_Q).level
	if Ready(_Q) and myHero:GetSpellData(_Q).name == "Takedown" then
        return CalcMagicalDamage(myHero, target, (14 + 90 * level + 0.75 * myHero.ap + 2.00 * myHero.totalDamage))
	end
	return 0
end

local function WWdmg(target)  --60 / 110 / 160 / 210 (+ 30% AP) 
    local level = myHero:GetSpellData(_W).level
	if Ready(_W) and myHero:GetSpellData(_W).name == "Pounce" then
    	return CalcMagicalDamage(myHero, target, (10 + 50 * level + 0.3 * myHero.ap))
	end
	return 0
end

local function EEdmg(target)   --70 / 130 / 190 / 250 (+ 45% AP)
    local level = myHero:GetSpellData(_E).level
	if Ready(_E) and myHero:GetSpellData(_E).name == "Swipe" then
        return CalcMagicalDamage(myHero, target, (10 + 60 * level + 0.45 * myHero.ap))
	end
	return 0
end
---
local function Idmg(target)
	if (myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1))
	or (myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2)) then
		return 50 + 20 * myHero.levelData.lvl
	end
	return 0
end

local function BSdmg(target)
	if (myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_1))
	or (myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_2)) then
		return 20 + 8 * myHero.levelData.lvl
	end
	return 0
end

local function RSdmg(target)
	if (myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_1))
	or (myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_2)) then
		return 54 + 6 * myHero.levelData.lvl
	end
	return 0
end

local function NoPotion()
	for i = 0, 63 do 
	local buff = myHero:GetBuff(i)
		if buff.type == 13 and Game.Timer() < buff.expireTime then 
			return false
		end
	end
	return true
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

local function CircleCircleIntersection(c1, c2, r1, r2) 
	local D = GetDistance(c1, c2)
	if D > r1 + r2 or D <= math.abs(r1 - r2) then return nil end 
	local A = (r1 * r2 - r2 * r1 + D * D) / (2 * D) 
	local H = math.sqrt(r1 * r1 - A * A)
	local Direction = (c2 - c1):Normalized() 
	local PA = c1 + A * Direction 
	local S1 = PA + H * Direction:Perpendicular() 
	local S2 = PA - H * Direction:Perpendicular() 
	return S1, S2 
end


local Nidalee = MenuElement({type = MENU, id = "NidaleeTocsin", name = "Nidalee"})

Nidalee:MenuElement({id = "Script", name = "Nidalee by Tocsin", drop = {"v1.04"}})
Nidalee:MenuElement({name = " ", drop = {"Champion Settings"}})
Nidalee:MenuElement({type = MENU, id = "C", name = "Combo"})
Nidalee:MenuElement({type = MENU, id = "H", name = "Harass"})
Nidalee:MenuElement({type = MENU, id = "LC", name = "LaneClear"})
Nidalee:MenuElement({type = MENU, id = "JC", name = "JungleClear"})
Nidalee:MenuElement({type = MENU, id = "F", name = "Flee"})
Nidalee:MenuElement({type = MENU, id = "KS", name = "KillSteal"})
Nidalee:MenuElement({name = " ", drop = {"Champion Utility"}})
Nidalee:MenuElement({type = MENU, id = "MM", name = "Mana"})
Nidalee:MenuElement({type = MENU, id = "D", name = "Drawings"})
Nidalee:MenuElement({name = " ", drop = {"Extra Settings"}})
Nidalee:MenuElement({type = MENU, id = "A", name = "Activator"})

Nidalee.C:MenuElement({id = "Q", name = "Q: Javelin Toss", value = true})
Nidalee.C:MenuElement({id = "W", name = "W: Bushwhack", value = true})
Nidalee.C:MenuElement({id = "E", name = "E: Primal Surge", value = true})
Nidalee.C:MenuElement({id = "R", name = "R: Aspect of the Cougar", value = true})

Nidalee.H:MenuElement({id = "Q", name = "Q: Javelin Toss", value = true})
Nidalee.H:MenuElement({id = "W", name = "W: Bushwhack", value = true})
Nidalee.H:MenuElement({id = "E", name = "E: Primal Surge", value = true})

Nidalee.LC:MenuElement({id = "Q", name = "Q: Javelin Toss", value = true})
Nidalee.LC:MenuElement({id = "W", name = "W: Bushwhack", value = true})
Nidalee.LC:MenuElement({id = "E", name = "E: Primal Surge", value = true})
Nidalee.LC:MenuElement({id = "R", name = "R: Aspect of the Cougar", value = true})

Nidalee.JC:MenuElement({id = "Q", name = "Q: Javelin Toss", value = true})
Nidalee.JC:MenuElement({id = "W", name = "W: Bushwhack", value = true})
Nidalee.JC:MenuElement({id = "E", name = "E: Primal Surge", value = true})
Nidalee.JC:MenuElement({id = "R", name = "R: Aspect of the Cougar", value = true})

Nidalee.F:MenuElement({id = "Q", name = "Q: Javelin Toss", value = true})
Nidalee.F:MenuElement({id = "W", name = "W: Bushwhack", value = true})
Nidalee.F:MenuElement({id = "E", name = "E: Primal Surge", value = true})
Nidalee.F:MenuElement({id = "R", name = "R: Aspect of the Cougar", value = true})

Nidalee.KS:MenuElement({id = "Q", name = "Q: Javelin Toss", value = true})
Nidalee.KS:MenuElement({id = "W", name = "W: Bushwhack", value = true})

Nidalee.MM:MenuElement({id = "C", name = "Mana % to Combo", value = 0, min = 0, max = 100})
Nidalee.MM:MenuElement({id = "H", name = "Mana % to Harass", value = 60, min = 0, max = 100})
Nidalee.MM:MenuElement({id = "LC", name = "Mana % to Lane", value = 55, min = 0, max = 100})
Nidalee.MM:MenuElement({id = "JC", name = "Mana % to Jungle", value = 30, min = 0, max = 100})
Nidalee.MM:MenuElement({id = "F", name = "Mana % to Flee", value = 5, min = 0, max = 100})
Nidalee.MM:MenuElement({id = "KS", name = "Mana % to KS", value = 0, min = 0, max = 100})

Nidalee.A:MenuElement({type = MENU, id = "P", name = "Potions"})
Nidalee.A.P:MenuElement({id = "Pot", name = "All Potions", value = true})
Nidalee.A.P:MenuElement({id = "HP", name = "Health % to Potion", value = 60, min = 0, max = 100})
Nidalee.A:MenuElement({type = MENU, id = "I", name = "Items"})
Nidalee.A.I:MenuElement({id = "HEX", name = "Hextech Gunblade", value = true})--Dont think Nidalee uses activation items?? there if it changes in future
Nidalee.A:MenuElement({type = MENU, id = "S", name = "Summoner Spells"})

DelayAction(function()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" then
		Nidalee.A.S:MenuElement({id = "Smite", name = "Smite in Combo [?]", value = true, tooltip = "If Combo will kill"})
		Nidalee.A.S:MenuElement({id = "SmiteS", name = "Smite Stacks to Combo", value = 1, min = 1, max = 2})
	end
end, 2)
DelayAction(function()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
		Nidalee.A.S:MenuElement({id = "Heal", name = "Auto Heal", value = true})
		Nidalee.A.S:MenuElement({id = "HealHP", name = "Health % to Heal", value = 25, min = 0, max = 100})
	end
end, 2)
DelayAction(function()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
		Nidalee.A.S:MenuElement({id = "Barrier", name = "Auto Barrier", value = true})
		Nidalee.A.S:MenuElement({id = "BarrierHP", name = "Health % to Barrier", value = 25, min = 0, max = 100})
	end
end, 2)
DelayAction(function()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
		Nidalee.A.S:MenuElement({id = "Ignite", name = "Ignite in Combo", value = true})
	end
end, 2)
DelayAction(function()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
		Nidalee.A.S:MenuElement({id = "Exh", name = "Exhaust in Combo [?]", value = true, tooltip = "If Combo will kill"})
	end
end, 2)
DelayAction(function()
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" then
		Nidalee.A.S:MenuElement({id = "Cleanse", name = "Auto Cleanse", value = true})
		Nidalee.A.S:MenuElement({id = "Blind", name = "Blind", value = false})
		Nidalee.A.S:MenuElement({id = "Charm", name = "Charm", value = true})
		Nidalee.A.S:MenuElement({id = "Flee", name = "Flee", value = true})
		Nidalee.A.S:MenuElement({id = "Slow", name = "Slow", value = false})
		Nidalee.A.S:MenuElement({id = "Root", name = "Root/Snare", value = true})
		Nidalee.A.S:MenuElement({id = "Poly", name = "Polymorph", value = true})
		Nidalee.A.S:MenuElement({id = "Silence", name = "Silence", value = true})
		Nidalee.A.S:MenuElement({id = "Stun", name = "Stun", value = true})
		Nidalee.A.S:MenuElement({id = "Taunt", name = "Taunt", value = true})
	end
end, 2)
Nidalee.A.S:MenuElement({type = SPACE, id = "Note", name = "Note: Ghost/TP/Flash is not supported"})

Nidalee.D:MenuElement({id = "Q", name = "Q: Javelin Toss", value = true})
Nidalee.D:MenuElement({id = "W", name = "W: Bushwhack", value = true})
Nidalee.D:MenuElement({id = "Dmg", name = "Damage HP bar", value = true})

local _OnVision = {}
function OnVision(unit)
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end

Callback.Add("Tick", function() OnVisionF() Tick() end)
Callback.Add("Draw", function() Drawings() end)

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

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function Tick()
	if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end
    local Mode = GetMode()
	if Mode == "Combo" then
		Combo()
	elseif Mode == "Clear" then
		Lane()
        Jungle()
	elseif Mode == "Harass" then
		Harass()
    elseif Mode == "Flee" then
        Flee()
	end
		Killsteal()
        Summoners()
        Activator()
end

function Combo()
    if Nidalee.MM.C:Value() > PercentMP(myHero) then return end
    local target = GetTarget(1500)
    if target == nil then return end

    if Ready(_Q) and ValidTarget(target, 1450) and myHero:GetSpellData(_Q).name == "JavelinToss" and myHero.pos:DistanceTo(target.pos) < 1450 then
        if Nidalee.C.Q:Value() and target:GetCollision(Q.Width, Q.Speed, Q.Delay) == 0 then
            local pos = GetPred(target, Q.Speed, 0.25 + (Game.Latency()/1000))
			EnableOrb(false)
			CustomCast(HK_Q, pos, 250)
			DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end

    if Ready(_R) and ValidTarget(target, 950) and myHero:GetSpellData(_Q).name == "JavelinToss" then
        if Nidalee.C.R:Value() and myHero.pos:DistanceTo(target.pos) < 800 and ForceCat() then
			Control.CastSpell(HK_R)
        end
    end

	if Ready(_W) and ValidTarget(target, 900) and myHero:GetSpellData(_W).name == "Bushwhack" then
        if Nidalee.C.W:Value() and myHero.pos:DistanceTo(target.pos) < 880 then
            local pos = GetPred(target, W.Speed, 0.25 + (Game.Latency()/1000))
			EnableOrb(false)
			CustomCast(HK_W, pos, 250)
			DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end

	if Ready(_E) and myHero:GetSpellData(_E).name == "PrimalSurge" then
        if Nidalee.C.E:Value() and myHero.health/myHero.maxHealth < .70 then
			Control.CastSpell(HK_E, myHero)
        end
    end

    if Ready(_W) and ValidTarget(target, 700) and myHero:GetSpellData(_W).name == "Pounce" then
        if Nidalee.C.W:Value() and myHero.pos:DistanceTo(target.pos) < 700 then
            local pos = GetPred(target, WC.Speed, 0.25 + (Game.Latency()/1000))
			EnableOrb(false)
			CustomCast(HK_W, pos, 250)
            Control.Attack(target)
			DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end

    if Ready(_Q) and ValidTarget(target, 200) and myHero:GetSpellData(_Q).name == "Takedown" then
        if Nidalee.C.Q:Value() then
			Control.CastSpell(HK_Q)
            Control.Attack(target)
        end
    end
	
    if Ready(_E) and ValidTarget(target, 300) and myHero:GetSpellData(_E).name == "Swipe" then
        if Nidalee.C.E:Value() then
            EnableOrb(false)
			Control.CastSpell(HK_E, target)
            Control.Attack(target)
            DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end

    if Ready(_R) and ValidTarget(target, 1450) and myHero:GetSpellData(_Q).name == "Takedown" then
        if Nidalee.C.R:Value() and myHero.pos:DistanceTo(target.pos) < 1400 and not Ready(_Q) and not Ready(_E) and not Ready(_W) then
			Control.CastSpell(HK_R)
        end
    end

    if Ready(_R) and myHero.health/myHero.maxHealth < .50 then
        if Nidalee.C.R:Value() and myHero.pos:DistanceTo(target.pos) > 700 and myHero:GetSpellData(_Q).name == "Takedown" then
			Control.CastSpell(HK_R)
        end
    end
end

function Lane()
    if Nidalee.MM.LC:Value() > PercentMP(myHero) then return end
    for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
        if minion and minion.team ~= myHero.team then

            if Ready(_R) and ValidTarget(minion, 1150) and myHero:GetSpellData(_Q).name == "Takedown" then
                if Nidalee.LC.R:Value() and myHero.pos:DistanceTo(minion.pos) < 1200 and not Ready(_Q) and not Ready(_E) and not Ready(_W) then
			        Control.CastSpell(HK_R)
                end
            end

            if Ready(_Q) and ValidTarget(minion, 1400) and myHero:GetSpellData(_Q).name == "JavelinToss" then
                if Nidalee.LC.Q:Value() and myHero.pos:DistanceTo(minion.pos) < 1400 then
                    local pos = GetPred(minion, Q.Speed, 0.25 + (Game.Latency()/1000))
					Control.CastSpell(HK_Q, minion)
                end
            end

            if Ready(_W) and ValidTarget(minion, 700) and myHero:GetSpellData(_W).name == "Pounce" then
                if Nidalee.LC.W:Value() and myHero.pos:DistanceTo(minion.pos) < 700 then
                    local pos = GetPred(minion, WC.Speed, 0.25 + (Game.Latency()/1000))
			        EnableOrb(false)
			        CustomCast(HK_W, pos, 250)
                    Control.Attack(minion)
			        DelayAction(function() EnableOrb(true) end, 0.2)
                end
            end

            if Ready(_Q) and ValidTarget(minion, 200) and myHero:GetSpellData(_Q).name == "Takedown" then
                if Nidalee.LC.Q:Value() and myHero.pos:DistanceTo(minion.pos) < 200 then
			        Control.CastSpell(HK_Q)
                    Control.Attack(minion)
                end
            end	

            if Ready(_E) and ValidTarget(minion, 300) and myHero:GetSpellData(_E).name == "Swipe" then
                if Nidalee.LC.E:Value() and myHero.pos:DistanceTo(minion.pos) < 300 then
                    EnableOrb(false)
			        Control.CastSpell(HK_E, minion)
                    Control.Attack(minion)
                    DelayAction(function() EnableOrb(true) end, 0.2)
                end
            end

            if Ready(_R) and ValidTarget(minion, 1150) and myHero:GetSpellData(_Q).name == "JavelinToss" then
                if Nidalee.LC.R:Value() and myHero.pos:DistanceTo(minion.pos) < 1200 and not Ready(_Q) then
			        Control.CastSpell(HK_R)
                end
            end
        end
    end
end

function Jungle()
    if Nidalee.MM.JC:Value() > PercentMP(myHero) then return end
    for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
        if minion and minion.team == 300 then

            if Ready(_R) and ValidTarget(minion, 1150) and myHero:GetSpellData(_Q).name == "Takedown" then
                if Nidalee.JC.R:Value() and myHero.pos:DistanceTo(minion.pos) < 1200 and not Ready(_Q) and not Ready(_E) and not Ready(_W) then
			        Control.CastSpell(HK_R)
                end
            end

            if Ready(_Q) and ValidTarget(minion, 1400) and myHero:GetSpellData(_Q).name == "JavelinToss" then
                if Nidalee.JC.Q:Value() and myHero.pos:DistanceTo(minion.pos) < 1400 then
                    local pos = GetPred(minion, Q.Speed, 0.25 + (Game.Latency()/1000))
                    Control.CastSpell(HK_Q, minion)
                end
            end

            if Ready(_W) and ValidTarget(minion, 700) and myHero:GetSpellData(_W).name == "Pounce" then
                if Nidalee.JC.W:Value() and myHero.pos:DistanceTo(minion.pos) < 700 then
                    local pos = GetPred(minion, WC.Speed, 0.25 + (Game.Latency()/1000))
			        EnableOrb(false)
			        CustomCast(HK_W, pos, 250)
                    Control.Attack(minion)
			        DelayAction(function() EnableOrb(true) end, 0.2)
                end
            end

            if Ready(_Q) and ValidTarget(minion, 300) and myHero:GetSpellData(_Q).name == "Takedown" then
                if Nidalee.JC.Q:Value() and myHero.pos:DistanceTo(minion.pos) < 300 then
			        Control.CastSpell(HK_Q)
                    Control.Attack(minion)
                end
            end

            if Ready(_E) and ValidTarget(minion, 300) and myHero:GetSpellData(_E).name == "Swipe" then
                if Nidalee.JC.E:Value() and myHero.pos:DistanceTo(minion.pos) < 300 then
                    EnableOrb(false)
			        Control.CastSpell(HK_E, minion)
                    Control.Attack(minion)
                    DelayAction(function() EnableOrb(true) end, 0.2)
                end
            end

            if Ready(_R) and ValidTarget(minion, 1150) and myHero:GetSpellData(_Q).name == "JavelinToss" then
                if Nidalee.JC.R:Value() and myHero.pos:DistanceTo(minion.pos) < 1200 and not Ready(_Q) then
			        Control.CastSpell(HK_R)
                end
            end
        end
    end
end

function Harass()
    if Nidalee.MM.H:Value() > PercentMP(myHero) then return end
    local target = GetTarget(1400)
    if target == nil then return end 

	if Ready(_Q) and ValidTarget(target, 1450) and myHero:GetSpellData(_Q).name == "JavelinToss" then
        if Nidalee.H.Q:Value() and target:GetCollision(Q.Width, Q.Speed, Q.Delay) == 0 then
            local pos = GetPred(target, Q.Speed, 0.25 + (Game.Latency()/1000))
			EnableOrb(false)
			CustomCast(HK_Q, pos, 250)
			DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end

    if Ready(_W) and ValidTarget(target, 900) and myHero:GetSpellData(_W).name == "Bushwhack" then
        if Nidalee.H.W:Value() and myHero.pos:DistanceTo(target.pos) < 880 then
            local pos = GetPred(target, W.Speed, 0.25 + (Game.Latency()/1000))
			EnableOrb(false)
			CustomCast(HK_W, pos, 250)
			DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end
end

function Flee()
    if Nidalee.MM.F:Value() > PercentMP(myHero) then return end

    if Ready(_R) and myHero:GetSpellData(_Q).name == "JavelinToss" then
        if Nidalee.F.R:Value() then
			Control.CastSpell(HK_R)
        end
    end

    if Ready(_W) and myHero:GetSpellData(_W).name == "Pounce" then
        if Nidalee.F.W:Value() then
			Control.CastSpell(HK_W)
        end
    end
end

function Killsteal()
    if Nidalee.MM.KS:Value() > PercentMP(myHero) then return end
    local target = GetTarget(Q.Range)

    if Ready(_E) and myHero:GetSpellData(_E).name == "PrimalSurge" then
        if Nidalee.C.E:Value() and myHero.health/myHero.maxHealth < .80 then
			Control.CastSpell(HK_E, myHero)
        end
    end

    if target == nil or myHero.pos:DistanceTo(target.pos) > 1450 then return end
	if Ready(_Q) and ValidTarget(target, Q.Range) then
        if Nidalee.KS.Q:Value() and Qdmg(target) > target.health then
            local pos = GetPred(target, Q.Speed, 0.25 + (Game.Latency()/1000))
			EnableOrb(false)
			CustomCast(HK_Q, pos, 250)
			DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end

    if Ready(_W) and ValidTarget(target, W.Range) then
        if Nidalee.KS.W:Value() and Wdmg(target) > target.health then
            local pos = GetPred(target, W.Speed, 0.25 + (Game.Latency()/1000))
			EnableOrb(false)
			CustomCast(HK_W, pos, 250)
			DelayAction(function() EnableOrb(true) end, 0.3)
        end
    end
end

function ForceCat()
    local target = GetTarget(1000)
	local count = 0
	for i = 0, Game.HeroCount() do
		local hero = Game.Hero(i)
		if myHero.pos:DistanceTo(target.pos) < 800 then
			if hero == nil then return end
			local t = {}
 			for i = 0, hero.buffCount do
    			local buff = hero:GetBuff(i)
    			if buff.count > 0 then
    				table.insert(t, buff)
    			end
  			end
  			if t ~= nil then
  				for i, buff in pairs(t) do
					if buff.name == "NidaleePassiveHunting" and buff.expireTime >= 2 then
						count = count +1
						if Nidalee.C.R:Value() then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function Summoners()
	local target = GetTarget(1200)
    if target == nil then return end
	if GetMode() == "Combo" then

		if myHero:GetSpellData(SUMMONER_1).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" then
			
            if Nidalee.A.S.Smite:Value() then
				local RedDamage = Qdmg(target) + EEdmg(target) + RSdmg(target)
				if myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_1) and RedDamage > target.health
				and myHero:GetSpellData(SUMMONER_1).ammo >= Nidalee.A.S.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
					Control.CastSpell(HK_SUMMONER_1, target)
				elseif myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_2) and RedDamage > target.health
				and myHero:GetSpellData(SUMMONER_2).ammo >= Nidalee.A.S.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
				local BlueDamage = Qdmg(target) + Wdmg(target) + BSdmg(target)
				if myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_1) and BlueDamage > target.health
				and myHero:GetSpellData(SUMMONER_1).ammo >= Nidalee.A.S.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
					Control.CastSpell(HK_SUMMONER_1, target)
				elseif myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_2) and BlueDamage > target.health
				and myHero:GetSpellData(SUMMONER_2).ammo >= Nidalee.A.S.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
			end
		end
		
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
			
            if Nidalee.A.S.Ignite:Value() then
				local IgDamage = Qdmg(target) + EEdmg(target) + Idmg(target)
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and IgDamage > target.health
				and myHero.pos:DistanceTo(target.pos) < 600 then
					Control.CastSpell(HK_SUMMONER_1, target)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_1) and IgDamage > target.health
				and myHero.pos:DistanceTo(target.pos) < 600 then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
			end
		end
		
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
		or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
			
            if Nidalee.A.S.Exh:Value() then
				local Damage = Qdmg(target) + EEdmg(target)
				if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and Ready(SUMMONER_1) and Damage > target.health
				and myHero.pos:DistanceTo(target.pos) < 650 then
					Control.CastSpell(HK_SUMMONER_1, target)
				elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and Ready(SUMMONER_1) and Damage > target.health
				and myHero.pos:DistanceTo(target.pos) < 650 then
					Control.CastSpell(HK_SUMMONER_2, target)
				end
			end
		end
	end
	
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
		
        if Nidalee.A.S.Heal:Value() then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) and PercentHP(myHero) < Nidalee.A.S.HealHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_1) and PercentHP(myHero) < Nidalee.A.S.HealHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end
	
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
		
        if Nidalee.A.S.Barrier:Value() then
			if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and Ready(SUMMONER_1) and PercentHP(myHero) < Nidalee.A.S.BarrierHP:Value() then
				Control.CastSpell(HK_SUMMONER_1)
			elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and Ready(SUMMONER_1) and PercentHP(myHero) < Nidalee.A.S.BarrierHP:Value() then
				Control.CastSpell(HK_SUMMONER_2)
			end
		end
	end
	
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost"
	or myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" then
		
        if Nidalee.A.S.Cleanse:Value() then
			for i = 0, myHero.buffCount do
			local buff = myHero:GetBuff(i);
				if buff.count > 0 then
					if ((buff.type == 5 and Nidalee.A.S.Stun:Value())
					or (buff.type == 7 and  Nidalee.A.S.Silence:Value())
					or (buff.type == 8 and  Nidalee.A.S.Taunt:Value())
					or (buff.type == 9 and  Nidalee.A.S.Poly:Value())
					or (buff.type == 10 and  Nidalee.A.S.Slow:Value())
					or (buff.type == 11 and  Nidalee.A.S.Root:Value())
					or (buff.type == 21 and  Nidalee.A.S.Flee:Value())
					or (buff.type == 22 and  Nidalee.A.S.Charm:Value())
					or (buff.type == 25 and  Nidalee.A.S.Blind:Value())
					or (buff.type == 28 and  Nidalee.A.S.Flee:Value())) then
						if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost" and Ready(SUMMONER_1) then
							Control.CastSpell(HK_SUMMONER_1)
						elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" and Ready(SUMMONER_2) then
							Control.CastSpell(HK_SUMMONER_2)
						end
					end
				end
			end
		end
	end
end

function Activator()
	local target = GetTarget(800)
    if target == nil then return end
	local items = {}
	for slot = ITEM_1,ITEM_6 do
		local id = myHero:GetItemData(slot).itemID 
		if id > 0 then
			items[id] = slot
		end
	end

	local Potion = items[2003] or items[2010] or items[2031] or items[2032] or items[2033]
	if Potion and myHero:GetSpellData(Potion).currentCd == 0 and Nidalee.A.P.Pot:Value() and PercentHP(myHero) < Nidalee.A.P.HP:Value() and NoPotion() then
		Control.CastSpell(HKITEM[Potion])
	end

	if GetMode() == "Combo" then
		local HEX = items[3146] or items[3144]
		if HEX and myHero:GetSpellData(HEX).currentCd == 0 and Nidalee.A.I.HEX:Value() and myHero.pos:DistanceTo(target.pos) < 550 then
			Control.CastSpell(HKITEM[HEX], target.pos)
		end
	end
end

function Drawings()
    if myHero.dead then return end
	if Nidalee.D.Q:Value() and Ready(_Q) then Draw.Circle(myHero.pos, 1500, 3,  Draw.Color(255, 000, 222, 255)) end
    if Nidalee.D.W:Value() and Ready(_W) then Draw.Circle(myHero.pos, 850, 3,  Draw.Color(255, 255, 200, 000)) end
	
	if Nidalee.D.Dmg:Value() then
		for i = 1, Game.HeroCount() do
			local enemy = Game.Hero(i)
			if enemy and enemy.isEnemy and not enemy.dead and enemy.visible then
				local barPos = enemy.hpBar
				local health = enemy.health
				local maxHealth = enemy.maxHealth
				local Qdmg = Qdmg(enemy)
				local Wdmg = Wdmg(enemy)
				local Edmg = EEdmg(enemy)
				local Damage = Qdmg + Wdmg + Edmg
				if Damage < health then
					Draw.Rect(barPos.x + (((health - Qdmg) / maxHealth) * 100), barPos.y, (Qdmg / maxHealth )*100, 10, Draw.Color(170, 000, 222, 255))
					Draw.Rect(barPos.x + (((health - (Qdmg + Wdmg)) / maxHealth) * 100), barPos.y, (Wdmg / maxHealth )*100, 10, Draw.Color(170, 255, 200, 000))
					Draw.Rect(barPos.x + (((health - (Qdmg + Wdmg + Edmg)) / maxHealth) * 100), barPos.y, (Edmg / maxHealth )*100, 10, Draw.Color(170, 246, 000, 255))
				else
    				Draw.Rect(barPos.x, barPos.y, (health / maxHealth ) * 100, 10, Draw.Color(170, 000, 255, 000))
				end
			end
		end
	end
end
