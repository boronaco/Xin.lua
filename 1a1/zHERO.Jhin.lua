if myHero.charName ~= "Jhin" then return end

require 'Eternal Prediction'
require 'DamageLib'

class "Jhin"

-- API :
--[[
-AATick()
-HasMoved(target, time)
-OrbCast()
-CheckMode()
-Target(range, type1)
-OrbState(state, bool)
-CastX(spell, target, hitchance, minion, hero)
-EnemyComing(target, time)
-DistTo(firstpos, secondpos)
-AbleCC(who)
-CCed(who, type1)
-TargetDistance(range)
-EnemiesCloseCanAttack(range)
-HealthPred(target, time)
-Force(target)
-TurretEnemyAround(range)
-EnemiesAround(CustomRange)
-MinionNumber(range, Type)
-Buffed(target, buffname)
-ForceR()
-ForceMove(position)
-ForceSteal()
-ForceW()
]]

--Datas
local Q = {range = 680, delay = 0, speed = 1800, width = 80}
local W = {range = 2550, delay = 0.75, speed = 5000, width = 40}
local E = {range = 750, delay = 0.25, speed = 1600, width = 120}
local R = {range = 3500, delay = 0.25, speed = 5000, width = 80}
local HeroIcon = "https://puu.sh/w5Hy1/772c7b6566.png"
local QIcon = "https://puu.sh/w4zpp/8bd45baf09.png"
local WIcon = "https://puu.sh/w4zrj/365ef7cc83.png"
local EIcon = "https://puu.sh/w4ztd/ebfeb7fe38.png"
local RIcon = "https://puu.sh/w4zut/d128a4c4dd.png"
local H = myHero
local ColorY = Draw.Color(255, 255, 255, 100)
local ColorZ = Draw.Color(255, 255, 200, 100)
local ping = Game.Latency()/1000
local castXstate = 1
local castXtick = 0
local AATick = 0
local AADown = 0
local ComboTick = 0
local AAUp = 0
local ETime = 0
local WSet = Prediction:SetSpell(W, TYPE_LINE, true)
local ESet = Prediction:SetSpell(E, TYPE_CIRCULAR, true)
local RSet = Prediction:SetSpell(R, TYPE_LINE, true)
local customWvalid = 0
local customEvalid = 0
if EOWLoaded then
	print("")
elseif _G.SDK then
	print("et ORb")
end

--Menus
local Menu = MenuElement({id = "Menu", name = "Jhin", type = MENU})
Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
Menu:MenuElement({id = "Laneclear", name = "Laneclear", type = MENU})
Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
Menu:MenuElement({id = "KsW", name = "Use W to Killsteal", value = false})
Menu:MenuElement({id = "AutoW", name = "Use W Auto on CC", value = false})
Menu:MenuElement({id = "Accuracy", name = "Skillshot Hitchance", value = 0.15, min = 0.01, max = 1, step = 0.01})
Menu:MenuElement({name = "Version : 1.10", type = SPACE})
Menu:MenuElement({name = "By Tarto", type = SPACE})
--Combo
Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true})
Menu.Combo:MenuElement({id = "UseWKs", name = "Use W Killsteal", value = true})
Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "UseEMana", name = "E Mana min", value = 40, min = 0, max = 100, step = 5})
Menu.Combo:MenuElement({id = "UseR", name = "Force R", key = string.byte("T")})
--Harass
Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = false})
Menu.Harass:MenuElement({id = "UseQMana", name = "Q Mana min", value = 40, min = 0, max = 100, step = 5})
Menu.Harass:MenuElement({id = "UseW", name = "Use W", value = false})
Menu.Harass:MenuElement({id = "UseWMana", name = "W Mana min", value = 40, min = 0, max = 100, step = 5})
--Harass
Menu.Laneclear:MenuElement({id = "UseQ", name = "Use Q", value = false})
Menu.Laneclear:MenuElement({id = "UseQMana", name = "Q Mana min", value = 40, min = 0, max = 100, step = 5})
Menu.Laneclear:MenuElement({id = "UseW", name = "Use W", value = false})
Menu.Laneclear:MenuElement({id = "UseWMana", name = "W Mana min", value = 40, min = 0, max = 100, step = 5})
Menu.Laneclear:MenuElement({id = "UseE", name = "Use E", value = false})
Menu.Laneclear:MenuElement({id = "UseEMana", name = "E Mana min", value = 40, min = 0, max = 100, step = 5})
--Lashit
Menu.Lasthit:MenuElement({id = "UseQ", name = "Use Q", value = true})
Menu.Lasthit:MenuElement({id = "UseQMana", name = "Q Mana min", value = 40, min = 0, max = 100, step = 5})
Menu.Lasthit:MenuElement({id = "UseW", name = "Use W", value = true})
Menu.Lasthit:MenuElement({id = "UseWMana", name = "W Mana min", value = 40, min = 0, max = 100, step = 5})

