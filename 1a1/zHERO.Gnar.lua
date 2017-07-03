if myHero.charName ~= "Gnar" then return end

require 'Eternal Prediction'
require 'DamageLib'

class "Gnar"

local Q = {range = 1125, delay = 0.25, speed = 2500, width = 60}
local QM = {range = 1150, delay = 0.5, speed = 2100, width = 80}
local W = {range = 600, delay = 0.6, speed = math.huge, width = 80}
local R = {range = 475, delay = 0.25, speed = math.huge, width = 500}
local AA = { Up = 0, Down = 0, Mrange = 335}
local HeroIcon = "https://puu.sh/w7a7c/7a388ab008.png"
local QIcon = "https://puu.sh/w7aOp/f57d73b4c0.png"
local QMIcon = "https://puu.sh/w7aQP/c2ab4c230c.png"
local WIcon = "https://puu.sh/w7aTE/524fd39032.png"
local RIcon = "https://puu.sh/w7aYn/a4ac942f9c.png"
local H = myHero
local ColorY, ColorZ = Draw.Color(255, 255, 255, 100), Draw.Color(255, 255, 200, 100)
local ping = Game.Latency()/1000
local castXstate = 1
local castXtick = 0
local QSet = Prediction:SetSpell(Q, TYPE_LINE, true)
local QMSet = Prediction:SetSpell(QM, TYPE_LINE, true)
local WSet = Prediction:SetSpell(W, TYPE_LINE, true)
local RSet = Prediction:SetSpell(R, TYPE_CIRCULAR, true)
local customQvalid = 0
local customQMvalid = 0
local customWvalid = 0
local customRvalid = 0

print("Competitive Gnar Loaded !")

local Menu = MenuElement({id = "Menu", name = "Gnar", type = MENU, leftIcon = HeroIcon})
Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
Menu:MenuElement({id = "Laneclear", name = "Laneclear", type = MENU})
Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
Menu:MenuElement({id = "Accuracy", name = "Skillshot Hitchance", value = 0.15, min = 0.01, max = 1, step = 0.01})
Menu:MenuElement({name = "Version : 1.0", type = SPACE})
Menu:MenuElement({name = "By Tarto", type = SPACE})

--Combo
Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
Menu.Combo:MenuElement({id = "UseQM", name = "Use Q MEGA", value = true, leftIcon = QMIcon})
Menu.Combo:MenuElement({id = "UseW", name = "Use W MEGA", value = true, leftIcon = WIcon})
--Menu.Combo:MenuElement({id = "UseR", name = "Use R", value = true, leftIcon = RIcon})

--Harass
Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
Menu.Harass:MenuElement({id = "UseQM", name = "Use Q MEGA", value = false, leftIcon = QMIcon})
Menu.Harass:MenuElement({id = "UseW", name = "Use W MEGA", value = true, leftIcon = WIcon})

--Laneclear
Menu.Laneclear:MenuElement({id = "UseQ", name = "Use Q", value = false, leftIcon = QIcon})
--Menu.Laneclear:MenuElement({id = "UseQM", name = "Use Q MEGA", value = true, leftIcon = QMIcon})
--Menu.Laneclear:MenuElement({id = "UseW", name = "Use W MEGA", value = true, leftIcon = WIcon})

--Lashit
Menu.Lasthit:MenuElement({id = "UseQ", name = "Use Q", value = false, leftIcon = QIcon})
--Menu.Lasthit:MenuElement({id = "UseQM", name = "Use QM", value = true, leftIcon = QIcon})
--Menu.Lasthit:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = QIcon})

--Drawings
Menu.Drawings:MenuElement({id = "DrawAuto", name = "Draw AA Range", value = true, leftIcon = HeroIcon})
Menu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true, leftIcon = QIcon})
Menu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = true, leftIcon = WIcon})
Menu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = true, leftIcon = EIcon})
Menu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true, leftIcon = RIcon})

function Tick()
	if H.dead then return end
	AATick()
	CheckMode()
	--ForceSteal()
end

function AATick()
	if H.attackData.state == 2 then
		AA.Up = Game.Timer()
	elseif H.attackData.state == 3 then
		AA.Down = Game.Timer()
	end
end

