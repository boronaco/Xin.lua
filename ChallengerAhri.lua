class "ChallengerAhri"


function ChallengerAhri:__init()
	if myHero.charName ~= "Ahri" then return end
	self:LoadSpells()
    self:LoadMenu()
    Callback.Add("Draw", function() self:Draw() end)

    self.predictionModified = {champion = "Ezreal", dodger = false}
    self.lastPath = 0
    self.counter = false
    self.ctimes = false
    self.clickCounter = 0
end

function ChallengerAhri:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "ChallengerAhri", name = "Challenger Ahri", leftIcon = "http://i.imgur.com/B1yTPrK.png"})
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Challenger Ahri - Combo Settings"})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger", name = "Hotkey Changer | Auto Q To Cursor", key = 0x5a, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "HotKeyChanger2", name = "Hotkey Changer | Auto Combo To Cursor", key = 0x58, toggle = true, value = false})
	self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
	self.Menu:MenuElement({type = MENU, id = "Prediction", name = "Challenger Ahri - xPrediction Settings"})
	self.Menu.Prediction:MenuElement({id = "Am", name = "Prediction Range", value = 80, min = 40, max = 120})
	self.Menu:MenuElement({type = MENU, id = "Ignite", name = "Challenger Ahri - Utility Settings"})
	self.Menu.Ignite:MenuElement({id = "IG", name = "Use Ignite", value = true})
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Challenger Ahri - Draw Settings"})
	self.Menu.Draw:MenuElement({id = "DrawQ", name = "Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawW", name = "W Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawE", name = "E Range", value = true})
	self.Menu.Draw:MenuElement({id = "DrawR", name = "R Range", value = true})
	
end

function ChallengerAhri:LoadSpells()
	Q = {Range = myHero:GetSpellData(_Q).range, Delay = myHero:GetSpellData(_Q).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = myHero:GetSpellData(_Q).speed}
	W = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_W).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = 0}
	E = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_E).delay, Radius = myHero:GetSpellData(_Q).radius, Speed = 0}
	R = {Range = myHero:GetSpellData(_W).range, Delay = myHero:GetSpellData(_R).delay, Radius = myHero:GetSpellData(_R).radius, Speed = 0}
end

function ChallengerAhri:xPath(unit)
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

function ChallengerAhri:Prediction(unit)

	local target = unit
	local offset = 50
	local pathingVector = self:xPath(target)
	if pathingVector == nil then 
		return target.pos
	end
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
	end
		
		return predictionVector8

end