--Drawings
Menu.Drawings:MenuElement({id = "DrawAuto", name = "Draw AA Range", value = false})
Menu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = false})
Menu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = false})
Menu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = false})
Menu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = false})

function Tick()
	if H.dead then return end
	AATick()
	ForceR()
	ForceW()
	ForceSteal()
	CheckMode()
end

function AATick()
	if H.attackData.state == 2 then
		AAUp = Game.Timer()
	elseif H.attackData.state == 3 then
		AADown = Game.Timer()
	end
end

function HasMoved(target, time)
	local first, second, delay = target.pos, nil, Game.Timer()
	if Game.Timer() - delay > time then
		second = target.pos
		if first ~= second then
			return true
		end
	end
	return false
end

function OrbCast()
	if castXstate == 1 then
		OrbState("Global", true)
	end
end

function CheckMode()
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			Combo()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			Harass()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			Laneclear()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
			Jungleclear()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
			Lasthit()
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_Flee] then
			Flee()
		end
	elseif EOWLoaded then
		if EOW:Mode() == 1 then
			Combo()
		elseif EOW:Mode() == 2 then
			Harass()
		elseif EOW:Mode() == 3 then
			Lasthit()
		elseif EOW:Mode() == 4 then
			Laneclear()
		end
	else
		GOS:GetMode()
	end
end

function Draws()
	if H.dead then return end
	if Menu.Drawings.DrawAuto:Value() then
		Draw.Circle(H.pos, 680, 2, ColorZ)
	end
	if Menu.Drawings.DrawQ:Value() then
		Draw.Circle(H.pos, Q.range, 2, ColorY)
	end
	if Menu.Drawings.DrawW:Value() then
		Draw.Circle(H.pos, W.range, 2, ColorY)
	end
	if Menu.Drawings.DrawE:Value() then
		Draw.Circle(H.pos, E.range, 2, ColorY)
	end
	if Menu.Drawings.DrawR:Value() then
		Draw.Circle(H.pos, R.range, 2, ColorY)
	end
end

function Target(range, type1)
	if _G.SDK then
		if type1 == "damage" then
			if H.totalDamage > H.ap then
				local target = _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
				return target
			elseif H.totalDamage <= H.ap then
				local target = _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
				return target
			end
		elseif type1 == "easy" then
			local target = _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
			return target
		elseif type1 == "distance" then
			local target = TargetDistance(range)
			return target
		end
	elseif EOWLoaded then
		if type1 == "damage" then
			if H.totalDamage > H.ap then
				local target = EOW:GetTarget(range, ad_dec, H.pos)
				return target
			elseif H.totalDamage <= H.ap then
				local target = EOW:GetTarget(range, ap_dec, H.pos)
				return target
			end
		elseif type1 == "easy" then
			local target = EOW:GetTarget(range, easykill_acd, H.pos)
			return target
		elseif type1 == "distance" then
			local target = EOW:GetTarget(range, distance_acd, H.pos)
			return target
		end
	else 
		if type1 == "damage" then
			if H.totalDamage > H.ap then
				local target = GOS:GetTarget(range, "AD")
				return target
			elseif H.totalDamage <= H.ap then
				local target = GOS:GetTarget(range, "AP")
				return target
			end
		elseif type1 == "easy" then
			local target = GOS:GetTarget(range, "AD")
			return target
		elseif type1 == "distance" then
			local target = TargetDistance(range)
			return target
		end
	end
