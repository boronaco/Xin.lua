
if myHero.charName ~= "Ezreal" then return end

print("Welcome to Jackie's Ezreal")



require "DamageLib"
require "Collision"

-- Spell

local Q = myHero:GetSpellData(_Q);
local W = myHero:GetSpellData(_W);
--local W = {range = 1500, delay = 600, minionCollisionWidth = 60, speed = 3200}
local E = myHero:GetSpellData(_E);
local R = myHero:GetSpellData(_R);
local myRange = myHero.range+myHero.boundingRadius
--Menu

local GameMenu = MenuElement({type = MENU, id = "GameMenu", name = "Jackie's Ezreal"})

GameMenu:MenuElement({type = SPACE, id = "ver", name = "v 1.0"})
GameMenu:MenuElement({type = SPACE, id = "about", name = "by Jackie099"})

local _OnVision = {}
function OnVision(unit)
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
	return _OnVision[unit.networkID]
end

local function GetBuffData(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return buff
		end
	end
	return {type = 0, name = "", startTime = 0, expireTime = 0, duration = 0, stacks = 0, count = 0}--
end

local function IsImmobileTarget(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
			return true
		end
	end
	return false	
end

local function GetBuffs(unit)
	local t = {}
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.count > 0 then
			table.insert(t, buff)
		end
	end
	return t
end

local sqrt = math.sqrt 
local function GetDistance(p1,p2)
	return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y) + (p2.z - p1.z)*(p2.z - p1.z))
end

local function GetDistance2D(p1,p2)
	return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
end



local _OnWaypoint = {}
function OnWaypoint(unit)
	if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = Game.Timer()} end
	if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
		-- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
		_OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
			DelayAction(function()
				local time = (Game.Timer() - _OnWaypoint[unit.networkID].time)
				local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
				if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and GetDistance(unit.pos,_OnWaypoint[unit.networkID].pos) > 200 then
					_OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(Game.Timer() - _OnWaypoint[unit.networkID].time)
					-- print("OnDash: "..unit.charName)
				end
			end,0.05)
	end
	return _OnWaypoint[unit.networkID]
end

function GetPred(unit,speed,delay)
	if unit == nil then return end
	local speed = speed or math.huge
	local delay = delay or 0.25
	local unitSpeed = unit.ms
	if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
	if OnVision(unit).state == false then
		local unitPos = unit.pos + Vector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)/1000 * unitSpeed)
		local predPos = unitPos + Vector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unitPos)/speed)))
		if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
		return predPos
	else
		if unitSpeed > unit.ms then
			local predPos = unit.pos + Vector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (GetDistance(myHero.pos,unit.pos)/speed)))
			if GetDistance(unit.pos,predPos) > GetDistance(unit.pos,unit.posTo) then predPos = unit.posTo end
			return predPos
		elseif IsImmobileTarget(unit) then
			return unit.pos
		else
			return unit:GetPrediction(speed,delay)
		end
	end
end

local ticks = GetTickCount()

function dCast(k,t,d)
	if t then
		local m
		local ping = Game.Latency()/1000
		local new_tick = GetTickCount() - ticks
		--print(new_tick)
		if new_tick > 0.4*1800 then	
			
			_G.SDK.Orbwalker:SetMovement(false)
			_G.SDK.Orbwalker:SetAttack(false)

			DelayAction(function()		
				m = mousePos
				--print(m,"got curse")	
				Control.SetCursorPos(t)
				Control.KeyDown(k)
				Control.KeyUp(k)
				--print(t,"finished cast")

				DelayAction(function()
					Control.SetCursorPos(m)
					--print(tick,"reset curse")
					_G.SDK.Orbwalker:SetMovement(true)
					
					DelayAction(function()
						_G.SDK.Orbwalker:SetAttack(true)  
					end,(0.1))
					
				end,(0.20))


			end,0.1)
			ticks = GetTickCount()
		end
	end
end




 
local Q_Collision = Collision:SetSpell(Q.range, Q.speed, 2, 70, true)

--local firstAttack = true


local pred
Callback.Add("Tick", function()
	--print(Game.Timer()-myHero:GetSpellData(_E).castTime)
	E_Spell = myHero:GetSpellData(_E)
	--print(myHero.activeSpell.name)

	local t = _G.SDK.TargetSelector:GetTarget(Q.range)
	pred = GetPred(t,Q.speed,0.1)
	
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		if myHero.attackData.state == STATE_WINDUP then
			return
		end
		

		if Game.CanUseSpell(_Q) == READY then
			
			if t then
				if t and t.distance < Q.range then
					--local predpos = t:GetPrediction(Q.speed,250/1000)
					
					local block, list = Q_Collision:__GetCollision(myHero, pred, 5)
					local dis = pred:DistanceTo(myHero.pos)
					--local dis = t.distance
					local onProcess = myHero.activeSpell.name
					if not is and onProcess == "EzrealArcaneShift" or onProcess == "EzrealMysticShot" then
						return
					end
					
					if dis < myRange and not block and myHero.attackData.state == 3 then
						--print(ticks,"aa cast")
						dCast(HK_Q,pred,250)
					-- elseif	dis < Q.range and  dis > myRange and not block then
					-- 	dCast(HK_Q,predpos,25)
					
					elseif dis < Q.range and not block then
						--print(ticks,"range cast")
						dCast(HK_Q,myHero.pos:Extended(pred,math.random(400,600)),250)
					end
				end
			end
		end

	end





end)

Callback.Add("Draw", function()
	if myHero.dead then return end
	--print(pred)
	Draw.Circle(pred,30,20,Draw.Color(189, 183, 107, 255))


end)

