local SeChamps = {"Ryze"}
if not table.contains(SeChamps, myHero.charName) then print("") return end

local SeSeries = MenuElement({type = MENU, id = "SeSeries", name = "SeSeries | "..myHero.charName})
SeSeries:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
SeSeries:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
SeSeries:MenuElement({type = MENU, id = "Ks", name = "KillSteal Settings"})
SeSeries:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})

local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
end

function CountAlliesInRange(point, range)
	if type(point) ~= "userdata" then error("{CountAlliesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
	local range = range == nil and math.huge or range 
	if type(range) ~= "number" then error("{CountAlliesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
	local n = 0
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if unit.isAlly and not unit.isMe and IsValidTarget(unit, range, false, point) then
			n = n + 1
		end
	end
	return n
end

local function CountEnemiesInRange(point, range)
	if type(point) ~= "userdata" then error("{CountEnemiesInRange}: bad argument #1 (vector expected, got "..type(point)..")") end
	local range = range == nil and math.huge or range 
	if type(range) ~= "number" then error("{CountEnemiesInRange}: bad argument #2 (number expected, got "..type(range)..")") end
	local n = 0
	for i = 1, Game.HeroCount() do
		local unit = Game.Hero(i)
		if IsValidTarget(unit, range, true, point) then
			n = n + 1
		end
	end
	return n
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

local _EnemyHeroes
function GetEnemyHeroes()
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

function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end

function GetPercentMP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentMP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.mana/unit.maxMana
end

function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}--
end

local function GetBuffs(unit)
	local t = {}
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.count > 0 then
			table.insert(t, buff)
		end
	end
	return t
end

local function GetDistance(p1,p2)
	return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

function HasBuff(unit, buffname)
	if type(unit) ~= "userdata" then error("{HasBuff}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	if type(buffname) ~= "string" then error("{HasBuff}: bad argument #2 (string expected, got "..type(buffname)..")") end
	for i, buff in pairs(GetBuffs(unit)) do
		if buff.name == buffname then 
			return true
		end
	end
	return false
end

function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

function IsImmune(unit)
	if type(unit) ~= "userdata" then error("{IsImmune}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	for i, buff in pairs(GetBuffs(unit)) do
		if (buff.name == "KindredRNoDeathBuff" or buff.name == "UndyingRage") and GetPercentHP(unit) <= 10 then
			return true
		end
		if buff.name == "VladimirSanguinePool" or buff.name == "JudicatorIntervention" then 
			return true
		end
	end
	return false
end

function IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
	if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
	if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
		return false 
	end 
	return unit.pos:DistanceTo(from.pos and from.pos or myHero.pos) < range 
end

require("DamageLib")

class "Brand"

function Brand:__init()
	print("")
	self.Spells = {
		Q = {range = 1050, delay = 0.25, speed = 1550,  width = 75},
		W = {range = 900, delay = 0.25, speed = math.huge,  width = 187},
		E = {range = 625, delay = 0.25, speed = math.huge},
		R = {range = 750, delay = 0.25, speed = math.huge}
	}
	self:Menu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Brand:Menu()
	SeSeries.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	SeSeries.Combo:MenuElement({id = "W", name = "Use W", value = true})
	SeSeries.Combo:MenuElement({id = "E", name = "Use E", value = true})
	SeSeries.Combo:MenuElement({id = "R", name = "Use R", value = true})

	SeSeries.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
	SeSeries.Harass:MenuElement({id = "W", name = "Use W", value = true})
	SeSeries.Harass:MenuElement({id = "E", name = "Use E", value = true})
	SeSeries.Harass:MenuElement({id = "Mana", name = "Min. Mana (%)", value = 40, min = 0, max = 100, step = 1})

	SeSeries.Ks:MenuElement({id = "Q", name = "Use Q", value = true})
	SeSeries.Ks:MenuElement({id = "W", name = "Use W", value = true})
	SeSeries.Ks:MenuElement({id = "E", name = "Use E", value = true})
	SeSeries.Ks:MenuElement({id = "R", name = "Use R", value = true})

	SeSeries.Draw:MenuElement({id = "Q", name = "Draw Q", value = true})
	SeSeries.Draw:MenuElement({id = "W", name = "Draw W", value = true})
	SeSeries.Draw:MenuElement({id = "E", name = "Draw E", value = true})
	SeSeries.Draw:MenuElement({id = "R", name = "Draw R", value = true})
	SeSeries.Draw:MenuElement({id = "Disabled", name = "Disable All", value = false})
end

function Brand:Tick()
	if myHero.dead then return end

	local target = _G.SDK.TargetSelector:GetTarget(2000)

	if target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		self:Combo(target)
	elseif target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
		self:Harass(target)
	end
	self:KillSteal()
end

function Brand:Combo(target)
	if Ready(_E) and SeSeries.Combo.E:Value() then
		if Ready(_E) and IsValidTarget(target, self.Spells.E.range, true, myHero) then
			Control.CastSpell(HK_E, target)
		end
		if Ready(_Q) and SeSeries.Combo.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
				local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
				if castPos then
					Control.CastSpell(HK_Q, castPos)
				end
			end
		end
		if Ready(_W) and SeSeries.Combo.W:Value() and IsValidTarget(target, self.Spells.W.range, true, myHero) then
			local castPos = target:GetPrediction(self.Spells.W.speed, self.Spells.W.delay)
			if castPos then
				Control.CastSpell(HK_W, castPos)
			end
		end
	elseif Ready(_W) and SeSeries.Combo.W:Value() then
		if Ready(_W) and IsValidTarget(target, self.Spells.W.range, true, myHero) then
			local castPos = target:GetPrediction(self.Spells.W.speed, self.Spells.W.delay)
			if castPos then
				Control.CastSpell(HK_W, castPos)
			end
		end
		if Ready(_Q) and SeSeries.Combo.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
				local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
				if castPos then
					Control.CastSpell(HK_Q, castPos)
				end
			end
		end
	else
		if Ready(_Q) and SeSeries.Combo.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
				local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
				if castPos then
					Control.CastSpell(HK_Q, castPos)
				end
			end
		end
	end
	if SeSeries.Combo.R:Value() and not target.dead and getdmg("R", target, myHero) >= target.health or (CountEnemiesInRange(target, 500) > 1 ) and IsValidTarget(target, self.Spells.R.range, true, myHero) and Ready(_R) then
		Control.CastSpell(HK_R, target)
	end
end

function Brand:Harass(target)
	if (myHero.mana/myHero.maxMana >= SeSeries.Harass.Mana:Value() / 100) then
		if Ready(_E) and SeSeries.Harass.E:Value() then
			if Ready(_E) and IsValidTarget(target, self.Spells.E.range, true, myHero) then
				Control.CastSpell(HK_E, target)
			end
			if Ready(_Q) and SeSeries.Harass.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
				if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
					local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
					if castPos then
						Control.CastSpell(HK_Q, castPos)
					end
				end
			end
			if Ready(_W) and SeSeries.Harass.W:Value() and IsValidTarget(target, self.Spells.W.range, true, myHero) then
				local castPos = target:GetPrediction(self.Spells.W.speed, self.Spells.W.delay)
				if castPos then
					Control.CastSpell(HK_W, castPos)
				end
			end
		elseif Ready(_W) and SeSeries.Harass.W:Value() then
			if Ready(_W) and IsValidTarget(target, self.Spells.W.range, true, myHero) then
				local castPos = target:GetPrediction(self.Spells.W.speed, self.Spells.W.delay)
				if castPos then
					Control.CastSpell(HK_W, castPos)
				end
			end
			if Ready(_Q) and SeSeries.Harass.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
				if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
					local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
					if castPos then
						Control.CastSpell(HK_Q, castPos)
					end
				end
			end
		else
			if Ready(_Q) and SeSeries.Harass.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
				if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
					local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
					if castPos then
						Control.CastSpell(HK_Q, castPos)
					end
				end
			end
		end
	end
end

function Brand:KillSteal()
	for i = 1, Game.HeroCount() do
		local target = Game.Hero(i)
		if SeSeries.Ks.Q:Value() and Ready(_Q) and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			if getdmg("Q", target, myHero) > target.health then
				if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
					local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
					if castPos then
						Control.CastSpell(HK_Q, castPos)
					end
				end
			end
		end
		if SeSeries.Ks.W:Value() and Ready(_W) and IsValidTarget(target, self.Spells.W.range, true, myHero) then
			if getdmg("W", target, myHero) > target.health then
				local castPos = target:GetPrediction(self.Spells.W.speed, self.Spells.W.delay)
				if castPos then
					Control.CastSpell(HK_W, castPos)
				end
			end
		end
		if SeSeries.Ks.E:Value() and Ready(_E) and IsValidTarget(target, self.Spells.E.range, true, myHero) then
			if getdmg("E", target, myHero) > target.health then
				Control.CastSpell(HK_E, target)
			end
		end
		if SeSeries.Ks.R:Value() and Ready(_R) and IsValidTarget(target, self.Spells.R.range, true, myHero) then
			if getdmg("R", target, myHero) > target.health then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end

function Brand:Draw()
	if not myHero.dead then
		if SeSeries.Draw.Disabled:Value() then return end
		if SeSeries.Draw.Q:Value() then
			Draw.Circle(myHero.pos, self.Spells.Q.range, 1, Draw.Color(255, 255, 255, 255))
		end
		if SeSeries.Draw.W:Value() then
			Draw.Circle(myHero.pos, self.Spells.W.range, 1, Draw.Color(255, 255, 255, 255))
		end
		if SeSeries.Draw.E:Value() then
			Draw.Circle(myHero.pos, self.Spells.E.range, 1, Draw.Color(255, 255, 255, 255))
		end
		if SeSeries.Draw.R:Value() then
			Draw.Circle(myHero.pos, self.Spells.R.range, 1, Draw.Color(255, 255, 255, 255))
		end
	end
end

class "Ryze"

function Ryze:__init()
	print("")
	self.Spells = {
		Q = {range = 1000, delay = 0.25, speed = 1700,  width = 55},
		W = {range = 615, delay = 0.25, speed = math.huge},
		E = {range = 615, delay = 0.25, speed = math.huge}
	}
	self:Menu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ryze:Menu()
	SeSeries.Combo:MenuElement({id = "Q", name = "Use Q", value = true})
	SeSeries.Combo:MenuElement({id = "W", name = "Use W", value = true})
	SeSeries.Combo:MenuElement({id = "E", name = "Use E", value = true})
	SeSeries.Combo:MenuElement({id = "Survive", name = "Use Survive Combo", value = false})
	SeSeries.Combo:MenuElement({id = "Health", name = "Min. Health to active Survive Combo", value = 40, min = 0, max = 100, step = 1})

	SeSeries.Harass:MenuElement({id = "Q", name = "Use Q", value = true})
	SeSeries.Harass:MenuElement({id = "W", name = "Use W", value = true})
	SeSeries.Harass:MenuElement({id = "E", name = "Use E", value = true})
	SeSeries.Harass:MenuElement({id = "Mana", name = "Min. Mana (%)", value = 40, min = 0, max = 100, step = 1})

	SeSeries.Ks:MenuElement({id = "Q", name = "Use Q", value = true})
	SeSeries.Ks:MenuElement({id = "W", name = "Use W", value = true})
	SeSeries.Ks:MenuElement({id = "E", name = "Use E", value = true})
	SeSeries.Ks:MenuElement({id = "R", name = "Use R", value = false})

	SeSeries.Draw:MenuElement({id = "Q", name = "Draw Q", value = false})
	SeSeries.Draw:MenuElement({id = "W", name = "Draw W", value = false})
	SeSeries.Draw:MenuElement({id = "E", name = "Draw E", value = false})
	SeSeries.Draw:MenuElement({id = "R", name = "Draw R", value = false})
	SeSeries.Draw:MenuElement({id = "Disabled", name = "Disable All", value = true})
end

function Ryze:Tick()
	if myHero.dead then return end

	local target = _G.SDK.TargetSelector:GetTarget(2000)

	if target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		self:Combo(target)
	elseif target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
		self:Harass(target)
	end
	self:KillSteal()
end

function Ryze:Combo(target)
	if Ready(_Q) and SeSeries.Combo.Q:Value() then
		if Ready(_Q) and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
				local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
				if castPos then
					Control.CastSpell(HK_Q, castPos)
				end
			end
		end
		if Ready(_E) and SeSeries.Combo.E:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero) then
			Control.CastSpell(HK_E, target)
		end
		if Ready(_W) and SeSeries.Combo.W:Value() and IsValidTarget(target, self.Spells.W.range, true, myHero) then
			Control.CastSpell(HK_W, target)
		end
	elseif GetPercentHP(myHero) <= SeSeries.Combo.Health:Value() and SeSeries.Combo.Survive:Value() then
		if Ready(_W) and SeSeries.Combo.W:Value() then
			if Ready(_W) and IsValidTarget(target, self.Spells.W.range, true, myHero) then
				Control.CastSpell(HK_W, target)
			end
		end
		if Ready(_E) and SeSeries.Combo.E:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero) then
			Control.CastSpell(HK_E, target)
		end
		if Ready(_Q) and SeSeries.Combo.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			Control.CastSpell(HK_Q, target)
		end
	elseif SeSeries.Combo.Survive:Value() and Ready(_Q) and SeSeries.Combo.Q:Value() and GetPercentHP(myHero) <= SeSeries.Combo.Health:Value() then
		if Ready(_Q) and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
				local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
				if castPos then
					Control.CastSpell(HK_Q, castPos)
				end
			end
		end
		if Ready(_E) and SeSeries.Combo.E:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero) then
			Control.CastSpell(HK_E, target)
		end
		if Ready(_W) and SeSeries.Combo.W:Value() and IsValidTarget(target, self.Spells.W.range, true, myHero) then
			Control.CastSpell(HK_W, target)
		end
	else 
		if Ready(_E) and SeSeries.Combo.E:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero) then
			Control.CastSpell(HK_E, target)
		end
	end