end

function OrbState(state, bool)
	if state == "Global" then
		if _G.SDK then 
			_G.SDK.Orbwalker:SetMovement(bool)
			_G.SDK.Orbwalker:SetAttack(bool)
		elseif EOWLoaded then
			EOW:SetAttacks(bool)
			EOW:SetMovements(bool)
		else
			GOS:BlockAttack(not bool)
			GOS:BlockMovement(not bool)
		end
	elseif state == "Attack" then
		if _G.SDK then 
			_G.SDK.Orbwalker:SetAttack(bool)
		elseif EOWLoaded then
			EOW:SetAttacks(bool)
		else
			GOS:BlockAttack(not bool)
		end
	elseif state == "Movement" then
		if _G.SDK then 
			_G.SDK.Orbwalker:SetMovement(bool)
		elseif EOWLoaded then
			EOW:SetMovements(bool)
		else
			GOS:BlockMovement(not bool)
		end
	end
end

function CastX(spell, target, hitchance, minion, hero)
	if H.activeSpell.valid then return end
	if customWvalid ~= 0 then
		if Game.Timer() - customWvalid <= 0.75 then return end
	end
	if customEvalid ~= 0 then
		if Game.Timer() - customEvalid <= 0.25 then return end
	end
	local Custom = {delay = ping, spell = spell, minion = minion, hero = hero, hitchance = hitchance, hotkey = nil, pred = nil, Delay = nil}
	if Custom.minion == nil then Custom.minion = 0 end
	if Custom.hero == nil then Custom.hero = 0 end
	if Custom.hitchance == nil then Custom.hitchance = 0.20 end
	if Custom.spell == 4 then
		Custom.hotkey = HK_Q
		Custom.Delay = Q.delay
	elseif Custom.spell == 1 then
		Custom.hotkey = HK_W
		Custom.Delay = W.delay
	elseif Custom.spell == 2 then
		Custom.hotkey = HK_E
		Custom.Delay = E.delay
	elseif Custom.spell == 3 then
		Custom.hotkey = HK_R
		Custom.Delay = R.delay
	end
	if target ~= nil and Custom.hotkey ~= nil and not target.dead then
		if castXstate == 1 then
			if H.attackData.state == 2 then return end
			castXstate = 2
			local mLocation = nil
			if Custom.spell == 4 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				if not target.dead and (Game.Timer() - castXtick) > 0.8 then
					DelayAction(function() Control.CastSpell(HK_Q, target) end, Custom.delay)
					castXstate = 1
					castXtick = Game.Timer()
				end
			elseif Custom.spell == 1 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = WSet:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and prediction:hCollision() == Custom.hero and not target.dead and (Game.Timer() - castXtick) > 1 then
					if H.attackData.state == 2 then return end
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customWvalid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay/2 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, Custom.delay)
					end
				end
			elseif Custom.spell == 2 and (Game.Timer() - (ETime + ping + E.delay)) > 10 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = ESet:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and not target.dead and (Game.Timer() - castXtick) > 1 then
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customEvalid, ETime = Game.Timer(), Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.8 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, Custom.delay)
					end
				end
			elseif Custom.spell == 2 and (H:GetSpellData(1).currentCd > H:GetSpellData(1).cd/2) and (Game.Timer() - (ETime + ping + E.delay)) > 5 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = ESet:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and not target.dead and (Game.Timer() - castXtick) > 1 then
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customEvalid, ETime = Game.Timer(), Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.8 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, Custom.delay)
					end
				end
			elseif Custom.spell == 3 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = RSet:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and prediction:hCollision() == Custom.hero and not target.dead and (Game.Timer() - castXtick) > 0.8 then
					if myHero:GetSpellData(_R).name == "JhinR" then
						DelayAction(function() OrbState("Movement", false) end, Custom.delay)
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
					elseif myHero:GetSpellData(_R).name == "JhinRShot" then
						Control.CastSpell(HK_Q, prediction.castPos)
					end
					castXstate = 1
					castXtick = Game.Timer()
					DelayAction(function() OrbState("Global", true) end, Custom.delay)
				end
			end
		elseif castXstate == 2 then return end
	end
