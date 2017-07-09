if myHero.charName ~= "Yasuo" then return end

require 'Eternal Prediction'
require 'DamageLib'

class "Yasuo"

--lasthit E priority___done
--Damages calculatiosn E et Q
--R sur tout knockup___done
--rework le E sur creep pour chase___done
--killsteal E, Q
--Utiliser moins E si plein d'ennemis
--laneclear, si pas de creep à finir et Q en cd, utiliser E quand meme___done
--Botrk usage
--Fin de hourglass prevoir trajectoire
--E tourelle check selon position___done
--flee
--insta R si sur le point de mourir
--delay R pour eviter de spammer pendant ulti
--Si creeps autour cible, Stacker E sur creeps avant de E l'ennemi pour les 50% de damages
--Angle pour E chase

local Q = {range = 550, delay = 0.4, speed = math.huge, width = 20}
local Q3 = {range = 1150, delay = 0.5, speed = 1500, width, 90}
--local W = {range = 2550, delay = 0.75, speed = 5000, width = }
local E = {range = 450, delay = 0.25}
local R = {range = 1200}
local HeroIcon = "https://i11.servimg.com/u/f11/16/33/77/19/yasuoi10.png"
local QIcon = "https://i11.servimg.com/u/f11/16/33/77/19/yasuoq11.png"
local Q3Icon = "https://i11.servimg.com/u/f11/16/33/77/19/yasuoq10.png"
local WIcon = "https://i11.servimg.com/u/f11/16/33/77/19/yasuow10.png"
local EIcon = "https://i11.servimg.com/u/f11/16/33/77/19/yasuoe10.png"
local RIcon = "https://i11.servimg.com/u/f11/16/33/77/19/yasuor10.png"
local H = myHero
local ping = Game.Latency()/1000
local ColorY, ColorZ = Draw.Color(255, 255, 255, 100), Draw.Color(255, 255, 200, 100)
local castXstate = 1
local castXtick = 0
local QSet = Prediction:SetSpell(Q, TYPE_LINE, true)
local Q3Set = Prediction:SetSpell(Q3, TYPE_LINE, true)
--local WSet = Prediction:SetSpell(W, TYPE_LINE, true)
local ESet = Prediction:SetSpell(E, TYPE_CIRCULAR, true)
local RSet = Prediction:SetSpell(R, TYPE_LINE, true)
local customQvalid = 0
local customQ3valid = 0
local customWvalid = 0
local customEvalid = 0
local customRvalid = 0
local AA = {Up = 0, Down = 0, range = 305}

print("")

local Menu = MenuElement({id = "Menu", name = "Yasuo", type = MENU})
Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
Menu:MenuElement({id = "Laneclear", name = "Laneclear", type = MENU})
Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
Menu:MenuElement({id = "Killsteal", name = "Lasthit", type = MENU})
--Menu:MenuElement({id = "Flee", name = "Flee", type = MENU})
Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
Menu:MenuElement({id = "UseQauto", name = "Auto stack Q (not recommended)", value = false})
Menu:MenuElement({id = "AccuracyQ", name = "Q1 Hitchance", value = 0.1, min = 0.01, max = 1, step = 0.01})
Menu:MenuElement({id = "AccuracyQ3", name = "Q3 Hitchance", value = 0.12, min = 0.01, max = 1, step = 0.01})

Menu:MenuElement({name = "Version : 1.10", type = SPACE})
Menu:MenuElement({name = "By Tarto", type = SPACE})

Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "UseQ3", name = "Use Q3", value = true})
Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "UseAIR", name = "Use R", value = true})
Menu.Combo:MenuElement({id = "UseAIRtype", name = "R type (1= 100% R, 2=moreDPS)", value = 2, min = 1, max = 2, step = 1})
Menu.Combo:MenuElement({id = "MiniR", name = "Minimum enemies to cast R", value = 1, min = 1, max = 5, step = 1})
--Harass
Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "UseQ3", name = "Use Q3", value = true})