function ChallengerAhri:Burst(aphromoo, yoff)
	local target = _G.SDK.TargetSelector:GetTarget(870, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	if target == nil then return end
	if self:IsReady(_W) then
		Control.KeyDown(HK_W)
		if self:IsReady(_E) and target:GetCollision(100,E.speed,E.delay) == 0 then
			Control.SetCursorPos(aphromoo.x, aphromoo.y)
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
			Control.KeyUp(HK_W)
		end
	elseif self:IsReady(_E) and target:GetCollision(100,E.speed,E.delay) == 0 then
		Control.KeyDown(HK_E)
		Control.KeyUp(HK_E)
	end

	if self:IsReady(_Q) then 
		Control.SetCursorPos(aphromoo.x, aphromoo.y)
		Control.KeyDown(HK_Q)
		Control.KeyUp(HK_Q)
	end
end

function ChallengerAhri:ComboQ(aphromoo, yoff)
	if self:IsReady(_Q) then
		Control.SetCursorPos(aphromoo.x, yoff)
		Control.KeyDown(HK_Q)
		Control.KeyUp(HK_Q)
	end
end


local timer = {state = false, tick = GetTickCount(), mouse = mousePos, done = false, inQueue = false, delayer = GetTickCount()}
function ChallengerAhri:ClickTimer(spellPos, target, spell, comb, sum)
	local summ = sum or false
	local curTime = GetTickCount()
	local h2d = myHero.pos:To2D()
	local t2d = target.pos:To2D()
	local aphromoo = self:Prediction(target):To2D()

	if timer.state == false and timer.inQueue == false then
		self.clickCounter = self.clickCounter + 1
		timer.tick = GetTickCount()
		timer.inQueue = true
		timer.state = true
	end

	if curTime - timer.tick > 0 and timer.state == true and target.pos:ToScreen().onScreen then
		timer.mouse = cursorPos
		
		if summ == false and comb == "Burst" then
			_G.SDK.Orbwalker:SetMovement(false)
			_G.SDK.Orbwalker:SetAttack(false)
			Control.SetCursorPos(aphromoo.x, aphromoo.y)
			self:Burst(aphromoo, yoff)
			_G.SDK.Orbwalker:SetMovement(true)
			_G.SDK.Orbwalker:SetAttack(true)
		elseif summ == true then
			Control.SetCursorPos(t2d.x, t2d.y)
			Control.KeyDown(HK_SUMMONER_2)
			Control.KeyUp(HK_SUMMONER_2)
		end

		if comb == "ComboQ" then
			_G.SDK.Orbwalker:SetMovement(false)
			_G.SDK.Orbwalker:SetAttack(false)
			Control.SetCursorPos(aphromoo.x, aphromoo.y)
			self:ComboQ(aphromoo, yoff)
			_G.SDK.Orbwalker:SetMovement(true)
			_G.SDK.Orbwalker:SetAttack(true)
		end
		
		timer.done = true
	end
	if curTime - timer.tick > (250 + Game.Latency()) and timer.state == true and timer.inQueue == true and self:IsReady(_E) == false and self:IsReady(_Q) == false then
		local coco = timer.mouse
		Control.SetCursorPos(coco.x, coco.y)
		timer.state = false
		timer.done = false
		timer.inQueue = false
	end

end

function ChallengerAhri:IsReady (spell)
	return Game.CanUseSpell(spell) == 0 
end
function ChallengerAhri:Draw()
	local textPos = myHero.pos:To2D()
	if self.Menu.Combo.HotKeyChanger2:Value() then
			
			Draw.Text("Auto Combo To Cursor", textPos.x, textPos.y + 40)
	end
	if self.Menu.Combo.HotKeyChanger:Value() then
		
		Draw.Text("Auto Q To Cursor", textPos.x, textPos.y + 30)
	end

	if self.Menu.Draw.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 1, Draw.Color(255, 255, 255, 255))
	end
	if self.Menu.Draw.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 1, Draw.Color(255, 255, 255, 255))
	end
	if self.Menu.Draw.DrawE:Value() then
		Draw.Circle(myHero.pos, E.Range, 1, Draw.Color(255, 255, 255, 255))
	end
	if self.Menu.Draw.DrawR:Value() then
		Draw.Circle(myHero.pos, R.Range, 1, Draw.Color(255, 255, 255, 255))
	end



	Draw.Text(tostring(self.clickCounter), 200, 300)
	local target = _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	if target == nil then return end
	
	if _G.SDK then
		if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
			if self:IsReady(_Q) then
				self:ClickTimer(69, target, HK_Q, "Burst")
			end
		end	
	end
	if GetTickCount() - timer.tick > (2000 + Game.Latency()) then
		timer.state = false
		timer.done = false
		timer.inQueue = false
	end
	if self.Menu.Combo.HotKeyChanger2:Value() and mousePos:DistanceTo(target.pos) < 150 then
		local unit = self:GetValidEnemy()
		self:ClickTimer(69, unit, HK_Q, "Burst")
	end

	if self.Menu.Combo.HotKeyChanger:Value() and mousePos:DistanceTo(target.pos) < 150 and self:IsReady(_Q) then
		local unit = self:GetValidEnemy()
		self:ClickTimer(69, unit, HK_Q, "ComboQ")
	end
	
	--if target.health < 200 and self.Menu.Ignite.IG:Value() and self:IsReady(SUMMONER_2) and myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then -- :D ya~
		--self:ClickTimer(69, target, HK_SUMMONER_2, "Burst", true)
	--elseif target.health < 201 and self.Menu.Ignite.IG:Value() and self:IsReady(SUMMONER_1) and myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" then -- :_D
		--self:ClickTimer(69, target, HK_SUMMONER_1, "Burst", true)
	--end

	
end
function ChallengerAhri:GetValidEnemy()
    for i = 1,Game.HeroCount() do
        local enemy = Game.Hero(i)
        if  enemy.team ~= myHero.team and enemy.valid and enemy.pos:DistanceTo(myHero.pos) < 900 then
            return enemy
        end
    end
    return enemy
end

function OnLoad()
	ChallengerAhri()
end
