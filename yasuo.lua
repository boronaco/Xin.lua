class "Common"

function Common:__init()
	
	require("MapPosition")
	
	self.Ally = myHero.team
	self.Enemy = 300 - myHero.team
	self.Neutral = 300
	self.OnAttack = 1
	self.AfterAttack = 2
	self.OnSpell = 3
	self.Callbacks = {
		[self.OnAttack] = {},
		[self.AfterAttack] = {},
		[self.OnSpell] = {}
	}
	
	self.WindingUp = myHero.attackData.state == STATE_WINDUP
	self.Spell = {Casting = myHero.isChanneling, ActiveSpell = myHero.activeSpell, slot = myHero.activeSpellSlot}
	
	self.str = {[-1] = "Passive", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
	
	self.ImmobileBuffs = {
		[5] = true,
		[11] = true,
		[24] = true,
		[29] = true,
		["zhonyasringshield"] = true,
		["willrevive"] = true
	}
	
	Callback.Add("Draw", function() self:Tick() end)
end

function Common:Tick()
	--ProcessAttack Stuff
	local WindingUp = myHero.attackData.state == STATE_WINDUP
	local WindingDown = myHero.attackData.state == STATE_WINDDOWN
	local target = myHero.attackData.target
	if self.WindingUp == false then
		if self.WindingUp ~= WindingUp then
			for _, cb in pairs(self.Callbacks[self.OnAttack]) do
				cb(target)
			end
			self.WindingUp = WindingUp
		end
	--ProcessAfterAttack Stuff
	elseif self.WindingUp == true then
		if WindingDown then
			for _, cb in pairs(self.Callbacks[self.AfterAttack]) do
				cb(target)
			end
			self.WindingUp = WindingUp
		end
	end
	--ProcessSpell Stuff
	local Channeling = myHero.isChanneling
	local ActiveSpell = myHero.activeSpell
	local Slot = myHero.activeSpellSlot
	if Channeling then
		if Channeling ~= self.Spell.Casting or Slot ~= self.Spell.slot then
			for _, cb in pairs(self.Callbacks[self.OnSpell]) do
				cb(myHero, ActiveSpell)
			end
			self.Spell = {Casting = Channeling, ActiveSpell = ActiveSpell, slot = Slot}
		end
	else
		self.Spell = {Casting = Channeling, ActiveSpell = ActiveSpell, slot = Slot}
	end
end

function Common:AddCallback(type, cb)
	table.insert(self.Callbacks[type], cb)
end

function Common:GotBuff(unit, buffName)
	for i = 0, 63 do 
		local Buff = unit:GetBuff(i)
		if Buff and Buff.name ~= "" and Game.Timer() < Buff.expireTime and Buff.count > 0 then
			return Buff.count
		end
	end
	return 0
end

function Common:HasBuffType(unit, buffType)
	for i = 0, 63 do 
		local Buff = unit:GetBuff(i)
		if Buff and Buff.name ~= "" and Game.Timer() >= Buff.startTime and Buff.expireTime < Game.Timer() and Buff.type == buffType then
			return true
		end
	end
	return false
end

function Common:IsImmobile(unit)
	for i = 0, 63 do 
		local Buff = unit:GetBuff(i)
		if Buff and Buff.name ~= "" and Buff.count > 0 then
			if self.ImmobileBuffs[Buff.type] or self.ImmobileBuffs[Buff.name] then
				return Buff.expireTime
			end
		end
	end
	return false
end

function Common:UnderEnemyTurret(pos)
	for i = 1, Game.TurretCount() do
		local t = Game.Turret(i)
		if t and t.team ~= myHero.team and not t.dead and Common:GetDistance(pos, t.pos) <= t.range + (t.boundingRadius * 2) then
			return true
		end
	end
	return false
end

function Common:GetMinionByHandle(handle)
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m.handle == handle then
			return m
		end
	end
end

function Common:GetHeroByHandle(handle)
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h.handle == handle then
			return h
		end
	end
end

function Common:EnemiesAround(pos, range)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and h.isEnemy and not h.dead and Common:GetDistance(pos, h.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

function Common:MinionsAround(pos, range, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == team and not m.dead and Common:GetDistance(pos, m.pos) <= range then
			Count = Count + 1
		end
	end
	return Count
end

function Common:MinionsOnLine(startpos, endpos, width, team)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == team and not m.dead then
			local w = width + m.boundingRadius
			local pointSegment, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(startpos, endpos, m.pos)
			if isOnSegment and self:GetDistanceSqr(pointSegment, m.pos) < w^2 and self:GetDistanceSqr(startpos, endpos) > self:GetDistanceSqr(startpos, m.pos) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function Common:GetBestCircularFarmPos(range, radius)
	local BestPos = nil
	local MostHit = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.isEnemy and not m.dead and self:GetDistance(m.pos, myHero.pos) <= range then
			local Count = self:MinionsAround(m.pos, radius, self.Enemy)
			if Count > MostHit then
				MostHit = Count
				BestPos = m.pos
			end
		end
	end
	return BestPos, MostHit
end

function Common:GetBestLinearFarmPos(range, width)
	local BestPos = nil
	local MostHit = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.isEnemy and not m.dead then
			local EndPos = myHero.pos + (m.pos - myHero.pos):Normalized() * range
			local Count = self:MinionsOnLine(myHero.pos, EndPos, width, self.Enemy)
			if Count > MostHit then
				MostHit = Count
				BestPos = m.pos
			end
		end
	end
	return BestPos, MostHit
end

function Common:GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or myHero.pos
	local dx = Pos1.x - Pos2.x
	local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return dx^2 + dz^2
end

function Common:GetDistance(Pos1, Pos2)
	return math.sqrt(self:GetDistanceSqr(Pos1, Pos2))
end

function Common:GetPercentHP(unit)
	return (unit.health / unit.maxHealth) * 100
end

function Common:GetPercentMP(unit)
	return (unit.mana / unit.maxMana) * 100
end

function Common:Ready(slot)
	return Game.CanUseSpell(slot) == 0
end

function Common:ItemReady(slot)
	return myHero:GetSpellData(slot).currentCd == 0
end

function Common:GetTarget()
	local Closest = math.huge
	local Best
	for i = 1, Game.HeroCount() do
		local H = Game.Hero(i)
		if H.team ~= myHero.team and self:ValidTarget(H) and H.distance < Closest then
			Closest = H.distance
			Best = H
		end
	end
	return Best
end

function Common:ValidTarget(unit, range)
	local range = type(range) == "number" and range or math.huge
	return unit and unit.team ~= myHero.team and unit.valid and unit.distance <= range and not unit.dead and unit.isTargetable and unit.visible
end

function Common:EnemiesAround(pos, range)
	local C = 0
	for i = 1, Game.HeroCount() do
		local H = Game.Hero(i)
		if H.isEnemy and self:ValidTarget(H) and self:GetDistance(H.pos, pos) <= range then
			C = C + 1
		end
	end
	return C
end

function Common:VectorPointProjectionOnLineSegment(v1, v2, v)
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), y = ay + rS * (by - ay)}
	return pointSegment, pointLine, isOnSegment
end

function Common:GetPrediction(unit, spellData)
	local pos = unit.posTo
	local unitpos = unit.pos
	if pos == unitpos or pos.x == 0 or pos.y == 0 or pos.z == 0 or self:IsImmobile(unit) or unit.attackData.state == STATE_WINDUP then
		return self:GetDistance(myHero.pos, unitpos) <= spellData.range and unitpos or false
	end
	local speed = spellData.speed
	local delay = spellData.delay
	local delay = delay + (Game.Latency() * 0.001)
	local WalkDistance = (((Common:GetDistance(myHero.pos, unitpos) / speed) + delay) * unit.ms)
	if self:GetDistance(unitpos, pos) < WalkDistance then
		WalkDistance = self:GetDistance(unitpos, pos)
	end
	local Pred = unitpos + (pos - unitpos):Normalized() * WalkDistance
	local LineSeg = LineSegment(Point(pos), Point(unitpos))
	if MapPosition:intersectsWall(LineSeg) then
		Pred = unitpos + (unit.dir):Normalized() * WalkDistance
	end
	if self:GetDistance(myHero.pos, Pred) > spellData.range then
		return false
	end
	return Pred
end

function Common:GetHeroCollision(StartPos, EndPos, Width, Target)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and h ~= Target and h.isEnemy and Common:ValidTarget(h) then
			local w = Width + h.boundingRadius
			local pointSegment, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(StartPos, EndPos, h.pos)
			if isOnSegment and self:GetDistanceSqr(pointSegment, h.pos) < w^2 and self:GetDistanceSqr(StartPos, EndPos) > self:GetDistanceSqr(StartPos, h.pos) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function Common:GetMinionCollision(StartPos, EndPos, Width, Target)
	local Count = 0
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m ~= Target and not m.isAlly and Common:ValidTarget(m) then
			local w = Width + m.boundingRadius
			local pointSegment, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(StartPos, EndPos, m.pos)
			if isOnSegment and self:GetDistanceSqr(pointSegment, m.pos) < w^2 and self:GetDistanceSqr(StartPos, EndPos) > self:GetDistanceSqr(StartPos, m.pos) then
				Count = Count + 1
			end
		end
	end
	return Count
end

function Common:GetItemSlot(unit, itemID)
	for i = ITEM_1, ITEM_7 do
		if unit:GetItemData(i).itemID == itemID then
			return i
		end
	end
	return 0
end

class "Jinx"

function Jinx:__init()

	self.Menu = MenuElement({id = "Jinx", name = "Jinx", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..myHero.charName..".png"})
	
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "CQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "CW", name = "Use W", value = true})
	
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "HQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "HW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "HMM", name = "Min Mana To Harass", value = 50, min = 0, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Laneclear", name = "Laneclear", type = MENU})
	self.Menu.Laneclear:MenuElement({id = "LCQ", name = "Use Q", value = true})
	self.Menu.Laneclear:MenuElement({id = "LCMM", name = "Min Mana To Laneclear", value = 50, min = 0, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "KSW", name = "Killsteal W", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSR", name = "Killsteal R", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSRR", name = "R Max Range", value = 2500, min = 300, max = 25000, step = 100})
	
	self.Menu:MenuElement({id = "Misc", name = "Misc", type = MENU})
	self.Menu.Misc:MenuElement({id = "ECC", name = "Auto E On CC", value = true})
	
	self.Menu:MenuElement({id = "Draw", name = "Drawings", type = MENU})
	
	self.Menu.Draw:MenuElement({id = "DA", name = "Disable All Drawings", value = false})
	
	self.Menu.Draw:MenuElement({id = "DRocket", name = "Draw Rocket Range", type = MENU})
	self.Menu.Draw.DRocket:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Draw.DRocket:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
	self.Menu.Draw.DRocket:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 0, 0)})
	
	self.Menu.Draw:MenuElement({id = "DMinigun", name = "Draw Minigun Range", type = MENU})
	self.Menu.Draw.DMinigun:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Draw.DMinigun:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
	self.Menu.Draw.DMinigun:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 0, 0, 255)})
	
	self.Menu.Draw:MenuElement({id = "DW", name = "Draw W Range", type = MENU})
	self.Menu.Draw.DW:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Draw.DW:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
	self.Menu.Draw.DW:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
	
	self.Menu.Draw:MenuElement({id = "DE", name = "Draw E Range", type = MENU})
	self.Menu.Draw.DE:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Draw.DE:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
	self.Menu.Draw.DE:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
	
	self.Target = nil
	
	self.Spells = {
		[1] = {range = 1500, delay = 0.6, width = 60, speed = 3300},
		[2] = {range = 900, delay = 0.75, width = 50, speed = math.huge},
		[3] = {range = math.huge, delay = 0.6, width = 140}
	}
	
	self.Damage = {
	[0] = function(unit) return EOW:CalcPhysicalDamage(myHero, unit, (not self:GotMinigun() and myHero.totalDamage * 1.1 or myHero.totalDamage)) end,
	[1] = function(unit) return EOW:CalcPhysicalDamage(myHero, unit, (-40 + (50 * myHero:GetSpellData(_W).level)) + (myHero.totalDamage * 1.4)) end,
	[3] = function(unit) return EOW:CalcPhysicalDamage(myHero, unit, (150 + (100 * myHero:GetSpellData(_R).level)) + (myHero.bonusDamage * 1.5) + ((unit.maxHealth - unit.health) * (0.2 + (0.05 * myHero:GetSpellData(_W).level)))) end
	}
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)