--Laneclear
Menu.Laneclear:MenuElement({id = "UseQ", name = "Use Q", value = true})
Menu.Laneclear:MenuElement({id = "UseQ3", name = "Use Q3", value = false})
Menu.Laneclear:MenuElement({id = "UseE", name = "Use E", value = false})

--Lasthit
Menu.Lasthit:MenuElement({id = "UseQ", name = "Use Q", value = true})
Menu.Lasthit:MenuElement({id = "UseQ3", name = "Use Q3", value = true})
Menu.Lasthit:MenuElement({id = "UseE", name = "Use E", value = true})

--Killsteal
Menu.Killsteal:MenuElement({id = "UseQ", name = "Use Q", value = true})
Menu.Killsteal:MenuElement({id = "UseQ3", name = "Use Q3", value = true})
Menu.Killsteal:MenuElement({id = "UseE", name = "Use E", value = true})

--Flee
--Menu.Flee:MenuElement({id = "UseE", name = "Use E", value = true})

--Drawings
Menu.Drawings:MenuElement({id = "DrawAuto", name = "Draw AA Range", value = false})
Menu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = false})
Menu.Drawings:MenuElement({id = "DrawQ3", name = "Draw Q3 Range", value = false})
Menu.Drawings:MenuElement({id = "DrawE", name = "Draw E Range", value = false})
Menu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = false})

function Tick()
	if H.dead then return end
	AATick()
	AutoUlt()
	CheckMode()
	AutoQ()
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

