class "XinZhao" 

function XinZhao:__init() 
	self:LoadSpells()
  	self:LoadMenu() 
  	Callback.Add("Tick", function() self:Tick() end)
  	
end

function XinZhao:LoadSpells() 
  	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
	E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
	
end

function XinZhao:LoadMenu()
  	local Icons = { C = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/6/63/Xin_ZhaoSquare.png",
    			Q = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/0/07/Three_Talon_Strike.png",
    			W = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/0/03/Battle_Cry.png",
    			E = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/d/d7/Audacious_Charge.png",
                    	
	-- Main Menu -------------------------------------------------------------------------------------------------------------------
  	self.Menu = MenuElement({type = MENU, id = "Menu", name = "The Ripper Series", leftIcon = Icons.C})
	-- XinZhao ---------------------------------------------------------------------------------------------------------------------
	self.Menu:MenuElement({type = MENU, id = "Ripper", name = "Xin Zhao The Ripper", leftIcon = Icons.C })
	-- Combo -----------------------------------------------------------------------------------------------------------------------
  	self.Menu.Ripper:MenuElement({type = MENU, id = "Combo", name = "Combo"})
  	self.Menu.Ripper.Combo:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.Ripper.Combo:MenuElement({id = "W", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.Ripper.Combo:MenuElement({id = "E", name = "Use E", value = true, leftIcon = Icons.E})
  	
	
	-- JungleClear -----------------------------------------------------------------------------------------------------------------
  	self.Menu.Ripper:MenuElement({type = MENU, id = "JungleClear", name = "Jungle Clear"})
  	self.Menu.Ripper.JungleClear:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.Ripper.JungleClear:MenuElement({id = "W", name = "Use W", value = true, leftIcon = Icons.W})
  	
	self.Menu.Ripper.JungleClear:MenuElement({id = "Mana", name = "Min mana to Clear (%)", value = 40, min = 0, max = 100})
	
	-- Killsteal -------------------------------------------------------------------------------------------------------------------
  	self.Menu.Ripper:MenuElement({type = MENU, id = "KS", name = "Killsteal"})
  	self.Menu.Ripper.KS:MenuElement({id = "E", name = "Use E", value = true, leftIcon = Icons.E})
  	
	
	
end

function XinZhao:Tick()
  	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
  	local LastHit = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.GOS and _G.GOS:GetMode() == "Lasthit") or (_G.EOWLoaded and EOW:Mode() == "LastHit")
  	local Clear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR]) or (_G.GOS and _G.GOS:GetMode() == "Clear") or (_G.EOWLoaded and EOW:Mode() == "LaneClear")
  	
  	
  	if Combo then
    	self:Combo()
    	elseif LastHit then
    	self:LastHitQ()
    	self:LastHitE()
    	elseif Clear then
    	self:LaneClear()
    	self:JungleClear()
    	
    	
    	
    	end
	self:KS()
end

function XinZhao:GetValidEnemy(range)
  	for i = 1,Game.HeroCount() do
    	local enemy = Game.Hero(i)
    	if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 650 then
    	return true
    	end
    	end
  	return false
end

function XinZhao:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 650 
end

function XinZhao:Ready (spell)
	return Game.CanUseSpell(spell) == 0 
end

function XinZhao:CountEnemys(range)
	local heroesCount = 0
    	for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 650 then
	heroesCount = heroesCount + 1
        end
    	end
    	return heroesCount
end

function XinZhao:Combo()
  	if self:GetValidEnemy(650) == false then return end
  	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
  	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(650, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(650,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())

	if self:IsValidTarget(target,125) and myHero.pos:DistanceTo(target.pos) < 125 and self.Menu.Ripper.Combo.W:Value() and self:Ready(_W) then
    	Control.CastSpell(HK_W)
    	end
  	if self:IsValidTarget(target,650) and myHero.pos:DistanceTo(target.pos) < 650  and self.Menu.Ripper.Combo.E:Value() and self:Ready(_E) then
    	Control.CastSpell(HK_E,target)
    	end
  	if self:IsValidTarget(target,125) and myHero.pos:DistanceTo(target.pos) < 125 and self.Menu.Ripper.Combo.Q:Value() and self:Ready(_Q) then
    	Control.CastSpell(HK_Q)
    	end
  	
    	
end

function XinZhao:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 650 then
        return true
        end
    	end
    	return false
end

function XinZhao:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
	end

function XinZhao:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
	local buff = unit:GetBuff(i)
	if buff.name == buffname and buff.count > 0 then 
	return true
	end
	end
	return false
	end

function XinZhao:LastHitQ()
  	if self.Menu.Ripper.LastHit.Q:Value() == false then return end
  	local level = myHero:GetSpellData(_Q).level
	if level == nil or level == 0 then return end
  	if self:GetValidMinion(myHero.range) == false then return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	local Qdamage = (({15, 30, 45, 60, 75})[level] + 0.2 * myHero.totalDamage)
    	if self:IsValidTarget(minion,125) and myHero.pos:DistanceTo(minion.pos) < 125 and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.LastHit.Mana:Value() / 100 ) and minion.isEnemy then
      	if Qdamage >= self:HpPred(minion, 0.5) and self:Ready(_Q) then
        Control.CastSpell(HK_Q)
        elseif Qdamage >= minion.health and self:HasBuff(myHero, "XenZhaoComboTarget") then
        Control.SetCursorPos(minion.pos)
        end
      	end
    	end
