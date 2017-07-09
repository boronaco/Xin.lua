if myHero.charName ~= "Khazix" then PrintChat("") return end

class "KhazixUnchained"
require("DamageLib")
require 'MapPositionGOS'

function OnLoad() KhazixUnchained() end

class "KhazixUnchained"
local aPosition

function KhazixUnchained:__init()
    Q = {range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay}
    W = {range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed,  width = myHero:GetSpellData(_W).width}
    E = {range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed,  width = myHero:GetSpellData(_E).width}

    self:Menu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function KhazixUnchained:Menu()
    self.Menu = MenuElement({type = MENU, name = "KhazixUnchained", id = "KhazixUnchained"})
    
    self.Menu:MenuElement({type = MENU, id ="Combo", name = "Combo Settings"})
    self.Menu.Combo:MenuElement({id = "Q", name ="Use Q", value = true})
    self.Menu.Combo:MenuElement({id = "W", name ="Use W", value = true})
    self.Menu.Combo:MenuElement({id = "E", name ="Use E", value = false})
    self.Menu.Combo:MenuElement({id = "R", name ="Use R", value = false})
    self.Menu.Combo:MenuElement({id = "Assassinate", name ="Assassinate (Only with Evloved E!)", key = 54, value = true, toggle = true})

    self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Menu.Harass:MenuElement({id = "Q", name ="Use Q", value = false})
    self.Menu.Harass:MenuElement({id = "W", name ="Use W", value = true})
    self.Menu.Harass:MenuElement({id = "Mana", name ="Mana Manager", value = 60, min = 0, max = 100, step = 1})

    self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	self.Menu.Misc:MenuElement({id = "WFlee", name = "W to flee", value = true})
    self.Menu.Misc:MenuElement({id = "RFlee", name = "R to flee", value = true})
    self.Menu.Misc:MenuElement({id = "REnemies", name ="Enemies for R", value = 2, min = 0, max = 5, step = 1})
end

function KhazixUnchained:Tick()
    if not myHero.dead then
        local target = _G.SDK.TargetSelector:GetTarget(2000)

        if target and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            self:Flee()
        end

        if  _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then   
            self:Combo(target)
        end

        if target  and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then   
            self:Harass(target)
        end     
    
    end
end

function KhazixUnchained:Combo(target)
    if target then
        if(myHero.pos:DistanceTo(target.pos) < Q.range and Utility:IsReady(_Q) and self.Menu.Combo.Q:Value()) then
            Control.CastSpell(HK_Q,target)
        end
        if(myHero.pos:DistanceTo(target:GetPrediction(W.speed, W.delay)) < 1.1*W.range and Utility:IsReady(_W) and target:GetCollision(W.width, W.speed, W.delay) == 0 and self.Menu.Combo.W:Value()) then
            Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay))
        end
        if(myHero.pos:DistanceTo(target:GetPrediction(E.speed, E.delay)) < (E.range+Q.range-50) and Utility:IsReady(_E) and self.Menu.Combo.E:Value()) then
            aPosition = target.pos:Extended(myHero.pos, E.range)
            Control.CastSpell(HK_E,target:GetPrediction(E.speed, E.delay))
        end
        if(Utility:IsReady(_R) and self.Menu.Combo.R:Value() and not Utility:IsReady(_Q)) then
            Control.CastSpell(HK_R)
        end
        if(not Utility:IsReady(_Q) and self.Menu.Combo.Assassinate:Value() and Utility:HasBuff(myHero,"KhazixEEvo")) then
            Control.CastSpell(HK_E, aPosition)
        end
    end
    if(not Utility:IsReady(_Q) and self.Menu.Combo.Assassinate:Value() and Utility:HasBuff(myHero,"KhazixEEvo")) then
        Control.CastSpell(HK_E, aPosition)
    end

end

function KhazixUnchained:Harass(target)
    if(Utility:GetPercentMP(myHero) >= self.Menu.Harass.Mana:Value()) then
        if(myHero.pos:DistanceTo(target.pos) < Q.range and Utility:IsReady(_Q) and self.Menu.Harass.Q:Value()) then
            Control.CastSpell(HK_Q,target)
        end
        if(myHero.pos:DistanceTo(target:GetPrediction(W.speed, W.delay)) < 1.1* W.range and Utility:IsReady(_W) and target:GetCollision(W.width, W.speed, W.delay) == 0 and self.Menu.Harass.W:Value()) then
            Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay))
        end
    end
end

function KhazixUnchained:Flee()
    if(Utility:IsReady(_E)) then
        local nearestEnemy = self:NearestEnemy(1500)
        local distance = E.range + (nearestEnemy.pos:DistanceTo(myHero.pos))
        local jumpPoint = nearestEnemy.pos:Extended(myHero.pos, distance)
        if(not MapPosition:inWall(jumpPoint)) then
            Control.CastSpell(HK_E,jumpPoint)
        end
    end

    if(self:EnemiesInRange(750) >= self.Menu.Misc.REnemies:Value() and Utility:IsReady(_E) == false) then
        Control.CastSpell(HK_R)
    end