function AutoUlt()
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			if Menu.Combo.UseAIR:Value() and Menu.Combo.UseAIRtype:Value() == 1 and Game.CanUseSpell(3) == 0 and CanUlt() then
				local target = Target(R.range, "damage")
				if target == nil then return end
				if Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name ~= "YasuoQ3W" and DistTo(target.pos, H.pos) < Q.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime ))
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime ))
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name == "YasuoQ3W" and DistTo(target.pos, H.pos) < Q3.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and DistTo(target.pos, H.pos) < AA.range then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime ))
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif H.attackData.state ~= 2 then
					Control.CastSpell(HK_R)
				end
			elseif Menu.Combo.UseAIR:Value() and Menu.Combo.UseAIRtype:Value() == 2 and Game.CanUseSpell(3) == 0 and CanUlt() then
				local target = Target(R.range, "damage")
				if target == nil then return end
				if Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name ~= "YasuoQ3W" and DistTo(target.pos, H.pos) < Q.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name == "YasuoQ3W" and DistTo(target.pos, H.pos) < Q3.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and DistTo(target.pos, H.pos) < AA.range then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif H.attackData.state ~= 2 then
					Control.CastSpell(HK_R)
				end
			end
		end
	elseif EOWLoaded then
		if EOW:Mode() == 1 then
			if Menu.Combo.UseAIR:Value() and Menu.Combo.UseAIRtype:Value() == 1 and Game.CanUseSpell(3) == 0 and CanUlt() then
				local target = Target(R.range, "damage")
				if target == nil then return end
				if Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name ~= "YasuoQ3W" and DistTo(target.pos, H.pos) < Q.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime ))
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime ))
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name == "YasuoQ3W" and DistTo(target.pos, H.pos) < Q3.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and DistTo(target.pos, H.pos) < AA.range then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay )
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime ))
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() Control.CastSpell(HK_R, target) end, ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif H.attackData.state ~= 2 then
					Control.CastSpell(HK_R)
				end
			elseif Menu.Combo.UseAIR:Value() and Menu.Combo.UseAIRtype:Value() == 2 and Game.CanUseSpell(3) == 0 and CanUlt() then
				local target = Target(R.range, "damage")
				if target == nil then return end
				if Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name ~= "YasuoQ3W" and DistTo(target.pos, H.pos) < Q.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						elseif check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and H:GetSpellData(0).name == "YasuoQ3W" and DistTo(target.pos, H.pos) < Q3.range and Game.CanUseSpell(0) == 0 then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + Q3.delay + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q3.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif Buffed(target, "YasuoQ3Mis") and DistTo(target.pos, H.pos) < AA.range then
					local check = BuffedReturn(target, "YasuoQ3Mis")
					if H.attackData.state ~= 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping*5 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_Q, target) end, (((Game.Timer() - AA.Up) - H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() Control.CastSpell(HK_R, target) end, Q.delay + ping)
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					elseif H.attackData.state == 2 then
						if check.expireTime > (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping*4 + 0.2) then
							OrbState("Movement", false)
							Force(target)
							DelayAction(function() Control.CastSpell(HK_R, target) end, (((Game.Timer() - AA.Up) - H.attackData.windUpTime + H.attackData.windDownTime) + H.attackData.windUpTime + ping))
							DelayAction(function() OrbState("Global", true) end, ping)
						end
					end
				elseif H.attackData.state ~= 2 then
					Control.CastSpell(HK_R)
				end
			end
		end
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
		Draw.Circle(H.pos, AA.range, 2, ColorZ)
	end
	if Menu.Drawings.DrawQ:Value() then
		Draw.Circle(H.pos, Q.range, 2, ColorY)
	end
	if Menu.Drawings.DrawQ3:Value() then
		Draw.Circle(H.pos, Q3.range, 2, ColorY)
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
	local Custom = {delay = ping, spell = spell, minion = minion, hero = hero, hitchance = hitchance, hotkey = nil, pred = nil, Delay = nil}
	if Custom.minion == nil then Custom.minion = 0 end
	if Custom.hero == nil then Custom.hero = 0 end
	if Custom.hitchance == nil then Custom.hitchance = 0.20 end
	if Custom.spell == 0 then
		Custom.hotkey = HK_Q
		Custom.Delay = Q.delay
	elseif Custom.spell == 1 then
		Custom.hotkey = HK_Q
		Custom.Delay = Q3.delay
	elseif Custom.spell == 2 then
		Custom.hotkey = HK_E
		Custom.Delay = E.delay
	elseif Custom.spell == 3 then
		Custom.hotkey = HK_R
		Custom.Delay = R.delay
	end
	if target ~= nil and Custom.hotkey ~= nil and Custom.Delay ~= nil and not target.dead then
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
				if prediction and prediction.hitChance >= Custom.hitchance and not target.dead and (Game.Timer() - castXtick) > 1 then
					if H.attackData.state == 2 then return end
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customQvalid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.25 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, (Custom.Delay*0.25 + Custom.delay))
					end
				end
			elseif Custom.spell == 1 then
				if HealthPred(target, Custom.Delay + 0.1) < 1 then return end
				if not target.toScreen.onScreen then
					return
				end
				local prediction = Q3Set:GetPrediction(target, H.pos)
				OrbState("Attack", false)
				if prediction and prediction.hitChance >= Custom.hitchance and not target.dead and (Game.Timer() - castXtick) > 1 then
					if H.attackData.state == 2 then return end
					mLocation = mousePos
					if mLocation == nil then return end
					DelayAction(function() OrbState("Movement", false) end, Custom.delay)
					if target ~= nil then
						DelayAction(function() Control.SetCursorPos(prediction.castPos) end, Custom.delay)
						DelayAction(function() Control.KeyDown(Custom.hotkey) end, Custom.delay)
						DelayAction(function() Control.KeyUp(Custom.hotkey) end, Custom.delay)
						customQ3valid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.25 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, (Custom.Delay*0.25 + Custom.delay))
					end
				end
			elseif Custom.spell == 2 then
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
						customEvalid = Game.Timer()
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.25 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, (Custom.Delay*0.25 + Custom.delay))
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
						DelayAction(function() Control.SetCursorPos(mLocation) end, (Custom.Delay*0.25 + Custom.delay))
						castXstate = 1
						castXtick = Game.Timer()
						DelayAction(function() OrbState("Global", true) end, (Custom.Delay*0.25 + Custom.delay))
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