function AARange()
	local level = H.levelData.lvl
	local range = ({510,516,522,528,534,540,545,551,557,563,569,575,581,587,593,599,604,610})[level]
	return range
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
	if Menu.Drawings.DrawAuto:Value() and not Buffed(H, "gnartransform") then
		Draw.Circle(H.pos, AARange() or 510, 2, ColorZ)
	elseif Menu.Drawings.DrawAuto:Value() then
		Draw.Circle(H.pos, AA.Mrange, 2, ColorZ)
	end
	if Menu.Drawings.DrawQ:Value() and not (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		Draw.Circle(H.pos, Q.range, 2, ColorY)
	elseif Menu.Drawings.DrawQ:Value() then
		Draw.Circle(H.pos, QM.range, 2, ColorZ)
	end
	if Menu.Drawings.DrawW:Value() and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		Draw.Circle(H.pos, W.range, 2, ColorY)
	end
	if Menu.Drawings.DrawR:Value() and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
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
	--[[if customWvalid ~= 0 then
		if Game.Timer() - customQvalid <= 0 then return end
	end
	if customEvalid ~= 0 then
		if Game.Timer() - customWvalid <= 0 then return end
	end
	if customWvalid ~= 0 then
		if Game.Timer() - customEvalid <= 0 then return end
	end
	if customWvalid ~= 0 then
		if Game.Timer() - customRvalid <= 0 then return end
	end]]
	local Custom = {delay = ping, spell = spell, minion = minion, hero = hero, hitchance = hitchance , hotkey = nil, pred = nil, Delay = nil}
	if Custom.minion == nil then Custom.minion = 0 end
	if Custom.hero == nil then Custom.hero = 0 end
	if Custom.spell == 0 then
		Custom.hotkey = HK_Q
		Custom.Delay = Q.delay
	elseif Custom.spell == 1 then
		Custom.hotkey = HK_Q
		Custom.Delay = QM.delay
	elseif Custom.spell == 2 then
		Custom.hotkey = HK_W
		Custom.Delay = W.delay
	elseif Custom.spell == 3 then
		Custom.hotkey = HK_R
		Custom.Delay = R.delay
	end
	if target ~= nil and Custom.hotkey ~= nil and not target.dead then
		if castXstate == 1 then
			if H.attackData.state == 2 then return end
			castXstate = 2
			local mLocation = nil
			if Custom.spell == 0 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = QSet:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and prediction:hCollision() == Custom.hero and prediction:mCollision() == Custom.minion and not target.dead and (Game.Timer() - castXtick) > 1 then
					if H.attackData.state == 2 then return end
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customQvalid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.8 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, Custom.delay)
					end
				end
			elseif Custom.spell == 1 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = QMSet:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and prediction:hCollision() == Custom.hero and prediction:mCollision() == Custom.minion and not target.dead and (Game.Timer() - castXtick) > 1 then
					if H.attackData.state == 2 then return end
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customQMvalid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay/2 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, Custom.delay)
					end
				end
			elseif Custom.spell == 2 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = WSet:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and not target.dead and (Game.Timer() - castXtick) > 1 then
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customWvalid = Game.Timer()
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
				if prediction and prediction.hitChance >= Custom.hitchance and not target.dead and (Game.Timer() - castXtick) > 1 then
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customRvalid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.8 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, Custom.delay)
					end
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

function TargetByDistance(range)
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

function MinionNumber(range, Type, who)
	if range == nil then return end
	if who == nil then who = H end
	local count = 0
	if Type == nil then
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if DistTo(minion.pos, who.pos) < range and minion.team ~= H.team then
				count = count + 1
				return count
			end
		end
	elseif Type == "ranged" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if who.team == 100 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_ChaosMinionRanged" then
					count = count + 1
					return count
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionRanged" then
					count = count + 1
					return count
				end
			end
		end
	elseif Type == "melee" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if who.team == 100 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_ChaosMinionMelee" then
					count = count + 1
					return count
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionRMelee" then
					count = count + 1
					return count
				end
			end
		end
	elseif Type == "siege" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if who.team == 100 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_ChaosMinionSiege" then
					count = count + 1
					return count
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionSiege" then
					count = count + 1
					return count
				end
			end
		end
	elseif Type == "super" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if who.team == 100 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_ChaosMinionSuper" then
					count = count + 1
					return count
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionSuper" then
					count = count + 1
					return count
				end
			end
		end
	end