end

function Jinx:Tick()
	self.Target = EOW:GetTarget() or Common:GetTarget()
	
	if EOW:Mode() == "Combo" then
		self:Combo()
	elseif EOW:Mode() == "Harass" then
		self:Harass()
	elseif EOW:Mode() == "LaneClear" then
		self:Laneclear()
	end
	
	self:AutoE()
	
	self:Killsteal()
end

function Jinx:Draw()
	if self.Menu.Draw.DA:Value() then
		return
	end
	
	if self.Menu.Draw.DRocket.Enabled:Value() then
		Draw.Circle(myHero.pos, self:RocketRange(), self.Menu.Draw.DRocket.Width:Value(), self.Menu.Draw.DRocket.Color:Value())
	end
	
	if self.Menu.Draw.DMinigun.Enabled:Value() then
		Draw.Circle(myHero.pos, self:MinigunRange(), self.Menu.Draw.DMinigun.Width:Value(), self.Menu.Draw.DMinigun.Color:Value())
	end
	
	if self.Menu.Draw.DW.Enabled:Value() then
		Draw.Circle(myHero.pos, self.Spells[1].range, self.Menu.Draw.DW.Width:Value(), self.Menu.Draw.DW.Color:Value())
	end
	
	if self.Menu.Draw.DE.Enabled:Value() then
		Draw.Circle(myHero.pos, self.Spells[2].range, self.Menu.Draw.DE.Width:Value(), self.Menu.Draw.DE.Color:Value())
	end
end

function Jinx:Combo()
	if myHero.attackData.state == STATE_WINDUP or not self.Target then
		return
	end
	
	if self.Menu.Combo.CW:Value() and Common:Ready(_W) and Common:ValidTarget(self.Target, self.Spells[1].range) and (Common:GetDistance(myHero.pos, self.Target.pos) > myHero.range or Common:IsImmobile(self.Target)) then
		self:CastW(self.Target)
	end

	if self.Menu.Combo.CQ:Value() and Common:Ready(_Q) then
		local Minigun = self:GotMinigun()
		local MinigunRange = self:MinigunRange()
		local RocketRange = self:RocketRange()
		local Distance = Common:GetDistance(myHero.pos, self.Target.pos)
		if Common:ValidTarget(self.Target, RocketRange) then
			if Minigun then
				if Common:EnemiesAround(self.Target.pos, 230) > 1 or Distance > MinigunRange then
					Order:CastSpell(_Q)
				end
			elseif Distance <= MinigunRange and Common:EnemiesAround(self.Target.pos, 230) == 1 then
				Order:CastSpell(_Q)
			end
		elseif not Minigun and Distance > RocketRange then
			Order:CastSpell(_Q)
		end
	end
end

function Jinx:Harass()
	if myHero.attackData.state == STATE_WINDUP or not self.Target then
		return
	end
	local Minigun = self:GotMinigun()
	if Common:GetPercentMP(myHero) < self.Menu.Harass.HMM:Value() then
		if not Minigun and Common:Ready(_Q) then
			Order:CastSpell(_Q)
		end
		return
	end
	
	if self.Menu.Harass.HW:Value() and Common:Ready(_W) and Common:ValidTarget(self.Target, self.Spells[1].range) and (Common:GetDistance(myHero.pos, self.Target.pos) > myHero.range or Common:IsImmobile(self.Target)) then
		self:CastW(self.Target)
	end
	
	if self.Menu.Harass.HQ:Value() and Common:Ready(_Q) then
		local MinigunRange = self:MinigunRange()
		local RocketRange = self:RocketRange()
		local Distance = Common:GetDistance(myHero.pos, self.Target.pos)
		if Common:ValidTarget(self.Target, RocketRange) then
			if Minigun then
				if Common:EnemiesAround(self.Target.pos, 300) > 1 or Distance > MinigunRange then
					Order:CastSpell(_Q)
				end
			elseif Distance <= MinigunRange and Common:EnemiesAround(self.Target.pos, 300) <= 1 then
				Order:CastSpell(_Q)
			end
		elseif not Minigun and Distance > 1000 then
			Order:CastSpell(_Q)
		end
	end
end

function Jinx:Laneclear()
	if myHero.attackData.state == STATE_WINDUP then
		return
	end
	
	if Common:GetPercentMP(myHero) < self.Menu.Laneclear.LCMM:Value() then
		if not self:GotMinigun() and Common:Ready(_Q) then
			Order:CastSpell(_Q)
		end
		return
	end
	if self.Menu.Laneclear.LCQ:Value() and Common:Ready(_Q) then
		local Target = EOW:GetLaneclear()
		if Target and Target.team == Common.Enemy and Common:ValidTarget(Target) then
			local MCount = Common:MinionsAround(Target.pos, 300, Common.Enemy)
			if self:GotMinigun() and MCount > 1 then
				Order:CastSpell(_Q)
			elseif not self:GotMinigun() and MCount <= 1 then
				Order:CastSpell(_Q)
			end
		end
	end
end

function Jinx:AutoE()
	if not Common:Ready(_E) or not self.Menu.Misc.ECC:Value() then
		return
	end
	for i = 1, Game.HeroCount() do
		local e = Game.Hero(i)
		if e.team ~= myHero.team then
			if not e.dead and Common:GetDistance(myHero.pos, e.pos) <= self.Spells[2].range then
				local ExpireTime = Common:IsImmobile(e)
				if ExpireTime and ExpireTime > Game.Timer() + self.Spells[2].delay and Game.Timer() < ExpireTime - self.Spells[2].delay then
					Order:CastSpell(_E, e.pos)
					return
				end
			end
		end
	end
end

function Jinx:Killsteal()
	for i = 1, Game.HeroCount() do
		local e = Game.Hero(i)
		if e and e.team ~= myHero.team then
			if self.Menu.Killsteal.KSW:Value() and Common:Ready(_W) and Common:GetDistance(myHero.pos, e.pos) > myHero.range and Common:ValidTarget(e, self.Spells[1].range) and self.Damage[1](e) >= e.health + e.shieldAD then
				self:CastW(e)
				break
			elseif self.Menu.Killsteal.KSR:Value() and Common:Ready(_R) and Common:GetDistance(myHero.pos, e.pos) > myHero.range and Common:ValidTarget(e, self.Menu.Killsteal.KSRR:Value()) and self.Damage[3](e) >= e.health + e.shieldAD then
				self:CastR(e)
				break
			end
		end
	end
end

function Jinx:GotMinigun()
	return myHero:GetSpellData(_Q).toggleState == 1
end

function Jinx:CastW(unit)
	local Pred = Common:GetPrediction(unit, self.Spells[1])
	if Pred and Common:GetHeroCollision(myHero.pos, Pred, self.Spells[1].width, unit) == 0 and Common:GetMinionCollision(myHero.pos, Pred, self.Spells[1].width, unit) == 0 then
		Pred = Vector(Pred)
		Pred = myHero.pos + (Pred - myHero.pos):Normalized() * 300
		Order:CastSpell(_W, Pred)
	end
end

function Jinx:CastR(unit)
	local Speed =  unit.distance > 1350 and (2295000 + (unit.distance - 1350) * 2200) / unit.distance or 1700
	self.Spells[3].speed = Speed
	local Pred = Common:GetPrediction(unit, self.Spells[3])
	if Pred and Common:GetHeroCollision(myHero.pos, Pred, self.Spells[3].width, unit) == 0 then
		Pred = Vector(Pred)
		Pred = myHero.pos + (Pred - myHero.pos):Normalized() * 300
		Order:CastSpell(_R, Pred)
	end
end

function Jinx:MinigunRange()
	return 525 + myHero.boundingRadius
