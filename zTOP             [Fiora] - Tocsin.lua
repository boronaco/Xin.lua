class "Fiora"
 
require = 'DamageLib'

function Fiora:__init()
	if myHero.charName ~= "Fiora" then return end
PrintChat("Fiora - Tocsin loaded")
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

local Icons = {
["FioraIcon"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/a/a7/Fiora_OriginalLoading.jpg",
["Q"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/7/79/Lunge.png",
["W"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/d/de/Riposte.png",
["E"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/0/05/Bladework.png",
["R"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/4/4e/Grand_Challenge.png"
}

function Fiora.LoadSpells()

	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Fiora:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "Fiora", name = "Fiora", leftIcon = Icons["FioraIcon"]})

--Combo Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
	self.Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
	self.Menu.Combo:MenuElement({id = "UseR", name = "Use R", value = true, leftIcon = Icons.R})
	self.Menu.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 1, min = 1, max = 5})
--Harass Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Harass:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.Harass:MenuElement({id = "UseE", name = "Use E", value = false, leftIcon = Icons.E})

--LaneClear Not used on Fiora

	--self.Menu:MenuElement({type = MENU, id = "LaneClear", name = "Lane Clear"})
  	--self.Menu.LaneClear:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
  	--self.Menu.LaneClear:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
  	--self.Menu.LaneClear:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})

--LastHit Not used on Fiora
--[[
	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	self.Menu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.LastHit:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.LastHit:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
--]]
--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.JungleClear:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.JungleClear:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.JungleClear:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
  	self.Menu.JungleClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 30, min = 0, max = 100})

--misc
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
		if myHero:GetSpellData(4).name == "SummonerDot" or myHero:GetSpellData(5).name == "SummonerDot" then
			self.Menu.Misc:MenuElement({id = "UseIgnite", name = "Use Ignite", value = true})
		end

--Drawings Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawing Settings"})
	self.Menu.Drawings:MenuElement({id = "drawQ", name = "Draw Q Range", value = true})
end

function Fiora:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			self:JungleClear()
		--elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
    	--	self:LastHit()
    	--elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
    	--	self:LaneClear()
    	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
    		self:Harass()
		end
	self:Misc()
end

function Fiora:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, Q.range, 3, Draw.Color(225, 225, 0, 10))
	end
end
 
function Fiora:Combo()
	local  rtarg = _G.SDK.TargetSelector:GetTarget(R.range) 
		if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    		if self:CountEnemys(400) >= self.Menu.Combo.ER:Value() then
    				self:CastR(rtarg)
      		end
    	end
	local qtarg = _G.SDK.TargetSelector:GetTarget(390)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
			local castPosition = qtarg
				self:CastQ(castPosition)
		end
	local etarg = _G.SDK.TargetSelector:GetTarget(E.range)
		if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
			Control.CastSpell(HK_E)
		end
	local wtarg = _G.SDK.TargetSelector:GetTarget(200)
		if wtarg and self.Menu.Combo.UseW:Value() and not self:CanCast(_E) and self:CanCast(_W) then
			local castPosition = wtarg
				self:CastW(castPosition)
		end
end

function Fiora:JungleClear()
  	if self:GetValidMinion(Q.range) == false then return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 then
			if self:IsValidTarget(minion,300) and myHero.pos:DistanceTo(minion.pos) < 350 and self.Menu.JungleClear.UseQ:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_Q) then
			Control.CastSpell(HK_Q)
			break
			end
			if self:IsValidTarget(minion,175) and myHero.pos:DistanceTo(minion.pos) < 175 and self.Menu.JungleClear.UseW:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_W) then
				Control.CastSpell(HK_W)
			break
			end
			if self:IsValidTarget(minion,175) and myHero.pos:DistanceTo(minion.pos) < 175 and self.Menu.JungleClear.UseE:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_E) then
			Control.CastSpell(HK_E)
			break
			end
		end
	end
end

	

function Fiora:Harass()
	local qtarg = _G.SDK.TargetSelector:GetTarget(390)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
			local castPosition = qtarg
				self:CastQ(castPosition)
		end
	local etarg = _G.SDK.TargetSelector:GetTarget(E.range)
		if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
			Control.CastSpell(HK_E)
		end
	local wtarg = _G.SDK.TargetSelector:GetTarget(200)
		if wtarg and self.Menu.Combo.UseW:Value() and not self:CanCast(_E) and self:CanCast(_W) then
			local castPosition = wtarg
				self:CastW(castPosition)
		end
end

function Fiora:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 400 
end

function Fiora:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Fiora:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < Q.range then
        return true
        end
    	end
    	return false
end

--[[
function Fiora:LastHit()
	
end
--]] 

function Fiora:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 500 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function Fiora:CastQ(position)
	if position then
		Control.SetCursorPos(position)
		Control.CastSpell(HK_Q, position)
	end
end

function Fiora:CastW(position)
	if position then
		Control.SetCursorPos(position)
		Control.CastSpell(HK_W, position)
	end
end

function Fiora:CastE(target)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=E.range then
				Control.CastSpell(HK_E)
			end
		end
	end
return false
end

function Fiora:CastR(target)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=450 then
				Control.CastSpell(HK_R)
			end
		end
	end
return false
end

--KS on tick
function Fiora:Misc()
     for i = 1,Game.HeroCount() do
        local Enemy = Game.Hero(i)
            if myHero:GetSpellData(5).name == "SummonerDot" and self.Menu.Misc.UseIgnite:Value() and self:IsReady(SUMMONER_2) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_2, Enemy)
                    return;
                end
            end

            if myHero:GetSpellData(4).name == "SummonerDot" and self.Menu.Misc.UseIgnite:Value() and self:IsReady(SUMMONER_1) then
                if self:IsValidTarget(Enemy, 600, false, myHero.pos) and Enemy.health + Enemy.hpRegen*2.5 + Enemy.shieldAD < 50 + 20*myHero.levelData.lvl then
                    Control.CastSpell(HK_SUMMONER_1, Enemy)
                    return;
                end
            end
        end
end

function Fiora:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Fiora:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	Fiora()
end