function TurretEnemyAround(range, position)
	local count = 0
	for i = 0, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret.isEnemy and DistTo(turret.pos, position) <= range then
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
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if DistTo(minion.pos, who.pos) < range and minion.isEnemy then
				count = count + 1
			end
		end
	elseif Type == "ranged" then
		local minion = 0
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if who.team == 100 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_ChaosMinionRanged" then
					count = count + 1
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionRanged" then
					count = count + 1
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
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionRMelee" then
					count = count + 1
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
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionSiege" then
					count = count + 1
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
				end
			elseif who.team == 200 then
				if DistTo(minion.pos, who.pos) < range and minion.charName == "SRU_OrderMinionSuper" then
					count = count + 1
				end
			end
		end
	end
	return count
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

function BuffedReturn(target, buffname)
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
				if buff == nil then
					return
				else
					return buff
				end
			elseif buffname == "YasuoQ3Mis" then
				if buff.type == (29 or 30) and buff.expireTime > 0 then
					return buff
				end
			end
		end
	end
end

function CanUlt()
	local count = 0
	for i = 0, Game.HeroCount() do
		local hero = Game.Hero(i)
		if DistTo(hero.pos, H.pos) < R.range then
			if hero == nil then return end
			local t = {}
 			for i = 0, hero.buffCount do
    			local buff = hero:GetBuff(i)
    			if buff.count > 0 then
    				table.insert(t, buff)
    			end
  			end
  			if t ~= nil then
  				for i, buff in pairs(t) do
					if buff.name == "YasuoQ3Mis" and buff.expireTime > 0 then
						count = count +1
						if count >= Menu.Combo.MiniR:Value() then
							return true
						end
					elseif buff.type == (29 or 30) and buff.expireTime > 0 then
						count = count +1
						if count >= Menu.Combo.MiniR:Value() then
							return true
						end
					end
				end
			end
		end
	end
	return false
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
	--
end

function AbleEChase()
	for i = 0, Game.HeroCount() do
		local target = Game.Hero(i)
		if DistTo(target.pos, H.pos) < Q.range and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name ~= "YasuoQ3W" then return false end
		if Menu.Combo.UseE:Value() and Game.CanUseSpell(2) == 0 then
			if DistTo(target.pos, H.pos) > E.range and DistTo(target.pos, H.pos) <= 1500 then
				for i = 0, Game.MinionCount() do
					local minion = Game.Minion(i)
					if minion.isEnemy and DistTo(minion.pos, H.pos) < DistTo(target.pos, H.pos) and DistTo(minion.pos, target.pos) < DistTo(target.pos, H.pos) and DistTo(minion.pos, H.pos) < E.range then
						for i = 0, Game.MinionCount() do
							local minion2 = Game.Minion(i)
							if minion2.isEnemy and DistTo(minion2.pos, H.pos) < DistTo(target.pos, H.pos) and DistTo(minion2.pos, target.pos) < DistTo(target.pos, H.pos) and DistTo(minion2.pos, target.pos) < (E.range + 100) then
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end

--[[function MinionNext(minion, target)
	if minion == nil or target == nil then return end
	for i = 0, Game.MinionCount()
		local minion2 = Game.Minion(i)
		if minion2.isEnemy and DistTo(minion2.pos, minion.pos) < (E.range + 50) and DistTo(minion2.pos, H.pos) < DistTo(hero.pos, H.pos) and DistTo(minion2.pos, hero.pos) < DistTo(hero.pos, H.pos) then


			for i = 0, Game.HeroCount() do
					local hero = Game.Hero(i)
					if hero.isEnemy and not hero.dead and DistTo(hero.pos, H.pos) <= 1800 then
						for i = 0, Game.MinionCount() do
							local minion = Game.Minion(i)
							if minion.isEnemy and DistTo(minion.pos, H.pos) < E.range and DistTo(minion.pos, H.pos) < DistTo(hero.pos, H.pos) and DistTo(minion.pos, hero.pos) < DistTo(hero.pos, H.pos) then
								Control.CastSpell(HK_E, minion)
							end
						end
					end
				end]]


