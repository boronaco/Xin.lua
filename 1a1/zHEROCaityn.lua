class "KoreanCaitlyn"


function KoreanCaitlyn:__init()
    if myHero.charName ~= "Caitlyn" then return end
    self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Draw", function() self:Draw() end)

    self.predictionModified = {champion = "Ezreal", dodger = false}
    self.lastPath = 0
    self.counter = false
    self.ctimes = false
end

function KoreanCaitlyn:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "KoreanCaitlyn", name = "Korean Caitlyn"})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Korean Caitlyn - Combo Settings"})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger", name = "Hotkey Changer | Auto Q: Mouse", key = 0x5a, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger2", name = "Hotkey Changer | Disable Q+E In Combo", key = 0x58, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger3", name = "Hotkey Changer | Auto Trap", key = 0x56, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
	self.Menu:MenuElement({type = MENU, id = "Prediction", name = "Korean Caitlyn - xPrediction Settings"})
	self.Menu.Prediction:MenuElement({id = "Am", name = "Prediction Range", value = 80, min = 20, max = 200})
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Korean Caitlyn - Harass Settings"})
	self.Menu.Harass:MenuElement({id = "CS", name = "Comming Soon.", value = true})
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Korean Caitlyn - Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawTraps", name = "Trap Helper", value = false})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Q Range", value = false})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "W Range", value = false})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "E Range", value = false})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "R Range", value = false})
	
end

function KoreanCaitlyn:LoadSpells()
	Q = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	W = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_W).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = 0}
	E = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_E).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = 0}
	R = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_R).delay, Radius = myHero:GetSpellData(_R).radius, Speed = 0}
end

function KoreanCaitlyn:xPath(unit)
	local hero = unit
	local path = hero.pathing
	local path_vec
	

		if path.hasMovePath then
			for i = path.pathIndex, path.pathCount do
				path_vec = hero:GetPath(i)
				
			end
		end
		
		return path_vec
end

function KoreanCaitlyn:Prediction(unit)

	local target = unit
	local offset = 50
	local pathingVector = self:xPath(target)
	if pathingVector == nil then return end
	local distanceToTarget = myHero.pos:DistanceTo(target.pos)
	local predictionVector
	local dirt = myHero.pos:DistanceTo(unit.pos)
	if dirt > 700 then
		offset = 35
	elseif dirt < 500 and dirt > 201 then
		offset = 50
	end
	if self.predictionModified.dodger == false then
		predictionVector = target.pos:Extended(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 200) - offset)
		
		Draw.Circle(predictionVector)
		return predictionVector
	elseif self.predictionModified.dodger == true then
		predictionVector = target.pos:Shortened(pathingVector, (distanceToTarget / 3) + target.ms - (self.Menu.Prediction.Am:Value() + 450))
		Draw.Circle(predictionVector)
		
		return predictionVector
	end

end

function KoreanCaitlyn:BlueTrapDraw()
	if myHero.pos:DistanceTo(Vector(0)) < 1050 then -- Blue Bot Tier 3
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
	elseif myHero.pos:DistanceTo(Vector(0)) < 1050 then -- Blue Mid Tier 3
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
	elseif myHero.pos:DistanceTo(Vector(0)) < 1050 then -- Blue Mid Tier 2
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))	
	elseif myHero.pos:DistanceTo(Vector(0)) < 1050 then -- Blue Mid Tier 1
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
	end	
end

function KoreanCaitlyn:RedTrapDraw()
	if myHero.pos:DistanceTo(Vector(0)) < 1050 then -- Red Bot Tier 3
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))	
	elseif myHero.pos:DistanceTo(Vector(0)) < 1050 then -- Red Mid Tier 3
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
		Draw.Circle(Vector(0))
	end	
end