end

function EnemyComing(target, time)
	if target == nil then return end
	local first, second, delay = target.pos, nil, Game.Timer()
	if Game.Timer() - delay > time then
		second = target.pos
		if DistTo(first, H.pos) > DistTo(second, H.pos) then
			return true
		elseif DistTo(first, H.pos) == DistTo(second, H.pos) then
			return false
		end
	end
	return false
end

function DistTo(firstpos, secondpos)
	local secondpos = secondpos or H.pos
	local distx = firstpos.x - secondpos.x
	local distyz = (firstpos.z or firstpos.y) - (secondpos.z or secondpos.y)
	local distf = (distx*distx) + (distyz*distyz)
	return math.sqrt(distf)
end

function AbleCC(who)
	if who == nil then return end
	if who.buffCount == 0 then return end
	for i = 0, who.buffCount do
		local buffs = who:GetBuff(i)
		if buffs.type == (5 or 8 or 11 or 22 or 24 or 29 or 30) and buffs.expireTime > (W.delay + ping)*0.95 then
			return true
		end
	end
	return false
end

function CCed(who, type1)
	if who == nil then return end
	if who.buffCount == 0 then return end
	for i = 0, who.buffCount do
		local buffs = who:GetBuff(i)
		if buffs.type == type1 and buffs.expireTime > 0.85 then
			return true
		end
	end
	return false
end

function TargetDistance(range)
	local target = nil
	for i = 0, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if DistTo(Hero.pos, H.pos) <= range and Hero.isEnemy then
			if target == nil then target = Hero break end
			if DistTo(Hero.pos, H.pos) < DistTo(target.pos, H.pos) then
				target = Hero
			end
		end
	end
	return target
end

function EnemiesCloseCanAttack(range)
	local Count = 0
	for i = 0, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if DistTo(Hero.pos, H.pos) <= range and Hero.isEnemy then
			if DistTo(Hero.pos, H.pos) < Hero.range then
				Count = Count + 1
			end
		end
	end
	return Count
end

function HealthPred(target, time)
	if _G.SDK then
		return _G.SDK.HealthPrediction:GetPrediction(target, time)
	elseif EOWLoaded then
		return EOW:GetHealthPrediction(target, time)
	else
		return GOS:HP_Pred(target,time)
	end
end

function Force(target)
	if target ~= nil then
		if _G.SDK then
			_G.SDK.Orbwalker.ForceTarget = target
		elseif EOWLoaded then
			EOW:ForceTarget(target)
		elseif GOS then
			GOS:ForceTarget(target)
		end
	else
		if _G.SDK then
			_G.SDK.Orbwalker.ForceTarget = nil
		elseif EOWLoaded then
			EOW:ForceTarget(nil)
		elseif GOS then
			GOS:ForceTarget(nil)
		end
	end
end

function TurretEnemyAround(range)
	local count = 0
	for i = 0, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret.isEnemy and DistTo(turret.pos, H.pos) <= range then
			count = count + 1
		end
	end
	return count
end

function EnemiesAround(CustomRange)
	local Count = 0
	for i = 0, Game.HeroCount() do
		local Enemy = Game.Hero(i)
		if DistTo(Enemy.pos, H.pos) <= CustomRange and Enemy.isEnemy then
			Count = Count + 1
		end
	end
	return Count
end