function AutoQ()
	if Game.Timer() < 91 or not Menu.UseQauto:Value() then return end
	if customQvalid ~= 0 then
		if Game.Timer() - customQvalid <= 0.4 then return end
	end
	if customQ3valid ~= 0 then
		if Game.Timer() - customQ3valid <= 0.5 then return end
	end
	if customEvalid ~= 0 then
		if Game.Timer() - customEvalid <= 0.5 then return end
	end
	if Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name ~= "YasuoQ3W" then
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			if DistTo(minion.pos, H.pos) < Q.range and H.attackData.state ~= 2 then
				CastX(0, minion, Menu.AccuracyQ:Value())
			end
		end
	end
end

function Combo()
	--YasuoDashWrapper
	--YasuoDashScalar
	if Game.Timer() >= 91 or not H.activeSpell.valid then 
		if customQvalid ~= 0 then
			if Game.Timer() - customQvalid <= 0.4 then return end
		end
		if customQ3valid ~= 0 then
			if Game.Timer() - customQ3valid <= 0.5 then return end
		end
		if customEvalid ~= 0 then
			if Game.Timer() - customEvalid <= 0.5 then return end
		end
		Force(nil)
		ForceMove(nil)
		castXstate = 1
		OrbState("Global", true)

		local target = Target(1500, "damage")
		if target == nil then return end

		if Menu.Combo.UseQ:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name ~= "YasuoQ3W" and DistTo(target.pos, H.pos) < Q.range then
			if H.attackData.state ~= 2 and DistTo(target.pos, H.pos) < Q.range then
				CastX(0, target, Menu.AccuracyQ:Value())
				return
			end
		elseif Menu.Combo.UseQ3:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name == "YasuoQ3W" and DistTo(target.pos, H.pos) < Q3.range then
			if H.attackData.state ~= 2 and DistTo(target.pos, H.pos) < Q3.range then
				CastX(1, target, Menu.AccuracyQ3:Value())
				return
			end
		elseif Menu.Combo.UseE:Value() and Game.CanUseSpell(2) == 0 and DistTo(target.pos, H.pos) < E.range then
			if target == nil then return end
			if H.attackData.state ~= 2 and DistTo(target.pos, H.pos) < E.range and DistTo(target.pos, H.pos) > 150 and not Buffed(target, "YasuoDashWrapper") then
				local distanceSup = 500 - DistTo(target.pos, H.pos)
				local new = H.pos:Extended(target.pos, distanceSup)
				if new == nil then return end
				if TurretEnemyAround(800, new.pos) == 0 then
					Control.CastSpell(HK_E, target)
					return
				end
			end
		elseif Menu.Combo.UseE:Value() and Game.CanUseSpell(2) == 0 and DistTo(target.pos, H.pos) < 1500 then
			if H.attackData.state ~= 2 then
				for i = 0, Game.MinionCount() do
					local minion = Game.Minion(i)
					if minion.isEnemy and DistTo(minion.pos, H.pos) <= E.range and DistTo(minion.pos, H.pos) < DistTo(target.pos, H.pos) and DistTo(minion.pos, target.pos) < DistTo(target.pos, H.pos) then
						local distanceSup = 500 - DistTo(minion.pos, H.pos)
						local new = H.pos:Extended(minion.pos, distanceSup)
						if new == nil then return end
						if minion.pos:AngleBetween(H.pos, target.pos) < 135 or minion.pos:AngleBetween(H.pos, target.pos) > 225 then return end
						if TurretEnemyAround(800, new.pos) == 0 then
							Control.CastSpell(HK_E, minion)
							return
						end
					end
				end
			end
		end		
	else
		if Menu.Combo.UseQ:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name ~= "YasuoQ3W" then
			target = Target(Q.range, "damage")
			if target == nil then return end
			if H.attackData.state ~= 2 then
				CastX(0, target, Menu.AccuracyQ:Value())
				return
			end
		elseif Menu.Combo.UseQ3:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name == "YasuoQ3W" then
			target = Target(Q3.range, "damage")
			if target == nil then return end
			if H.attackData.state ~= 2 then
				CastX(1, target, Menu.AccuracyQ3:Value())
				return
			end
		end
	end
