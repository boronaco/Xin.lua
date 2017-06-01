--Hero
if myHero.charName ~= "LeeSin" then return end

--Locals
local LoL = "7.6"
local ver = "1.2"

--icon
local MenuIcons = "http://static.lolskill.net/img/champions/64/leesin.png"
local WardIcons = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/0/06/Conquering_Ward.jpg"
local SpellIcons = { Q1 = "http://static.lolskill.net/img/abilities/64/LeeSin_Q1.png",
					 Q2 = "http://static.lolskill.net/img/abilities/64/LeeSin_Q2.png",
					 W1 = "http://static.lolskill.net/img/abilities/64/LeeSin_W1.png",
					 W2 = "http://static.lolskill.net/img/abilities/64/LeeSin_W2.png",
					 E1 = "http://static.lolskill.net/img/abilities/64/LeeSin_E1.png",
					 E2 = "http://static.lolskill.net/img/abilities/64/LeeSin_E2.png",
					 R = "http://static.lolskill.net/img/abilities/64/LeeSin_R.png"
}

--Main Menu
local Menu = MenuElement({type = MENU, id = "Menu", name = "LeeSin", leftIcon = MenuIcons})
Menu:MenuElement({id = "Enabled", name = "Enabled", value = true})

--Main Menu-- Mode Setting
Menu:MenuElement({type = MENU, id = "Mode", name = "Mode Settings"})
--Main Menu-- Mode Setting-- Combo
Menu.Mode:MenuElement({type = MENU, id = "Combo", name = "Combo"})
Menu.Mode.Combo:MenuElement({id = "Q1", name = "Use Q1", value = true, leftIcon = SpellIcons.Q1})
Menu.Mode.Combo:MenuElement({id = "Q2", name = "Use Q2", value = true, leftIcon = SpellIcons.Q2})
Menu.Mode.Combo:MenuElement({id = "W1", name = "Use W1", value = true, leftIcon = SpellIcons.W1})
--Menu.Mode.Combo:MenuElement({id = "W2", name = "Use W2", value = true, leftIcon = SpellIcons.W2})
Menu.Mode.Combo:MenuElement({id = "E1", name = "Use E1", value = true, leftIcon = SpellIcons.E1})
--Menu.Mode.Combo:MenuElement({id = "E2", name = "Use E2", value = true, leftIcon = SpellIcons.E2})
Menu.Mode.Combo:MenuElement({id = "R", name = "Use R", value = true, leftIcon = SpellIcons.R})
--Main Menu-- Mode Setting-- JungleClear
Menu.Mode:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear"})
Menu.Mode.JungleClear:MenuElement({id = "Q1", name = "Use Q1", value = true, leftIcon = SpellIcons.Q1})
Menu.Mode.JungleClear:MenuElement({id = "Q2", name = "Use Q2", value = true, leftIcon = SpellIcons.Q2})
Menu.Mode.JungleClear:MenuElement({id = "W1", name = "Use W1", value = true, leftIcon = SpellIcons.W1})
Menu.Mode.JungleClear:MenuElement({id = "E1", name = "Use E1", value = true, leftIcon = SpellIcons.E1})
--Main Menu-- Mode Setting-- Flee
Menu.Mode:MenuElement({type = MENU, id = "Flee", name = "Flee"})
Menu.Mode.Flee:MenuElement({id = "W1", name = "Use W1", value = true, leftIcon = SpellIcons.W1})
Menu.Mode.Flee:MenuElement({id = "Ward", name = "Use W1 with Ward ", key = 0 , toggle = true , leftIcon = WardIcons})

--[[
--Main Menu-- Ward Iteam 
Menu:MenuElement({type = MENU, id = "Ward", name = "Ward Items"})
Menu.Ward:MenuElement({id = "2049", name = "Sightstone", value = true, leftIcon = "http://cdn.championcounter.com/images/items/2049-sightstone.png"})
Menu.Ward:MenuElement({id = "2045", name = "Ruby Sightstone", value = true, leftIcon = "http://cdn.championcounter.com/images/items/2045-rubysightstone.png"})
Menu.Ward:MenuElement({id = "3340", name = "Warding Totem (Trinket)", value = true, leftIcon = "http://cdn.championcounter.com/images/items/3340-wardingtotemtrinket.png"})
Menu.Ward:MenuElement({id = "3711", name = "Tracker's Knife", value = true, leftIcon = "http://cdn.championcounter.com/images/items/3711-trackersknife.png"})
--]]
--Main Menu-- Ward Iteam 
Menu:MenuElement({type = MENU, id = "Insec", name = "Insec Setting"})
Menu.Insec:MenuElement({id = "UseInsec",name = "Use Insec", key = string.byte("+"), toggle = true})
Menu.Insec:MenuElement({id = "SetKick",name = "Set Kick Direction", key = string.byte("/")})