local startEQCombo = false
function KoreanCaitlyn:KTDeft(target, target2)
	
	if target.pos:DistanceTo(myHero.pos) < 630 and self:IsReady(_E) and self.Menu.Combo.ComboE:Value() and target:GetCollision(E.width,E.speed,E.delay) == 0 then
		local pree = self:Prediction(target)
		if target.activeSpell.windup > 0.1 then
			local possAfterAutoAttack = target.pos:Extended(self.lastPath, 20)
			

			self:fast(HK_E, _E, target, possAfterAutoAttack, 10, false, false)
			

			startEQCombo = true
		elseif pree ~= nil and target:GetCollision(100,E.speed,E.delay) == 0 then
			
			self:fast(HK_E, _E, target, pree, 10, false, false)
				
			startEQCombo = true
		elseif target:GetCollision(100,E.speed,E.delay) == 0 then
			self:fast(HK_E, _E, target, target.pos, 10, false, false)
		end
	end
	if self:IsReady(_Q) and self:IsReady(_E) ~= true and self.Menu.Combo.ComboQ:Value() then
		local offset = 50
		local pree = self:Prediction(target)
		if target.activeSpell.windup > 0.1 then
			local posAfterAutoAttack = target.pos:Extended(self.lastPath, 20)
				Draw.Circle(posAfterAutoAttack)
				
				self:fast(HK_Q, _Q, target, posAfterAutoAttack, 10, false, false)
				self:Orbwalker(true)
			
			
		elseif pree ~= nil then
			
			self:fast(HK_Q, _Q, target, self:Prediction(target), 10, false, false)
			self:Orbwalker(true)
			
		else 
			
			self:fast(HK_Q, _Q, target, target.pos, 10, false, false)
		end
		
	end

	if self:IsReady(_Q) ~= true and self:IsReady(_E) ~= true then
		startEQCombo = false
		self:Orbwalker(true)
		return
	end
end

function KoreanCaitlyn:Orbwalker(bool)
	if  _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	elseif _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	end
end

function KoreanCaitlyn:OrbTarget(range)
	if  _G.SDK and _G.SDK.Orbwalker then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	elseif _G.EOWLoaded then
		return EOW:GetTarget(range)
	end
end

local timer = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos, done = false}
function KoreanCaitlyn:fast(spell, spell2, unit, prediction, delay, keepmouse, trap)
	local keepmousee = keepmouse or false
	local trap = trap or false
	local target = prediction:To2D()
	local done = false

	local unit2 = unit
	local myHeroPos = myHero.pos
	local targetPos = unit2.pos
	local ticker = GetTickCount()
	
	if target.onScreen ~= true then
		PrintChat("OffScreen, please report if still fires: 0001")
		return
	end
	
	if timer.state == 0 and ticker - timer.tick > delay then
		timer.state = 1
		timer.mouse = mousePos
		timer.tick = ticker
		self.predi = prediction
	end

	if timer.state == 1 then
		
		if ticker - timer.tick > 0 and ticker - timer.tick <= 500 then
			
			if ticker - timer.tick > 0 and ticker - timer.tick < 10 + Game.Latency() and targetPos:ToScreen().onScreen then
				if self.predi:DistanceTo(unit.pos) > 1250 or target:DistanceTo(unit2.pos:To2D()) > 600 then
					return
				end
				self:Orbwalker(false)

				Control.SetCursorPos(target.x, target.y)
				--if mousePos:DistanceTo(targetPos) > myHeroPos:DistanceTo(targetPos) then
					--return
				--else
				if trap == true then
						self.ctimes = true
				end
					Control.CastSpell(spell)

				self:Orbwalker(true)
				done = true
					
				--end
				

			end
			
		end
		if ticker - timer.tick > 300 + Game.Latency() and keepmousee == false or done == true then
				--Control.SetCursorPos(timer.mouse)
				timer.state = 0
		elseif ticker - timer.tick > 300 + Game.Latency() and keepmousee == true then
				timer.state = 0	
		end
	end
end

local staticCoolTimer = GetTickCount()
function KoreanCaitlyn:TrapGod()
	local dCoolTimer = GetTickCount()
	if self.counter == false then
		staticCoolTimer = dCoolTimer
		self.counter = true
	end
	if self.counter == true and self.ctimes == false then
		local target = self:GetValidEnemy()
		if target == nil then return end
		local dist = target.pos:DistanceTo(myHero.pos)
		if dist < 775 and dist > 251 then
			if self:IsSnared(target) or self:xPath(target) == nil then
				self:fast(HK_W, _W, target, target.pos, 10, false, false)
			end
			local predic = target.pos:Extended(self:xPath(target), target.ms + 20)
			if predic:DistanceTo(myHero.pos) > 800 then return end		
			self:fast(HK_W, _W, target, predic, 100, false, true)
			self:Orbwalker(true)
		elseif dist < 250 then
			self:fast(HK_W, _W, target, myHero.pos, 100, false, true)
			self:Orbwalker(true)
		end
	end
		
	if dCoolTimer - staticCoolTimer > 4000 then
		self.counter = false
		self.ctimes = false
	end