end

function Ryze:Harass(target)
	if (myHero.mana/myHero.maxMana >= SeSeries.Harass.Mana:Value() / 100) then
		if Ready(_W) and SeSeries.Combo.W:Value() then
			if Ready(_W) and IsValidTarget(target, self.Spells.W.range, true, myHero) then
				Control.CastSpell(HK_W, target)
			end
		end
		if Ready(_E) and SeSeries.Combo.E:Value() and IsValidTarget(target, self.Spells.E.range, true, myHero) then
			Control.CastSpell(HK_E, target)
		end
		if Ready(_Q) and SeSeries.Combo.Q:Value() and IsValidTarget(target, self.Spells.Q.range, true, myHero) then
			Control.CastSpell(HK_Q, target)
		end
	end
end

function Ryze:KillSteal()
	for i = 1, Game.HeroCount() do
		local target = Game.Hero(i)
		if Ready(_W) and IsValidTarget(target, self.Spells.W.range, true, myHero) and SeSeries.Combo.W:Value() then
			if getdmg("W", target, myHero) > target.health then
				Control.CastSpell(HK_W, target)
			end
		end
		if Ready(_E) and IsValidTarget(target, self.Spells.E.range, true, myHero) and SeSeries.Combo.E:Value() then
			if getdmg("E", target, myHero) > target.health then
				Control.CastSpell(HK_E, target)
			end
		end
		if Ready(_Q) and IsValidTarget(target, self.Spells.Q.range, true, myHero) and SeSeries.Combo.Q:Value() then
			if getdmg("Q", target, myHero) > target.health then
				if target:GetCollision(self.Spells.Q.width, self.Spells.Q.speed, self.Spells.Q.delay) == 0 then
					local castPos = target:GetPrediction(self.Spells.Q.speed, self.Spells.Q.delay)
					if castPos then
						Control.CastSpell(HK_Q, castPos)
					end
				end
			end
		end
	end
end

function Ryze:Draw()
	if not myHero.dead then
		if SeSeries.Draw.Disabled:Value() then return end
		if SeSeries.Draw.Q:Value() then
			Draw.Circle(myHero.pos, self.Spells.Q.range, 1, Draw.Color(255, 255, 255, 255))
		end
		if SeSeries.Draw.W:Value() then
			Draw.Circle(myHero.pos, self.Spells.W.range, 1, Draw.Color(255, 255, 255, 255))
		end
		if SeSeries.Draw.E:Value() then
			Draw.Circle(myHero.pos, self.Spells.E.range, 1, Draw.Color(255, 255, 255, 255))
		end
		if SeSeries.Draw.R:Value() then
			Draw.Circle(myHero.pos, myHero:GetSpellData(_R).range, 1, Draw.Color(255, 255, 255, 255))
		end
	end
end

if _G[myHero.charName]() then print("") end
