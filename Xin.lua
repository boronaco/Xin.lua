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
                    	R = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/6/69/Crescent_Sweep.png" }
	-- Main Menu -------------------------------------------------------------------------------------------------------------------
  	self.Menu = MenuElement({type = MENU, id = "Menu", name = "The Ripper Series", leftIcon = Icons.C})
	-- XinZhao ---------------------------------------------------------------------------------------------------------------------
	self.Menu:MenuElement({type = MENU, id = "Ripper", name = "Xin Zhao The Ripper", leftIcon = Icons.C })
	-- Combo -----------------------------------------------------------------------------------------------------------------------
  	self.Menu.Ripper:MenuElement({type = MENU, id = "Combo", name = "Combo"})
  	self.Menu.Ripper.Combo:MenuElement({id = "Q", name = "Use Q", value = true, leftIcon = Icons.Q})
  	self.Menu.Ripper.Combo:MenuElement({id = "W", name = "Use W", value = true, leftIcon = Icons.W})
  	self.Menu.Ripper.Combo:MenuElement({id = "E", name = "Use E", value = true, leftIcon = Icons.E})
  	self.Menu.Ripper.Combo:MenuElement({id = "R", name = "Use R", value = true, leftIcon = Icons.R})
	self.Menu.Ripper.Combo:MenuElement({id = "ER", name = "Min enemies to use R", value = 2, min = 1, max = 5})
	
end

function XinZhao:Tick()
  	local Combo = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]) or (_G.GOS and _G.GOS:GetMode() == "Combo") or (_G.EOWLoaded and EOW:Mode() == "Combo")
  	
  	if Combo then
    	self:Combo()
    	self:JungleClear()
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
  	if self:IsValidTarget(target,R.range) and myHero.pos:DistanceTo(target.pos) < R.range and self.Menu.Ripper.Combo.R:Value() and self:Ready(_R) then
    	if self:CountEnemys(R.range) >= self.Menu.Ripper.Combo.ER:Value() then
    	Control.CastSpell(HK_R)
      	end
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

function OnLoad()
    	if myHero.charName ~= "XinZhao" then return end
	XinZhao()
end