end

function Jinx:RocketRange()
	return 525 + myHero.boundingRadius + (50 + (25 * myHero:GetSpellData(_Q).level))
end

class "Ezreal"

function Ezreal:__init()
	
	self.Spells = {
		[0] = {delay = 0.25, speed = 2000, range = 1200, width = 60},
		[1] = {delay = 0.25, speed = 1600, range = 1050, width = 80},
		[2] = {delay = 0.25, speed = math.huge, range = 450, width = 1},
		[3] = {delay = 1, speed = 2000, range = math.huge, width = 160}
	}
	
	self.Damage = {
		[0] = function(unit)
			local BaseDamage = 15 + (20 * myHero:GetSpellData(_Q).level) + (myHero.ap * 0.4) + (myHero.totalDamage * 1.1)
			local BonusPhysicalDamage = 0
			local BonusMagicalDamage = 0
			local Sheen = nil
			local TriForce = nil
			local Lichbane = nil
			local IceBorn = nil
			for i = ITEM_1, ITEM_7 do
				local ItemID = myHero:GetItemData(i).itemID
				if ItemID == 3057 then
					Sheen = i
				elseif ItemID == 3100 then
					Lichbane = i
				elseif ItemID == 3078 then
					TriForce = i
				elseif ItemID == 3025 then
					IceBorn = i
				end
			end
			if Sheen then
				if Game.CanUseSpell(Sheen) ~= ONCOOLDOWN or Common:GotBuff(myHero, "sheen") > 0 then
					BonusPhysicalDamage = myHero.baseDamage
				end
			elseif TriForce then
				if Game.CanUseSpell(TriForce) ~= ONCOOLDOWN or Common:GotBuff(myHero, "sheen") > 0 then
					BonusPhysicalDamage = myHero.baseDamage * 2
				end
			elseif IceBorn then
				if Game.CanUseSpell(IceBorn) ~= ONCOOLDOWN or Common:GotBuff(myHero, "itemfrozenfist") > 0 then
					BonusPhysicalDamage = myHero.baseDamage
				end
			elseif Lichbane then
				if Game.CanUseSpell(Lichbane) ~= ONCOOLDOWN or Common:GotBuff(myHero, "lichbane") > 0 then
					BonusMagicalDamage = (myHero.baseDamage * 0.75) + (myHero.ap * 0.5)
				end
			end
			return EOW:CalcPhysicalDamage(myHero, unit, BaseDamage + BonusMagicalDamage + BonusPhysicalDamage)
		end,
		[1] = function(unit)
			return EOW:CalcMagicalDamage(myHero, unit, 25 + (45 * myHero:GetSpellData(_W).level) + (myHero.ap + 0.8))
		end,
		[3] = function(unit)
			local BaseDamage = 200 + (150 * myHero:GetSpellData(_R).level) + (myHero.bonusDamage) + (myHero.ap * 0.9)
			local Reduction = math.min(Common:GetHeroCollision(myHero.pos, unit.pos, self.Spells[3].width, unit) + Common:GetMinionCollision(myHero.pos, unit.pos, self.Spells[3].width, unit), 7)
			BaseDamage = BaseDamage * ((10 - Reduction) / 10)
			return EOW:CalcMagicalDamage(myHero, unit, BaseDamage)
		end
	}
	
	self.Menu = MenuElement({id = "Ezreal", name = "Ezreal", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..myHero.charName..".png"})
	
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "CQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "CW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "CR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({id = "Items", name = "Items", type = MENU})
	self.Menu.Combo.Items:MenuElement({id = "BORK", name = "Blade of the Ruined King", value = true})
	self.Menu.Combo.Items:MenuElement({id = "BORKMYHP", name = "Use If My HP < x%", value = 70, min = 1, max = 100, step = 1})
	self.Menu.Combo.Items:MenuElement({id = "BORKEHP", name = "Use If Target HP < x%", value = 70, min = 1, max = 100, step = 1})
	self.Menu.Combo.Items:MenuElement({id = "Bilge", name = "Bilgewater Cutlass", value = true})
	self.Menu.Combo.Items:MenuElement({id = "BilgeMYHP", name = "Use If My HP < x%", value = 70, min = 1, max = 100, step = 1})
	self.Menu.Combo.Items:MenuElement({id = "BilgeEHP", name = "Use If Target HP < x%", value = 70, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "HQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "HW", name = "Use W", value = true})
	self.Menu.Harass:MenuElement({id = "HMM", name = "Min Mana To Harass", value = 50, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Laneclear", name = "Laneclear", type = MENU})
	self.Menu.Laneclear:MenuElement({id = "LCQ", name = "Use Q", value = true})
	self.Menu.Laneclear:MenuElement({id = "LCMM", name = "Min Mana To Laneclear", value = 50, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	self.Menu.Lasthit:MenuElement({id = "LHQ", name = "Use Q", value = true})
	self.Menu.Lasthit:MenuElement({id = "LHMM", name = "Min Mana To Lasthit", value = 40, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Jungleclear", name = "Jungleclear", type = MENU})
	self.Menu.Jungleclear:MenuElement({id = "JCQ", name = "Use Q", value = true})
	self.Menu.Jungleclear:MenuElement({id = "JCMM", name = "Min Mana To Jungleclear", value = 40, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSQ", name = "Use Q", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSW", name = "Use W", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSR", name = "Use R", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSRC", name = "R Max Range", value = 2000, min = 300, max = 25000, step = 100})
	
	self.Menu:MenuElement({id = "Draw", name = "Drawings", type = MENU})
	self.Menu.Draw:MenuElement({id = "DA", name = "Disable All Drawings", value = false})
	for i = 0, 2 do
		self.Menu.Draw:MenuElement({id = "D"..Common.str[i], name = "Draw "..Common.str[i].." Range", type = MENU})
		self.Menu.Draw["D"..Common.str[i]]:MenuElement({id = "Enabled", name = "Enabled", value = true})
		self.Menu.Draw["D"..Common.str[i]]:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
		self.Menu.Draw["D"..Common.str[i]]:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
	end
	
	self.Menu:MenuElement({id = "Misc", name = "Misc", type = MENU})
	
	self.Target = nil
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ezreal:Tick()
	self.Target = EOW:GetTarget() or Common:GetTarget()
	
	if EOW:Mode() == "Combo" then
		self:Combo()
	elseif EOW:Mode() == "Harass" then
		self:Harass()
	elseif EOW:Mode() == "LaneClear" then
		self:Lasthit()
		self:Laneclear()
		self:Jungleclear()
	elseif EOW:Mode() == "LastHit" then
		self:Lasthit()
	end
	
	if self.Menu.Killsteal.Enabled:Value() then
		self:Killsteal()
	end
end

function Ezreal:Draw()
	if self.Menu.Draw.DA:Value() then
		return
	end
	for i = 0, 2 do
		local Str = Common.str[i]
		if self.Menu.Draw["D"..Str].Enabled:Value() then
			Draw.Circle(myHero.pos, self.Spells[i].range, self.Menu.Draw["D"..Str].Width:Value(), self.Menu.Draw["D"..Str].Color:Value())
		end
	end
end

function Ezreal:Combo()
	if myHero.attackData.state == STATE_WINDUP or not self.Target then
		return
	end
	
	if self.Menu.Combo.CQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self.Spells[0].range) then
		self:CastQ(self.Target)
	end
	
	if self.Menu.Combo.CW:Value() and Common:Ready(_W) and Common:ValidTarget(self.Target, self.Spells[1].range) then
		self:CastW(self.Target)
	end
	
	if self.Menu.Combo.CR:Value() and Common:Ready(_R) and Common:ValidTarget(self.Target, 2000) then
		if Common:GetPercentHP(self.Target) <= 50 and Common:GetDistance(myHero.pos, self.Target.pos) > 800 and Common:EnemiesAround(myHero.pos, 800) <= 1 then
			self:CastR(self.Target)
		end
	end
	
	if self.Menu.Combo.Items.BORK:Value() then
		local Bork = Common:GetItemSlot(myHero, 3153)
		if Bork > 0 and Common:Ready(Bork) and Common:ValidTarget(self.Target, 550) and Common:GetPercentHP(myHero) <= self.Menu.Combo.Items.BORKMYHP:Value() and Common:GetPercentHP(self.Target) <= self.Menu.Combo.Items.BORKEHP:Value() then
			Order:CastSpell(Bork, self.Target.pos)
		end
	end
	
	if self.Menu.Combo.Items.Bilge:Value() then
		local Bilge = Common:GetItemSlot(myHero, 3144)
		if Bilge > 0 and Common:Ready(Bilge) and Common:ValidTarget(self.Target, 550) and Common:GetPercentHP(myHero) <= self.Menu.Combo.Items.BilgeMYHP:Value() and Common:GetPercentHP(self.Target) <= self.Menu.Combo.Items.BilgeEHP:Value() then
			Order:CastSpell(Bilge, self.Target.pos)
		end
	end
end

function Ezreal:Harass()
	if myHero.attackData.state == STATE_WINDUP or not self.Target or Common:GetPercentMP(myHero) < self.Menu.Harass.HMM:Value() then
		return
	end
	
	if self.Menu.Harass.HQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self.Spells[0].range) then
		self:CastQ(self.Target)
	end
	
	if self.Menu.Harass.HW:Value() and Common:Ready(_W) and Common:ValidTarget(self.Target, self.Spells[1].range) then
		self:CastW(self.Target)
	end
end

function Ezreal:Laneclear()
	if myHero.attackData.state == STATE_WINDUP or Common:GetPercentMP(myHero) < self.Menu.Laneclear.LCMM:Value() then
		return
	end
	if self.Menu.Laneclear.LCQ:Value() and Common:Ready(_Q) then
		for i = 1, Game.MinionCount() do
			local m = Game.Minion(i)
			if m and m.isEnemy and Common:ValidTarget(m, self.Spells[0].range) then
				self:CastQ(m)
				break
			end
		end
	end
end

function Ezreal:Jungleclear()
	if myHero.attackData.state == STATE_WINDUP or Common:GetPercentMP(myHero) < self.Menu.Jungleclear.JCMM:Value() then
		return
	end
	if self.Menu.Jungleclear.JCQ:Value() and Common:Ready(_Q) then
		for i = 1, Game.MinionCount(i) do
			local m = Game.Minion(i)
			if m and m.team == Common.Neutral and Common:ValidTarget(m, self.Spells[0].range) then
				self:CastQ(m)
				break
			end
		end
	end
end

function Ezreal:Lasthit()
	if myHero.attackData.state == STATE_WINDUP or Common:GetPercentMP(myHero) < self.Menu.Lasthit.LHMM:Value() then
		return
	end
	if self.Menu.Lasthit.LHQ:Value() and Common:Ready(_Q) then
		for i = 1, Game.MinionCount() do
			local m = Game.Minion(i)
			if m and m.isEnemy and Common:ValidTarget(m, self.Spells[0].range) and self.Damage[0](m) >= m.health and myHero.attackData.target ~= m.handle then
				if myHero.attackData.state == STATE_WINDDOWN or not EOW:CanOrb(m) then
					self:CastQ(m)
					break
				end
			end
		end
	end
end

function Ezreal:Killsteal()
	if myHero.attackData.state == STATE_WINDUP then
		return
	end
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and h.isEnemy then
			if self.Menu.Killsteal.KSQ:Value() and Common:Ready(_Q) and Common:ValidTarget(h, self.Spells[0].range) and self.Damage[0](h) >= h.health + h.shieldAD then
				self:CastQ(h)
			elseif self.Menu.Killsteal.KSW:Value() and Common:Ready(_W) and Common:ValidTarget(h, self.Spells[1].range) and self.Damage[1](h) >= h.health + h.shieldAP then
				self:CastW(h)
			elseif self.Menu.Killsteal.KSR:Value() and Common:Ready(_R) and Common:ValidTarget(h, self.Menu.Killsteal.KSRC:Value()) and Common:GetDistance(myHero.pos, h.pos) > myHero.range and self.Damage[3](h) >= h.health + h.shieldAD then
				self:CastR(h)
			end
		end
	end
end

function Ezreal:CastQ(unit)
	local Pred = Common:GetPrediction(unit, self.Spells[0])
	if Pred and Common:GetHeroCollision(myHero.pos, Pred, self.Spells[0].width, unit) == 0 and Common:GetMinionCollision(myHero.pos, Pred, self.Spells[0].width, unit) == 0 then
		Order:CastSpell(_Q, Pred)
	end
end

function Ezreal:CastW(unit)
	local Pred = Common:GetPrediction(unit, self.Spells[1])
	if Pred then
		Order:CastSpell(_W, Pred)
	end
end

function Ezreal:CastR(unit)
	local Pred = Common:GetPrediction(unit, self.Spells[3])
	if Pred then
		Pred = Vector(Pred)
		Pred = myHero.pos + (Pred - myHero.pos):Normalized() * 500
		Order:CastSpell(_R, Pred)
	end
end

class "Lux"

function Lux:__init()

	self.Spells = {
		[0] = {delay = 0.25, speed = 1600, range = 1300, width = 70},
		[1] = {delay = 0.25, speed = 1400, range = 1075},
		[2] = {delay = 0.25, speed = 1300, range = 1100, width = 350},
		[3] = {delay = 1, speed = math.huge, range = 3500, width = 190}
	}
	
	self.Damage = {
		[0] = function(unit)
			return EOW:CalcMagicalDamage(myHero, unit, (50 * myHero:GetSpellData(_Q).level) + (myHero.ap * 0.7))
		end,
		[2] = function(unit)
			return EOW:CalcMagicalDamage(myHero, unit, 15 + (45 * myHero:GetSpellData(_E).level) + (myHero.ap * 0.6))
		end,
		[3] = function(unit)
			local BaseDamage = 200 + (100 * myHero:GetSpellData(_R).level) + (myHero.ap * 0.75)
			local BonusDamage = Common:GotBuff(unit, "luxilluminatingfraulein") > 0 and 10 + (myHero.levelData.lvl * 10) + (myHero.ap * 0.2) or 0
			return EOW:CalcMagicalDamage(myHero, unit, BaseDamage + BonusDamage)
		end
	}
	
	self.Target = nil
	
	self.Menu = MenuElement({id = "Lux", name = "Lux", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..myHero.charName..".png"})
	
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "CQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "CE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "CR", name = "Use R", value = true})
	
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "HQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "HE", name = "Use E", value = true})
	self.Menu.Harass:MenuElement({id = "HMM", name = "Min Mana To Harass", value = 60, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Laneclear", name = "Laneclear", type = MENU})
	self.Menu.Laneclear:MenuElement({id = "LCQ", name = "Use Q", value = false})
	self.Menu.Laneclear:MenuElement({id = "LCQC", name = "Min Minions To Hit With Q", value = 2, min = 1, max = 2, step = 1})
	self.Menu.Laneclear:MenuElement({id = "LCE", name = "Use E", value = true})
	self.Menu.Laneclear:MenuElement({id = "LCEC", name = "Min Minions To Hit With E", value = 3, min = 1, max = 8, step = 1})
	self.Menu.Laneclear:MenuElement({id = "LCMM", name = "Min Mana To Laneclear", value = 60, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	self.Menu.Lasthit:MenuElement({id = "LHQ", name = "Use Q", value = true})
	self.Menu.Lasthit:MenuElement({id = "LHMM", name = "Min Mana To Lasthit", value = 60, min = 1, max = 100, step = 1})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSQ", name = "Use Q", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSE", name = "Use E", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSR", name = "Use R", value = true})
	
	self.Menu:MenuElement({id = "Misc", name = "Misc", type = MENU})
	self.Menu.Misc:MenuElement({id = "AE", name = "Auto E2", value = true})
	self.Menu.Misc:MenuElement({id = "AQCC", name = "Auto Q On CC", value = true})
	self.Menu.Misc:MenuElement({id = "AECC", name = "Auto E On CC", value = true})
	self.Menu.Misc:MenuElement({id = "ARCC", name = "Only Ult On CC", value = false})
	
	self.Menu:MenuElement({id = "Draw", name = "Drawings", type = MENU})
	self.Menu.Draw:MenuElement({id = "DA", name = "Disable All Draws", value = true})
	for i = 0, 3 do
		local k = Common.str[i]
		self.Menu.Draw:MenuElement({id = "D"..k, name = "Draw "..k.." Range", type = MENU})
		self.Menu.Draw["D"..k]:MenuElement({id = "Enabled", name = "Enabled", value = true})
		self.Menu.Draw["D"..k]:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
		self.Menu.Draw["D"..k]:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
	end
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Lux:Tick()
	self.Target = EOW:GetTarget() or Common:GetTarget()
	if EOW:Mode() == "Combo" then
		self:Combo()
	elseif EOW:Mode() == "Harass" then
		self:Harass()
	elseif EOW:Mode() == "LaneClear" then
		self:Lasthit()
		self:Laneclear()
	elseif EOW:Mode() == "LastHit" then
		self:Lasthit()
	end
	
	self:Auto()
	
	if self.Menu.Killsteal.Enabled:Value() then
		self:Killsteal()
	end
end

function Lux:Draw()
	if self.Menu.Draw.DA:Value() then
		return
	end
	for i = 0, 3 do
		local k = Common.str[i]
		if self.Menu.Draw["D"..k].Enabled:Value() then
			Draw.Circle(myHero.pos, self.Spells[i].range, self.Menu.Draw["D"..k].Width:Value(), self.Menu.Draw["D"..k].Color:Value())
		end
	end
end

function Lux:Combo()
	if myHero.attackData.state == STATE_WINDUP then
		return
	end
	
	if self.Menu.Combo.CQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self.Spells[0].range) then
		self:CastQ(self.Target)
	end
	
	if self.Menu.Combo.CE:Value() and Common:Ready(_E) then
		if not self:IsE2() and Common:ValidTarget(self.Target, self.Spells[2].range) then
			self:CastE(self.Target)
		elseif self:IsE2() then
			Order:CastSpell(_E)
		end
	end
	
	if self.Menu.Combo.CR:Value() and Common:Ready(_R) and Common:ValidTarget(self.Target, self.Spells[3].range) and self.Damage[3](self.Target) >= self.Target.health + self.Target.shieldAP then
		if not self.Menu.Misc.ARCC:Value() or Common:IsImmobile(self.Target) then
			self:CastR(self.Target)
		end
	end
end

function Lux:Harass()
	if myHero.attackData.state == STATE_WINDUP or Common:GetPercentMP(myHero) < self.Menu.Harass.HMM:Value() then
		return
	end
	
	if self.Menu.Harass.HQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self.Spells[0].range) then
		self:CastQ(self.Target)
	end
	
	if self.Menu.Harass.HE:Value() and Common:Ready(_E) then
		if not self:IsE2() and Common:ValidTarget(self.Target, self.Spells[2].range) then
			self:CastE(self.Target)
		elseif self:IsE2() then
			Order:CastSpell(_E)
		end
	end
end

function Lux:Laneclear()
	if myHero.attackData.state == STATE_WINDUP or Common:GetPercentMP(myHero) < self.Menu.Laneclear.LCMM:Value() then
		return
	end
	if self.Menu.Laneclear.LCE:Value() and Common:Ready(_E) then
		if not self:IsE2() then
			local BestPos, BestHit = Common:GetBestCircularFarmPos(self.Spells[2].range, self.Spells[2].width)
			if BestPos and BestHit >= self.Menu.Laneclear.LCEC:Value() then
				Order:CastSpell(_E, BestPos)
			end
		else
			Order:CastSpell(_E)
		end
	end
	if self.Menu.Laneclear.LCQ:Value() and Common:Ready(_Q) then
		local BestPos, BestHit = Common:GetBestLinearFarmPos(self.Spells[0].range, self.Spells[0].width)
		if BestPos and BestHit >= self.Menu.Laneclear.LCQC:Value() then
			Order:CastSpell(_Q, BestPos)
		end
	end
end

function Lux:Lasthit()
	if myHero.attackData.state == STATE_WINDUP or Common:GetPercentMP(myHero) < self.Menu.Lasthit.LHMM:Value() then
		return
	end
	if self.Menu.Lasthit.LHQ:Value() and Common:Ready(_Q) then
		for i = 1, Game.MinionCount() do
			local m = Game.Minion(i)
			if m and m.isEnemy and Common:ValidTarget(m, self.Spells[0].range) and self.Damage[0](m) > m.health and myHero.attackData.target ~= m.handle then
				if myHero.attackData.state == STATE_WINDDOWN or not EOW:CanOrb(m) then
					self:CastQ(m)
				end
			end
		end
	end
end

function Lux:Killsteal()
	if myHero.attackData.state == STATE_WINDUP then
		return
	end
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and h.isEnemy then
			if self.Menu.Killsteal.KSQ:Value() and Common:Ready(_Q) and Common:ValidTarget(h, self.Spells[0].range) and self.Damage[0](h) >= h.health + h.shieldAP then
				self:CastQ(h)
				break
			elseif self.Menu.Killsteal.KSE:Value() and Common:Ready(_E) and self.Damage[2](h) >= h.health + h.shieldAP then
				if not self:IsE2() and Common:ValidTarget(h, self.Spells[2].range) then
					self:CastE(h)
					break
				elseif self:IsE2() then
					Order:CastSpell(_E)
					break
				end
			elseif self.Menu.Killsteal.KSR:Value() and Common:Ready(_R) and Common:ValidTarget(h, self.Spells[3].range) and self.Damage[3](h) >= h.health + h.shieldAP then
				if not self.Menu.Misc.ARCC:Value() or Common:IsImmobile(h) then
					self:CastR(h)
					break
				end
			end
		end
	end
end

function Lux:Auto()
	if self.Menu.Misc.AE:Value() and self:IsE2() then
		Order:CastSpell(_E)
	end
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and h.isEnemy then 
			if self.Menu.Misc.AECC:Value() and Common:Ready(_E) and Common:ValidTarget(h, self.Spells[2].range) and Common:IsImmobile(h) then
				self:CastE(h)
			elseif self.Menu.Misc.AQCC:Value() and Common:Ready(_Q) and not h.dead and Common:GetDistance(myHero.pos, h.pos) <= self.Spells[0].range then
				local ExpireTime = Common:IsImmobile(h)
				local TimeToReach = self.Spells[0].delay + (Common:GetDistance(myHero.pos, h.pos) / self.Spells[0].speed)
				if ExpireTime and ExpireTime > Game.Timer() + TimeToReach and Game.Timer() < ExpireTime - TimeToReach then
					self:CastQ(h)
				end
			end
		end	
	end
end

function Lux:CastQ(unit)
	local Pred = Common:GetPrediction(unit, self.Spells[0])
	if Pred and Common:GetHeroCollision(myHero.pos, Pred, self.Spells[0].width, unit) + Common:GetMinionCollision(myHero.pos, Pred, self.Spells[0].width, unit) < 2 then
		Pred = Vector(Pred)
		Pred = myHero.pos + (Pred - myHero.pos):Normalized() * 300
		Order:CastSpell(_Q, Pred)
	end
end

function Lux:CastE(unit)
	if self:IsE2() then
		return
	end
	local Pred = Common:GetPrediction(unit, self.Spells[2])
	if Pred then
		Order:CastSpell(_E, Pred)
	end
end

function Lux:CastR(unit)
	local Pred = Common:GetPrediction(unit, self.Spells[3])
	if Pred then
		Pred = Vector(Pred)
		Pred = myHero.pos + (Pred - myHero.pos):Normalized() * 300
		Order:CastSpell(_R, Pred)
	end
end

function Lux:IsE2()
	return myHero:GetSpellData(_E).toggleState == 2
end

class "Yasuo"

function Yasuo:__init()

	self.Q1 = {delay = 0.4, speed = math.huge, range = 475, radius = 30}
	self.Q2 = {delay = 0.5, speed = 1500, range = 1150, radius = 90}
	self.Q3 = {delay = 0.5, speed = math.huge, range = 375, radius = 375}
	self.W = {range = 400}
	self.R = {range = 1200}
	self.E = {range = 475}
	
	self.TargetSpells = {
		["Ahri"] = {
			["ahrifoxfiremissiletwo"] = {slot = 1, danger = 2, name = "Fox-Fire"},
			["ahritumblemissile"] = {slot = 3, danger = 2, name = "SpiritRush"}
		},
		["Akali"] = {
			["akalimota"] = {slot = 0, danger = 2, name = "Mark of the Assasin"}
		},
		["Anivia"] = {
			["frostbite"] = {slot = 2, danger = 3, name = "Frostbite"}
		},
		["Annie"] = {
			["disintegrate"] = {slot = 0, danger = 3, name = "Disintegrate"}
		},
		["Brand"] = {
			--BrandR
			["brandr"] = {slot = 3, danger = 5, name = "Pyroclasm"}
		},
		["Caitlyn"] = {
			["caitlynaceintheholemissile"] = {slot = 3, danger = 4, name = "Ace in the Hole"},
			["caitlynheadshotmissile"] = {slot = -1, danger = 3, name = "Headshot"}
		},
		["Cassiopeia"] = {
			["cassiopeiatwinfang"] = {slot = 2, danger = 2, name = "Twin Fang"}
		},
		["Elise"] = {
			["elisehumanq"] = {slot = 0, danger = 3, name = "Neurotoxin"}
		},
		["Ezreal"] = {
			["ezrealarcaneshiftmissile"] = {slot = 2, danger = 2, name = "Arcane Shift"}
		},
		["FiddleSticks"] = {
			["fiddlesticksdarkwindmissile"] = {slot = 2, danger = 3, name = "Dark Wind"}
		},
		["Gangplank"] = {
			["parley"] = {slot = 0, danger = 2, name = "Parley"}
		},
		["Janna"] = {
			["sowthewind"] = {slot = 1, danger = 2, name = "Zephyr"}
		},
		["Kassadin"] = {
			["nulllance"] = {slot = 0, danger = 3, name = "Null Sphere"}
		},
		["Katarina"] = {
			["katarinaqmis"] = {slot = 0, danger = 3, name = "Bouncing Blade"}
		},
		["Kayle"] = {
			["judicatorreckoning"] = {slot = 0, danger = 3, name = "Reckoning"}
		},
		["Leblanc"] = {
			["leblancchaosorbm"] = {slot = 0, danger = 3, name = "Shatter Orb"}
		},
		["Malphite"] = {
			["seismicshard"] = {slot = 0, danger = 3, name = "Seismic Shard"}
		},
		["MissFortune"] = {
			["missfortunericochetshot"] = {slot = 0, danger = 3, name = "Double Up"}
		},
		["Nami"] = {
			["namiwmissileenemy"] = {slot = 1, danger = 2, name = "Ebb and Flow"}
		},
		["Nunu"] = {
			["iceblast"] = {slot = 2, danger = 3, name = "Ice Blast"}
		},
		["Pantheon"] = {
			["pantheonq"] = {slot = 0, danger = 2, name = "Spear Shot"}
		},
		["Ryze"] = {
			["ryzee"] = {slot = 2, danger = 3, name = "Spell Flux"}
		},
		["Shaco"] = {
			["twoshivpoison"] = {slot = 2, danger = 3, name = "Two-Shiv Poison"}
		},
		["Sona"] = {
			["sonaqmissile"] = {slot = 0, danger = 3, name = "Hymn of Valor"}
		},
		["Swain"] = {
			["swaintorment"] = {slot = 2, danger = 4, name = "Torment"}
		},
		["Syndra"] = {
			--SyndraRSpell
			["syndrarspell"] = {slot = 3, danger = 5, name = "Unleashed Power"}
		},
		["Teemo"] = {
			["blindingdart"] = {slot = 0, danger = 4, name = "Blinding Dart"}
		},
		["Tristana"] = {
			["detonatingshot"] = {slot = 2, danger = 3, name = "Explosive Charge"}
		},
		["TwistedFate"] = {
			["bluecardpreattack"] = {slot = 1, danger = 3, name = "Blue Card"},
			["goldcardpreattack"] = {slot = 1, danger = 4, name = "Gold Card"},
			["redcardpreattack"] = {slot = 1, danger = 3, name = "Red Card"}
		},
		["Urgot"] = {
			["urgotheatseekinghomemissile"] = {slot = 0, danger = 3, name = "Acid Hunter"}
		},
		["Vayne"] = {
			["vaynecondemnmissile"] = {slot = 2, danger = 3, name = "Condemn"}
		},
		["Veigar"] = {
			--VeigarR
			["veigarr"] = {slot = 3, danger = 5, name = "Primordial Burst"}
		},
		["Viktor"] = {
			["viktorpowertransfer"] = {slot = 0, danger = 3, name = "Siphon Power"}
		},
		["Vladimir"] = {
			["vladimirtidesofbloodnuke"] = {slot = 2, danger = 3, name = "Tides of Blood"}
		}
	}
	
	self.Damage = {
		[0] = function(unit)
			local Crit = myHero.critChance
			local CritDamage = Common:GetItemSlot(myHero, 3031) > 0 and 2.25 or 1.75
			local ShivDamage = 0
			if Common:GotBuff(myHero, "statikshankcharge") == 100 then
				ShivDamage = (Crit == 1 and (({50,50,50,50,50,56,61,67,72,77,83,88,84,99,104,110,115,120})[myHero.levelData.lvl] * CritDamage) or ({50,50,50,50,50,56,61,67,72,77,83,88,84,99,104,110,115,120})[myHero.levelData.lvl])
			end
			local AD = (Crit == 1 and myHero.totalDamage * CritDamage or myHero.totalDamage)
			return EOW:CalcPhysicalDamage(myHero, unit, 20 * myHero:GetSpellData(_Q).level + AD) + EOW:CalcMagicalDamage(myHero, unit, ShivDamage)
		end,
		[2] = function(unit)
			local EStacks = Common:GotBuff(myHero, "YasuoDashScalar")
			local BaseDamage = ((50 + (10 * myHero:GetSpellData(_E).level)) * (1 + (0.25 * EStacks))) + (myHero.bonusDamage * 0.2) + (myHero.ap * 0.6)
			return EOW:CalcMagicalDamage(myHero, unit, BaseDamage)
		end,
		[3] = function(unit)
			return EOW:CalcPhysicalDamage(myHero, unit, 100 + (100 * myHero:GetSpellData(_R).level) + (myHero.bonusDamage * 1.5))
		end
	}
	
	self.Target = nil
	
	self.LastMovement = 0
	
	self.KnockUps = {
		[29] = true,
		[30] = true
	}
	
	self.Menu = MenuElement({id = "Yasuo", name = "Yasuo", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..myHero.charName..".png"})
	
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "CQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "CE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "CR", name = "Use R", value = true})
	
	self.Menu:MenuElement({id = "AW", name = "Auto Windwall", type = MENU})
	self.Menu.AW:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.AW:MenuElement({id = "AWC", name = "Min Danger To Windwall", value = 3, min = 1, max = 5, step = 1})
	self.Menu.AW:MenuElement({id = "Info", name = "Detecting Spells Please Wait", type = SPACE})
	local Delay = Game.Timer() > 30 and 0 or 30 - Game.Timer()
	local AddedSpell = false
	DelayAction(function()
		for i = 1, Game.HeroCount() do
			local h = Game.Hero(i)
			if h.isEnemy then
				if not AddedSpell then
					self.Menu.AW:MenuElement({id = "WAA", name = "Windwall Auto Attacks", type = MENU})
					self.Menu.AW.WAA:MenuElement({id = "Enabled", name = "Enabled", value = true})
					self.Menu.AW.WAA:MenuElement({id = "WAAC", name = "If Health < x%", value = 15, min = 0, max = 100, step = 1})
					AddedSpell = true
				end
				self.Menu.AW.WAA:MenuElement({id = h.networkID, name = h.charName.." Enabled", value = true})
				if self.TargetSpells[h.charName] then
					for _, x in pairs(self.TargetSpells[h.charName]) do
						self.Menu.AW:MenuElement({id = x.name, name = h.charName.." | "..Common.str[x.slot].." | "..x.name, type = MENU})
						self.Menu.AW[x.name]:MenuElement({id = "Enabled", name = "Enabled", value = true})
						self.Menu.AW[x.name]:MenuElement({id = "Danger", name = "Danger", value = x.danger, min = 1, max = 5, step = 1})
						AddedSpell = true
					end
				end
			end
		end
		self.Menu.AW.Info:Remove()
		if not AddedSpell then
			self.Menu.AW:MenuElement({id = "Info", name = "No Spells Detected", type = SPACE})
		end
	end, Delay)
	
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "HQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "HE", name = "Use E", value = true})
	
	self.Menu:MenuElement({id = "LaneClear", name = "Laneclear", type = MENU})
	self.Menu.LaneClear:MenuElement({id = "LCQ", name = "Use Q", value = true})
	self.Menu.LaneClear:MenuElement({id = "LCE", name = "Use E", value = true})
	
	self.Menu:MenuElement({id = "Jungleclear", name = "Jungleclear", type = MENU})
	self.Menu.Jungleclear:MenuElement({id = "JCQ", name = "Use Q", value = true})
	self.Menu.Jungleclear:MenuElement({id = "JCE", name = "Use E", value = true})
	
	self.Menu:MenuElement({id = "LastHit", name = "Lasthit", type = MENU})
	self.Menu.LastHit:MenuElement({id = "LHQ", name = "Use Q", value = true})
	self.Menu.LastHit:MenuElement({id = "LHE", name = "Use E", value = true})
	
	self.Menu:MenuElement({id = "GapClose", name = "Gapclose", type = MENU})
	self.Menu.GapClose:MenuElement({id = "GCE", name = "Use E", value = true})
	self.Menu.GapClose:MenuElement({id = "GCC", name = "Gapclose in Combo", value = true})
	self.Menu.GapClose:MenuElement({id = "GCH", name = "Gapclose in Harass", value = false})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSQ", name = "Use Q", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSE", name = "Use E", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSR", name = "Use R", value = true})
	
	self.Menu:MenuElement({id = "Flee", name = "Flee", type = MENU})
	self.Menu.Flee:MenuElement({id = "Enabled", name = "Flee To Mouse", value = true})
	self.Menu.Flee:MenuElement({id = "Key", name = "Flee Key", key = string.byte("G")})
	
	self.Menu:MenuElement({id = "Misc", name = "Misc", type = MENU})
	self.Menu.Misc:MenuElement({id = "AR", name = "Auto R", value = true})
	self.Menu.Misc:MenuElement({id = "ARC", name = "Min Enemies To Auto R", value = 3, min = 1, max = 5, step = 1})
	
	self.Menu:MenuElement({id = "Draw", name = "Drawings", type = MENU})
	self.Menu.Draw:MenuElement({id = "DA", name = "Disable All Drawings", value = true})
	for i = 0, 3 do
		local str = Common.str[i]
		self.Menu.Draw:MenuElement({id = "D"..str, name = "Draw "..str.." Range", type = MENU})
		self.Menu.Draw["D"..str]:MenuElement({id = "Enabled", name = "Enabled", value = true})
		self.Menu.Draw["D"..str]:MenuElement({id = "Width", name = "Width", value = 2, min = 1, max = 5, step = 1})
		self.Menu.Draw["D"..str]:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
	end
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	
end

function Yasuo:Tick()
	self.Target = EOW:GetTarget() or Common:GetTarget()
	
	if self.Menu.AW.Enabled:Value() and Common:Ready(_W) then
		self:Windwall()
	end
	
	if self.Menu.Flee.Enabled:Value() and self.Menu.Flee.Key:Value() then
		self:Flee()
	end
	
	if EOW:Mode() == "Combo" then
		self:Combo()
	elseif EOW:Mode() == "Harass" then
		self:Harass()
	elseif EOW:Mode() == "LaneClear" then
		self:LaneClear()
		self:Jungleclear()
	elseif EOW:Mode() == "LastHit" then
		self:LastHit()
	end
	
	if self.Menu.Killsteal.Enabled:Value() then
		self:Killsteal()
	end
	
	if self.Menu.Misc.AR:Value() and Common:Ready(_R) then
		if self:CountKnockedUpEnemies() >= self.Menu.Misc.ARC:Value() then
			self:CastR()
		end
	end
end

function Yasuo:Draw()
	if self.Menu.Draw.DA:Value() or myHero.dead then
		return
	end
	
	for i = 0, 3 do
		local str = Common.str[i]
		if Common:Ready(i) and self.Menu.Draw["D"..str].Enabled:Value() then
			Draw.Circle(myHero.pos, myHero:GetSpellData(i).range, self.Menu.Draw["D"..str].Width:Value(), self.Menu.Draw["D"..str].Color:Value())
		end
	end
end

function Yasuo:Windwall()
	for i = 1, Game.MissileCount() do
		local Missile = Game.Missile(i)
		local Data = Missile.missileData
		local Source = Common:GetHeroByHandle(Data.owner)
		if Source and Data.target == myHero.handle then
			if self.TargetSpells[Source.charName] then
				Spell = self.TargetSpells[Source.charName][Data.name:lower()]
			end
			if Spell then
				if self.Menu.AW[Spell.name].Enabled:Value() and self.Menu.AW[Spell.name].Danger:Value() >= self.Menu.AW.AWC:Value() then
					Order:CastSpell(_W, Missile.pos)
					return
				end
			end
			if self.Menu.AW.WAA.Enabled:Value() and self:IsAutoAttack(Data.name) and self.Menu.AW.WAA[Source.networkID]:Value() then
				if Common:GetPercentHP(myHero) <= self.Menu.AW.WAA.WAAC:Value() or EOW:GetDamage(Source, myHero) >= myHero.health then
					Order:CastSpell(_W, Missile.pos)
					return
				end
			end
		end
	end
	if self.Menu.AW.WAA and self.Menu.AW.WAA.Enabled:Value() then
		for i = 1, Game.HeroCount() do
			local h = Game.Hero(i)
			if h and h.isEnemy and h.range > 400 and self.Menu.AW.WAA[h.networkID] then
				if h.attackData.state == STATE_WINDUP and h.attackData.target == myHero.handle then
					if Common:GetPercentHP(myHero) <= self.Menu.AW.WAA.WAAC:Value() or EOW:GetDamage(h, myHero) >= myHero.health then
						Order:CastSpell(_W, h.pos)
						return
					end
				end
			end
		end
	end
end

function Yasuo:IsAutoAttack(name)
	local AltAttacks = {"caitlynheadshotmissile", "frostarrow", "garenslash2", "kennenmegaproc", "lucianpassiveattack", "masteryidoublestrike", "quinnwenhanced", "renektonexecute", "renektonsuperexecute", "rengarnewpassivebuffdash", "trundleq", "xenzhaothrust", "xenzhaothrust2", "xenzhaothrust3", "viktorqbuff"}
	local NotAttacks = {"jarvanivcataclysmattack", "monkeykingdoubleattack","shyvanadoubleattack", "shyvanadoubleattackdragon", "zyragraspingplantattack", "zyragraspingplantattack2", "zyragraspingplantattackfire", "zyragraspingplantattack2fire", "viktorpowertransfer", "gravesautoattackrecoil"}
	local Name = name:lower()
	if Name:find("attack") and not EOW:TableContains(NotAttacks, Name) then
		return true
	end
	return EOW:TableContains(AltAttacks, Name)
end

function Yasuo:Combo()
	if myHero.attackData.state == STATE_WINDUP or not self.Target then
		return
	end
	
	self:GapClose()
	
	self:ComboR()
	
	if self.Menu.Combo.CQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self:GetQRange()) then
		self:CastQ(self.Target)
	end
	
	if self.Menu.Combo.CE:Value() and Common:Ready(_E) and Common:ValidTarget(self.Target, self.E.range) and Common:GetDistance(self:EPos(self.Target), self.Target.pos) <= Common:GetDistance(myHero.pos, self.Target.pos) and not self:IsUnderTurret(self:EPos(self.Target)) and not self:IsMarked(self.Target) then
		self:CastE(self.Target)
	end
end

function Yasuo:ComboR()
	if self.Menu.Combo.CR:Value() and Common:Ready(_R) and Common:ValidTarget(self.Target, self.R.range) and not self:IsUnderTurret(self.Target.pos) then
		local ExpireTime = self:IsKnockedUp(self.Target)
		if ExpireTime and ExpireTime - Game.Timer() <= 0.01 + ((Game.Latency() * 2) * 0.002) then
			self:CastR()
		end
	end
end

function Yasuo:Harass()
	if myHero.attackData.state == STATE_WINDUP or not self.Target then
		return
	end
	
	self:GapClose()
	
	if self.Menu.Harass.HQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self:GetQRange()) then
		self:CastQ(self.Target)
	end
	
	if self.Menu.Harass.HE:Value() and Common:Ready(_E) and Common:ValidTarget(self.Target, self.E.range) and Common:GetDistance(self:EPos(self.Target), self.Target.pos) <= Common:GetDistance(myHero.pos, self.Target.pos) and not self:IsUnderTurret(self:EPos(self.Target)) and not self:IsMarked(self.Target) then
		self:CastE(self.Target)
	end
end

function Yasuo:LaneClear()
	if myHero.attackData.state == STATE_WINDUP then
		return
	end
	
	self:LastHit()
	
	if self.Menu.LaneClear.LCE:Value() and Common:Ready(_E) then
		local m = self:GetLaneclearEMinion()
		if m then
			self:CastE(m)
		end
	end
	
	if self.Menu.LaneClear.LCQ:Value() and Common:Ready(_Q) then
		local Width = self:IsQ2() and self.Q2.radius or self.Q1.radius
		local BestPos, BestHit = Common:GetBestLinearFarmPos(self:GetQRange(), Width)
		if BestPos and BestHit >= 1 then
			Order:CastSpell(_Q, BestPos)
		end
	end
end

function Yasuo:Jungleclear()
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.team == Common.Neutral then
			if self.Menu.Jungleclear.JCQ:Value() and Common:Ready(_Q) and Common:ValidTarget(m, self:GetQRange()) then
				self:CastQ(m)
				break
			elseif self.Menu.Jungleclear.JCE:Value() and Common:Ready(_E) and Common:ValidTarget(m, self.E.range) and not self:IsMarked(m) then
				self:CastE(m)
				break
			end
		end
	end
end

function Yasuo:LastHit()
	if myHero.attackData.state == STATE_WINDUP then
		return
	end
	
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.isEnemy then
			if myHero.attackData.state == STATE_WINDDOWN or not EOW:CanOrb(m) then
				if self.Menu.LastHit.LHQ:Value() and Common:Ready(_Q) and Common:ValidTarget(m, self:GetQRange()) and self.Damage[0](m) > m.health then
					self:CastQ(m)
					break
				elseif self.Menu.LastHit.LHE:Value() and Common:Ready(_E) and Common:ValidTarget(m, self.E.range) and self:IsSafe(self:EPos(m)) and self.Damage[2](m) > m.health and not self:IsMarked(m) then
					self:CastE(m)
					break
				end
			end
		end
	end
end

function Yasuo:GapClose()
	if myHero.attackData.state == STATE_WINDUP or not self.Target then
		return
	end

	if (EOW:Mode() == "Combo" and self.Menu.GapClose.GCC:Value() or EOW:Mode() == "Harass" and self.Menu.GapClose.GCH:Value()) and self.Menu.GapClose.GCE:Value() then
		local m = self:GetGapCloseMinion()
		if m and Common:Ready(_E) and Common:ValidTarget(self.Target, 1500) then
			self:CastE(m)
		end
	end
end

function Yasuo:Killsteal()
	if myHero.attackData.state == STATE_WINDUP then
		return
	end
	
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and h.isEnemy then
			if self.Menu.Killsteal.KSQ:Value() and Common:Ready(_Q) and Common:ValidTarget(h, self:GetQRange()) and self.Damage[0](h) >= h.health + h.shieldAD then
				self:CastQ(h)
				break
			elseif self.Menu.Killsteal.KSE:Value() and Common:Ready(_E) and Common:ValidTarget(h, self.E.range) and not self:IsUnderTurret(self:EPos(h)) and self.Damage[2](h) >= h.health + h.shieldAP and not self:IsMarked(h) then
				self:CastE(h)
				break
			elseif self.Menu.Killsteal.KSR:Value() and Common:Ready(_R) and Common:ValidTarget(h, self.R.range) and self.Damage[3](h) >= h.health + h.shieldAD and self:IsKnockedUp(h) then
				self:CastR()
			end
		end
	end
end

function Yasuo:Flee()
	local TickCount = GetTickCount()
	if TickCount > self.LastMovement + 150 then
		Order:Move()
		self.LastMovement = TickCount
	end
	
	if not Common:Ready(_E) then
		return
	end
	local M = self:GetFleeMinion()
	if M then
		Order:CastSpell(_E, M.pos)
	end
end

function Yasuo:GetFleeMinion()
	local best = nil
	local closest = math.huge
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if Common:ValidTarget(m, self.E.range) then
			local DistanceM = Common:GetDistance(myHero.pos, mousePos)
			local DistanceP = Common:GetDistance(self:EPos(m), mousePos)
			local DistanceC = Common:GetDistance(self:EPos(m), myHero.pos)
			if DistanceP < DistanceM and DistanceC < closest and not self:IsMarked(m) then
				best = m
				closest = DistanceC
			end
		end
	end
	return best
end

function Yasuo:GetGapCloseMinion()
	local best = nil
	local closest = math.huge
	for x = 1, Game.MinionCount() do
		local i = Game.Minion(x)
		if Common:ValidTarget(i, self.E.range) and not self:IsUnderTurret(self.Target.pos) and self:IsSafe(self:EPos(i)) and not self:IsMarked(i) then
			if Common:GetDistance(self.Target.pos, self:EPos(i)) < Common:GetDistance(myHero.pos, self.Target.pos) and Common:GetDistance(self:EPos(i), self.Target.pos) < closest then
				best = i
				closest = Common:GetDistance(self:EPos(i), self.Target.pos)
			end
		end
	end
	return best
end

function Yasuo:GetLaneclearEMinion()
	local Closest = math.huge
	local Best = nil
	for i = 1, Game.MinionCount() do
		local m = Game.Minion(i)
		if m and m.isEnemy and Common:ValidTarget(m, self.E.range) and self:IsSafe(self:EPos(m)) and not self:IsMarked(m) then
			local Distance = Common:GetDistance(myHero.pos, m.pos)
			if Distance < Closest then
				Closest = Distance
				Best = m
			end
		end
	end
	return Best
end

function Yasuo:CastQ(unit)
	local Q = self:IsQ2() and self.Q2 or self.Q1
	if Game.CanUseSpell(_E) == 8 and Common:GetDistance(myHero.posTo, unit.pos) < self.Q3.range and unit.health - self.Damage[2](unit) > 0 then
		Order:CastSpell(_Q)
		return
	end
	
	local Pred = Common:GetPrediction(unit, Q)
	if Pred then
		Order:CastSpell(_Q, Pred)
	end
end

function Yasuo:CastE(unit)
	Order:CastSpell(_E, unit.pos)
end

function Yasuo:CastR()
	Order:CastSpell(_R)
end

function Yasuo:IsSafe(pos)
	local t = self:GetClosestTurret(pos)
	if t then
		local range = 775 + (t.boundingRadius * 2)
		local Distance = Common:GetDistance(pos, t.pos)
		if Distance > range then
			return true
		elseif Distance <= range and Common:MinionsAround(t.pos, range - (t.boundingRadius * 2), Common.Ally) > 1 then
			return true
		end
		return false
	end
	return true
end

function Yasuo:GetClosestTurret(pos)
	local Closest = math.huge
	local Best = nil
	for i = 1, Game.TurretCount() do
		local t = Game.Turret(i)
		if t and t.isEnemy and not t.dead then
			local Distance = Common:GetDistance(t.pos, pos)
			if Distance < Closest then
				Closest = Distance
				Best = t
			end
		end
	end
	return Best
end

function Yasuo:IsUnderTurret(pos)
	local t = self:GetClosestTurret(pos)
	return t and Common:GetDistance(t.pos, pos) <= 775 + (t.boundingRadius * 2) 
end

function Yasuo:CountKnockedUpEnemies()
	local Count = 0
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if h and h.isEnemy and Common:ValidTarget(h, self.R.range) and self:IsKnockedUp(h) then
			Count = Count + 1
		end
	end
	return Count
end

function Yasuo:IsKnockedUp(unit)
	for i = 0, 63 do
		local buff = unit:GetBuff(i)
		if buff and self.KnockUps[buff.type] and buff.count > 0 then
			return buff.expireTime
		end
	end
	return false
end

function Yasuo:EPos(unit)
	return myHero.pos + (unit.pos - myHero.pos):Normalized() * 600
end

function Yasuo:IsMarked(unit)
	for i = 0, 63 do
		local buff = unit:GetBuff(i)
		if buff and buff.name == "YasuoDashWrapper" and buff.count > 0 then
			return Game.Timer() < buff.expireTime
		end
	end
end

function Yasuo:GetQRange()
	return self:IsQ2() and self.Q2.range or self.Q1.range
end

function Yasuo:IsQ2()
	return myHero:GetSpellData(_Q).toggleState == 2
end

class "Lucian"

function Lucian:__init()

	self.Menu = MenuElement({id = "Lucian", name = "Lucian", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..myHero.charName..".png"})
	
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "CQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "CW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "CE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "CC", name = "Combo Rotation Priority", value = 3, drop = {"Q", "W", "E"}})
	
	self.Spells = {
		[1] = {speed = 1600, delay = 0.25, width = 55, range = 1000}
	}
	
	Common:AddCallback(Common.AfterAttack, function(target) self:AfterAttack(target) end)
end

function Lucian:AfterAttack(target)
	if EOW:Mode() == "Combo" then
		local Target = Common:GetHeroByHandle(target)
		if Target and Common:ValidTarget(Target) and EOW:GetDamage(myHero, Target) < Target.health + Target.shieldAD then
			local ComboMode = self.Menu.Combo.CC:Value() - 1
			if (ComboMode == 0 or not Common:Ready(ComboMode)) and self.Menu.Combo.CQ:Value() and Common:Ready(_Q) then
				Order:CastSpell(_Q, Target.pos)
			elseif (ComboMode == 1 or not Common:Ready(ComboMode)) and self.Menu.Combo.CW:Value() and Common:Ready(_W) then
				self:CastW(Target)
			elseif (ComboMode == 2 or not Common:Ready(ComboMode)) and self.Menu.Combo.CE:Value() and Common:Ready(_E) then
				self:CastE(Target)
			end
		end
	end
end

function Lucian:CastE(unit)
	Order:CastSpell(_E)
end

function Lucian:CastW(unit)
	local Pred = Common:GetPrediction(unit, self.Spells[1])
	if Pred and Common:GetHeroCollision(myHero.pos, unit.pos, self.Spells[1].width, unit) + Common:GetMinionCollision(myHero.pos, unit.pos, self.Spells[1].width, unit) == 0 then
		Order:CastSpell(_W, Pred)
	end
end

class "Riven"

function Riven:__init()
	
	self.Menu = MenuElement({id = "Riven", name = "Riven", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..myHero.charName..".png"})
	
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "CQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "CW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "CE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "CR", name = "Use R", value = true})
	self.Menu.Combo:MenuElement({id = "CR2", name = "Use R2", value = true})
	self.Menu.Combo:MenuElement({id = "Items", name = "Items", type = MENU})
	self.Menu.Combo.Items:MenuElement({id = "CH", name = "Use Hydra", value = true})
	self.Menu.Combo.Items:MenuElement({id = "CGB", name = "Use Ghostblade", value = true})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "Enabled", name = "Enabled", value = true})
	self.Menu.Killsteal:MenuElement({id = "KSR", name = "Use R", value = true})
	
	self.Damage = {
		[3] = function(unit)
			return EOW:CalcPhysicalDamage(myHero, unit, (50 + (50 * myHero:GetSpellData(_R).level) + (myHero.bonusDamage * 0.6)) * math.max((0.04 * math.min((100 - Common:GetPercentHP(unit)), 75)), 1))
		end
	}
	
	self.Spells = {
		[0] = {delay = 0.25, speed = math.huge, range = 300, width = 300},
		[1] ={delay = 0.25, speed = math.huge, range = 300, width = 300},
		[2] = {delay = 0, speed = 1200, range = 325, width = 0},
		[3] = {delay = 0.25, speed = 1600, range = 1100, width = 125}
	}
	
	self.CanUseQ = Game.CanUseSpell(_Q) == 0
	self.CanUseE = Game.CanUseSpell(_E) == 0
	self.Target = EOW:GetTarget() or Common:GetTarget()
	
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Common:AddCallback(Common.OnSpell, function(unit, spell) self:OnProcessSpell(unit, spell) end)
	Common:AddCallback(Common.AfterAttack, function(target) self:OnAfterAttack(target) end)