end

function Buffed(target, buffname)
	if target == nil then return end
	local t = {}
 	for i = 0, target.buffCount do
    	local buff = target:GetBuff(i)
    	if buff.count > 0 then
      		table.insert(t, buff)
    	end
  	end
  	if t ~= nil then
  		for i, buff in pairs(t) do
			if buff.name == buffname and buff.expireTime > 0 then
				return true
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

function validDelays()
	if customQvalid ~= 0 then
		if Game.Timer() - customQvalid <= 0.25 then
			return true
		end
	elseif customQMvalid ~= 0 then
		if Game.Timer() - customQMvalid <= 0.5 then
			return true
		end
	elseif customWvalid ~= 0 then
		if Game.Timer() - customWvalid <= 0.6 then
			return true
		end
	elseif customRvalid ~= 0 then
		if Game.Timer() - customRvalid <= 0.25 then
			return true
		end
	else return false
	end
end

function ForceSteal()
	--
end

function CalculateDamage(spell)
	if spell == 0 and not (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		return ({5, 45, 85, 125, 165})[H:GetSpellData(0).level] + (1.15 * H.totalDamage)
	elseif spell == 1 and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		return ({5, 45, 85, 125, 165})[H:GetSpellData(0).level] + (1.2 * H.totalDamage)
	elseif spell == 2 and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		return ({25, 45, 65, 85, 105})[H:GetSpellData(1).level] + H.totalDamage
	elseif spell == 3 and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		return ({200, 300, 400})[H:GetSpellData(3).level] + (0.5 * H.ap) + (0.2 * H.totalDamage)
	else return
	end
end

function Combo()
	if H.activeSpell.valid or validDelays() then return end
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)

	if Game.CanUseSpell(0) == 0 then
		if Menu.Combo.UseQ:Value() and not Buffed(H, "gnartransform") and not Buffed(H, "gnartransformsoon") then
			local target = Target(Q.range, "damage")
			if target == nil then return end
			if DistTo(target.pos, H.pos) <= AARange() then
				if H.attackData.state ~= 2 and (Game.Timer() - AA.Up) < ((H.attackData.windDownTime)*0.6) then
					CastX(0, target, Menu.Accuracy:Value())
				end
			elseif DistTo(target.pos, H.pos) > AARange() and DistTo(target.pos, H.pos) < (AARange() + 40) and H.ms > target.ms then
				if H.attackData.state ~= 2 and (Game.Timer() - AA.Up) < ((H.attackData.windDownTime)*0.6) then
					CastX(0, target, Menu.Accuracy:Value())
				end
			elseif DistTo(target.pos, H.pos) > AARange() then
				CastX(0, target, Menu.Accuracy:Value())
			end
		elseif Menu.Combo.UseQM:Value() and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
			local target = Target(QM.range, "damage")
			if target == nil then return end
			if DistTo(target.pos, H.pos) <= AA.Mrange then
				if H.attackData.state ~= 2 and (Game.Timer() - AA.Up) < ((H.attackData.windDownTime)*0.6) then
					CastX(1, target, Menu.Accuracy:Value())
				end
			elseif DistTo(target.pos, H.pos) > AA.Mrange and DistTo(target.pos, H.pos) < (AA.Mrange + 40) and H.ms > target.ms then
				if H.attackData.state ~= 2 and (Game.Timer() - AA.Up) < ((H.attackData.windDownTime)*0.6) then
					CastX(1, target, Menu.Accuracy:Value())
				end
			elseif DistTo(target.pos, H.pos) > AA.Mrange then
				CastX(1, target, Menu.Accuracy:Value())
			end
		end
	end
	if Menu.Combo.UseW:Value() and Game.CanUseSpell(1) == 0 and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		local target = Target(W.range, "damage")
		if target == nil then return end
		if DistTo(target.pos, H.pos) < W.range then
			if (H.health*100)/H.maxHealth > 30 then
				if H.attackData.state ~= 2 and (Game.Timer() - AA.Up) < ((H.attackData.windDownTime)*0.6) then
					CastX(2, target, Menu.Accuracy:Value())
				else
					CastX(2, target, Menu.Accuracy:Value())
				end
			end
		end
	end