end

function Harass()
	if H.activeSpell.valid then return end
	if customQvalid ~= 0 then
		if Game.Timer() - customQvalid <= 0.4 then return end
	end
	if customQ3valid ~= 0 then
		if Game.Timer() - customQ3valid <= 0.5 then return end
	end
	if customEvalid ~= 0 then
		if Game.Timer() - customEvalid <= 0.25 then return end
	end
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)

	if Menu.Harass.UseQ:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name ~= "YasuoQ3W" then
		local target = Target(Q.range, "damage")
		if target == nil then return end
		if H.attackData.state ~= 2 then
			CastX(0, target, Menu.AccuracyQ:Value())
		end
	elseif Menu.Harass.UseQ3:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name == "YasuoQ3W" then
		local target = Target(Q3.range, "damage")
		if target == nil then return end
		if H.attackData.state ~= 2 then
			CastX(1, target, Menu.AccuracyQ3:Value())
		end
	end
end

function Laneclear()
	if H.activeSpell.valid or Game.Timer() < 91 then return end
	if customQvalid ~= 0 then
		if Game.Timer() - customQvalid <= 0.4 then return end
	end
	if customQ3valid ~= 0 then
		if Game.Timer() - customQ3valid <= 0.5 then return end
	end
	if customEvalid ~= 0 then
		if Game.Timer() - customEvalid <= 0.25 then return end
	end
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)

	for i = 0, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion == nil then return end
		if Menu.Laneclear.UseE:Value() and Game.CanUseSpell(2) == 0 then
			if minion == nil then return end
			local distanceSup = 500 - DistTo(minion.pos, H.pos)
			local new = H.pos:Extended(minion.pos, distanceSup)
			if new == nil then return end
			if TurretEnemyAround(800, new.pos) == 0 then
				local t = {}
				local hihi, buff = 0, nil
 				for i = 0, H.buffCount do
    				buff = H:GetBuff(i)
    				if buff.count > 0 then
      					table.insert(t, buff)
    				end
  				end
  				if t ~= nil then
  					for i, buff in pairs(t) do
						if buff.name == "YasuoDashScalar" and buff.expireTime > 0 then
							hihi = 1
						end
					end
				end
				if hihi ~= 1 then
					if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < E.range and minion.health < getdmg("E", minion, H) then
						Control.CastSpell(HK_E, minion)
					end
				elseif hihi == 1 then
					if buff.count == 1 then
						if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < E.range and minion.health < (getdmg("E", minion, H)*1.25) then
							Control.CastSpell(HK_E, minion)
						end
					elseif buff.count == 2 then
						if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < E.range and minion.health < (getdmg("E", minion, H)*1.5) then
							Control.CastSpell(HK_E, minion)
						end
					end
				elseif minion.isEnemy and H.attackData ~= 2 and DistTo(minion.pos, H.pos) < E.range and Game.CanUseSpell(0) ~= 0 then
					for i = 0, Game.MinionCount() do
						local minion2 = Game.Minion(i)
						if minion == nil then return end
						if minion.isEnemy and HealthPred(minion, E.delay + ping + 0.1) then
							return
						else
							Control.CastSpell(HK_E, minion)
						end
					end
				end
			end
		end
		if Menu.Laneclear.UseQ:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name ~= "YasuoQ3W" then
			if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < Q.range then
				OrbState("Global", true)
				CastX(0, minion, 0.075)
			end
		elseif Menu.Laneclear.UseQ3:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name == "YasuoQ3W" then
			local minion = Game.Minion(i)
			if minion == nil then return end
			if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < Q3.range then
				OrbState("Global", true)
				CastX(1, minion, 0.075)
			end
		end
	end