--Main Menu-- Drawing 
Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
Menu.Drawing:MenuElement({id = "Q1", name = "Draw Q1 Range", value = false, leftIcon = SpellIcons.Q1})
Menu.Drawing:MenuElement({id = "Q2", name = "Draw Q2 Range", value = false, leftIcon = SpellIcons.Q2})
Menu.Drawing:MenuElement({id = "W1", name = "Draw W1 Range", value = false, leftIcon = SpellIcons.W1})
Menu.Drawing:MenuElement({id = "E1", name = "Draw E1 Range", value = false, leftIcon = SpellIcons.E1})
Menu.Drawing:MenuElement({id = "E2", name = "Draw E2 Range", value = false, leftIcon = SpellIcons.E2})
Menu.Drawing:MenuElement({id = "R", name = "Draw R Range", value = false, leftIcon = SpellIcons.R})
Menu.Drawing:MenuElement({id = "Ward", name = "Draw Ward Status", value = false, leftIcon = WardIcons})
Menu.Drawing:MenuElement({id = "Kick", name = "Draw Kick Position", value = false, leftIcon = WardIcons})


local LeeSinQ1 = 	{ name = "BlindMonkQOne" , range = 1000, 	speed = myHero:GetSpellData(_Q).speed, delay = 0.2, width = myHero:GetSpellData(_Q).width }
local LeeSinQ2 = 	{ name = "BlindMonkQTwo" , range = 1250, 	speed = myHero:GetSpellData(_Q).speed, delay = 0.2, width = myHero:GetSpellData(_Q).width }
local LeeSinW1 = 	{ name = "BlindMonkWOne" , range = 700, 	speed = myHero:GetSpellData(_W).speed, delay = 0.2, width = myHero:GetSpellData(_W).width }
local LeeSinW2 = 	{ name = "BlindMonkWTwo" , range = 300, 	speed = myHero:GetSpellData(_W).speed, delay = 0.2, width = myHero:GetSpellData(_W).width }
local LeeSinE1 = 	{ name = "BlindMonkEOne" , range = 420, 	speed = myHero:GetSpellData(_E).speed, delay = 0.2, width = myHero:GetSpellData(_E).width }
local LeeSinE2 = 	{ name = "BlindMonkETwo" , range = 575, 	speed = myHero:GetSpellData(_E).speed, delay = 0.2, width = myHero:GetSpellData(_E).width }
local LeeSinR = 	{ name = "BlindMonkRKick" , range = 375, 	speed = myHero:GetSpellData(_R).speed, delay = 0.2, width = myHero:GetSpellData(_R).width }
local Resolution = Game.Resolution()
local wardItemes = {2049,2045,3711,1408,1409,1418,1410}
local wardAmmo = nil
local kickPos = nil

local function getMode()
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then return "Combo" end
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then return "Harass" end
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then return "LaneClear" end
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then return "JungleClear" end
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then return "LastHit" end
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then return "Flee" end
	return ""
end

function isReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function castQ1(pos)
	if not myHero.isChanneling then
		Control.CastSpell(HK_Q,pos)
	end
end

function castQ2()
	Control.CastSpell(HK_Q)
end

function castW(target)
	Control.SetCursorPos(target.pos)
	Control.KeyDown(HK_W)
	Control.KeyUp(HK_W)
end

function castE1() 
	Control.CastSpell(HK_E)
end

function castR(target) 
	if not myHero.isChanneling then
		Control.CastSpell(HK_R,target.pos)
	end
end

function getWardsAmmo()
	local count = 0
	if myHero:GetItemData(ITEM_7).itemID == 3340 then 
		count = myHero:GetSpellData(ITEM_7).ammo
	end
	
	for i = ITEM_1, ITEM_6 do  -- 6 to 12
		if myHero:GetItemData(i).itemID ~= 0 and myHero:GetItemData(i).stacks > 0 then
			for j = 1, #wardItemes do
				if myHero:GetItemData(i).itemID == wardItemes[j]  then
					count = count + myHero:GetItemData(i).ammo
					break
				end
			end
		end
	end
	return count
end