end

function Riven:Tick()
	if self:IsUltOn() then
		self.Spells[0].range = 340
		self.Spells[1].range = 355
	else
		self.Spells[0].range = 265
		self.Spells[1].range = 280
	end
	
	self.Target = EOW:GetTarget() or Common:GetTarget()
	
	local CanUseQ = Game.CanUseSpell(_Q) == ONCOOLDOWN
	local CanUseE = Game.CanUseSpell(_E) == ONCOOLDOWN
	if CanUseQ then
		if self.CanUseQ then
			self:OnProcessSpell(myHero, {name = "RivenTriCleave"})
			self.CanUseQ = Game.CanUseSpell(_Q) == 0
		end
	else
		self.CanUseQ = Game.CanUseSpell(_Q) == 0
	end
	if CanUseE then
		if self.CanUseE then
			self:OnProcessSpell(myHero, {name = "RivenFeint"})
			self.CanUseE = Game.CanUseSpell(_E) == 0
		end
	else
		self.CanUseE = Game.CanUseSpell(_E) == 0
	end
	
	if EOW:Mode() == "Combo" then
		self:Combo()
	end
	
	if self.Menu.Killsteal.Enabled:Value() then
		self:Killsteal()
	end
end

function Riven:Draw()

end	

function Riven:OnProcessSpell(unit, spell)
	if unit.isMe then
		if spell.name == "RivenTriCleave" then
			DelayAction(function()
				Order:CastEmote(4)
			end, 0.2 - (Game.Latency() / 1000))
		elseif spell.name == "RivenFeint" then
			if EOW:Mode() == "Combo" then
				if self.Menu.Combo.CR:Value() and Common:Ready(_R) and not self:IsUltOn() and Common:ValidTarget(self.Target, 500) then
					Order:CastSpell(_R)
				end
			end
		elseif spell.name == "RivenMartyr" then
			if EOW:Mode() == "Combo" then
				if self.Menu.Combo.CQ:Value() and Common:ValidTarget(self.Target, self.Spells[0].range) then
					DelayAction(function()
						if Common:Ready(_Q) then
							Order:CastSpell(_Q, self.Target.pos)
						end
					end, Game.Latency() / 1000)
				end
			end
		elseif spell.name == "RivenIzunaBlade" then
			if EOW:Mode() == "Combo" then
				if self.Menu.Combo.CQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self.Spells[0].range) then
					Order:CastSpell(_Q)
				elseif self.Menu.Combo.Items.CH:Value() and self:HydraCheck() and Common:ValidTarget(self.Target, 350) then
					self:CastHydra()
				end
			end
		elseif spell.name == "ItemTiamatCleave" then
			if EOW:Mode() == "Combo" then
				if self.Menu.Combo.CW:Value() and Common:Ready(_W) and Common:ValidTarget(self.Target, self.Spells[1].range) then
					DelayAction(function()
						Order:CastSpell(_W)
					end, Game.Latency() / 1000)
				elseif self.Menu.Combo.CQ:Value() and Common:Ready(_Q) and Common:ValidTarget(self.Target, self.Spells[0].range) then
					Order:CastSpell(_Q, self.Target.pos)
				end
			end
		elseif spell.name == "RivenFengShuiEngine" then
			if self.Menu.Combo.Items.CGB:Value() then
				self:CastGhostblade()
			end
		end
	end