end

function Harass()
	if H.activeSpell.valid or validDelays() then return end
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)

	if Game.CanUseSpell(0) == 0 then
		if Menu.Harass.UseQ:Value() and not Buffed(H, "gnartransform") then
			local target = Target(Q.range, "damage")
			if target == nil then return end
			if DistTo(target.pos, H.pos) <= Q.range and H.attackData.state ~= 2 then
				CastX(0, target, Menu.Accuracy:Value())
			end
		elseif Menu.Harass.UseQM:Value() and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
			local target = Target(QM.range, "damage")
			if target == nil then return end
			if DistTo(target.pos, H.pos) <= QM.range and H.attackData.state ~= 2 then
				CastX(1, target, Menu.Accuracy:Value())
			end
		end
	end
	if Game.CanUseSpell(1) == 0 then
		if Menu.Harass.UseW:Value() and (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
			local target = Target(W.range, "damage")
			if target== nil then return end
			if DistTo(target.pos, H.pos) <= W.range and H.attackData ~= 2 then
				CastX(2, target, Menu.Accuracy:Value())
			end
		end
	end
end

function Laneclear()
	if H.activeSpell.valid or validDelays() then return end
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)

	if Menu.Laneclear.UseQ:Value() and Game.CanUseSpell(0) == 0 and not (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion.team ~= H.team and DistTo(minion.pos, H.pos) < Q.range and minion ~= nil and HealthPred(minion, Q.delay) > 0 then
				if minion == nil then return end
				local mLocation = nil
				if not minion.toScreen.onScreen then
					return
				end
				local prediction = QSet:GetPrediction(minion, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Menu.Accuracy:Value() and prediction:hCollision() == 0 and prediction:mCollision() == 0 and not minion.dead and (Game.Timer() - castXtick) > 1 then
					if H.attackData.state == 2 then return end
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, ping)
					if minion ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, ping)
						DelayAction(function() Control.KeyDown(HK_Q) end, ping)
						DelayAction(function() Control.KeyUp(HK_Q) end, ping)
						customQvalid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Q.delay*0.8 + ping))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, ping)
					end
				end
			end
		end
	end
end

function Jungleclear()
	--
end

function Lasthit()
	if H.activeSpell.valid or validDelays() then return end
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)

	if Menu.Lasthit.UseQ:Value() and Game.CanUseSpell(0) == 0 and not (Buffed(H, "gnartransform") or Buffed(H, "gnartransformsoon")) then
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if minion.team ~= H.team and DistTo(minion.pos, H.pos) < Q.range and DistTo(minion.pos, H.pos) > AARange() and minion ~= nil then
				if (HealthPred(minion, (Q.delay + ping)) < CalculateDamage(0) or minion.health < CalculateDamage(0)) and minion.health ~= minion.maxHealth then
					local mLocation = nil
					if not minion.toScreen.onScreen then
						return
					end
					local prediction = QSet:GetPrediction(minion, H.pos)
					OrbState("Attack", false)
					if prediction and prediction.hitChance >= Menu.Accuracy:Value() and prediction:hCollision() == 0 and prediction:mCollision() == 0 and not minion.dead and (Game.Timer() - castXtick) > 1 then
						if H.attackData.state == 2 then return end
						mLocation = mousePos
						if mLocation == nil then return end
						DelayAction(function() OrbState("Movement", false) end, ping)
						if minion ~= nil then
							DelayAction(function() Control.SetCursorPos(prediction.castPos) end, ping)
							DelayAction(function() Control.KeyDown(HK_Q) end, ping)
							DelayAction(function() Control.KeyUp(HK_Q) end, ping)
							customQvalid = Game.Timer()
							DelayAction(function() Control.SetCursorPos(mLocation) end, (Q.delay*0.8 + ping))
							castXstate = 1
							castXtick = Game.Timer()
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				end
			end
		end
	end
end

function Flee()
	--
end

Callback.Add("Tick", function() Tick() end)
Callback.Add("Draw", function() Draws() end)