function getWardSlot()
	if myHero:GetItemData(ITEM_7).itemID == 3340 and myHero:GetSpellData(ITEM_7).ammo > 0 then return ITEM_7 end
	
	if  Game.Timer() < myHero:GetSpellData(ITEM_7).castTime + 5 then return nil end

	local wardSlot
	for i = ITEM_1, ITEM_6 do  -- 6 to 12
		if myHero:GetItemData(i).itemID ~= 0 and myHero:GetItemData(i).stacks > 0 then
			for j = 1, #wardItemes do
				if myHero:GetItemData(i).itemID == wardItemes[j] and Game.Timer() > myHero:GetSpellData(i).castTime + 5 then
					wardSlot = i
					break
				end
			end
		end
	end
	return wardSlot
end

function getEnemyMinions(range)
	local target
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and IsValidTarget(minion, range) then
            target = minion
            break
        end
    end
    return target
end

function IsValidTarget(unit, range)
    return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.distance <= range
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

local function GetPred(unit,speed,delay)
	if IsImmobileTarget(unit) then
		return unit.pos
	else
		return unit:GetPrediction(speed,delay)
	end
end

function wardKey(ward)
	if ward == ITEM_1 then
		return HK_ITEM_1
	elseif ward == ITEM_2 then
		return HK_ITEM_2
	elseif ward == ITEM_3 then
		return HK_ITEM_3
	elseif ward == ITEM_4 then
		return HK_ITEM_4
	elseif ward == ITEM_5 then
		return HK_ITEM_5
	elseif ward == ITEM_6 then
		return HK_ITEM_6
	elseif ward == ITEM_7 then
		return HK_ITEM_7
	end
end

function InsectCheck()
	local target = _G.SDK.TargetSelector:GetTarget(1300)
	if kickPos == nil or target == nil then return nil end
	local tempPos = kickPos:DistanceTo(target.pos) + LeeSinR.range - 100
	local wardPos = kickPos:Extended(target.pos, tempPos)
	return wardPos
end

function OnTick()

	if not Menu.Enabled:Value() then return end
	
	if myHero.dead then return end
	
	if Menu.Insec.UseInsec:Value() and Menu.Insec.SetKick:Value() then 
		kickPos = mousePos 
	end
	
	if getMode() == "Combo" then
		OnCombo()
	elseif getMode() == "Harass" then
		--onHarass()
	elseif getMode() == "LaneClear" or getMode() == "JungleClear" then
		OnClear()
	elseif getMode() == "LastHit" then
		--OnLastHit()
	elseif getMode() == "Flee" then
		OnFlee()
	end	
	
end