end

function KhazixUnchained:DamageCalc(isIsolated,target)
    local damage = 0
    if(isIsolated) then
        if(Utility:IsReady(_Q)) then
            damage = (getdmg("Q",target)*1.5)
        end
        if(Utility:IsReady(_W)) then
            damage = damage + getdmg("W", target)
        end
        if(Utility:IsReady(_E)) then
            damage = damage + getdmg("E", target)
        end
    else
        if(Utility:IsReady(_Q)) then
            damage = getdmg("Q",target)
        end
        if(Utility:IsReady(_W)) then
            damage = damage + getdmg("W", target)
        end
        if(Utility:IsReady(_E)) then
            damage = damage + getdmg("E", target)
        end
    end
    damage = damage + getdmg("AA",target)
    return damage
end

function KhazixUnchained:TargetIsolated(target)
    local count = 0

    for i=1, #Utility:GetEnemyHeroes() do
        if(Utility:GetEnemyHeroes()[i] ~= target and Utility:GetEnemyHeroes()[i].pos:DistanceTo(target.pos) < 300) then
            count = count + 1
        end
    end

    for i=1, Game.MinionCount() do
        if(Game.Minion(i).pos:DistanceTo(target.pos) < 300) then
            count = count + 1
        end
    end
    if (count > 0) then
        return false
    else
        return true
    end
end


function KhazixUnchained:NearestEnemy(range)
    local distance = range
    local champion
    for i=1, #Utility:GetEnemyHeroes() do
        if (myHero.pos:DistanceTo(Utility:GetEnemyHeroes()[i].pos) ~= nil and myHero.pos:DistanceTo(Utility:GetEnemyHeroes()[i].pos) < distance) then 
            distance = myHero.pos:DistanceTo(Utility:GetEnemyHeroes()[i].pos)
            champion = Utility:GetEnemyHeroes()[i]
        end
    end
    return champion
end

function KhazixUnchained:EnemiesInRange(range)
    local count = 0
    for i=1, #Utility:GetEnemyHeroes() do
        if (myHero.pos:DistanceTo(Utility:GetEnemyHeroes()[i].pos) < range) then
            count = count + 1
        end
    end
    return count
end

function KhazixUnchained:EnemiesInRangeofTarget(range,target)
    local count = 0
    for i=1, #Utility:GetEnemyHeroes() do
        if (target.pos:DistanceTo(Utility:GetEnemyHeroes()[i].pos) < range) then
            count = count + 1
        end
    end
    return count
end

function KhazixUnchained:Draw()
    local target = _G.SDK.TargetSelector:GetTarget(1000)
    if target then 
        local isIsolated = self:TargetIsolated(target)
        local calculatedDamage = self:DamageCalc(isIsolated,target)
        if(calculatedDamage > target.health) then
            Draw.Text("", target.pos:To2D())
        end
    end
    local offOn
    if (self.Menu.Combo.Assassinate:Value()) then offOn = "" else offOn = "" end
    Draw.Text("" .. offOn, myHero.pos:To2D() )
end

class "Utility"

function Utility:__init()
end

function Utility:GetPercentHP(unit)
	return 100 * unit.health / unit.maxHealth
end

function Utility:GetPercentMP(unit)
	return 100 * unit.mana / unit.maxMana
end

function Utility:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Utility:GetAllyHeroes()
	self.AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isAlly and not Hero.isMe then
			table.insert(self.AllyHeroes, Hero)
		end
	end
	return self.AllyHeroes
end

function Utility:GetBuffs(unit)
	self.T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(self.T, Buff)
		end
	end
	return self.T
end

function Utility:HasBuff(unit, buffname)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			return true
		end
	end
	return false
end

function Utility:GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.name:lower() == buffname:lower() and Buff.count > 0 then
			return Buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}
end

function Utility:IsImmune(unit)
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if (Buff.name == "kindredrnodeathbuff" or Buff.name == "undyingrage") and self:GetPercentHP(unit) <= 10 then
			return true
		end
		if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" then 
            return true
        end
	end
	return false
end

function Utility:IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if type(range) ~= "number" then error("{IsValidTarget}: bad argument #2 (number expected, got "..type(range)..")") end
    if type(checkTeam) ~= "nil" and type(checkTeam) ~= "boolean" then error("{IsValidTarget}: bad argument #3 (boolean or nil expected, got "..type(checkTeam)..")") end
    if type(from) ~= "nil" and type(from) ~= "userdata" then error("{IsValidTarget}: bad argument #4 (vector or nil expected, got "..type(from)..")") end
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or Utility:IsImmune(unit) or (checkTeam and unit.isAlly) then 
    return false 
  end 
  return unit.pos:DistanceTo(from and from or myHero) < range 
end

function Utility:IsReady(slot)
	if Game.CanUseSpell(slot) == 0 then
		return true
	end
	return false
end


Utility()