end  	

function XinZhao:LastHitE()
  	if self.Menu.Ripper.LastHit.E:Value() == false then return end
  	local level = myHero:GetSpellData(_E).level
	if level == nil or level == 0 then return end
  	if self:GetValidMinion(myHero.range) == false then return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	local Edamage = (({70, 110, 150, 190, 230})[level] + 0.6 * myHero.ap)
    	if self:IsValidTarget(minion,925) and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.LastHit.Mana:Value() / 100 ) and minion.isEnemy then
      	if Edamage >= minion.health and Edamage >= self:HpPred(minion, 0.5) and self:Ready(_E) then
        Control.CastSpell(HK_E,minion.pos)
        end
      	end
    	end
end  
    		
function XinZhao:JungleClear()
  	if self:GetValidMinion(E.range) == false then return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 300 then
      	if self:IsValidTarget(minion,125) and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.JungleClear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) < 125  and self.Menu.Ripper.JungleClear.Q:Value() and self:Ready(_Q) then
	Control.CastSpell(HK_Q)
	break
	end
	if self:IsValidTarget(minion,125) and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.JungleClear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) < 125 and self.Menu.Ripper.JungleClear.W:Value() and self:Ready(_W) then
	Control.CastSpell(HK_W)
	break
	end
	if self:IsValidTarget(minion,650) and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.JungleClear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.Ripper.JungleClear.E:Value() and self:Ready(_E) then
	Control.CastSpell(HK_E,minion.pos)
	break
	end
      	end
    	end
end

function XinZhao:LaneClear()
  	if self:GetValidMinion(E.range) == false then return end
  	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
    	if  minion.team == 200 then
      	if self:IsValidTarget(minion,125) and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.LaneClear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) < 125 and self.Menu.Ripper.LaneClear.Q:Value() and self:Ready(_Q) then
	Control.CastSpell(HK_Q)
	break
	end
	if self:IsValidTarget(minion,125) and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.LaneClear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) < 125 and self.Menu.Ripper.LaneClear.W:Value() and self:Ready(_W) then
	Control.CastSpell(HK_W)
	break
	end
	if self:IsValidTarget(minion,650) and myHero.mana/myHero.maxMana >= (self.Menu.Ripper.LaneClear.Mana:Value() / 100 ) and myHero.pos:DistanceTo(minion.pos) < 650 and self.Menu.Ripper.LaneClear.E:Value() and self:Ready(_E) then
	Control.CastSpell(HK_E,minion.pos)
	break
	end
      	end
    	end
end





function XinZhao:KS()
  	if self:GetValidEnemy(650) == false then return end
  	if (not _G.SDK and not _G.GOS and not _G.EOWLoaded) then return end
  	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(650, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(650,"AD")) or ( _G.EOWLoaded and EOW:GetTarget())
  	if self:IsValidTarget(target,650) and myHero.pos:DistanceTo(target.pos) < 650 and self.Menu.Ripper.KS.E:Value() and self:Ready(_E) then
    	local level = myHero:GetSpellData(_E).level
    	local Edamage = CalcMagicalDamage(myHero, target, (({70, 110, 150, 190, 230})[level] + 0.6 * myHero.ap))
	if Edamage >= self:HpPred(target,1) + target.hpRegen * 2 then
  	Control.CastSpell(HK_E,target)
	end
	end
	
end


  
function OnLoad()
    	if myHero.charName ~= "XinZhao" then return end
	XinZhao()
end