local wardUsed = false
local wardPinPos = nil
function OnCombo()
	local comboQ1 = Menu.Mode.Combo.Q1:Value()
	local comboQ2 = Menu.Mode.Combo.Q2:Value()
	local comboW1 = Menu.Mode.Combo.W1:Value()
	local comboE1 = Menu.Mode.Combo.E1:Value()
	local comboR = Menu.Mode.Combo.R:Value()
	local Insec = Menu.Insec.UseInsec:Value()
	
	local target = _G.SDK.TargetSelector:GetTarget(1300)
	
	if Insec then 
		local wardAmmo = getWardsAmmo()
		if isReady(_R) then
			if(IsValidTarget(target,LeeSinQ1.range) and  myHero.pos:DistanceTo(target.pos) >= LeeSinR.range) then
				--Q1
				if IsValidTarget(target,LeeSinQ1.range-50) and isReady(_Q) and myHero:GetSpellData(_Q).name == LeeSinQ1.name  then
					local Q1pos = GetPred(target, LeeSinQ1.speed, LeeSinQ1.delay + Game.Latency()/1000)
					if Q1pos and target:GetCollision(LeeSinQ1.width * 1.1 ,LeeSinQ1.speed,LeeSinQ1.delay) == 0 then
						castQ1(Q1pos)
					end
				end
				--Q2
				if IsValidTarget(target,LeeSinQ2.range) and isReady(_Q) and myHero:GetSpellData(_Q).name == LeeSinQ2.name then
					local levelQ2 = myHero:GetSpellData(_Q).level
					local Q2dmg = ({50, 80, 110, 140, 170})[levelQ2] + 0.9 * target.totalDamage 
					if  Q2dmg >= target.health + target.hpRegen * 2 then
						castQ2()
					end
					if getMode() == "Combo" and myHero:GetSpellData(_Q).name == LeeSinQ2.name then
						castQ2()
					end
				end
			else
				local wardPos = InsectCheck()
				if IsValidTarget(target,LeeSinW1.range-50) and wardPos ~= nil and isReady(_W) and myHero:GetSpellData(_W).name == LeeSinW1.name and not myHero.isChanneling and wardAmmo and wardUsed == false then
					Control.SetCursorPos(wardPos)
					if getWardSlot() ~= nil then
						Control.CastSpell(wardKey(getWardSlot()),wardPos)
					elseif getWardSlot() == nil then
						wardUsed = true
						wardPinPos = wardPos
					end
				end
					
				if wardUsed and isReady(_W) then
					Control.CastSpell(HK_W, wardPinPos)
				end
	
				if wardUsed and not isReady(_W) then
					Control.CastSpell(HK_R,target)
				end
				
			end
		else
			Menu.Insec.UseInsec:Value(false)
			wardUsed = false
		end
	else 
		--Q1
		if IsValidTarget(target,LeeSinQ1.range-50) and comboQ1 and isReady(_Q) and myHero:GetSpellData(_Q).name == LeeSinQ1.name  then
			local Q1pos = GetPred(target, LeeSinQ1.speed, LeeSinQ1.delay + Game.Latency()/1000 )
			if Q1pos and target:GetCollision(LeeSinQ1.width * 1.1 ,LeeSinQ1.speed,LeeSinQ1.delay) == 0 then
				castQ1(Q1pos)
			end
		end
		--Q2
		if IsValidTarget(target,LeeSinQ2.range) and comboQ2 and isReady(_Q) and myHero:GetSpellData(_Q).name == LeeSinQ2.name then
			local levelQ2 = myHero:GetSpellData(_Q).level
			local Q2dmg = ({50, 80, 110, 140, 170})[levelQ2] + 0.9 * target.totalDamage 
			if  Q2dmg >= target.health + target.hpRegen * 2 then
				castQ2()
			end
			DelayAction(function()
				if getMode() == "Combo" and myHero:GetSpellData(_Q).name == LeeSinQ2.name then
					castQ2()
				end
			end,2.8)
		end
		--E1
		if IsValidTarget(target,LeeSinE1.range-50) and comboE1 and isReady(_E) and myHero:GetSpellData(_E).name == LeeSinE1.name then
				castE1()
		end
		--W1
		if IsValidTarget(target,LeeSinW1.range) and myHero.health / myHero.maxHealth * 100  <= 35 and comboW1 and isReady(_W) and myHero:GetSpellData(_W).name == LeeSinW1.name then
			Control.CastSpell(HK_W, myHero)
		end
		--R
		if IsValidTarget(target,LeeSinR.range) and comboR and isReady(_R) and not isReady(_Q) and myHero:GetSpellData(_E).name ~= LeeSinE1.name then
			local levelR = myHero:GetSpellData(_R).level
			local Rdmg = ({150, 300, 450})[levelR] + 2 * target.totalDamage
			if  Rdmg >= target.health + target.hpRegen * 2 then
				castR(target)
			end
		end
	end
    
end

function OnClear()
	local JungleClearQ1 = Menu.Mode.JungleClear.Q1:Value()
	local JungleClearQ2 = Menu.Mode.JungleClear.Q2:Value()
	local JungleClearW1 = Menu.Mode.JungleClear.W1:Value()
	local JungleClearE1 = Menu.Mode.JungleClear.E1:Value()
	
	local minion = getEnemyMinions(1200)
	if minion == nil then return end
	
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.team == 300 then
			--Q1
			if IsValidTarget(minion,LeeSinQ1.range-50) and JungleClearQ1 and isReady(_Q) and myHero:GetSpellData(_Q).name == LeeSinQ1.name  then
				Control.SetCursorPos(minion)
				Control.CastSpell(HK_Q)
			end
			--Q2
			if IsValidTarget(minion,LeeSinQ2.range) and JungleClearQ2 and isReady(_Q) and myHero:GetSpellData(_Q).name == LeeSinQ2.name then
				local levelQ2 = myHero:GetSpellData(_Q).level
				local Q2dmg = ({50, 80, 110, 140, 170})[levelQ2] + 0.9 * minion.totalDamage 
				if  Q2dmg >= minion.health then
					castQ2()
				end
				DelayAction(function()
					if (getMode() == "JungleClear" or getMode() == "LaneClear") and myHero:GetSpellData(_Q).name == LeeSinQ2.name then
						castQ2()
					end
				end,2.8)
			end
			--W
			if IsValidTarget(minion,LeeSinW1.range) and myHero.health / myHero.maxHealth * 100  <= 80 and JungleClearW1 and isReady(_W) and myHero:GetSpellData(_W).name == LeeSinW1.name then
				Control.SetCursorPos(myHero)
				Control.CastSpell(HK_W)
			end
			--E
			if IsValidTarget(minion,LeeSinE1.range-50) and JungleClearE1 and isReady(_E) and myHero:GetSpellData(_E).name == LeeSinE1.name then
					castE1()
			end
		end
	end
	