end

function Riven:OnAfterAttack(target)
	if EOW:Mode() == "Combo" then
		local Target = Common:GetHeroByHandle(target)
		if not Target then
			return
		end
		if self.Menu.Combo.CR2:Value() and Common:Ready(_R) and self:IsUltOn() and self:ShouldCastUlt(Target) and Common:ValidTarget(Target, self.Spells[3].range) then
			self:CastR(Target)
		elseif self.Menu.Combo.Items.CH:Value() and self:HydraCheck() and Common:ValidTarget(Target, 350) then
			self:CastHydra()
		elseif self.Menu.Combo.CW:Value() and Common:Ready(_W) and Common:ValidTarget(Target, self.Spells[1].range) then
			Order:CastSpell(_W)
		elseif self.Menu.Combo.CQ:Value() and Common:Ready(_Q) and Common:ValidTarget(Target) then
			Order:CastSpell(_Q, Target.pos)
		end
	end
end

function Riven:Combo()
	if myHero.attackData.state == STATE_WINDUP or not self.Target then
		return
	end
	if self.Menu.Combo.CE:Value() and Common:Ready(_E) and Common:ValidTarget(self.Target, 500) then
		Order:CastSpell(_E, self.Target.pos)
	end
	if self.Menu.Combo.CR2:Value() and Common:Ready(_R) and self:IsUltOn() and self:ShouldCastUlt(self.Target) and Common:ValidTarget(self.Target, self.Spells[3].range) then
		self:CastR(self.Target)
	end