end

function Jungleclear()
	--
end

function Lasthit()
	if H.activeSpell.valid or Game.Timer() < 91 then return end
	if customQvalid ~= 0 then
		if Game.Timer() - customQvalid <= 0.4 then return end
	end
	if customQ3valid ~= 0 then
		if Game.Timer() - customQ3valid <= 0.5 then return end
	end
	if customEvalid ~= 0 then
		if Game.Timer() - customEvalid <= 0.25 then return end
	end
	Force(nil)
	ForceMove(nil)
	castXstate = 1
	OrbState("Global", true)

	for i = 0, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion == nil then return end
		if Menu.Lasthit.UseE:Value() and Game.CanUseSpell(2) == 0 then
			if minion == nil then return end
			local distanceSup = 500 - DistTo(minion.pos, H.pos)
			local new = H.pos:Extended(minion.pos, distanceSup)
			if new == nil then return end
			if TurretEnemyAround(800, new.pos) == 0 then
				local t = {}
				local hihi, buff = 0, nil
 				for i = 0, H.buffCount do
    				buff = H:GetBuff(i)
    				if buff.count > 0 then
    					table.insert(t, buff)
    				end
  				end
  				if t ~= nil then
  					for i, buff in pairs(t) do
						if buff.name == "YasuoDashScalar" and buff.expireTime > 0 then
							hihi = 1
						end
					end
				end
				if hihi ~= 1 then
					if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < E.range and minion.health < getdmg("E", minion, H) then
						Control.CastSpell(HK_E, minion)
					end
				elseif hihi == 1 then
					if buff.count == 1 then
						if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < E.range and minion.health < (getdmg("E", minion, H)*1.25) then
							Control.CastSpell(HK_E, minion)
						end
					elseif buff.count == 2 then
						if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < E.range and minion.health < (getdmg("E", minion, H)*1.5) then
							Control.CastSpell(HK_E, minion)
						end
					end
				end
			end
		end
		if Menu.Lasthit.UseQ:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name ~= "YasuoQ3W" then
			if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < Q.range and minion.health < getdmg("Q", minion, H) then
				CastX(0, minion, Menu.AccuracyQ:Value())
			end
		elseif Menu.Lasthit.UseQ3:Value() and Game.CanUseSpell(0) == 0 and H:GetSpellData(0).name == "YasuoQ3W" then
			if minion.isEnemy and H.attackData.state ~= 2 and DistTo(minion.pos, H.pos) < Q3.range and minion.health < getdmg("Q", minion, H) then
				CastX(1, minion, Menu.AccuracyQ3:Value())
			end
		end
	end
end


function Flee()
	if H.activeSpell.valid or Game.Timer() < 91 then return end
	if customQvalid ~= 0 then
		if Game.Timer() - customQvalid <= 0.4 then return end
	end
	if customQ3valid ~= 0 then
		if Game.Timer() - customQ3valid <= 0.5 then return end
	end
	if customEvalid ~= 0 then
		if Game.Timer() - customEvalid <= 0.25 then return end
	end 
	ForceMove(nil)
	OrbState("Global", true)
	print("lol")

	if Menu.Flee.UseE:Value() and Game.CanUseSpell(2) == 0 then
		for i = 0, Game.MinionCount() do
			local minion = Game.Minion(i)
			local cucur = mousePos
			if minion == nil then return end
			print("non")
			if minion.isEnemy and DistTo(minion.pos, H.pos) < DistTo(cucur, H.pos) and DistTo(minion.pos, cucur) < DistTo(cucur, H.pos) and DistTo(minion.pos, H.pos) < E.range then
				print("oui")
				Control.CastSpell(HK_E, minion)
			end
		end
	end
end

Callback.Add("Tick", function() Tick() end)
Callback.Add("Draw", function() Draws() end)