end

function OnFlee()
	local fleeW1 = Menu.Mode.Flee.W1:Value()
	if  fleeW1 and isReady(_W) and myHero:GetSpellData(_W).name == LeeSinW1.name and myHero.pos:DistanceTo(mousePos) <= LeeSinW1.range + 50 then

		if Menu.Mode.Flee.Ward:Value() and getWardSlot() ~= nil and myHero.pos:DistanceTo(mousePos) <= 650 then
			local wardPos = mousePos
			Control.CastSpell(wardKey(getWardSlot()))
			DelayAction(function()
				if wardPos:DistanceTo(mousePos) <= 80 then
					Control.CastSpell(HK_W, wardPos)
				end
			end, 0.1)
		end
		
		for i = 1, Game.WardCount() do
			local ward = Game.Ward(i)
				if ward.pos:DistanceTo(mousePos) <= 100 and IsValidTarget(ward,LeeSinW1.range) then
					Control.CastSpell(HK_W, ward)
				end
		end
		
		for i = 1, Game.HeroCount() do
			local hero = Game.Hero(i)
				if hero.pos:DistanceTo(mousePos) <= 100 and IsValidTarget(hero,LeeSinW1.range) and hero.team == myHero.team and not hero.isMe then
					Control.CastSpell(HK_W, hero)
				end
		end

		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
				if minion.pos:DistanceTo(mousePos) <= 100 and IsValidTarget(minion,LeeSinW1.range) and minion.team == myHero.team then
					Control.CastSpell(HK_W, minion)
				end
		end
		
	end
end

function OnDraw()
	--Draw Range
	if myHero.dead then return end
	if Menu.Drawing.Q1:Value() and myHero:GetSpellData(_Q).name == LeeSinQ1.name then Draw.Circle(myHero.pos,LeeSinQ1.range,1,Draw.Color(255, 0, 0, 220)) end			
	if Menu.Drawing.Q2:Value() and myHero:GetSpellData(_Q).name == LeeSinQ2.name then Draw.Circle(myHero.pos,LeeSinQ2.range,1,Draw.Color(255, 0, 0, 220)) end	
	if Menu.Drawing.W1:Value() and myHero:GetSpellData(_W).name == LeeSinW1.name then Draw.Circle(myHero.pos,LeeSinW1.range,1,Draw.Color(255, 255, 220, 0)) end			
	if Menu.Drawing.E1:Value() and myHero:GetSpellData(_E).name == LeeSinE1.name then Draw.Circle(myHero.pos,LeeSinE1.range,1,Draw.Color(220,0,255,0)) end	
	if Menu.Drawing.E2:Value() and myHero:GetSpellData(_E).name == LeeSinE2.name then Draw.Circle(myHero.pos,LeeSinE2.range,1,Draw.Color(220,0,255,0)) end	
	if Menu.Drawing.R:Value() then Draw.Circle(myHero.pos,LeeSinR.range,1,Draw.Color(220,255,0,0)) end	
	if Menu.Drawing.Ward:Value() then 
		if Menu.Mode.Flee.Ward:Value() then 
			Draw.Text("Use Ward to Flee : ON", 20, Resolution.x/2.2, Resolution.y * 0.75, Draw.Color(150, 0, 255, 0)) 
		elseif not Menu.Mode.Flee.Ward:Value() then 
			Draw.Text("Use Ward to Flee : OFF", 20, Resolution.x/2.2, Resolution.y * 0.75, Draw.Color(180, 204, 0, 0)) 
		end
	end
	if Menu.Drawing.Kick:Value() then 
		if Menu.Insec.UseInsec:Value() then 
			Draw.Text("Use Insec : ON", 20, Resolution.x/2.2, Resolution.y * 0.73, Draw.Color(150, 0, 255, 0)) 
		elseif not Menu.Insec.UseInsec:Value() then
			Draw.Text("Use Insec : OFF", 20, Resolution.x/2.2, Resolution.y * 0.73, Draw.Color(180, 204, 0, 0)) 
		end
	end
	if Menu.Drawing.Kick:Value() and kickPos ~= nil and myHero.pos:DistanceTo(kickPos) <= 3000 then Draw.Circle(kickPos,80,1,Draw.Color(255, 255, 0, 0)) end
end
