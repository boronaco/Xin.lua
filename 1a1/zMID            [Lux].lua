-- Copyright Smart under GNU licence.
-- Smart LoL GOS User
-- AKA : Call me Smart / SmartSharp
-- Contact skype: smart0095

if myHero.charName ~= "Lux" then return end

require "DamageLib"

-- Spells
local Q = {Delay = 0.250, Radius = 75, Range = 1160, Speed = 1750, Collision = true}
local E = {Delay = 0.250, Radius = 200, Range = 1250, Speed = 900, Collision = false}
local R = {Delay = 1, Radius = 120, Range = 3300, Speed = math.huge, Collision = false}

-- Menu local
local Menu = MenuElement({type = MENU, id = "SmartLux", name = "Smart Lux", leftIcon="https://puu.sh/urze2/9ecca9ea34.jpg"})

-- Keys Menu
Menu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
Menu.Key:MenuElement({id = "ComboKey", name = "Combo Key", key = 32})
Menu.Key:MenuElement({id = "HarassKey", name = "Harass Key", key = 67})
Menu.Key:MenuElement({id = "WaveClearKey", name = "Wave Clear Key", key = 86})
Menu.Key:MenuElement({id = "LastHitKey", name = "Last Hit Key", key = 88})
Menu.Key:MenuElement({id = "TrapKey", name = "Trap on Fow HK", key = 84})
Menu.Key:MenuElement({id = "StealKey", name = "Steal Drake / Nash Key (Low Range - Behind the Wall of the Boss)", key = 72})

-- Combo Menu
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "SmartQ", name = "Smart Q WIP", value = true})
Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
Menu.Combo:MenuElement({id = "SmartR", name = "Smart R - WIP", value = true})

-- Harass Menu
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 70, min = 0, max = 100})

-- Farm Menu
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
Menu.Farm:MenuElement({id = "FarmSpells", name = "Farm Spells", value = true})
Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 70, min = 0, max = 100})

-- LastHit Menu
Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit Settings - WORK IN PROGRESS"})
Menu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = false})
Menu.LastHit:MenuElement({id = "LastHitMana", name = "Min. Mana", value = 40, min = 0, max = 100})

Menu:MenuElement({type = MENU, id = "Shield", name = "Smart W Usage"})
Menu.Shield:MenuElement({id = "Auto", name = "Auto Shield", value = true})
Menu.Shield:MenuElement({id = "Mode", name = "Only in Combo", value = false})
Menu.Shield:MenuElement({id = "MinHealth", name = "Min Health -> %", value = 20,min = 0, max = 100})

-- Ultimate Misc Menu
Menu:MenuElement({type = MENU, id = "AutoEvent", name = "Auto Event Misc - WORK IN PROGRESS"})
Menu.AutoEvent:MenuElement({id = "AutoRks", name = "Lux will R to Kill Single enemy ON CC", value = true})
Menu.AutoEvent:MenuElement({id = "AutoQ", name = "Q on CC Enemy (OP in Teamfighting)", value = true})
Menu.AutoEvent:MenuElement({id = "KsR", name = "Lux Will R on ANY ENEMY LOW HP to KSecure Kappa", value = true})
Menu.AutoEvent:MenuElement({id = "AutoRtf", name = "Set R to hit as much enemies as you want:", value = 3, min = 1, max = 5, step = 1})

-- General Misc Menu
Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
Menu.Misc:MenuElement({id = "MaxRange", name = "Max Range Limiter", value = 0.9, min = 0.5, max = 1, step = 0.01})
Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "eg. X = 0.80 (Q.Range = (1150 * 0.80) = 920)"})
Menu.Misc:MenuElement({id = "Debug", name = "Debug Mode", value = false})

-- Drawings Menu
Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q", value = true})
Menu.Draw:MenuElement({id = "DrawE", name = "Draw E", value = true})
Menu.Draw:MenuElement({id = "DrawR", name = "Draw R", value = true})
Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})

--Call me Stupid for not Setting this Function before.
--[[
function STarget(targetRange)
	local result
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)
		if isValidTarget(hero, targetRange) and hero.team ~= myHero.team then
      		result = hero
      		break
		end
	end
	return result
end--]]