end

function Riven:Killsteal()
	for i = 1, Game.HeroCount() do
		local h = Game.Hero(i)
		if self.Menu.Killsteal.KSR:Value() and Common:ValidTarget(h, self.Spells[3].range) and Common:Ready(_R) and self:IsUltOn() and self.Damage[3](h) > h.health + h.shieldAD then
			self:CastR(h)
			return
		end
	end
end

function Riven:CastR(unit)
	if not self:IsUltOn() then
		return
	end
	local Pred = Common:GetPrediction(unit, self.Spells[3])
	if Pred then
		Order:CastSpell(_R, Pred)
	end
end

function Riven:ShouldCastUlt(unit)
	return Common:GetPercentHP(unit) <= 25 or self.Damage[3](unit) > unit.health + unit.shieldAD
end

function Riven:HydraCheck()
	local Hydra = Common:GetItemSlot(myHero, 3074)
	local Tiamat = Common:GetItemSlot(myHero, 3077)
	if Hydra > 0 then
		return Common:ItemReady(Hydra)
	elseif Tiamat > 0 then
		return Common:ItemReady(Tiamat)
	end
end

function Riven:CastHydra()
	local Hydra = Common:GetItemSlot(myHero, 3074)
	local Tiamat = Common:GetItemSlot(myHero, 3077)
	if Hydra > 0 then
		if Common:ItemReady(Hydra) then
			Order:CastSpell(Hydra)
		end
	elseif Tiamat > 0 then
		if Common:ItemReady(Tiamat) then
			Order:CastSpell(Tiamat)
		end
	end
end

function Riven:CastGhostblade()
	local GB = Common:GetItemSlot(myHero, 3142)
	if GB > 0 and Common:ItemReady(GB) then
		Order:CastSpell(GB)
	end
end

function Riven:IsUltOn()
	return myHero:GetSpellData(_R).name == "RivenIzunaBlade"
end

Callback.Add("Load", function()
	if _G[myHero.charName] then
		_G.Common = Common()
		_G[myHero.charName]()
	end
end)