function MinionNumber(range, Type)
	if range == nil or Game.Timer() < 91 then return end
	local count = 0
	if Type == nil then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if DistTo(minion.pos, H.pos) < range then
				count = count + 1
			end
		end
	elseif Type == "ranged" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if H.team == 100 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_ChaosMinionRanged" then
					count = count + 1
				end
			elseif H.team == 200 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_OrderMinionRanged" then
					count = count + 1
				end
			end
		end
	elseif Type == "melee" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if H.team == 100 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_ChaosMinionMelee" then
					count = count + 1
				end
			elseif H.team == 200 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_OrderMinionRMelee" then
					count = count + 1
				end
			end
		end
	elseif Type == "siege" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if H.team == 100 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_ChaosMinionSiege" then
					count = count + 1
				end
			elseif H.team == 200 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_OrderMinionSiege" then
					count = count + 1
				end
			end
		end
	elseif Type == "super" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if H.team == 100 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_ChaosMinionSuper" then
					count = count + 1
				end
			elseif H.team == 200 then
				if DistTo(minion.pos, H.pos) < range and minion.charName == "SRU_OrderMinionSuper" then
					count = count + 1
				end
			end
		end
	end
	return count
end

function Buffed(target, buffname)
	if target == nil then return end
 	for i = 0, target.buffCount do
    	local buff = target:GetBuff(i)
    	if buff.count > 0 and buff.name == buffname and buff.duration > 0 then
			return true
		end
	end
end

function ForceR()
	local NameR = H:GetSpellData(_R).name
	if Menu.Combo.UseR:Value() then
		if NameR == "JhinR" and Game.CanUseSpell(3) then
			local target = Target(2500, "easy")
			CastX(3, target, Menu.Accuracy:Value())
		elseif NameR == "JhinRShot" then
			local target = Target(3500, "easy")
			if target == nil then return end
			local prediction = RSet:GetPrediction(target, myHero.pos)
			if prediction and prediction.hitChance >= Menu.Accuracy:Value() and prediction:hCollision() == 0 then
				Control.CastSpell(HK_R, prediction.castPos)
			end
		end
	end
end

function ForceMove(position)
	if position ~= nil then
		if _G.SDK then
			_G.SDK.Orbwalker.ForceMovement = position
		elseif EOWLoaded then
			EOW:ForceMovePos(position)
		elseif GOS then
			GOS:ForceMove(position)
		end
	else
		if _G.SDK then
			_G.SDK.Orbwalker.ForceMovement = nil
		elseif EOWLoaded then
			EOW:ForceMovePos(nil)
		elseif GOS then
			GOS:ForceMove(nil)
		end
	end
end

function ForceSteal()
	if Menu.KsW:Value() and Game.CanUseSpell(1) == 0 and myHero:GetSpellData(_R).name ~= "JhinRShot" and not CheckSpellValid() then
		EnableAll()
		local target = Target(W.range, "easy")
		if target == nil then return end
		if target ~= nil and DistTo(target.pos, H.pos) > 680 and EnemiesAround(500) == 0 and (target.health + target.shieldAD + target.shieldAP) < getdmg("W", target, myHero) then
			CastX(1, target, Menu.Accuracy:Value())
		end
	end
end

function ForceW()
	if Menu.AutoW:Value() and Game.CanUseSpell(1) == 0 and myHero:GetSpellData(_R).name ~= "JhinRShot" then
		if CheckSpellValid() then return end
		EnableAll()
		local target = Target(W.range, "damage")
		if Buffed(target, "jhinespotteddebuff") and DistTo(target.pos, H.pos) > 700 and target ~= nil and EnemiesAround(300) == 0 and EnemiesCloseCanAttack(680) <= 1 then
			CastX(1, target, Menu.Accuracy:Value())
		end
	end
end

function CheckSpellValid()
	if Game.Timer() - customWvalid <= 0.75 then
		return true
	elseif Game.Timer() - customEvalid <= 0.25 then
		return true
	else return false
	end
end

function EnableAll()
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)
end