function SDistance(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

local _IsVisible = {}
function OnVision(unit)
	if _IsVisible[unit.networkID] == nil then _IsVisible[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _IsVisible[unit.networkID].state == true and not unit.visible then _IsVisible[unit.networkID].state = false _IsVisible[unit.networkID].tick = GetTickCount() end
	if _IsVisible[unit.networkID].state == false and unit.visible then _IsVisible[unit.networkID].state = true _IsVisible[unit.networkID].tick = GetTickCount() end
	return _IsVisible[unit.networkID]
end

function GetBuffs(unit)
	T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(T, Buff)
		end
	end
	return T
end

function ImRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function Priority(charName)
  local p1 = {"Alistar", "Amumu", "Blitzcrank", "Braum", "Cho'Gath", "Dr. Mundo", "Garen", "Gnar", "Maokai", "Hecarim", "Jarvan IV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "TahmKench", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Poppy"}
  local p2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gragas", "Irelia", "Jax", "Lee Sin", "Morgana", "Janna", "Nocturne", "Pantheon", "Rengar", "Rumble", "Swain", "Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai", "Bard", "Nami", "Sona", "Camille"}
  local p3 = {"Akali", "Diana", "Ekko", "FiddleSticks", "Fiora", "Gangplank", "Fizz", "Heimerdinger", "Jayce", "Kassadin", "Kayle", "Kha'Zix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo", "Zilean", "Zyra", "Ryze"}
  local p4 = {"Ahri", "Anivia", "Annie", "Ashe", "Azir", "Brand", "Caitlyn", "Cassiopeia", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "Karma", "Karthus", "Katarina", "Kennen", "KogMaw", "Kindred", "Leblanc", "Lucian", "Lux", "Malzahar", "MasterYi", "MissFortune", "Orianna", "Quinn", "Sivir", "Syndra", "Talon", "Teemo", "Tristana", "TwistedFate", "Twitch", "Varus", "Vayne", "Veigar", "Velkoz", "Viktor", "Xerath", "Zed", "Ziggs", "Jhin", "Soraka"}
  if table.contains(p1, charName) then return 1 end
  if table.contains(p2, charName) then return 1.25 end
  if table.contains(p3, charName) then return 1.75 end
  return table.contains(p4, charName) and 2.25 or 1
end

function STarget(range,t,pos)-- Ty Nod
local t = t or "AD"
local pos = pos or myHero.pos
local target = {}
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy and not hero.dead then
			OnVision(hero)
		end
		if hero.isEnemy and hero.valid and not hero.dead and (OnVision(hero).state == true or (OnVision(hero).state == false and GetTickCount() - OnVision(hero).tick < 650)) and hero.isTargetable then
			local heroPos = hero.pos
			if OnVision(hero).state == false then heroPos = hero.pos + Vector(hero.pos,hero.posTo):Normalized() * ((GetTickCount() - OnVision(hero).tick)/1000 * hero.ms) end
			if SDistance(pos,heroPos) <= range then
				if t == "AD" then
					target[(CalcPhysicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
				elseif t == "AP" then
					target[(CalcMagicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
				elseif t == "HYB" then
					target[((CalcMagicalDamage(myHero,hero,50) + CalcPhysicalDamage(myHero,hero,50))/ hero.health)*Priority(hero.charName)] = hero
				end
			end
		end
	end
	local bT = 0
	for d,v in pairs(target) do
		if d > bT then
			bT = d
		end
	end
	if bT ~= 0 then return target[bT] end
end

function IsImmobileTarget(unit) --Noddy CC Detector
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
            return true
        end
    end
    return false    
end

function IsSlowTarget(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.type == 10 and buff.count > 0 then
            return true
        end
    end
    return false    
end

function IsFearOrCharm(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and (buff.type == 21 or buff.type == 22) and buff.count > 0 then
            return true
        end
    end
    return false    
end


function GetFarmTarget(minionRange)
	local getFarmTarget
	for j = 1,Game.MinionCount()	do
		local minion = Game.Minion(j)
		if isValidTarget(minion, minionRange) and minion.team ~= myHero.team then
      		getFarmTarget = minion
      		break
		end
	end
	return getFarmTarget
end

-- Damage Calculations TEST Function
--[[
function GetRDmg(target)

	local spellLevel = myHero:GetSpellData(_R).level

	local rDamage = {300, 400, 500}
	local apDamage = myHero.ap * 0.70

	local finalDamage = rDamage[spellLevel] + apDamage
	--local finalDamage = (getdmg("R", target, myHero, 1) * luxR[target.networkID].stacks) * 0.8

end--]]

--DEBUG Function

-- FINISH DEBUG


-- CastSpell Mouse Sync TEST Function (Noddy)
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpell(spell,pos,range,delay)
local range = range or math.huge
local delay = delay or 250
local ticker = GetTickCount()

	if castSpell.state == 0 and pos:DistanceTo(myHero.pos) < range and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end


function autoshield()
	if Menu.Shield.Auto:Value() and isReady(_W) and myHero.health <= (myHero.maxHealth * Menu.Shield.MinHealth:Value() / 100) then
			Control.CastSpell(HK_W)
	end
end

-- Events
-- OnUpdate (30')
Callback.Add('Tick',function()

if not Menu.Shield.Mode:Value() then
	autoshield()
	end

	if Menu.Key.ComboKey:Value()  then--START COMBO SECTION
	--print(myHero:GetSpellData(_E).name)
	-- LuxLightstrikeToggle -- EXPLOSION
	-- LuxLightStrikeKugel -- Lanzamiento
	--local Evar = 0
	--local Qvar = 0
	
	if Menu.Shield.Mode:Value() then
	autoshield()
	end

	if myHero:GetSpellData(_E).name == "LuxLightStrikeKugel" then
   --throw here
   if isReady(_E) and Menu.Combo.ComboE:Value() then
   local eTarget = STarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget then
			local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				if Menu.Misc.Debug:Value() then
                PrintChat("Combo E Predict")
			end
		end
		end
else if isReady(_E) then --IF Q on Air + E Aviable or NO posible Q + E aviable Then CAST E EXPLOSION
local eTarget = STarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget and not isReady(_Q) and isReady(_E) or eTarget:GetCollision(E.Radius, E.Speed, E.Delay) > 1 and isReady(_E) then
			local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				if Menu.Misc.Debug:Value() then
				PrintChat("Auto Smart Explosion")
			end
		end
		end
  --explode here
end


		--SMART Q (IF SMART Q ENABLED)
		if isReady(_Q) and --[[not Evar and--]] Menu.Combo.SmartQ:Value() then
			local qTarget = STarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget --[[and (IsSlowTarget(qTarget) or IsImmobileTarget(qTarget) or IsFearOrCharm(qTarget))]] and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,qPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				if Menu.Misc.Debug:Value() then
                PrintChat("Smart Q After E Predict")
			end
		end
		end
		
	
		--DEFAULT Q	(IF SMART Q DISABLED)
		if not Menu.Combo.SmartQ:Value() then
		if isReady(_Q) and Menu.Combo.ComboQ:Value() then
			local qTarget = STarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,qPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				if Menu.Misc.Debug:Value() then
                PrintChat("Q DEFAULT")
		end
		end
		end
		end
		
		
		

--[[ OLD E SYSTEM
		
		-- THROW E (Actually there are no more E Casting methods) -- PROBLEM HERE
		if isReady(_E) and Menu.Combo.ComboE:Value() then --Throw E
			local eTarget = STarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget and Evar then -- Si la E no esta en el Aire entonces la Lanzamos
				local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				local Evar = false -- Como E esta en en Aire desactivamos mas Cast hasta la Q
				if Menu.Misc.Debug:Value() then
                PrintChat("Combo E THROW BEFORE Q")
			end
		end
		end
		
 -- Explodes E
        if isReady(_E) and not Evar and not isReady(_Q) and Menu.Combo.ComboE:Value() then -- Cuando la E este ya en el aire y la Q tambien entonces Explotamos
            local eTarget = STarget(E.Range * Menu.Misc.MaxRange:Value())
            if eTarget and IsSlowTarget(eTarget) and not isReady(_Q) then
                local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
                CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
          --local Evar = true -- Reiniciamos bucle de E
				--local Evar = 0
				if Menu.Misc.Debug:Value() then
                PrintChat("Combo E EXPLODED AFTER E-Q")
            end
        end
		end
      
      if not isReady(_E) then --Cuando E esta en CD entonces la habilitamos para volver a lanzar de nuevo.
        local Evar = true
        end
	--]]	

		--- DEFAULT R (IF SMART R DISABLED, BAD IDEA)
				 if isReady(_R) and not isReady(_Q) and not isReady(_E) and Menu.Combo.ComboR:Value() and not Menu.Combo.SmartR:Value()  then
			local rTarget = STarget(R.Range * Menu.Misc.MaxRange:Value())
			if rTarget then
				local rPos = rTarget:GetPrediction(R.Speed, R.Delay)
				Control.CastSpell(HK_R, rPos)
				if Menu.Misc.Debug:Value() then
				PrintChat("Debug: BAD R COMBO CAST")
				end
			--end
			end
		end
		--end
		
		
		
		
		-- SMART R (IF SMART R ENABLED) NO R IF ENEMY WONT DIE / NO R IF ISNT SAFE HIT ON CC (SINGLE TARGET ATM)
		 if isReady(_R) and Menu.Combo.SmartR:Value() and Menu.Combo.ComboR:Value() then
			local rTarget = STarget(R.Range * Menu.Misc.MaxRange:Value())
			if rTarget and IsImmobileTarget(rTarget) then
			if Menu.Misc.Debug:Value() then
			PrintChat("Target Not Killeable with Smart R")
			end
			--PrintChat("Target Not Killeable with Smart R")
				local rPos = rTarget:GetPrediction(R.Speed, R.Delay)
local hp = rTarget.health + rTarget.shieldAP
local dmg = CalcMagicalDamage(myHero,rTarget,200 + 100*myHero:GetSpellData(_R).level + (0.75*myHero.ap))
local dmg2 = dmg * 1.40
--PrintChat(dmg)
if Menu.Misc.Debug:Value() then
PrintChat(dmg2)
end
						if hp < dmg2 then
						if Menu.Misc.Debug:Value() then
						PrintChat("Debug:Combo Smart R CAST")
						end
				CastSpell(HK_R, rPos --[[rTarget]], R.Range, R.Delay*1000)--Si el enemigo se mueve falla la R en Root. Set no Pred
			--PrintChat("Debug:Combo Smart R CAST") --Test
			--end
			--end
			end
		end
		end
		
		


		
	end--FINISH COMBO KEY
	
			--TRAP KEY
		
		
		if Menu.Key.TrapKey:Value()  then
			local qTarget = STarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q, qPos, Q.Range)
		  CastSpell(HK_E, qPos, Q.Range)
		  if not isReady(_Q) and IsImmobileTarget(qTarget) then
		  CastSpell(HK_R, qPos, Q.Range)
				--Control.CastSpell(HK_Q, qPos)
			if Menu.Misc.Debug:Value() then
				PrintChat("DEBUG : Trap Casted")
		end
		end
		end
		

		end--END TRAP KEY

	--Begins Steal Key 1
	
	if Menu.Key.StealKey:Value()  then
		if isReady(_Q) and Menu.Key.StealKey:Value() then
			local qTarget = STarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,qPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				if Menu.Misc.Debug:Value() then
				PrintChat("Steal Q Casted")
				end
		end
		end
		
		if isReady(_E) and Menu.Key.StealKey:Value() then
			local eTarget = STarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget then
				local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				--PrintChat("Combo E Casted")
			end
		end

	
end--End of Steal System


	
	if Menu.Key.HarassKey:Value() and (myHero.mana/myHero.maxMana >= Menu.Harass.HarassMana:Value()/100) then
		if isReady(_Q) and Menu.Harass.HarassQ:Value() then
			local qTarget = STarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
				Control.CastSpell(HK_Q, qPos)
			end
		end
		if isReady(_E) and Menu.Harass.HarassE:Value() then
			local eTarget = STarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget then
				local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				Control.CastSpell(HK_E, ePos)
			end
		end
	end

	if Menu.Key.WaveClearKey:Value() and Menu.Farm.FarmSpells:Value() and (myHero.mana/myHero.maxMana >= Menu.Farm.FarmMana:Value()/100) then
		if isReady(_E) and Menu.Farm.FarmE:Value() then
			local eMinion = GetFarmTarget(E.Range * Menu.Misc.MaxRange:Value())
			if eMinion then
				local eMinPos = eMinion:GetPrediction(E.Speed, E.Delay)
				Control.CastSpell(HK_E, eMinPos)
			end
		end
	end
	
	
--Start AUTO System
--AUTO Q
if isReady(_Q) and Menu.AutoEvent.AutoQ:Value()  then
			local aqTarget = STarget(Q.Range * Menu.Misc.MaxRange:Value())
			if aqTarget and (IsSlowTarget(aqTarget) or IsImmobileTarget(aqTarget) or IsFearOrCharm(aqTarget)) and aqTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local aqPos = aqTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,aqPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				if Menu.Misc.Debug:Value() then
                PrintChat("AUTO Smart Q")
			end
		end
		end
		
		
		--AUTO R on CC
		if isReady(_R) and Menu.AutoEvent.AutoRks:Value() then
			local arTarget = STarget(R.Range * Menu.Misc.MaxRange:Value())
			if arTarget and (IsImmobileTarget(arTarget) or IsFearOrCharm(arTarget)) then
			if Menu.Misc.Debug:Value() then
			PrintChat("Posible R on Immobile Enemy (But wont die so Aborted)")
			end
				local arPos = arTarget:GetPrediction(R.Speed, R.Delay)
local hp = arTarget.health + arTarget.shieldAP
local dmg = CalcMagicalDamage(myHero,arTarget,200 + 100*myHero:GetSpellData(_R).level + (0.75*myHero.ap))
local dmg2 = dmg * 1.3
if Menu.Misc.Debug:Value() then
PrintChat(dmg)
end
--print(dmg)
						if hp < dmg2 then
						if Menu.Misc.Debug:Value() then
						PrintChat("Debug: Auto R on Killeable Immobile Enemy")
						end
				CastSpell(HK_R, arPos, R.Range, R.Delay*1000)--Si el enemigo se mueve falla la R en Root. Set no Pred
				if Menu.Misc.Debug:Value() then
--PrintChat("Debug: Auto R")
end
			--end
			end
			--end
		end
		end
		
		-- AUTO R AS KS
				if isReady(_R) and Menu.AutoEvent.KsR:Value() then
			local arTarget = STarget(R.Range * Menu.Misc.MaxRange:Value())
			if arTarget then
			if Menu.Misc.Debug:Value() then
			PrintChat("Posible R on Immobile Enemy (But wont die so Aborted)")
			end
				local arPos = arTarget:GetPrediction(R.Speed, R.Delay)
local hp = arTarget.health + arTarget.shieldAP
local dmg = CalcMagicalDamage(myHero,arTarget,200 + 100*myHero:GetSpellData(_R).level + (0.75*myHero.ap))
local dmg2 = dmg * 1.3
if Menu.Misc.Debug:Value() then
PrintChat(dmg)
end
--print(dmg)
						if hp < dmg2 then
						if Menu.Misc.Debug:Value() then
						PrintChat("Debug: Auto R on Killeable Immobile Enemy")
						end
				CastSpell(HK_R, arPos, R.Range, R.Delay*1000)--Si el enemigo se mueve falla la R en Root. Set no Pred
				if Menu.Misc.Debug:Value() then
--PrintChat("Debug: Auto R")
end
			--end
			end
			--end
		end
		end
		
		
-- END AUTO SYSTEM
end)--END OnUptade TICK




-- OnLoad
Callback.Add('Load',function()
	PrintChat("Smart Lux - Loaded")
end)

-- OnDraw ADJUSTABLE by Scale MISC to prevent MAX RANGE PROBLEMS and Complains :D
function OnDraw()
	if myHero.dead then return end

	if Menu.Draw.DrawQ:Value()	then
		Draw.Circle(myHero.pos,Q.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end
	if Menu.Draw.DrawE:Value()	then
		Draw.Circle(myHero.pos,E.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end
	if Menu.Draw.DrawR:Value()	then
		Draw.Circle(myHero.pos,R.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end

    if Menu.Draw.DrawTarget:Value() then
	    local drawTarget = STarget(Q.Range)
	    if drawTarget then
		    Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
	    end
    end
end


-- isReady - Returns bool
function isReady(slot)
	return (myHero:GetSpellData(slot).currentCd == 0) and (myHero:GetSpellData(spellSlot).mana < myHero.mana) and (myHero:GetSpellData(slot).level >= 1) -- Thanks MeoBeo
end

-- isValidTarget - Returns bool
function isValidTarget(obj, spellRange)
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

--[[ TO DO :

Auto R to kill (Ks)
Auto R en X enemies Slider
Fix R en Combo (inmobile target no pred)

E QR Dragon / Nash Stealer (Ya vere)
Ally Shielding

Wave Clear E en X minions Slider

Q para LastHit que no alcanze el AA por distancia o windup

+ Algunos misc como:

No autoatak apartir de X Nivel
Solo autoatak si no hay spells disponibles o esta cerca o lux tiene el buff de AA
Stack Tear con Shield constante si hay mas de 90% Mana

]]--

-- CREDITS : Smart
-- Thanks to Noddy for helping
-- Contact Skype: smart0095