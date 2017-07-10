class "Renekton"

function Renekton:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Renekton:LoadSpells()
	Q = {range = 325, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width}
	W = {range = 200, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width}
	E = {range = 450, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width}
	R = {range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width}
end

function Renekton:LoadMenu()

	-------Menu------------------------------------------------------------------------------
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "Renekton"})
	-------BronzeSeries----------------------------------------------------------------------
	self.Menu:MenuElement({type = MENU, id = "Mode", name = "BronzeSeries: Renekton"})
	-------Combo---------------------------------------------------------------------------------------
	self.Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	self.Menu.Mode.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "W", name = "Use [W]", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "E", name = "Use [E]", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "R", name = "Use auto [R]", value = true})
	self.Menu.Mode.Combo:MenuElement({id = "RHP", name = "HP% to [R]", value = 15, min = 0, max = 100, step = 1})
	-------LaneClear------------------------------------------------------------------------------------
	self.Menu.Mode:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
	self.Menu.Mode.LaneClear:MenuElement({id = "Q", name = "Use [Q]", value = true})
	self.Menu.Mode.LaneClear:MenuElement({id = "Qhits", name = "Use [Q] when X minions", value = 3,min = 1, max = 7, step = 1})
	self.Menu.Mode.LaneClear:MenuElement({id = "fm", name = "Fury Manager", drop = {"Save Fury at 50", "Don't save Fury"}})
	-------JungleClear--------------------------------------------------------------------------------------------------------
	self.Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
	self.Menu.Mode.JungleClear:MenuElement({id = "Q", name = "Use [Q]", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "W", name = "Use [W]", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "E", name = "Use [E]", value = true})
	self.Menu.Mode.JungleClear:MenuElement({id = "fm", name = "Fury Manager", drop = {"Save Fury at 50", "Don't save Fury"}})
	-------Drawing----------------------------------------------------------------------
	self.Menu:MenuElement({type = MENU, id = "Drawing", name = "BronzeSeries: Drawings"})
	self.Menu.Drawing:MenuElement({id = "Q", name = "Draw [Q] Range", value = false})
	self.Menu.Drawing:MenuElement({id = "E", name = "Draw [E] Range", value = false})

end

function Renekton:Tick()
	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
	local LastHit = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.GOS and _G.GOS:GetMode() == "Lasthit") or (_G.EOWLoaded and EOW:Mode() == "LastHit")
	if Combo then
		self:Combo()
	elseif Clear then
		self:Clear()
	elseif LastHit then
		self:LastHit()
	end
end

function Renekton:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function Renekton:GetValidEnemy(range)
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < range then
            return true
        end
    end
    return false
end

function Renekton:GetValidMinion(range)
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < range then
            return true
        end
    end
    return false
end

function Renekton:CountEnemyMinions(range)
	local minionsCount = 0
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < range then
            minionsCount = minionsCount + 1
        end
    end
    return minionsCount
end