end

function KoreanCaitlyn:GetValidEnemy()
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 1500 then
            return enemy
        end
    end
    return enemy
end

function KoreanCaitlyn:Buffs(unit, buffname)
	

	local textPos2 = unit.pos:To2D()
	textOffset = 50

	local activeBuffs = {}

	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(activeBuffs, Buff)
		end
	end
	for i, Buff in pairs(activeBuffs) do
		if Buff.name:lower() == buffname:lower() then
			return true
		end
	end
	return false
end

function KoreanCaitlyn:IsSnared(unit)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
			if buff and (buff.type == 11 or buff.type == 5) and buff.count > 0 then
				return true
			end
	end
	return false
end


function KoreanCaitlyn:Draw()
	local textPos = myHero.pos:To2D()
	if self.Menu.Combo.HotKeyChanger2:Value() then
			
			Draw.Text("", textPos.x, textPos.y + 40)
	end
	if self.Menu.Combo.HotKeyChanger:Value() then
		
		Draw.Text("", textPos.x, textPos.y + 30)
	end

	if self.Menu.Combo.HotKeyChanger3:Value() then
		Draw.Text("", textPos.x, textPos.y + 50)
	end

	if self.Menu.Draw.DrawTraps:Value() then
		self:BlueTrapDraw()
		self:RedTrapDraw()
	end

	if self.Menu.Draw.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(0))
	end
	if self.Menu.Draw.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(0))
	end
	if self.Menu.Draw.DrawE:Value() then
		Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(0))
	end
	if self.Menu.Draw.DrawR:Value() then
		Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(0))
	end


	local target = self:OrbTarget(1100)
	local target2 =  (_G.GOS and _G.GOS:GetTarget(1100,"AD"))

	if target2 == nil then return end
	if target == nil then return end

	if self:xPath(target) ~= nil then
		self.lastPath = self:xPath(target)
	end

	if GetTickCount() - timer.tick > 4000 then
			timer.state = 0
	end
	
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			if self.Menu.Combo.HotKeyChanger:Value() == false then
				self:KTDeft(target, target2)
			end
		end	
	elseif EOWLoaded then
		if EOW.CurrentMode == 1 then
			if self.Menu.Combo.HotKeyChanger:Value() == false then
				self:KTDeft(target, target2)
			end
		end
	end
	
	
	
	if self.Menu.Combo.HotKeyChanger:Value() then
		self:AutoQ()
	end

	if self:IsReady(_W) and self.Menu.Combo.HotKeyChanger3:Value() then
		self:TrapGod()
	end

	if self.Menu.Draw.DrawTraps:Value() then
		self:BlueTrapDraw()
		self:RedTrapDraw()
	end
end

function KoreanCaitlyn:AutoQ()
	if self:IsReady(_Q) ~= true or self.Menu.Combo.ComboQ:Value() ~= true then return end
	local target = self:GetValidEnemy()
	local pree = self:Prediction(target)
	local wtf = false
	if mousePos:DistanceTo(target.pos) < 100 then
		if pree ~= nil then
			wtf = true 
		end
		if target.activeSpell.windup > 0.1 then
			local posAfterAutoAttack = target.pos:Extended(self.lastPath, 50)
				Draw.Circle(posAfterAutoAttack)
				
				self:fast(HK_Q, _Q, target, posAfterAutoAttack, 10, true, false)
				
		elseif wtf == true then
		
			self:fast(HK_Q, _Q, target, pree, 10, true, false)
		end
		if wtf == false then
				Control.CastSpell(HK_Q, target.pos)
			
		end
	end
end




function KoreanCaitlyn:IsReady (spell)
	return Game.CanUseSpell(spell) == 0 
end

function OnLoad()
	KoreanCaitlyn()
end