function Combo()
	if Game.Timer() >= 91 or not H.activeSpell.valid then
		if CheckSpellValid() then return end
		EnableAll()
		if Menu.Combo.UseW:Value() and Game.CanUseSpell(1) == 0 then
			local target = Target(W.range, "damage")
			if target == nil then return end
			if Buffed(target, "jhinespotteddebuff") then
				local DistanceCheck = DistTo(target.pos, H.pos)
				if DistanceCheck > 750 and EnemiesAround(300) == 0 and EnemiesCloseCanAttack(680) <= 1 then
					CastX(1, target, Menu.Accuracy:Value())
				elseif Buffed(target, "jhinespotteddebuff") and DistanceCheck < 350 and DistanceCheck > 150 and H.attackData.state == 3 and Game.CanUseSpell(0) ~= 0 and EnemiesCloseCanAttack(680) <= 1 then
					CastX(1, target, Menu.Accuracy:Value())
				end
			elseif DistTo(target.pos, H.pos) > 680 and EnemiesAround(500) == 0 and Menu.Combo.UseWKs:Value() and (target.health + target.shieldAD + target.shieldAP) < getdmg("W", target, myHero) then
				CastX(1, target, Menu.Accuracy:Value())
			end
		end
		if Menu.Combo.UseQ:Value() and Game.CanUseSpell(0) == 0 then
			local target = Target(Q.range, "damage")
			if not Buffed(target, "jhinpassiveattackbuff") and target ~= nil then
				CastX(4, target, Menu.Accuracy:Value())
			end
		end
		if Menu.Combo.UseQ:Value() and Game.CanUseSpell(0) == 0 and Buffed(H, "JhinPassiveReload") then
			local target = Target(Q.range, "damage")
			if target ~= nil then
				CastX(4, target, Menu.Accuracy:Value())
			end
		end
		if Menu.Combo.UseE:Value() and Menu.Combo.UseEMana:Value() < (100*H.mana/H.maxMana) and Game.CanUseSpell(0) ~= 0 and Game.CanUseSpell(1) ~= 0 and Game.CanUseSpell(2) == 0 and not myHero.activeSpell.valid then
			local target = Target(750, "damage")
			if Buffed(target, "jhinpassiveattackbuff") or H.hudAmmo == 1 or target == nil or  HealthPred(target, 0.85) < (target.health*100)/target.maxHealth or (Game.Timer() - AAUp) < ((H.attackData.windDownTime)*0.6) or CCed(H, 10) then return end
			CastX(2, target, Menu.Accuracy:Value())
		end
	else
		if Menu.Combo.UseQ:Value() and Game.CanUseSpell(0) == 0 then
			local target = Target(Q.range, "damage")
			if not Buffed(target, "jhinpassiveattackbuff") then
				CastX(4, target, Menu.Accuracy:Value())
			end
		end
	end
end

function Harass()
	--[[if H.activeSpell.valid or Game.Timer() < 91 then return end
	EnableAll()]]
end

function Laneclear()
	--[[if H.activeSpell.valid or Game.Timer() < 91 then return end
	EnableAll()]]
end

function Jungleclear()
	--[[if H.activeSpell.valid or Game.Timer() < 91 then return end
	EnableAll()]]
end

function Lasthit()
	--[[if H.activeSpell.valid or Game.Timer() < 91 then return end
	EnableAll()

	if Menu.Lasthit.UseQ:Value() and Game.CanUseSpell(0) == 0 then
		if Menu.Lasthit.UseQMana:Value() < (100*H.mana/H.maxMana) and H.attackData.state == 3 then
			for i = 0, Game.MinionCount() do
				local minion = Game.Minion(i)
				if DistTo(minion.pos, H.pos) < 680 and getdmg("Q", minion, H) > minion.health then
					OrbState("Global", true)
					CastX(4, target, Menu.Accuracy:Value())
				end
			end
		end
	end]]
end

function Flee()
	--[[if H.activeSpell.valid or Game.Timer() < 91 then return end
	EnableAll()]]
end

Callback.Add("Tick", function() Tick() end)
Callback.Add("Draw", function() Draws() end)