function Renekton:isReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function Renekton:IsValidTarget(unit,range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= range
end

function Renekton:Combo()

	if self:GetValidEnemy(1000) == false then return end
	
	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
	
	local target =  (_G.SDK and _G.SDK.TargetSelector:GetTarget(1000, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(1000,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
	---------- Auto R in combo -------------------
	if self.Menu.Mode.Combo.R:Value() and self:isReady(_R) and (myHero.health/myHero.maxHealth <= self.Menu.Mode.Combo.RHP:Value() / 100) then
		Control.CastSpell(HK_R)
	end
	if self:IsValidTarget(target,E.range) and self.Menu.Mode.Combo.E:Value() and self:isReady(_E) and not myHero.isChanneling then
		Control.CastSpell(HK_E,target)
		if self:IsValidTarget(target,Q.range) and self.Menu.Mode.Combo.W:Value() and myHero.attackData.state == STATE_WINDDOWN and self:isReady(_W) and not myHero.isChanneling  then
			Control.CastSpell(HK_W)
		end
	    if self:IsValidTarget(target,Q.range) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
			Control.CastSpell(HK_Q)
		end
	end
	if self:IsValidTarget(target,Q.range) and self.Menu.Mode.Combo.W:Value() and myHero.attackData.state == STATE_WINDDOWN and self:isReady(_W) and not myHero.isChanneling  then
		Control.CastSpell(HK_W)
		if self:IsValidTarget(target,Q.range) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
			Control.CastSpell(HK_Q)
		end
	end
	if self:IsValidTarget(target,Q.range) and self.Menu.Mode.Combo.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
		Control.CastSpell(HK_Q)
	end	
end

function Renekton:Clear()

	if self:GetValidMinion(600) == false then return end

	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if  minion.team == 200 then
			---------------- Save Fury at 50 --------
			if self.Menu.Mode.LaneClear.fm:Value() == 1 then
				if self:IsValidTarget(minion,Q.range) and myHero.mana <= 49 and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
					if self:CountEnemyMinions(Q.range) >= self.Menu.Mode.LaneClear.Qhits:Value() then
						Control.CastSpell(HK_Q)
					break
					end
				end
			end
			---------------- Don't save Fury --------
			if self.Menu.Mode.LaneClear.fm:Value() == 2 then
				if self:IsValidTarget(minion,Q.range) and self.Menu.Mode.LaneClear.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
					if self:CountEnemyMinions(Q.range) >= self.Menu.Mode.LaneClear.Qhits:Value() then
						Control.CastSpell(HK_Q)
					break
				end
			end
		end
		elseif minion.team == 300 then
			---------------- Save Fury at 50 --------
			if self.Menu.Mode.JungleClear.fm:Value() == 1 then
				if self:IsValidTarget(minion,Q.range) and myHero.mana <= 49 and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
						Control.CastSpell(HK_Q)
					break
				end
				if  self:IsValidTarget(minion,Q.range) and myHero.mana <= 49 and self.Menu.Mode.JungleClear.W:Value() and self:isReady(_W) and myHero.attackData.state == STATE_WINDUP and not myHero.isChanneling then
						Control.CastSpell(HK_W)
					break
					end
				if  self:IsValidTarget(minion,E.range) and myHero.mana <= 49 and self.Menu.Mode.JungleClear.E:Value() and self:isReady(_E) and not myHero.isChanneling then
						Control.CastSpell(HK_E,target)
					break
					end
			end
			---------------- Don't save Fury --------
			if self.Menu.Mode.JungleClear.fm:Value() == 2 then
				if self:IsValidTarget(minion,Q.range) and self.Menu.Mode.JungleClear.Q:Value() and self:isReady(_Q) and not myHero.isChanneling then
						Control.CastSpell(HK_Q)
					break
				end
				if  self:IsValidTarget(minion,Q.range) and self.Menu.Mode.JungleClear.W:Value() and self:isReady(_W) and myHero.attackData.state == STATE_WINDUP and not myHero.isChanneling then
						Control.CastSpell(HK_W)
					break
				end
				if  self:IsValidTarget(minion,E.range) and self.Menu.Mode.JungleClear.E:Value() and self:isReady(_E) and not myHero.isChanneling then
						Control.CastSpell(HK_E,target)
					break
				end
			end
		end
	end
end	

function Renekton:GetPercentHP(unit)
  if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
  return 100*unit.health/unit.maxHealth
end

function Renekton:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Renekton:Draw()
	if myHero.dead then return end
	if self.Menu.Drawing.Q:Value() then Draw.Circle(myHero.pos,Q.range,3,Draw.Color(255, 0, 0, 220)) end			
	if self.Menu.Drawing.E:Value() then Draw.Circle(myHero.pos,E.range,3,Draw.Color(220,255,0,0)) end	
end

function OnLoad()
	if myHero.charName ~= "Renekton" then return end
	Renekton()
end
