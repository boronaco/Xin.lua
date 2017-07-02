class "Amumu"
 
require = 'DamageLib'

function Amumu:__init()
	if myHero.charName ~= "Amumu" then return end
PrintChat("Amumu - Tocsin loaded")
self:LoadSpells()
self:LoadMenu()
Callback.Add("Tick", function() self:Tick() end)
Callback.Add("Draw", function() self:Draw() end)
end

local Icons = {
["AmumuIcon"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/a/a9/Amumu_OriginalLoading.jpg",
["Q"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/b/b5/Bandage_Toss.png",
["W"] = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/2/25/Despair.png",
["E"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/b/b3/Tantrum.png",
["R"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/7/72/Curse_of_the_Sad_Mummy.png"
}

function Amumu.LoadSpells()

	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width }
end

function Amumu:LoadMenu()

--Main Menu

	self.Menu = MenuElement({type = MENU, id = "Amumu", name = "Amumu", leftIcon = Icons["AmumuIcon"]})

--Combo Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})
	self.Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = Icons.W})
	self.Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true, leftIcon = Icons.E})
	self.Menu.Combo:MenuElement({id = "UseR", name = "Use R", value = true, leftIcon = Icons.R})
	self.Menu.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 2, min = 1, max = 5})
--Harass Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})

--LastHit

	self.Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit"})
	self.Menu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = Icons.Q})

--JungleClear
	self.Menu:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.JungleClear:MenuElement({id = "W", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.JungleClear:MenuElement({id = "E", name = "Use E", value = true, leftIcon = Icons.E})
  	self.Menu.JungleClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 30, min = 0, max = 100})

--Drawings Settings Menu

	self.Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawing Settings"})
	self.Menu.Drawings:MenuElement({id = "drawQ", name = "Draw Q Range", value = true})
	self.Menu.Drawings:MenuElement({id = "drawW", name = "Draw W Range", value = true})
end

function Amumu:Tick()
	if myHero.dead then return end
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			self:Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			self:JungleClear()
		--elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
    		--self:LastHit()
		end

end

function Amumu:Draw()
	if myHero.dead then return end
	if(self.Menu.Drawings.drawQ:Value())then
		Draw.Circle(myHero, Q.range, 3, Draw.Color(225, 225, 0, 10))
	end
	if(self.Menu.Drawings.drawW:Value())then
		Draw.Circle(myHero, W.range, 3, Draw.Color(225, 225, 0, 10))
	end
end

function Amumu:Combo()
	local qtarg = _G.SDK.TargetSelector:GetTarget(1000)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q) then
			self:CastQ(qtarg)
		end

	local wtarg = _G.SDK.TargetSelector:GetTarget(300)
		if wtarg and self.Menu.Combo.UseW:Value() and myHero:GetSpellData(_W).toggleState == 1 then
			Control.CastSpell(HK_W)
		end

	local etarg = _G.SDK.TargetSelector:GetTarget(E.range)
		if etarg and self.Menu.Combo.UseE:Value() and self:CanCast(_E) then
			local castPosition = etarg
			self:CastE(castPosition)
		end
	
	local otarg = _G.SDK.TargetSelector:GetTarget(1000)
		if not otarg and self.Menu.Combo.UseW:Value() and myHero:GetSpellData(_W).toggleState == 2 then
			Control.CastSpell(HK_W)
		end

	local  rtarg = _G.SDK.TargetSelector:GetTarget(E.range) 
		if rtarg and self.Menu.Combo.UseR:Value() and self:CanCast(_R) then
    	if self:CountEnemys(450) >= self.Menu.Combo.ER:Value() then
    	Control.CastSpell(HK_R)
      	end
    	end	
end

function Amumu:JungleClear()
  	if self:GetValidMinion(Q.range) == false then self:JungleW() return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 then
			if self:IsValidTarget(minion,800) and myHero.pos:DistanceTo(minion.pos) < 800 and self.Menu.JungleClear.Q:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_Q) then
			Control.CastSpell(HK_Q,minion.pos)
			break
			end
			if self:IsValidTarget(minion,300) and myHero.pos:DistanceTo(minion.pos) < 300 and self.Menu.JungleClear.W:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and myHero:GetSpellData(_W).toggleState == 1 then
				Control.CastSpell(HK_W)
			break
			end
			if self:IsValidTarget(minion,350) and myHero.pos:DistanceTo(minion.pos) < 350 and self.Menu.JungleClear.E:Value() and (myHero.mana/myHero.maxMana >= self.Menu.JungleClear.Mana:Value() / 100 ) and self:CanCast(_E) then
			Control.CastSpell(HK_E,minion.pos)
			break
			end
		end
	end
end

function Amumu:JungleW()
  	if self:GetValidMinion(Q.range) == false then
  		if self.Menu.Combo.UseW:Value() and myHero:GetSpellData(_W).toggleState == 2 then
			Control.CastSpell(HK_W)
		end	
	end
end		
--[[
function Amumu:Harass()
	local qtarg = _G.SDK.TargetSelector:GetTarget(950)
		if qtarg and self.Menu.Combo.UseQ:Value() and self:CanCast(_Q)then
			self:CastQ(qtarg)
		end
end
--]]
function Amumu:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 970 
end

function Amumu:HpPred(unit, delay)
	if _G.GOS then
		hp =  GOS:HP_Pred(unit,delay)
	else
		hp = unit.health
	end
	return hp
end

function Amumu:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < Q.range then
        return true
        end
    	end
    	return false
end

--[[
function Amumu:LastHit()
	if self.Menu.LastHit.UseQ:Value() == false then return end
	local level = myHero:GetSpellData(_Q).level
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
		if  minion.team == 200 then
		local Qdamage = (({80, 130, 180, 230, 280})[level])
    		if self:IsValidTarget(minion,970) and myHero.pos:DistanceTo(minion.pos) < 970 and minion.isEnemy then
      			if Qdamage >= self:HpPred(minion, 0.5) and self:CanCast(_Q) then
					Control.CastSpell(HK_Q,minion.pos)
				end
			end
		end
	end
end
--]] 

function Amumu:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 450 then
			heroesCount = heroesCount + 1
        end
    	end
		return heroesCount
end 

function Amumu:CastQ(target)
	if target then
		if not target.dead and not target.isImmune then
			if target.distance<=Q.range then
				local pred=target:GetPrediction(Q.speed,Q.delay)
				Control.CastSpell(HK_Q,pred)
			end
		end
	end
return false
end

function Amumu:CastW(target)
	if target then
		if not target.dead and not target.isImmune then
			if myHero:GetSpellData(_W).toggleState == 1 and target.distance<=W.range then
				Control.CastSpell(HK_W)
			end
		end
	end
return false
end

function Amumu:CastE(position)
	if position then
		Control.SetCursorPos(position)
		Control.CastSpell(HK_E, position)
	end
end


function Amumu:IsReady(spellSlot)
	return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function Amumu:CanCast (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	Amumu()
end