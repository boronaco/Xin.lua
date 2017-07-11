local myHeroes = { Morgana = true, Janna = true, Nami = true, Soraka = true, Karma = true }

if myHero.charName == "Ashe" or myHero.charName == "Ezreal" or myHero.charName == "Lucian" or myHero.charName == "Caitlyn" or myHero.charName == "Twitch" or myHero.charName == "KogMaw" or myHero.charName == "Kalista" or myHero.charName == "Corki" then
	require "2DGeometry"
	
	
	keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
	
	castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
	function SetMovement(bool)
		if _G.EOWLoaded then
			EOW:SetMovements(bool)
			EOW:SetAttacks(bool)
		elseif _G.SDK then
			_G.SDK.Orbwalker:SetMovement(bool)
			_G.SDK.Orbwalker:SetAttack(bool)
		else
			GOS.BlockMovement = not bool
			GOS.BlockAttack = not bool
		end
		if bool then
			castSpell.state = 0
		end
	end
	
	function CurrentModes()
		local combomodeactive, harassactive, canmove, canattack, currenttarget
		if _G.SDK then -- ic orbwalker
			combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
			harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
			canmove = _G.SDK.Orbwalker:CanMove()
			canattack = _G.SDK.Orbwalker:CanAttack()
			currenttarget = _G.SDK.TargetSelector.SelectedTarget or _G.SDK.Orbwalker:GetTarget()
		elseif _G.EOW then -- eternal orbwalker
			combomodeactive = _G.EOW:Mode() == 1
			harassactive = _G.EOW:Mode() == 2
			canmove = _G.EOW:CanMove() 
			canattack = _G.EOW:CanAttack()
			currenttarget = _G.EOW:GetTarget()
		else -- default orbwalker
			combomodeactive = _G.GOS:GetMode() == "Combo"
			harassactive = _G.GOS:GetMode() == "Harass"
			canmove = _G.GOS:CanMove()
			canattack = _G.GOS:CanAttack()
			currenttarget = _G.GOS:GetTarget()
		end
		return combomodeactive, harassactive, canmove, canattack, currenttarget
	end
	
	function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	end
	
	function UseBotrk()
		local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(300, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(300,"AD"))
		if target then 
			local botrkitem = GetInventorySlotItem(3153) or GetInventorySlotItem(3144)
			if botrkitem then
				Control.CastSpell(keybindings[botrkitem],target.pos)
			end
		end
	end
end


if not myHeroes[myHero.charName] then return end

require "DamageLib"

class "_AutoInterrupter"
function _AutoInterrupter:__init()
	self.Spells = {
		["Fiddlesticks"] = {{Key = _W, Duration = 5, KeyName = "W" },{Key = _R,Duration = 1,KeyName = "R"  }},
		["VelKoz"] = {{Key = _R, Duration = 1, KeyName = "R", Buff = "VelkozR" }},
		["Warwick"] = {{Key = _R, Duration = 1,KeyName = "R" , Buff = "warwickrsound"}},
		["MasterYi"] = {{Key = _W, Duration = 4,KeyName = "W", Buff = "Meditate" }},
		["Lux"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Janna"] = {{Key = _R, Duration = 3,KeyName = "R",Buff = "ReapTheWhirlwind" }},
		["Jhin"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Xerath"] = {{Key = _R, Duration = 3,KeyName = "R", SpellName = "XerathRMissileWrapper" }},
		["Karthus"] = {{Key = _R, Duration = 3,KeyName = "R", Buff = "karthusfallenonecastsound" }},
		["Ezreal"] = {{Key = _R, Duration = 1,KeyName = "R" }},
		["Galio"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "GalioIdolOfDurand" }},
		["Caitlyn"] = {{Key = _R, Duration = 2,KeyName = "R" , Buff = "CaitlynAceintheHole"}},
		["Malzahar"] = {{Key = _R, Duration = 2,KeyName = "R" }},
		["MissFortune"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "missfortunebulletsound" }},
		["Nunu"] = {{Key = _R, Duration = 2,KeyName = "R", Buff = "AbsoluteZero"  }},
		["TwistedFate"] = {{Key = _R, Duration = 2,KeyName = "R",Buff = "Destiny" }},
		["Shen"] = {{Key = _R, Duration = 2,KeyName = "R",Buff = "shenstandunitedlock" }},
	}
end

function _AutoInterrupter:IsChannelling(unit)
	if not self.Spells[unit.charName] then return false end
	local result = false
	for _, spell in pairs(self.Spells[unit.charName]) do
		if unit:GetSpellData(spell.Key).level > 0 and (unit:GetSpellData(spell.Key).name == spell.SpellName or unit:GetSpellData(spell.Key).currentCd > unit:GetSpellData(spell.Key).cd - spell.Duration or (spell.Buff and self:GotBuff(unit,spell.Buff) > 0)) then
				result = true
				break
			
		end
	end
	return result
end

function _AutoInterrupter:GotBuff(unit,name)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name and buff.name:lower() == name:lower() and buff.count > 0 then 
			return buff.count
		end
	end
	return 0
end

AutoInterrupter = AutoInterrupter or _AutoInterrupter()



local MissileSpells = {
["Sion"] = {"SionEMissile"},
["Velkoz"] = {"VelkozQMissile","VelkozQMissileSplit","VelkozWMissile","VelkozEMissile"},
["Ahri"] = {"AhriOrbMissile","AhriOrbReturn","AhriSeduceMissile"},
["Irelia"] = {"IreliaTranscendentBlades"},
["Sona"] = {"SonaR"},
["Illaoi"] = {"illaoiemis","illaoiemis",""},
["Jhin"] = {"JhinWMissile","JhinRShotMis"},
["Rengar"] = {"RengarEFinal"},
["Zyra"] = {"ZyraQ","ZyraE","zyrapassivedeathmanager"},
["TwistedFate"] = {"SealFateMissile"},
["Shen"] = {"ShenE"},
["Kennen"] = {"KennenShurikenHurlMissile1"},
["Nami"] = {"namiqmissile","NamiRMissile"},
["Xerath"] = {"xeratharcanopulse2","XerathArcaneBarrage2","XerathMageSpearMissile","xerathrmissilewrapper"},
["Nocturne"] = {"NocturneDuskbringer"},
["AurelionSol"] = {"AurelionSolQMissile","AurelionSolRBeamMissile"},
["Lucian"] = {"LucianQ","LucianWMissile","lucianrmissileoffhand"},
["Ivern"] = {"IvernQ"},
["Tristana"] = {"RocketJump"},
["Viktor"] = {"ViktorDeathRayMissile"},
["Malzahar"] = {"MalzaharQ"},
["Braum"] = {"BraumQMissile","braumrmissile"},
["Tryndamere"] = {"slashCast"},
["Malphite"] = {"UFSlash"},
["Amumu"] = {"SadMummyBandageToss",""},
["Janna"] = {"HowlingGaleSpell"},
["Morgana"] = {"DarkBindingMissile"},
["Ezreal"] = {"EzrealMysticShotMissile","EzrealEssenceFluxMissile","EzrealTrueshotBarrage"},
["Kalista"] = {"kalistamysticshotmis"},
["Blitzcrank"] = {"RocketGrabMissile",},
["Chogath"] = {"Rupture"},
["TahmKench"] = {"tahmkenchqmissile"},
["LeeSin"] = {"BlindMonkQOne"},
["Zilean"] = {"ZileanQMissile"},
["Darius"] = {"DariusCleave","DariusAxeGrabCone"},
["Ziggs"] = {"ZiggsQSpell","ZiggsQSpell2","ZiggsQSpell3","ZiggsW","ZiggsE","ZiggsR"},
["Zed"] = {"ZedQMissile"},
["Leblanc"] = {"LeblancSlide","LeblancSlideM","LeblancSoulShackle","LeblancSoulShackleM"},
["Zac"] = {"ZacQ"},
["Quinn"] = {"QuinnQ"},
["Urgot"] = {"UrgotHeatseekingLineMissile","UrgotPlasmaGrenadeBoom"},
["Cassiopeia"] = {"CassiopeiaQ","CassiopeiaR"},
["Sejuani"] = {"sejuaniglacialprison"},
["Vi"] = {"ViQMissile"},
["Leona"] = {"LeonaZenithBladeMissile","LeonaSolarFlare"},
["Veigar"] = {"VeigarBalefulStrikeMis"},
["Varus"] = {"VarusQMissile","VarusE","VarusRMissile"},
["Aatrox"] = {"","AatroxEConeMissile"},
["Twitch"] = {"TwitchVenomCaskMissile"},
["Thresh"] = {"ThreshQMissile","ThreshEMissile1"},
["Diana"] = {"DianaArcThrow"},
["Draven"] = {"DravenDoubleShotMissile","DravenR"},
["Talon"] = {"talonrakemissileone","talonrakemissiletwo"},
["JarvanIV"] = {"JarvanIVDemacianStandard"},
["Gragas"] = {"GragasQMissile","GragasE","GragasRBoom"},
["Lissandra"] = {"LissandraQMissile","lissandraqshards","LissandraEMissile"},
["Swain"] = {"SwainShadowGrasp"},
["Lux"] = {"LuxLightBindingMis","LuxLightStrikeKugel","LuxMaliceCannon"},
["Gnar"] = {"gnarqmissile","GnarQMissileReturn","GnarBigQMissile","GnarBigW","GnarE","GnarBigE",""},
["Bard"] = {"BardQMissile","BardR"},
["Riven"] = {"RivenLightsaberMissile"},
["Anivia"] = {"FlashFrostSpell"},
["Karma"] = {"KarmaQMissile","KarmaQMissileMantra"},
["Jayce"] = {"JayceShockBlastMis","JayceShockBlastWallMis"},
["RekSai"] = {"RekSaiQBurrowedMis"},
["Evelynn"] = {"EvelynnR"},
["Sivir"] = {"SivirQMissileReturn","SivirQMissile"},
["Shyvana"] = {"ShyvanaFireballMissile","ShyvanaTransformCast","ShyvanaFireballDragonFxMissile"},
["Yasuo"] = {"yasuoq2","yasuoq3w","yasuoq"},
["Corki"] = {"PhosphorusBombMissile","MissileBarrageMissile","MissileBarrageMissile2"},
["Ryze"] = {"RyzeQ"},
["Rumble"] = {"RumbleGrenade","RumbleCarpetBombMissile"},
["Syndra"] = {"SyndraQ","syndrawcast","syndrae5","SyndraE"},
["Khazix"] = {"KhazixWMissile","KhazixE"},
["Taric"] = {"TaricE"},
["Elise"] = {"EliseHumanE"},
["Nidalee"] = {"JavelinToss"},
["Olaf"] = {"olafaxethrow"},
["Nautilus"] = {"NautilusAnchorDragMissile"},
["Kled"] = {"KledQMissile","KledRiderQMissile"},
["Brand"] = {"BrandQMissile"},
["Ekko"] = {"ekkoqmis","EkkoW","EkkoR"},
["Fiora"] = {"FioraWMissile"},
["Graves"] = {"GravesQLineMis","GravesChargeShotShot"},
["Galio"] = {"GalioResoluteSmite","GalioRighteousGust",""},
["Ashe"] = {"VolleyAttack","EnchantedCrystalArrow"},
["Kogmaw"] = {"KogMawQ","KogMawVoidOozeMissile","KogMawLivingArtillery"},
["Skarner"] = {"SkarnerFractureMissile"},
["Taliyah"] = {"TaliyahQMis","TaliyahW"},
["Heimerdinger"] = {"HeimerdingerWAttack2","heimerdingerespell"},
["Lulu"] = {"LuluQMissile","LuluQMissileTwo"},
["DrMundo"] = {"InfectedCleaverMissile"},
["Poppy"] = {"PoppyQ","PoppyRMissile"},
["Caitlyn"] = {"CaitlynPiltoverPeacemaker","CaitlynEntrapmentMissile"},
["Jinx"] = {"JinxWMissile","JinxR"},
["Fizz"] = {"FizzRMissile"},
["Kassadin"] = {"RiftWalk"},
}

function GetDistanceSqr(p1, p2)
    assert(p1, "GetDistance: invalid argument: cannot calculate distance to "..type(p1))
    p2 = p2 or myHero.pos
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function GetDistance(p1, p2)
    return math.sqrt(GetDistanceSqr(p1, p2))
end


function isReady(slot)
	return Game.CanUseSpell(slot) == READY
end

function isValidTarget(obj,range)
	range = range or math.huge
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= range
end

function IsImmobileTarget(unit)
	assert(unit, "IsImmobileTarget: invalid argument: unit expected got "..type(unit))
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 ) and buff.count > 0 then
			return true
		end
	end
	return false	
end

function CountEnemies(pos,range)
	local N = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if isValidTarget(hero,range) and hero.team ~= myHero.team then
			N = N + 1
		end
	end
	return N	
end

function GetTarget(range)
	local result = nil
	local N = math.huge
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if isValidTarget(hero,range) and hero.isEnemy then
			local dmgtohero = getdmg("AA",hero,myHero) or 1
			local tokill = hero.health/dmgtohero
			if tokill < N or result == nil then
				N = tokill
				result = hero
			end
		end
	end
	return result
end

function VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

local function EnableOrb()
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetAttack(true)
		_G.SDK.Orbwalker:SetMovement(true)
	end
	if _G.GOS then
		_G.GOS.BlockMovement = false
		_G.GOS.BlockAttack  = false
	end
end

local function DisableOrb()
	if _G.SDK and _G.SDK.Orbwalker then
		_G.SDK.Orbwalker:SetAttack(false)
		_G.SDK.Orbwalker:SetMovement(false)
	end
	if _G.GOS then
		_G.GOS.BlockMovement = true
		_G.GOS.BlockAttack  = true
	end
end

local spellcast = {state = 1, mouse = mousePos}

function CastSpell(hk,pos,delay)
	if spellcast.state == 2 then return end
	if ExtLibEvade and ExtLibEvade.Evading then return end
	
	spellcast.state = 2
	DisableOrb()
	spellcast.mouse = mousePos
	DelayAction(function() Control.SetCursorPos(pos) end, 0.01) 
	if true then
		DelayAction(function() 
			--print("keydown")
			Control.KeyDown(hk)
			Control.KeyUp(hk)
		end, 0.012)
		DelayAction(function()
			Control.SetCursorPos(spellcast.mouse)
		end,0.15)
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.1)
	else
		
		DelayAction(function()
			EnableOrb()
			spellcast.state = 1
		end,0.01)
	end
end

local Q,W,E,R

class "Morgana"

function Morgana:__init()
	Q = {ready = false, range = 1175, radius = 65, speed = 1200, delay = 0.25, type = "line",col = {"minion","champion"}}
	W = {ready = false, range = 900,radius = 225, speed = 2200, delay = 0.5, type = "circular" }
	E = {ready = false, range = 750 }
	R = {ready = false,range = 600}
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly then
			table.insert(self.Allies,hero)
		else
			table.insert(self.Enemies,hero)
		end	
	end	
	self.lastTick = 0
	self.SelectedTarget = nil 
	self:LoadData()
	self:LoadMenu()
	Callback.Add("Tick",function() self:Tick() end)
	Callback.Add("Tick",function() self:ProcessMissile() end)
	Callback.Add("Draw",function() self:Draw() end)
	Callback.Add("WndMsg",function(Msg, Key) self:WndMsg(Msg, Key) end)
end

function Morgana:LoadMenu()
	self.Menu = MenuElement( {id =  "SB"..myHero.charName, name = "Morgana", type = MENU})
	self.Menu:MenuElement({id = "Key", name = "> Key Settings", type = MENU})
	self.Menu.Key:MenuElement({id = "Combo",name = "Combo", key = 32})
	self.Menu.Key:MenuElement({id = "Harass",name = "Harass", key = string.byte("C")})

	
	self.Menu:MenuElement({type = MENU, id = "Qset", name = "> Q Settings"})
	self.Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	self.Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = false})
	self.Menu.Qset:MenuElement({id = "Immobile",name = "Auto on Immobile",value = true})

	self.Menu:MenuElement({type = MENU, id = "Wset", name = "> W Settings"})
	self.Menu.Wset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Wset:MenuElement({ id = "Harass", name = "Use in Harass",value = false})
	self.Menu.Wset:MenuElement({ id = "Immobile",name = "Auto on Immobile",value = true})
	
	self.Menu:MenuElement({id = "Eset", name = "> E Settings", type = MENU})
	self.Menu.Eset:MenuElement({id = "Spell", name = "Use Against Spells",value = true})
	
	
	self.Menu:MenuElement({id = "Rset", name = "> R Settings",type = MENU})
	self.Menu.Rset:MenuElement({id = "AutoR",name ="AutoR", value = false})
	self.Menu.Rset:MenuElement({id = "Min", name = "x Enemies Around", value =  4, min = 1, max = 5, step =1})
	
	self.Menu:MenuElement({type = MENU, id = "Draw",name = "> Draw Settings"})
	self.Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = false})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = false})
	self.Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = false})
	self.Menu.Draw:MenuElement({id = "Root",name = "Draw Root Time", value = false})
	
	PrintChat("")

end

function Morgana:LoadData()
	self.MissileSpells = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy then
			if MissileSpells[hero.charName] then
				for k,v in pairs(MissileSpells[hero.charName]) do
					if #v > 1 then
						self.MissileSpells[v] = true
					else
						--print(hero.charName)
					end	
				end
			end
		end
	end
end


function Morgana:GetTarget(range)
	if self.SelectedTarget and isValidTarget(self.SelectedTarget,range) then
		return self.SelectedTarget
	end	
	return GetTarget(range)
end

function Morgana:ProcessMissile()
	if (not isReady(_E) or not self.Menu.Eset.Spell:Value())then return end
	local enemy = true
	local allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if isValidTarget(hero,2500) and hero.isAlly then
			table.insert(allies,hero)
		elseif isValidTarget(hero,2500) and hero.isEnemy then
			enemy = false
		end
	end
	if enemy then return end	
	for i = 1, Game.MissileCount() do
		local obj = Game.Missile(i)
		if obj and obj.isEnemy and obj.missileData and self.MissileSpells[obj.missileData.name] then
			local speed = obj.missileData.speed
			local width = obj.missileData.width
			local endPos = obj.missileData.endPos
			local pos = obj.pos
			if speed and width and endPos and pos then
				for k, hero in pairs(allies) do 
					if isValidTarget(hero,E.range) then
						local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(pos,endPos,hero.pos)
						if isOnSegment and hero.pos:DistanceTo(Vector(pointSegment.x,myHero.pos.y,pointSegment.y)) < width+ hero.boundingRadius then
							CastSpell(HK_E,hero.pos)
						end
					end
				end
			elseif pos then
				for k,hero in pairs(allies)	 do
					if isValidTarget(hero,E.range) and pos:DistanceTo(hero.pos) < 80 then
						CastSpell(HK_E,hero.pos)
					end
				end
			end
		end
	end	
end

function Morgana:Tick()
	
	if self.SelectedTarget and self.SelectedTarget.dead then 
		self.SelectedTarget = nil
	end
	--self:
	
	self:AutoCC()
	
	if self.Menu.Key.Combo:Value() then
		self:Combo()
	end
	if self.Menu.Key.Harass:Value() then
		self:Harass()
	end
	if Game.CanUseSpell(_R) == READY then
		self:AutoR()
	end
	
end

function Morgana:CastQ(unit,pos)
	if unit:GetCollision(Q.radius,Q.speed,Q.delay) == 0  then
		pos = pos or unit:GetPrediction(Q.speed,Q.delay)
		if pos then
			CastSpell(HK_Q,pos)
		end
	end
end

function Morgana:CastW(unit)
	local pos = unit:GetPrediction(W.speed,W.delay)
	if pos then
		CastSpell(HK_W,pos)
	end
end

function Morgana:Combo()
	local qtarget = self:GetTarget(Q.range)
	local wtarget = self:GetTarget(W.range)
	
	if qtarget and isReady(_Q) and self.Menu.Qset.Combo:Value() then
		self:CastQ(qtarget)
	end
	if wtarget and isReady(_W) and self.Menu.Wset.Combo:Value() and (not isReady(_Q) or myHero.mana > 200 ) then
		self:CastW(wtarget)
	end
end

function Morgana:Harass()
	local qtarget = self:GetTarget(Q.range)
	local wtarget = self:GetTarget(W.range)
	
	if qtarget and isReady(_Q) and self.Menu.Qset.Harass:Value() then
		self:CastQ(qtarget)
	end
	if wtarget and Game.CanUseSpell(_W) == READY and self.Menu.Wset.Harass:Value() and (not isReady(_Q) or myHero.mana > 200 ) then
		self:CastW(wtarget)
	end
end

function Morgana:AutoR()
	if self.Menu.Rset.AutoR:Value() then
		if CountEnemies(myHero.pos,R.range - 50) >= self.Menu.Rset.Min:Value() then
			Control.CastSpell(HK_R)
		end
	end
end

function Morgana:AutoCC()
	for i = 1, Game.HeroCount() do
		local enemy  = Game.Hero(i)
 
		if enemy.isEnemy and isReady(_Q) and isValidTarget(enemy,Q.range) and IsImmobileTarget(enemy) and self.Menu.Qset.Immobile:Value() then
			self:CastQ(enemy,enemy.pos)
			return
		end
		if enemy.isEnemy and isReady(_W) and isValidTarget(enemy,W.range) and IsImmobileTarget(enemy) and self.Menu.Wset.Immobile:Value() then
			CastSpell(HK_W,enemy.pos)
			return
		end
	end
end

function Morgana:Draw()
	if myHero.dead then return end

	if self.Menu.Draw.Q:Value() then
		local qcolor = isReady(_Q) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.range,1,qcolor)
	end
	if self.Menu.Draw.W:Value() then
		local wcolor = isReady(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.range,1,wcolor)
	end
	if self.Menu.Draw.E:Value() then
		local ecolor = isReady(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.range,1,ecolor)
	end
	if self.Menu.Draw.Root:Value() then
	
	end
end

function Morgana:WndMsg(msg,key)
	if msg == 513 then
		local starget = nil
		for i  = 1,Game.HeroCount(i) do
			local enemy = Game.Hero(i)
			if isValidTarget(enemy) and enemy.isEnemy and enemy.pos:DistanceTo(mousePos) < 200 then
				starget = enemy
				break
			end
		end
		if starget then
			self.SelectedTarget = starget
			print("")
		else
			self.SelectedTarget = nil
		end
	end	
end


--[[Janna]]


class "Janna"

function Janna:__init()
	Q = {ready = false, range = 850,maxrange = 1700, radius = 120 , speed = 900, delay = 0.25, type = "line"}
	W = {ready = false, range = 600,radius = 225, speed = 2200, delay = 0.5, type = "circular" }
	E = {ready = false, range = 800 }
	R = {ready = false,range = 725}
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly then
			self.Allies[hero.handle] = hero
		else
			self.Enemies[hero.handle] = hero
		end	
	end	
	self.lastTick = 0
	self.LastSpellT = 0
	self.SelectedTarget = nil
	self:LoadData()
	self:LoadMenu()
	Callback.Add("Tick",function() self:Tick() end)
	Callback.Add("Tick",function() self:ProcessMissile() end)
	Callback.Add("Draw",function() self:Draw() end)
	Callback.Add("WndMsg",function(Msg, Key) self:WndMsg(Msg, Key) end)
end

function Janna:LoadMenu()
	self.Menu = MenuElement( {id =  "SB"..myHero.charName, name = "Janna", type = MENU})
	self.Menu:MenuElement({id = "Key", name = "> Key Settings", type = MENU})
	self.Menu.Key:MenuElement({id = "Combo",name = "Combo", key = 32})
	self.Menu.Key:MenuElement({id = "Harass",name = "Harass", key = string.byte("C")})

	
	self.Menu:MenuElement({type = MENU, id = "Qset", name = "> Q Settings"})
	self.Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	self.Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = false})
	self.Menu.Qset:MenuElement({id = "Interrupt",name = "Auto on Interrupt Spells",value = true})

	self.Menu:MenuElement({type = MENU, id = "Wset", name = "> W Settings"})
	self.Menu.Wset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Wset:MenuElement({ id = "Harass", name = "Use in Harass",value = false})
	
	
	self.Menu:MenuElement({id = "Eset", name = "> E Settings", type = MENU})
	self.Menu.Eset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Eset:MenuElement({id = "Spell", name = "Use Against Spells",value = true})
	self.Menu.Eset:MenuElement({id = "HP", name = "Shield if HP Percent below ",value = 80, min = 0, max = 100,step = 1})
	self.Menu.Eset:MenuElement({id = "Turret", name = "Use Against Turrets",value = true})
	self.Menu.Eset:MenuElement({id = "Attack", name = "Use Against Attacks",value = true})
	
	self.Menu:MenuElement({id = "Rset", name = "> R Settings",type = MENU})
	self.Menu.Rset:MenuElement({id = "AutoR",name ="AutoR", value = false})
	self.Menu.Rset:MenuElement({id = "HP", name = "Active if HP below (%)", value =  30, min = 0, max = 100, step =1})
	
	self.Menu:MenuElement({type = MENU, id = "Draw",name = "> Draw Settings"})
	self.Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = false})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = false})
	self.Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = false})
	--self.Menu.Draw:MenuElement({id = "Root",name = "Draw Root Time", value = true})
	
	PrintChat("")

end

function Janna:LoadData()
	self.MissileSpells = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy then
			if MissileSpells[hero.charName] then
				for k,v in pairs(MissileSpells[hero.charName]) do
					if #v > 1 then
						self.MissileSpells[v] = true
					else
						--print(hero.charName)
					end	
				end
			end
		end
	end
end


function Janna:GetTarget(range)
	if self.SelectedTarget and isValidTarget(self.SelectedTarget,range) then
		return self.SelectedTarget
	end	
	return GetTarget(range)
end

function Janna:ProcessMissile()
	if (not isReady(_E) or not self.Menu.Eset.Spell:Value())then return end
	local enemy = true
	local allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if isValidTarget(hero,2500) and hero.isAlly then
			table.insert(allies,hero)
		elseif isValidTarget(hero,2500) and hero.isEnemy then
			enemy = false
		end
	end
	if enemy then return end	
	for i = 1, Game.MissileCount() do
		local obj = Game.Missile(i)
		if obj and obj.isEnemy and obj.missileData and self.MissileSpells[obj.missileData.name] then
			local speed = obj.missileData.speed
			local width = obj.missileData.width
			local endPos = obj.missileData.endPos
			local pos = obj.pos
			if speed and width > 0 and endPos and pos then
				for k, hero in pairs(allies) do 
					if isValidTarget(hero,E.range) and hero.health/hero.maxHealth  < self.Menu.Eset.HP:Value()/100 then
						local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(pos,endPos,hero.pos)
						if isOnSegment and hero.pos:DistanceTo(Vector(pointSegment.x,myHero.pos.y,pointSegment.y)) < width+ hero.boundingRadius and os.clock() - self.LastSpellT > 0.35 then
							self.LastSpellT = os.clock()
							CastSpell(HK_E,hero.pos)
						end
					end
				end
				
			elseif pos and endPos then
				for k,hero in pairs(allies)	do
					if isValidTarget(hero,E.range) and (pos:DistanceTo(hero.pos) < 80 or Vector(endPos):DistanceTo(hero.pos) < 80) and hero.health/hero.maxHealth  < self.Menu.Eset.HP:Value()/100  then
						CastSpell(HK_E,hero.pos)--not sure 
					end
				end
			end
			--Shield Attacks 
		elseif obj and obj.isEnemy and obj.missileData and obj.missileData.name and not obj.missileData.name:find("Minion") and obj.missileData.target > 0 then
			local target = obj.missileData.target
			for k, hero in pairs(allies) do 
				if isValidTarget(hero,E.range) and target == hero.handle and hero.health/hero.maxHealth  < self.Menu.Eset.HP:Value()/100  then
					CastSpell(HK_E,hero.pos)
				end
			end
		end
	end	
end

function Janna:Tick()
	
	if self.SelectedTarget and self.SelectedTarget.dead then 
		self.SelectedTarget = nil
	end
	--self:
	self:AutoInterrupt()
	
	if self.Menu.Key.Combo:Value() then
		self:Combo()
	end
	if self.Menu.Key.Harass:Value() then
		self:Harass()
	end
	if isReady(_R) then
		self:AutoR()
	end
	
end

function Janna:CastQ(unit)
	if not unit  then return end
		local pos =  unit:GetPrediction(Q.speed,Q.delay)
		if pos and os.clock() - self.LastSpellT > 0.35 then
			self.LastSpellT = os.clock()
			CastSpell(HK_Q,pos)
		end
	
end

function Janna:CastW(unit)
	if os.clock() - self.LastSpellT > 0.35 then
		self.LastSpellT = os.clock()
		CastSpell(HK_W,unit.pos)
	end
end

function Janna:Combo()
	local qtarget = self:GetTarget(Q.range)
	local wtarget = self:GetTarget(W.range)
	
	if qtarget and isReady(_Q) and self.Menu.Qset.Combo:Value() then
		self:CastQ(qtarget)
	end
	if wtarget and isReady(_W) and self.Menu.Wset.Combo:Value() and (not isReady(_Q) or myHero.mana > myHero:GetSpellData(_R).mana) then
		self:CastW(wtarget)
	end
	if isReady(_E) and self.Menu.Eset.Combo:Value() then
		for id, hero in pairs(self.Allies) do
			if isValidTarget(hero,E.range) and  hero.attackData.state == 2 and self.Enemies[hero.attackData.target] and os.clock() - self.LastSpellT > 0.35 then  
				self.LastSpellT = os.clock()
				CastSpell(HK_E,hero.pos)
			end
		end
	end
end

function Janna:Harass()
	local qtarget = self:GetTarget(Q.range)
	local wtarget = self:GetTarget(W.range)
	
	if qtarget and isReady(_Q) and self.Menu.Qset.Harass:Value() then
		self:CastQ(qtarget)
	end
	if wtarget and isReady(_W) and self.Menu.Wset.Harass:Value() and (not isReady(_Q) or myHero.mana > myHero:GetSpellData(_R).mana ) then
		self:CastW(wtarget)
	end
end

function Janna:AutoR()
	if self.Menu.Rset.AutoR:Value() then
		for i, hero in pairs(self.Allies) do
			if isValidTarget(hero,500) and hero.health/hero.maxHealth  < self.Menu.Rset.HP:Value()/100 and CountEnemies(hero.pos,R.range - 100) > 0  then
				Control.CastSpell(HK_R)
			end
		end
	end
end

function Janna:AutoInterrupt()--to do
	if not isReady(_Q) then return end
	for i = 1, Game.HeroCount() do
		local enemy  = Game.Hero(i)
 		if enemy.isEnemy and isReady(_Q) and isValidTarget(enemy,Q.range) and AutoInterrupter:IsChannelling(enemy) and self.Menu.Qset.Interrupt:Value() then
			self:CastQ(enemy,enemy.pos)
			return
		end
		
	end
end

function Janna:Draw()
	if myHero.dead then return end

	if self.Menu.Draw.Q:Value() then
		local qcolor = isReady(_Q) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.range,1,qcolor)
	end
	if self.Menu.Draw.W:Value() then
		local wcolor = isReady(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.range,1,wcolor)
	end
	if self.Menu.Draw.E:Value() then
		local ecolor = isReady(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.range,1,ecolor)
	end
end

function Janna:WndMsg(msg,key)
	if msg == 513 then
		local starget = nil
		for i  = 1,Game.HeroCount(i) do
			local enemy = Game.Hero(i)
			if isValidTarget(enemy) and enemy.isEnemy and enemy.pos:DistanceTo(mousePos) < 200 then
				starget = enemy
				break
			end
		end
		if starget then
			self.SelectedTarget = starget
			print("")
		else
			self.SelectedTarget = nil
		end
	end	
end

--[[Nami]]


class "Nami"

function Nami:__init()
	Q = {ready = false, range = 875, radius = 150, speed = 5000, delay = 0.7, type = "circular"}
	W = {ready = false, range = 725,}
	E = {ready = false, range = 800}
	R = {ready = false, range = 2750,radius = 260, speed = 850, delay = 0.5, type = "line" }
	
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly then
			self.Allies[hero.handle] = hero
		else
			self.Enemies[hero.handle] = hero
		end	
	end	
	self.lastTick = 0
	self.SelectedTarget = nil
	self:LoadData()
	self:LoadMenu()
	Callback.Add("Tick",function() self:Tick() end)
	Callback.Add("Draw",function() self:Draw() end)
	Callback.Add("WndMsg",function(Msg, Key) self:WndMsg(Msg, Key) end)
end

function Nami:LoadMenu()
	self.Menu = MenuElement( {id = "SB"..myHero.charName, name = "Nami - The River Spirit", type = MENU})
	self.Menu:MenuElement({id = "Key", name = "> Key Settings", type = MENU})
	self.Menu.Key:MenuElement({id = "Combo",name = "Combo", key = 32})
	self.Menu.Key:MenuElement({id = "Harass",name = "Harass", key = string.byte("C")})

	self.Menu:MenuElement({type = MENU, id = "Qset", name = "> Q Settings"})
	self.Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	self.Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = false})
	self.Menu.Qset:MenuElement({id = "Immobile",name = "Auto on Immobile",value = true})
	self.Menu.Qset:MenuElement({id = "Interrupt",name = "Auto Interrupt Spells",value = true})

	self.Menu:MenuElement({type = MENU, id = "Eset", name = "> E Settings"})
	self.Menu.Eset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Eset:MenuElement({ id = "Harass", name = "Use in Harass",value = false})
	
	self.Menu:MenuElement({id = "Wset", name = "> W Settings", type = MENU})
	self.Menu.Wset:MenuElement({id = "AutoW", name = "Enable Auto Health",value = true})
	self.Menu.Wset:MenuElement({id = "Me", name = "Heal me",value = true})
	self.Menu.Wset:MenuElement({id = "MyHp", name = "Heal me if HP Percent below ",value = 50, min = 0, max = 100,step = 1})
	self.Menu.Wset:MenuElement({id = "Ally", name = "Heal Allies",value = true})
	self.Menu.Wset:MenuElement({id = "AllyHp", name = "Heal Allies if HP Percent below ",value = 40, min = 0, max = 100,step = 1})
	
	self.Menu:MenuElement({id = "Rset", name = "> R Settings",type = MENU})
	self.Menu.Rset:MenuElement({id = "AimR",name = "R-Cast Assistant Key", key = string.byte("+")})
	self.Menu.Rset:MenuElement({id = "Interrupt",name ="Auto Interrupt Spells", value = false})
	self.Menu.Rset:MenuElement({id = "Min", name = "Active if Hits X Enemies", value =  3, min = 1, max = 5, step =1})
	
	self.Menu:MenuElement({type = MENU, id = "Draw",name = "> Draw Settings"})
	self.Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = false})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = false})
	self.Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = false})
	self.Menu.Draw:MenuElement({id = "R", name = "Draw R Range", value = false})
	PrintChat("")
end

function Nami:LoadData()
	self.MissileSpells = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy then
			if MissileSpells[hero.charName] then
				for k,v in pairs(MissileSpells[hero.charName]) do
					if #v > 1 then
						self.MissileSpells[v] = true
					else
						--print(hero.charName)
					end	
				end
			end
		end
	end
end


function Nami:GetTarget(range)
	if self.SelectedTarget and isValidTarget(self.SelectedTarget,range) then
		return self.SelectedTarget
	end	
	return GetTarget(range)
end

function Nami:AutoW()
	if (not isReady(_W) or not self.Menu.Wset.AutoW:Value())then return end
	for i, ally in pairs(self.Allies) do
		if isValidTarget(ally,W.range) then
			if ally.isMe then
				if ally.health/ally.maxHealth  < self.Menu.Wset.MyHp:Value()/100 then
					CastSpell(HK_W,myHero.pos)
					return
				end	
			else 
				if ally.health/ally.maxHealth  < self.Menu.Wset.AllyHp:Value()/100 then
					CastSpell(HK_W,ally.pos)
					return
				end	
			end			
		end
	end
end

function Nami:Tick()
	if myHero.dead then return end
	if self.SelectedTarget and self.SelectedTarget.dead then 
		self.SelectedTarget = nil
	end
	--self:
	if isReady(_Q) then
		self:AutoQ()
	end	
	if isReady(_R) then
		self:AutoR()
	end
	if isReady(_W) then
		self:AutoW()
	end
	if self.Menu.Key.Combo:Value() then
		self:Combo()
	end
	if self.Menu.Key.Harass:Value() then
		self:Harass()
	end

	
end

function Nami:CastQ(unit)
	if not unit then return end
	local pos = unit:GetPrediction(Q.speed,Q.delay)
		if pos then
			CastSpell(HK_Q,pos)
		end

end

function Nami:CastR(unit)
	if not unit then return end
	local pos = unit:GetPrediction(R.speed,R.delay)
	if pos then
		CastSpell(HK_R,pos)
	end
end

function Nami:CastE(unit)
	if not unit then return end
	CastSpell(HK_E,unit.pos)
end

function Nami:Combo()
	local qtarget = self:GetTarget(Q.range)
	local etarget = self:GetTarget(E.range)
	
	if qtarget and isReady(_Q) and self.Menu.Qset.Combo:Value() then
		self:CastQ(qtarget)
	end
	if etarget and isReady(_E) and self.Menu.Eset.Combo:Value()  then
		self:CastE(etarget)
	end
	if isReady(_E) and self.Menu.Eset.Combo:Value() then
		for id, hero in pairs(self.Allies) do
			if isValidTarget(hero,E.range) and  hero.attackData.state == 2 and self.Enemies[hero.attackData.target] then  
				CastSpell(HK_E,hero.pos)
			end
		end
	end
end

function Nami:Harass()
	local qtarget = self:GetTarget(Q.range)
	local etarget = self:GetTarget(E.range)
	
	if qtarget and isReady(_Q) and self.Menu.Qset.Harass:Value() then
		self:CastQ(qtarget)
	end
	if etarget and isReady(_W) and self.Menu.Eset.Harass:Value() and (not isReady(_Q) or myHero.mana > myHero:GetSpellData(_R).mana ) then
		self:CastE(etarget)
	end
end

function Nami:AutoR()
	local target = self:GetTarget(R.range)
	if self.Menu.Rset.AimR:Value() then
		if target then
			self:CastR(target)
		end
	end
	if target and CountEnemies(target.pos,R.radius) >= self.Menu.Rset.Min:Value() then-- :3
		self:CastR(target)
	end
end

function Nami:AutoQ()
	for i = 1, Game.HeroCount() do
		local enemy  = Game.Hero(i)
 
		if enemy.isEnemy and isReady(_Q) and isValidTarget(enemy,Q.range) and IsImmobileTarget(enemy) and self.Menu.Qset.Immobile:Value() then
			self:CastQ(enemy,enemy.pos)
			return
		end
		if enemy.isEnemy and isReady(_Q) and isValidTarget(enemy,Q.range) and AutoInterrupter:IsChannelling(enemy) and self.Menu.Qset.Interrupt:Value() then
			self:CastQ(enemy,enemy.pos)
			return
		end
	end
end

function Nami:Draw()
	if myHero.dead then return end

	if self.Menu.Draw.Q:Value() then
		local qcolor = isReady(_Q) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.range,1,qcolor)
	end
	if self.Menu.Draw.W:Value() then
		local wcolor = isReady(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.range,1,wcolor)
	end
	if self.Menu.Draw.E:Value() then
		local ecolor = isReady(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.range,1,ecolor)
	end
	--R
end

function Nami:WndMsg(msg,key)
	if msg == 513 then
		local starget = nil
		for i  = 1,Game.HeroCount(i) do
			local enemy = Game.Hero(i)
			if isValidTarget(enemy) and enemy.isEnemy and enemy.pos:DistanceTo(mousePos) < 200 then
				starget = enemy
				break
			end
		end
		if starget then
			self.SelectedTarget = starget
			print("")
		else
			self.SelectedTarget = nil
		end
	end	
end

--[[Soraka]]


class "Soraka"

function Soraka:__init()
	Q = {ready = false, range = 810, radius = 235, speed = math.huge, delay = 0.250, type = "circular"}
	W = {ready = false, range = 550,}
	E = {ready = false, range = 925, radius = 310, speed = math.huge, delay = 1.75, type = "circular"}
	R = {ready = false, range = math.huge,}
	self.SpellCast = {state = 1, mouse = mousePos}
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly  then
			self.Allies[hero.handle] = hero
		else
			self.Enemies[hero.handle] = hero
		end	
	end	
	self.lastTick = 0
	self.SelectedTarget = nil
	self:LoadData()
	self:LoadMenu()
	
	Callback.Add("Tick",function() self:Tick() end)
	Callback.Add("Draw",function() self:Draw() end)
	Callback.Add("WndMsg",function(Msg, Key) self:WndMsg(Msg, Key) end)
end


function Soraka:LoadMenu()
	self.Menu = MenuElement( {id = "SB"..myHero.charName, name = "Soraka - The Starchild", type = MENU})
	self.Menu:MenuElement({id = "Key", name = "> Key Settings", type = MENU})
	self.Menu.Key:MenuElement({id = "Combo",name = "Combo", key = 32})
	self.Menu.Key:MenuElement({id = "Harass",name = "Harass", key = string.byte("C")})

	self.Menu:MenuElement({type = MENU, id = "Qset", name = "> Q Settings"})
	self.Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	self.Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = true})

	self.Menu:MenuElement({type = MENU, id = "Eset", name = "> E Settings"})
	self.Menu.Eset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Eset:MenuElement({id = "Harass", name = "Use in Harass",value = true})
	self.Menu.Eset:MenuElement({id = "Immobile",name = "Auto on Immobile",value = true})
	self.Menu.Eset:MenuElement({id = "Interrupt",name = "Auto Interrupt Spells",value = true})
	
	self.Menu:MenuElement({id = "Wset", name = "> W Settings", type = MENU})
	self.Menu.Wset:MenuElement({id = "AutoW", name = "Enable Auto Health",value = true})
	self.Menu.Wset:MenuElement({id = "MyHp", name = "Heal Allies if my HP Percent above ",value = 8, min = 1, max = 100,step = 1})
	self.Menu.Wset:MenuElement({id = "AllyHp", name = "Heal Allies if HP Percent below ",value = 80, min = 1, max = 100,step = 1})
	
	self.Menu:MenuElement({id = "Rset", name = "> R Settings",type = MENU})
	self.Menu.Rset:MenuElement({id = "AutoR", name = "Enable Auto R",value = true})
	self.Menu.Rset:MenuElement({id = "AllyHp", name = "Heal Allies if HP Percent below",value = 15, min = 1, max = 100,step = 1})
	
	self.Menu:MenuElement({type = MENU, id = "Draw",name = "> Draw Settings"})
	self.Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = true})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = true})
	self.Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = true})
	PrintChat("")
end

function Soraka:LoadData()
	self.MissileSpells = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy then
			if MissileSpells[hero.charName] then
				for k,v in pairs(MissileSpells[hero.charName]) do
					if #v > 1 then
						self.MissileSpells[v] = true
					end	
				end
			end
		end
	end
end

function Soraka:Tick()
	if myHero.dead then return end
	if self.SelectedTarget and self.SelectedTarget.dead then 
		self.SelectedTarget = nil
	end
	--self:
	if isReady(_E) then
		self:AutoE()
	end	
	if isReady(_R) then
		self:AutoR()
	end
	if isReady(_W) then
		self:AutoW()
	end
	if self.Menu.Key.Combo:Value() then
		self:Combo()
	end
	if self.Menu.Key.Harass:Value() then
		self:Harass()
	end
end

function Soraka:GetTarget(range)
	if self.SelectedTarget and isValidTarget(self.SelectedTarget,range) then
		return self.SelectedTarget
	end	
	return GetTarget(range)
end

function Soraka:CastQ(unit)
	if not unit then return end
	local pos = unit:GetPrediction(Q.speed,Q.delay)
		if pos then
			CastSpell(HK_Q,pos)
		end
end

function Soraka:CastE(unit)
	if not unit then return end
	local pos = unit:GetPrediction(E.speed,E.delay)
		if pos then
			CastSpell(HK_E,pos)
		end
end

function Soraka:Combo()
	local qtarget = self:GetTarget(Q.range)
	local etarget = self:GetTarget(E.range)
	
	if etarget and isReady(_E) and self.Menu.Eset.Combo:Value()  then
		self:CastE(etarget)
	end
	if qtarget and isReady(_Q) and self.Menu.Qset.Combo:Value() then
		self:CastQ(qtarget)
	end
end

function Soraka:Harass()
	local qtarget = self:GetTarget(Q.range)
	local etarget = self:GetTarget(E.range)
	
	if etarget and isReady(_E) and self.Menu.Eset.Harass:Value() and (myHero.mana > myHero:GetSpellData(_R).mana) then
		self:CastE(etarget)
	end
	if qtarget and isReady(_Q) and self.Menu.Qset.Harass:Value() and (myHero.mana > myHero:GetSpellData(_R).mana) then
		self:CastQ(qtarget)
	end
end

function Soraka:AutoW()
	if (not isReady(_W) or not self.Menu.Wset.AutoW:Value())then return end
	for i, ally in pairs(self.Allies) do
		if isValidTarget(ally,W.range) then
			if not ally.isMe then
				if (ally.health/ally.maxHealth  < self.Menu.Wset.AllyHp:Value()/100) and (myHero.health/myHero.maxHealth  >= self.Menu.Wset.MyHp:Value()/100) then
					CastSpell(HK_W,ally.pos)
					return
				end	
			end			
		end
	end
end

function Soraka:AutoR()
	if (not isReady(_R) or not self.Menu.Rset.AutoR:Value())then return end
	for i, ally in pairs(self.Allies) do
		if (ally.health/ally.maxHealth  < self.Menu.Rset.AllyHp:Value()/100) and (CountEnemies(ally.pos,300) > 0) then
			Control.CastSpell(HK_R)
			return
		end	
	end
end

function Soraka:AutoE()
	for i = 1, Game.HeroCount() do
		local enemy  = Game.Hero(i)
 
		if enemy.isEnemy and isReady(_E) and isValidTarget(enemy,E.range) and IsImmobileTarget(enemy) and self.Menu.Eset.Immobile:Value() then
			self:CastE(enemy,enemy.pos)
			return
		end
		if enemy.isEnemy and isReady(_E) and isValidTarget(enemy,E.range) and AutoInterrupter:IsChannelling(enemy) and self.Menu.Eset.Interrupt:Value() then
			self:CastQ(enemy,enemy.pos)
			return
		end
	end
end

function Soraka:Draw()
	if myHero.dead then return end

	if self.Menu.Draw.Q:Value() then
		local qcolor = isReady(_Q) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.range,1,qcolor)
	end
	if self.Menu.Draw.W:Value() then
		local wcolor = isReady(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.range,1,wcolor)
	end
	if self.Menu.Draw.E:Value() then
		local ecolor = isReady(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.range,1,ecolor)
	end
	--R
end

function Soraka:WndMsg(msg,key)
	if msg == 513 then
		local starget = nil
		for i  = 1,Game.HeroCount(i) do
			local enemy = Game.Hero(i)
			if isValidTarget(enemy) and enemy.isEnemy and enemy.pos:DistanceTo(mousePos) < 200 then
				starget = enemy
				break
			end
		end
		if starget then
			self.SelectedTarget = starget
			print("")
		else
			self.SelectedTarget = nil
		end
	end	
end

--[[Sona]]


class "Sona"

function Sona:__init()
	Q = {ready = false, range = 810, radius = 235, speed = math.huge, delay = 0.250, type = "circular"}
	W = {ready = false, range = 550,}
	E = {ready = false, range = 925, radius = 310, speed = math.huge, delay = 1.75, type = "circular"}
	R = {ready = false, range = math.huge,}
	self.SpellCast = {state = 1, mouse = mousePos}
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly  then
			self.Allies[hero.handle] = hero
		else
			self.Enemies[hero.handle] = hero
		end	
	end	
	self.lastTick = 0
	self.SelectedTarget = nil
	self:LoadData()
	self:LoadMenu()
	
	Callback.Add("Tick",function() self:Tick() end)
	Callback.Add("Draw",function() self:Draw() end)
	Callback.Add("WndMsg",function(Msg, Key) self:WndMsg(Msg, Key) end)
end


function Sona:LoadMenu()
	self.Menu = MenuElement( {id = "SB"..myHero.charName, name = "Sona - The Starchild", type = MENU, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/Sona.png"})
	self.Menu:MenuElement({id = "Key", name = "> Key Settings", type = MENU})
	self.Menu.Key:MenuElement({id = "Combo",name = "Combo", key = 32})
	self.Menu.Key:MenuElement({id = "Harass",name = "Harass", key = string.byte("C")})

	self.Menu:MenuElement({type = MENU, id = "Qset", name = "> Q Settings"})
	self.Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	self.Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = true})

	self.Menu:MenuElement({type = MENU, id = "Eset", name = "> E Settings"})
	self.Menu.Eset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Eset:MenuElement({id = "Harass", name = "Use in Harass",value = true})
	self.Menu.Eset:MenuElement({id = "Immobile",name = "Auto on Immobile",value = true})
	self.Menu.Eset:MenuElement({id = "Interrupt",name = "Auto Interrupt Spells",value = true})
	
	self.Menu:MenuElement({id = "Wset", name = "> W Settings", type = MENU})
	self.Menu.Wset:MenuElement({id = "AutoW", name = "Enable Auto Health",value = true})
	self.Menu.Wset:MenuElement({id = "MyHp", name = "Heal Allies if my HP Percent above ",value = 8, min = 1, max = 100,step = 1})
	self.Menu.Wset:MenuElement({id = "AllyHp", name = "Heal Allies if HP Percent below ",value = 80, min = 1, max = 100,step = 1})
	
	self.Menu:MenuElement({id = "Rset", name = "> R Settings",type = MENU})
	self.Menu.Rset:MenuElement({id = "AutoR", name = "Enable Auto R",value = true})
	self.Menu.Rset:MenuElement({id = "RHit", name = "Min enemies hit",value = 3, min = 1, max = 5,step = 1})
	
	self.Menu:MenuElement({type = MENU, id = "Draw",name = "> Draw Settings"})
	self.Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = false})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = false})
	self.Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = false})
	PrintChat("")
end

function Sona:LoadData()
	self.MissileSpells = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy then
			if MissileSpells[hero.charName] then
				for k,v in pairs(MissileSpells[hero.charName]) do
					if #v > 1 then
						self.MissileSpells[v] = true
					end	
				end
			end
		end
	end
end

function Sona:Tick()
	if myHero.dead then return end
	if self.SelectedTarget and self.SelectedTarget.dead then 
		self.SelectedTarget = nil
	end
	--self:
	if isReady(_E) then
		self:AutoE()
	end	
	if isReady(_R) then
		self:AutoR()
	end
	if isReady(_W) then
		self:AutoW()
	end
	if self.Menu.Key.Combo:Value() then
		self:Combo()
	end
	if self.Menu.Key.Harass:Value() then
		self:Harass()
	end
end

function Sona:GetTarget(range)
	if self.SelectedTarget and isValidTarget(self.SelectedTarget,range) then
		return self.SelectedTarget
	end	
	return GetTarget(range)
end

function Sona:CastQ(unit)
	if not unit then return end
	local pos = unit:GetPrediction(Q.speed,Q.delay)
		if pos then
			CastSpell(HK_Q,pos)
		end
end

function Sona:CastE(unit)
	if not unit then return end
	local pos = unit:GetPrediction(E.speed,E.delay)
		if pos then
			CastSpell(HK_E,pos)
		end
end

function Sona:Combo()
	local qtarget = self:GetTarget(Q.range)
	local etarget = self:GetTarget(E.range)
	
	if etarget and isReady(_E) and self.Menu.Eset.Combo:Value()  then
		self:CastE(etarget)
	end
	if qtarget and isReady(_Q) and self.Menu.Qset.Combo:Value() then
		self:CastQ(qtarget)
	end
end

function Sona:Harass()
	local qtarget = self:GetTarget(Q.range)
	local etarget = self:GetTarget(E.range)
	
	if etarget and isReady(_E) and self.Menu.Eset.Harass:Value() and (myHero.mana > myHero:GetSpellData(_R).mana) then
		self:CastE(etarget)
	end
	if qtarget and isReady(_Q) and self.Menu.Qset.Harass:Value() and (myHero.mana > myHero:GetSpellData(_R).mana) then
		self:CastQ(qtarget)
	end
end

function Sona:AutoW()
	if (not isReady(_W) or not self.Menu.Wset.AutoW:Value())then return end
	for i, ally in pairs(self.Allies) do
		if isValidTarget(ally,W.range) then
			if not ally.isMe then
				if (ally.health/ally.maxHealth  < self.Menu.Wset.AllyHp:Value()/100) and (myHero.health/myHero.maxHealth  >= self.Menu.Wset.MyHp:Value()/100) then
					CastSpell(HK_W,ally.pos)
					return
				end	
			end			
		end
	end
end

function Sona:AutoR()
	if (not isReady(_R) or not self.Menu.Rset.AutoR:Value())then return end
	for i, ally in pairs(self.Allies) do
		if (ally.health/ally.maxHealth  < self.Menu.Rset.AllyHp:Value()/100) and (CountEnemies(ally.pos,300) > 0) then
			Control.CastSpell(HK_R)
			return
		end	
	end
end

function Sona:AutoE()
	for i = 1, Game.HeroCount() do
		local enemy  = Game.Hero(i)
 
		if enemy.isEnemy and isReady(_E) and isValidTarget(enemy,E.range) and IsImmobileTarget(enemy) and self.Menu.Eset.Immobile:Value() then
			self:CastE(enemy,enemy.pos)
			return
		end
		if enemy.isEnemy and isReady(_E) and isValidTarget(enemy,E.range) and AutoInterrupter:IsChannelling(enemy) and self.Menu.Eset.Interrupt:Value() then
			self:CastQ(enemy,enemy.pos)
			return
		end
	end
end

function Sona:Draw()
	if myHero.dead then return end

	if self.Menu.Draw.Q:Value() then
		local qcolor = isReady(_Q) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.range,1,qcolor)
	end
	if self.Menu.Draw.W:Value() then
		local wcolor = isReady(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.range,1,wcolor)
	end
	if self.Menu.Draw.E:Value() then
		local ecolor = isReady(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.range,1,ecolor)
	end
	--R
end

function Sona:WndMsg(msg,key)
	if msg == 513 then
		local starget = nil
		for i  = 1,Game.HeroCount(i) do
			local enemy = Game.Hero(i)
			if isValidTarget(enemy) and enemy.isEnemy and enemy.pos:DistanceTo(mousePos) < 200 then
				starget = enemy
				break
			end
		end
		if starget then
			self.SelectedTarget = starget
			print("")
		else
			self.SelectedTarget = nil
		end
	end	
end

--[[Karma]]


class "Karma"

function Karma:__init()
	Q = {ready = false, range = 950, radius = 70, speed = 1700, delay = 0.250, type = "line"}
	W = {ready = false, range = 700,}
	E = {ready = false, range = 800}
	R = {ready = false, range = math.huge,}
	self.SpellCast = {state = 1, mouse = mousePos}
	self.Enemies = {}
	self.Allies = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isAlly  then
			self.Allies[hero.handle] = hero
		else
			self.Enemies[hero.handle] = hero
		end	
	end	
	self.lastTick = 0
	self.SelectedTarget = nil
	self:LoadData()
	self:LoadMenu()
	
	Callback.Add("Tick",function() self:Tick() end)
	Callback.Add("Draw",function() self:Draw() end)
	Callback.Add("WndMsg",function(Msg, Key) self:WndMsg(Msg, Key) end)
end


function Karma:LoadMenu()
	self.Menu = MenuElement( {id = "SB"..myHero.charName, name = "Karma", type = MENU})
	self.Menu:MenuElement({id = "Key", name = "> Key Settings", type = MENU})
	self.Menu.Key:MenuElement({id = "Combo",name = "Combo", key = 32})
	self.Menu.Key:MenuElement({id = "Harass",name = "Harass", key = string.byte("C")})

	self.Menu:MenuElement({type = MENU, id = "Qset", name = "> Q Settings"})
	self.Menu.Qset:MenuElement({id = "Combo",name = "Use in Combo", value = true })
	self.Menu.Qset:MenuElement({id = "Harass", name = "Use in Harass", value = false})

	self.Menu:MenuElement({type = MENU, id = "Eset", name = "> E Settings"})
	self.Menu.Eset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Eset:MenuElement({id = "HPShield",name = "Use if my HP is lower than",value = 50, min = 1, max = 100,step = 1})
	
	self.Menu.Eset:MenuElement({id = "AutoShield",name = "Auto Shield x Allies",value = 4, min = 1, max = 5,step = 1})
	
	
	self.Menu:MenuElement({id = "Wset", name = "> W Settings", type = MENU})
	self.Menu.Wset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	self.Menu.Wset:MenuElement({id = "PreferW",name = "Combo R -> W if my HP is lower than",value = 30, min = 1, max = 100,step = 1})
	
	self.Menu:MenuElement({id = "Rset", name = "> R Settings",type = MENU})
	self.Menu.Rset:MenuElement({id = "Combo", name = "Use in Combo",value = true})
	
	
	self.Menu:MenuElement({type = MENU, id = "Draw",name = "> Draw Settings"})
	self.Menu.Draw:MenuElement({id = "Q", name = "Draw Q Range", value = false})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw W Range", value = false})
	self.Menu.Draw:MenuElement({id = "E", name = "Draw E Range", value = false})
	PrintChat("")
end

function Karma:LoadData()
	self.MissileSpells = {}
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy then
			if MissileSpells[hero.charName] then
				for k,v in pairs(MissileSpells[hero.charName]) do
					if #v > 1 then
						self.MissileSpells[v] = true
					end	
				end
			end
		end
	end
end

function Karma:HasMantra()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff.name and buff.name:lower() == "karmamantra" and buff.count > 0 and Game.Timer() < buff.expireTime then 
			return true
		end
	end
	return false
end

function Karma:Tick()
	if myHero.dead then return end
	if self.SelectedTarget and self.SelectedTarget.dead then 
		self.SelectedTarget = nil
	end
	if self:HasMantra() then
		Q.range = 1150
	else
		Q.range = 950
	end

	if self.Menu.Key.Combo:Value() then
		self:Combo()
	end
	if self.Menu.Key.Harass:Value() then
		self:Harass()
	end
end

function Karma:GetTarget(range)
	if self.SelectedTarget and isValidTarget(self.SelectedTarget,range) then
		return self.SelectedTarget
	end	
	return GetTarget(range)
end

function Karma:CastQ(unit)
	if not unit then return end
	local pos = unit:GetPrediction(Q.speed,Q.delay)
		if pos then
			CastSpell(HK_Q,pos)
		end
end

function Karma:CastE(unit)
	if not unit then return end
	local pos = unit:GetPrediction(E.speed,E.delay)
		if pos then
			CastSpell(HK_E,pos)
		end
end

function Karma:Combo()
	local qtarget = self:GetTarget(Q.range)
	local wtarget = self:GetTarget(W.range)
	if wtarget then
		qtarget = wtarget
	end
	if isReady(_W) and wtarget then
		if isReady(_R) and myHero.health/myHero.maxHealth < self.Menu.Wset.PreferW:Value()/100 then
			Control.CastSpell(_R)
		end
		CastSpell(HK_W,wtarget.pos)
		return
	end
	if isReady(_Q) and qtarget then
		if isReady(_R) and self.Menu.Rset.Combo:Value() then
			Control.CastSpell(HK_R)
		end
		if isReady(_Q) then
			local pos = qtarget:GetPrediction(Q.speed,Q.delay)
			if qtarget:GetCollision(Q.radius,Q.speed,Q.delay) == 0 then
				CastSpell(HK_Q,pos)
			elseif self:HasMantra() then
				
				local object = self:GetCollisionObject(pos)
				if not object or (object and object.pos:DistanceTo(pos) < 150) then
					CastSpell(HK_Q,pos)
				end
			end
		end
	end
	if isReady(_E) and self.Menu.Eset.Combo:Value() and myHero.health/myHero.maxHealth < self.Menu.Eset.HPShield:Value()/100  then
		CastSpell(HK_E,myHero.pos)
		return
	end
	if isReady(_E) and self.Menu.Eset.Combo:Value() then
		local ally = self:GetShieldTarget()
		if ally and isReady(_R) then
			Control.CastSpell(HK_R)
		end
		if ally and self:HasMantra() then	
			CastSpell(HK_E,ally.pos)
		end
	end
end

function Karma:GetCollisionObject(pos)
	local objects = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if isValidTarget(minion,Q.range + 150) then
			local pointSegment,pointLine,isOnSegment = VectorPointProjectionOnLineSegment(myHero.pos,pos,minion.pos)
			if isOnSegment and GetDistance(minion.pos,myHero.pos) < Q.radius + minion.boundingRadius then
				table.insert(objects,minion)
			end
		end
	end
	table.sort(objects,function(a,b) return GetDistance(a.pos,myHero.pos)	< GetDistance(b.pos,myHero.pos)  end)
	return objects[1]
end

function Karma:Harass()
	local qtarget = self:GetTarget(Q.range)
	if qtarget and isReady(_Q) and self.Menu.Qset.Harass:Value() and (myHero.mana > myHero:GetSpellData(_R).mana) then
		local pos = qtarget:GetPrediction(Q.speed,Q.delay)
		if qtarget:GetCollision(Q.radius,Q.speed,Q.delay) == 0 then
			CastSpell(HK_Q,pos)
		end	
	end
end


function Karma:CountAllyNearPos(pos,range)
	local count = 0
	for i = 1, Game.HeroCount() do
		local ally = Game.Hero(i)
		if ally and not ally.isEnemy and not ally.dead and ally.pos:DistanceTo(pos) < range then
			count=count + 1
		end
	end
	return count	
end

function Karma:GetShieldTarget()
	local result = myHero
	local total = self:CountAllyNearPos(myHero.pos,660)
	for i = 1, Game.HeroCount() do
		local ally = Game.Hero(i)
		if ally and not ally.isEnemy and not ally.dead and ally.charName ~= myHero.charName and ally.distance < E.range then
			local count = self:CountAllyNearPos(ally.pos,660)
			if count > total then
				total = count
				result = ally
			end
		end
	end
	if total >= self.Menu.Eset.AutoShield:Value() then
		return result
	else
		return nil
	end	
end

function Karma:Clear()

end

function Karma:Draw()
	if myHero.dead then return end

	if self.Menu.Draw.Q:Value() then
		local qcolor = isReady(_Q) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),Q.range,1,qcolor)
	end
	if self.Menu.Draw.W:Value() then
		local wcolor = isReady(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.range,1,wcolor)
	end
	if self.Menu.Draw.E:Value() then
		local ecolor = isReady(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.range,1,ecolor)
	end
	--R
end

function Karma:WndMsg(msg,key)
	if msg == 513 then
		local starget = nil
		for i  = 1,Game.HeroCount(i) do
			local enemy = Game.Hero(i)
			if isValidTarget(enemy) and enemy.isEnemy and enemy.pos:DistanceTo(mousePos) < 200 then
				starget = enemy
				break
			end
		end
		if starget then
			self.SelectedTarget = starget
			print("")
		else
			self.SelectedTarget = nil
		end
	end	
end

Callback.Add("Load",function() _G[myHero.charName]() end)


if myHero.charName == "Ashe" then
	class "Ashe"
	local Scriptname,Version,Author,LVersion = "TRUSt in my Ashe","v1.5","TRUS","7.11"
	function Ashe:GetBuffs(unit)
		self.T = {}
		for i = 0, unit.buffCount do
			local Buff = unit:GetBuff(i)
			if Buff.count > 0 then
				table.insert(self.T, Buff)
			end
		end
		return self.T
	end
	
	function Ashe:QBuff(buffname)
		for K, Buff in pairs(self:GetBuffs(myHero)) do
			if Buff.name:lower() == "asheqcastready" then
				return true
			end
		end
		return false
	end
	
	function Ashe:__init()
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"	
			_G.SDK.Orbwalker:OnPostAttack(function() 
				local combomodeactive = (_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO])
				local currenttarget = _G.SDK.Orbwalker:GetTarget()
				if (combomodeactive) and self.Menu.UseQCombo:Value() and self:QBuff() then
					self:CastQ()
				end
			end)
		elseif _G.EOW then
			orbwalkername = "EOW"	
			_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
				local combomodeactive = _G.EOW:Mode() == 1
				local currenttarget = _G.EOW:GetTarget()
				if (combomodeactive) and self.Menu.UseQCombo:Value() and self:QBuff() then
					self:CastQ()
				end
			end)
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			
			_G.GOS:OnAttackComplete(function() 
				local combomodeactive = _G.GOS:GetMode() == "Combo"
				local currenttarget = _G.GOS:GetTarget()
				if (combomodeactive) and currenttarget and self.Menu.UseQCombo:Value() and self:QBuff() and currenttarget then
					self:CastQ()
				end
			end)
			
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	
	--[[Spells]]
	function Ashe:LoadSpells()
		W = {Range = 1200, width = nil, Delay = 0.25, Radius = 30, Speed = 900}
	end
	
	
	function GetConeAOECastPosition(unit, delay, angle, range, speed, from)
		range = range and range - 4 or 20000
		radius = 1
		from = from and Vector(from) or Vector(myHero.pos)
		angle = angle * math.pi / 180
		
		local CastPosition = unit:GetPrediction(speed,delay)
		local points = {}
		local mainCastPosition = CastPosition
		
		table.insert(points, Vector(CastPosition) - Vector(from))
		
		local function CountVectorsBetween(V1, V2, points)
			local result = 0	
			local hitpoints = {} 
			for i, test in ipairs(points) do
				local NVector = Vector(V1):CrossP(test)
				local NVector2 = Vector(test):CrossP(V2)
				if NVector.y >= 0 and NVector2.y >= 0 then
					result = result + 1
					table.insert(hitpoints, test)
				elseif i == 1 then
					return -1 --doesnt hit the main target
				end
			end
			return result, hitpoints
		end
		
		local function CheckHit(position, angle, points)
			local direction = Vector(position):Normalized()
			local v1 = position:Rotated(0, -angle / 2, 0)
			local v2 = position:Rotated(0, angle / 2, 0)
			return CountVectorsBetween(v1, v2, points)
		end
		local enemyheroestable = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(range)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
		for i, target in ipairs(enemyheroestable) do
			if target.networkID ~= unit.networkID and myHero.pos:DistanceTo(target.pos) < range then
				CastPosition = target:GetPrediction(speed,delay)
				if from:DistanceTo(CastPosition) < range then
					table.insert(points, Vector(CastPosition) - Vector(from))
				end
			end
		end
		
		local MaxHitPos
		local MaxHit = 1
		local MaxHitPoints = {}
		
		if #points > 1 then
			
			for i, point in ipairs(points) do
				local pos1 = Vector(point):Rotated(0, angle / 2, 0)
				local pos2 = Vector(point):Rotated(0, - angle / 2, 0)
				
				local hits, points1 = CountVectorsBetween(pos1, pos2, points)
				--
				if hits >= MaxHit then
					
					MaxHitPos = C1
					MaxHit = hits
					MaxHitPoints = points1
				end
				
			end
		end
		
		if MaxHit > 1 then
			--Center the cone
			local maxangle = -1
			local p1
			local p2
			for i, hitp in ipairs(MaxHitPoints) do
				for o, hitp2 in ipairs(MaxHitPoints) do
					local cangle = Vector():AngleBetween(hitp2, hitp) 
					if cangle > maxangle then
						maxangle = cangle
						p1 = hitp
						p2 = hitp2
					end
				end
			end
			
			
			return Vector(from) + range * (((p1 + p2) / 2)):Normalized(), MaxHit
		else
			return unit.pos, 1
		end
	end
	
	
	
	function Ashe:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyAshe", name = Scriptname})
		self.Menu:MenuElement({id = "UseWCombo", name = "UseW in combo", value = true})
		self.Menu:MenuElement({id = "UseQCombo", name = "UseQ in combo", value = true})
		self.Menu:MenuElement({id = "UseQAfterAA", name = "UseQ only afterattack", value = true})
		self.Menu:MenuElement({id = "UseWHarass", name = "UseW in Harass", value = true})
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Ashe:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		
		if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "Volley" then 
			SetMovement(true)
		end
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		if combomodeactive and self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end
		
		if combomodeactive and self.Menu.UseWCombo:Value() and canmove and not canattack then
			self:CastW()
		end
		if combomodeactive and self:QBuff() and self.Menu.UseQCombo:Value() and (not self.Menu.UseQAfterAA:Value()) and currenttarget and canmove and not canattack then
			self:CastQ()
		end
		if harassactive and self.Menu.UseWHarass:Value() and ((canmove and not canattack) or not currenttarget) then
			self:CastW()
		end
	end
	
	function ReturnCursor(pos)
		Control.SetCursorPos(pos)
		SetMovement(true)
	end
	
	function LeftClick(pos)
		Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
		Control.mouse_event(MOUSEEVENTF_LEFTUP)
		DelayAction(ReturnCursor,0.05,{pos})
	end
	
	function Ashe:CastSpell(spell,pos)
		local customcast = self.Menu.CustomSpellCast:Value()
		if not customcast then
			Control.CastSpell(spell, pos)
			return
		else
			local delay = self.Menu.delay:Value()
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker > castSpell.casting then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
				if ticker - castSpell.tick < Game.Latency() then
					--block movement
					SetMovement(false)
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	
	function Ashe:CastQ()
		if self:CanCast(_Q) then
			Control.CastSpell(HK_Q)
		end
	end
	
	
	function Ashe:CastW(target)
		local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AD"))
		if target and self:CanCast(_W) and target:GetCollision(W.Radius,W.Speed,W.Delay) == 0 then
			local getposition = self:GetWPos(target)
			if getposition then
				self:CastSpell(HK_W,getposition)
			end
		end
	end
	
	
	function Ashe:GetWPos(unit)
		if unit then
			local temppos = GetConeAOECastPosition(unit, W.Delay, 45, W.Range, W.Speed)
			if temppos then 
				local newpos = myHero.pos:Extended(temppos,math.random(100,300))
				return newpos
			end
		end
		
		return false
	end
	
	function Ashe:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Ashe:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Ashe:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	function OnLoad()
		Ashe()
	end
end

if myHero.charName == "Lucian" then
	class "Lucian"
	local Scriptname,Version,Author,LVersion = "TRUSt in my Lucian","v1.4","TRUS","7.11"
	local passive = true
	local lastbuff = 0
	function Lucian:__init()
		
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"		
			_G.SDK.Orbwalker:OnPostAttack(function() 
				passive = false 
				--PrintChat("passive removed")
				local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
				if combomodeactive and _G.SDK.Orbwalker:CanMove() and Game.Timer() > lastbuff - 3.5 then 
					if self:CanCast(_E) and self.Menu.UseE:Value() and _G.SDK.Orbwalker:GetTarget() then
						self:CastSpell(HK_E,mousePos)
						return
					end
				end
			end)
		elseif _G.EOW then
			orbwalkername = "EOW"	
			_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
				passive = false 
				local combomodeactive = _G.EOW:Mode() == 1
				local canmove = _G.EOW:CanMove()
				if combomodeactive and canmove and Game.Timer() > lastbuff - 3.5 then 
					if self:CanCast(_E) and self.Menu.UseE:Value() and _G.EOW:GetTarget() then
						self:CastSpell(HK_E,mousePos)
						return
					end
				end
			end)
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			_G.GOS:OnAttackComplete(function() 
				passive = false 
				local combomodeactive = _G.GOS:GetMode() == "Combo"
				local canmove = _G.GOS:CanMove()
				if combomodeactive and canmove and Game.Timer() > lastbuff - 3.5 then 
					if self:CanCast(_E) and self.Menu.UseE:Value() and _G.GOS:GetTarget() then
						self:CastSpell(HK_E,mousePos)
						return
					end
				end
			end)
			
			
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	
	--[[Spells]]
	function Lucian:LoadSpells()
		Q = {Range = 1190, width = nil, Delay = 0.25, Radius = 60, Speed = 2000, Collision = false, aoe = false, type = "linear"}
	end
	
	
	
	function Lucian:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyLucian", name = Scriptname})
		self.Menu:MenuElement({id = "UseQ", name = "UseQ", value = true})
		self.Menu:MenuElement({id = "UseW", name = "UseW", value = true})
		self.Menu:MenuElement({id = "UseE", name = "UseE", value = true})
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		self.Menu:MenuElement({id = "UseQHarass", name = "Harass with Q", value = true})
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Lucian:GetBuffs(unit)
		self.T = {}
		for i = 0, unit.buffCount do
			local Buff = unit:GetBuff(i)
			if Buff.count > 0 then
				table.insert(self.T, Buff)
			end
		end
		return self.T
	end
	
	function Lucian:HasBuff(unit, buffname)
		for K, Buff in pairs(self:GetBuffs(unit)) do
			if Buff.name:lower() == buffname:lower() then
				return Buff.expireTime
			end
		end
		return false
	end
	
	function Lucian:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		local buffcheck = self:HasBuff(myHero,"lucianpassivebuff")
		if buffcheck and buffcheck ~= lastbuff then
			lastbuff = buffcheck
			--PrintChat("Passive added : "..Game.Timer().." : "..lastbuff)
			passive = true
		end
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		if combomodeactive and self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end
		if harassactive and self.Menu.UseQHarass:Value() and self:CanCast(_Q) then self:Harass() end 
		if combomodeactive and canmove and not canattack and Game.Timer() > lastbuff - 3 then 
			if self:CanCast(_E) and self.Menu.UseE:Value() and currenttarget then
				self:CastSpell(HK_E,mousePos)
				return
			end
			if self:CanCast(_Q) and self.Menu.UseQ:Value() and currenttarget then
				self:CastQ(currenttarget)
				return
			end
			if self:CanCast(_W) and self.Menu.UseW:Value() and currenttarget then
				self:CastW(currenttarget)
				return
			end
			
			
		end
		
		if myHero.activeSpell and myHero.activeSpell.valid and 
		(myHero.activeSpell.name == "LucianQ" or myHero.activeSpell.name == "LucianW") then
			passive = true
			--PrintChat("found passive1")
		end
		
		
	end
	
	function EnableMovement()
		--unblock movement
		SetMovement(true)
	end
	
	function ReturnCursor(pos)
		Control.SetCursorPos(pos)
		DelayAction(EnableMovement,0.1)
	end
	
	function LeftClick(pos)
		Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
		Control.mouse_event(MOUSEEVENTF_LEFTUP)
		DelayAction(ReturnCursor,0.05,{pos})
	end
	
	function Lucian:CastSpell(spell,pos)
		local customcast = self.Menu.CustomSpellCast:Value()
		if not customcast then
			Control.CastSpell(spell, pos)
			return
		else
			local delay = self.Menu.delay:Value()
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker > castSpell.casting then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
				if ticker - castSpell.tick < Game.Latency() then
					--block movement
					SetMovement(false)
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	
	--[[CastQ]]
	function Lucian:CastQ(target)
		if target and self:CanCast(_Q) and passive == false then
			self:CastSpell(HK_Q, target.pos)
		end
	end
	
	--[[CastQ]]
	function Lucian:CastW(target)
		if target and self:CanCast(_W) and passive == false then
			self:CastSpell(HK_W, target.pos)
		end
	end
	
	
	function Lucian:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Lucian:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Lucian:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	
	
	function Lucian:Harass()
		local temptarget = self:FarQTarget()
		if temptarget then
			self:CastSpell(HK_Q,temptarget.pos)
		end
	end
	
	
	
	
	function Lucian:FarQTarget()
		local qtarget = (_G.SDK and _G.SDK.TargetSelector:GetTarget(900, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(900,"AD"))
		if qtarget then
			
			if myHero.pos:DistanceTo(qtarget.pos)<500 then
				return qtarget
			end
			
			
			local qdelay = 0.4 - myHero.levelData.lvl*0.01
			local pos = qtarget:GetPrediction(math.huge,qdelay)
			if not pos then return false end 
			local minionlist = {}
			if _G.SDK then
				minionlist = _G.SDK.ObjectManager:GetEnemyMinions(500)
			elseif _G.GOS then
				for i = 1, Game.MinionCount() do
					local minion = Game.Minion(i)
					if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 500 then
						table.insert(minionlist, minion)
					end
				end
			end
			V = Vector(pos) - Vector(myHero.pos)
			
			Vn = V:Normalized()
			Distance = myHero.pos:DistanceTo(pos)
			tx, ty, tz = Vn:Unpack()
			TopX = pos.x - (tx * Distance)
			TopY = pos.y - (ty * Distance)
			TopZ = pos.z - (tz * Distance)
			
			Vr = V:Perpendicular():Normalized()
			Radius = qtarget.boundingRadius or 65
			tx, ty, tz = Vr:Unpack()
			
			LeftX = pos.x + (tx * Radius)
			LeftY = pos.y + (ty * Radius)
			LeftZ = pos.z + (tz * Radius)
			RightX = pos.x - (tx * Radius)
			RightY = pos.y - (ty * Radius)
			RightZ = pos.z - (tz * Radius)
			
			Left = Point(LeftX, LeftY, LeftZ)
			Right = Point(RightX, RightY, RightZ)
			Top = Point(TopX, TopY, TopZ)
			Poly = Polygon(Left, Right, Top)
			
			for i, minion in pairs(minionlist) do
				toPoint = Point(minion.pos.x, minion.pos.y,minion.pos.z)
				if Poly:__contains(toPoint) then
					return minion
				end
			end
		end
		return false 
	end
	
	
	function OnLoad()
		Lucian()
	end
end


if myHero.charName == "Caitlyn" then
	class "Caitlyn"
	local Scriptname,Version,Author,LVersion = "TRUSt in my Caitlyn","v1.6","TRUS","7.11"
	require "DamageLib"
	local qtarget
	if FileExist(COMMON_PATH .. "Eternal Prediction.lua") then
		require 'Eternal Prediction'
		PrintChat("Eternal Prediction library loaded")
	end
	local EPrediction = {}
	local LastW
	function Caitlyn:__init()
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		Callback.Add("Draw", function() self:Draw() end)
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"
		elseif _G.EOW then
			orbwalkername = "EOW"	
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	onetimereset = true
	blockattack = false
	blockmovement = false
	
	local lastpick = 0
	--[[Spells]]
	function Caitlyn:LoadSpells()
		Q = {Range = 1190, Width = 90, Delay = 0.625, Radius = 60, Speed = 2000}
		E = {Range = 800, Width = 70, Delay = 0.125, Radius = 80, Speed = 1600}
		
		if TYPE_GENERIC then
			local QSpell = Prediction:SetSpell({range = Q.Range, speed = Q.Speed, delay = Q.Delay, width = Q.Width}, TYPE_LINE, true)
			EPrediction[_Q] = QSpell
			local ESpell = Prediction:SetSpell({range = E.Range, speed = E.Speed, delay = Q.Delay, width = Q.Width}, TYPE_LINE, true)
			EPrediction[_E] = ESpell
		end
	end
	
	function Caitlyn:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyCaitlyn", name = Scriptname})
		self.Menu:MenuElement({id = "UseUlti", name = "Use R", tooltip = "On killable target which is on screen", key = string.byte("R")})
		self.Menu:MenuElement({id = "UseEQ", name = "UseEQ", key = string.byte("X")})
		self.Menu:MenuElement({id = "autoW", name = "Use W on cc", value = true})
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", value = true})
		self.Menu:MenuElement({id = "DrawR", name = "Draw Killable with R", value = true})
		self.Menu:MenuElement({id = "DrawColor", name = "Color for Killable circle", color = Draw.Color(0xBF3F3FFF)})
		
		if TYPE_GENERIC then
			self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 0.25, min = 0, max = 1, step = 0.05, identifier = ""})
		end
		
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Caitlyn:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		if combomodeactive and self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end
		
		local useEQ = self.Menu.UseEQ:Value()
		
		if self.Menu.UseUlti:Value() and self:CanCast(_R) then
			self:UseR()
		end
		
		if self:CanCast(_Q) and self:CanCast(_E) and useEQ and currenttarget then
			self:CastE(currenttarget)
		end
		
		if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name == "CaitlynEntrapment" and self:CanCast(_Q) and useEQ then
			Control.CastSpell(HK_Q,qtarget)
		end
		if self:CanCast(_W) then
			self:AutoW()
		end
	end
	
	function ReturnCursor(pos)
		Control.SetCursorPos(pos)
		SetMovement(true)
	end
	
	function LeftClick(pos)
		DelayAction(ReturnCursor,0.01,{pos})
	end
	
	function Caitlyn:GetRTarget()
		self.KillableHeroes = {}
		local RRange = ({2000, 2500, 3000})[myHero:GetSpellData(_R).level]
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(RRange)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
		for i, hero in pairs(heroeslist) do
			local RDamage = getdmg("R",hero,myHero,1)
			if hero.health and RDamage and RDamage > hero.health and hero.pos2D.onScreen and myHero.pos:DistanceTo(hero.pos) < RRange then
				table.insert(self.KillableHeroes, hero)
			end
		end
		return self.KillableHeroes
	end
	
	function Caitlyn:UseR()
		local RTarget = self:GetRTarget()
		if #RTarget > 0 then
			Control.SetCursorPos(RTarget[1].pos)
			Control.KeyDown(HK_R)
			Control.KeyUp(HK_R)
		end
	end
	
	function Caitlyn:Draw()
		if self.Menu.DrawR:Value() then
			local RTarget = self:GetRTarget()
			for i, hero in pairs(RTarget) do
				Draw.Circle(hero.pos, 60, 3, self.Menu.DrawColor:Value())
			end
		end
	end
	
	function Caitlyn:Stunned(enemy)
		for i = 0, enemy.buffCount do
			local buff = enemy:GetBuff(i);
			if (buff.type == 5 or buff.type == 11 or buff.type == 24) and buff.duration > 0.5 and buff.name ~= "caitlynyordletrapdebuff" then
				return true
			end
		end
		return false
	end
	
	function Caitlyn:AutoW()
		if not self.Menu.autoW:Value() then return end
		local ImmobileEnemy = self:GetImmobileTarget()
		if ImmobileEnemy and myHero.pos:DistanceTo(ImmobileEnemy.pos)<800 and (not LastW or LastW:DistanceTo(ImmobileEnemy.pos)>60) then
			LastW = ImmobileEnemy.pos
			self:CastSpell(HK_W,ImmobileEnemy.pos)
		end
	end
	
	function Caitlyn:CastSpell(spell,pos)
		local customcast = self.Menu.CustomSpellCast:Value()
		if not customcast then
			Control.CastSpell(spell, pos)
			return
		else
			local delay = self.Menu.delay:Value()
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker > castSpell.casting then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
				if ticker - castSpell.tick < Game.Latency() then
					--block movement
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker
				end
			end
		end
	end
	
	
	function Caitlyn:GetImmobileTarget()
		local GetEnemyHeroes = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(800)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
		for i = 1, #GetEnemyHeroes do
			local Enemy = GetEnemyHeroes[i]
			if Enemy and self:Stunned(Enemy) and myHero.pos:DistanceTo(Enemy.pos) < 800 then
				return Enemy
			end
		end
		return false
	end
	
	
	
	function Caitlyn:CastCombo(pos)
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				--block movement
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(HK_E)
				Control.KeyUp(HK_E)
				Control.KeyDown(HK_Q)
				Control.KeyUp(HK_Q)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker
			end
		end
	end
	
	
	
	--[[CastEQ]]
	function Caitlyn:CastE(target)
		if not _G.SDK and not _G.GOS then return end
		local castpos
		if TYPE_GENERIC then
			castPos = EPrediction[_E]:GetPrediction(target, myHero.pos)
			if castPos.hitChance >= self.Menu.minchance:Value() and EPrediction[_E]:mCollision() == 0 then
				local newpos = myHero.pos:Extended(castPos.castPos,math.random(100,300))
				self:CastCombo(newpos)
				qtarget = newpos
			end
		elseif target:GetCollision(E.Radius,E.Speed,E.Delay) == 0 then
			castPos = target:GetPrediction(E.Speed,E.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastCombo(newpos)
			qtarget = newpos
		end
	end
	
	
	function Caitlyn:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Caitlyn:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Caitlyn:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	function OnLoad()
		Caitlyn()
	end
end

if myHero.charName == "Ezreal" then
	class "Ezreal"
	local Scriptname,Version,Author,LVersion = "TRUSt in my Ezreal","v1.7","TRUS","7.11"
	require "DamageLib"
	
	if FileExist(COMMON_PATH .. "Eternal Prediction.lua") then
		require 'Eternal Prediction'
		PrintChat("Eternal Prediction library loaded")
	end
	local EPrediction = {}
	
	function Ezreal:__init()
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"	
		elseif _G.EOW then
			orbwalkername = "EOW"	
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
		else
			orbwalkername = "Orbwalker not found"
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	
	local lastpick = 0
	--[[Spells]]
	function Ezreal:LoadSpells()
		Q = {Range = 1190, width = 60, Delay = 0.25, Radius = 60, Speed = 2000, Collision = false, aoe = false, type = "linear"}
		if TYPE_GENERIC then
			local QSpell = Prediction:SetSpell({range = Q.range, speed = Q.speed, delay = Q.Delay, width = Q.width}, TYPE_LINE, true)
			EPrediction[_Q] = QSpell
		end
	end
	
	function Ezreal:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyEzreal", name = Scriptname})
		self.Menu:MenuElement({id = "UseQ", name = "UseQ on champions", value = true})
		self.Menu:MenuElement({id = "UseQLH", name = "[WIP] UseQ to lasthit", value = true})
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		if TYPE_GENERIC then
			self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 0.25, min = 0, max = 1, step = 0.05, identifier = ""})
		end
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Ezreal:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		local farmactive = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT]) or (_G.EOW and _G.EOW:Mode() == 3) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Lasthit") 
		local laneclear = (_G.SDK and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR]) or (_G.EOW and _G.EOW:Mode() == 4) or (not _G.SDK and _G.GOS and _G.GOS:GetMode() == "Clear") 
		
		if combomodeactive and self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end
		if (combomodeactive or harassactive) and self:CanCast(_Q) and self.Menu.UseQ:Value() and canmove and (not canattack or not currenttarget) then
			self:CastQ()
		end
		
		if (farmactive or laneclear) and self.Menu.UseQLH:Value() then 
			self:QLastHit()
		end
		
		
	end
	
	function EnableMovement()
		--unblock movement
		SetMovement(true)
	end
	
	function ReturnCursor(pos)
		Control.SetCursorPos(pos)
		DelayAction(EnableMovement,0.1)
	end
	
	function LeftClick(pos)
		Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
		Control.mouse_event(MOUSEEVENTF_LEFTUP)
		DelayAction(ReturnCursor,0.05,{pos})
	end
	
	function Ezreal:CastSpell(spell,pos)
		local customcast = self.Menu.CustomSpellCast:Value()
		if not customcast then
			Control.CastSpell(spell, pos)
			return
		else
			local delay = self.Menu.delay:Value()
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker > castSpell.casting then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
				if ticker - castSpell.tick < Game.Latency() then
					--block movement
					SetMovement(false)
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	
	--[[CastQ]]
	function Ezreal:CastQ(target)
		if (not _G.SDK and not _G.GOS) then return end
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
		if target and target.type == "AIHeroClient" and self:CanCast(_Q) and self.Menu.UseQ:Value() then
			local castPos
			if TYPE_GENERIC then
				castPos = EPrediction[_Q]:GetPrediction(target, myHero.pos)
				if castPos.hitChance >= self.Menu.minchance:Value() and EPrediction[_Q]:mCollision() == 0 then
					local newpos = myHero.pos:Extended(castPos.castPos,math.random(100,300))
					self:CastSpell(HK_Q, newpos)
				end
			elseif target:GetCollision(Q.Radius,Q.Speed,Q.Delay) == 0 then
				castPos = target:GetPrediction(Q.Speed,Q.Delay)
				local newpos = myHero.pos:Extended(castPos,math.random(100,300))
				self:CastSpell(HK_Q, newpos)
			end
			
		end
	end
	function Ezreal:QLastHit()
		local minionlist = {}
		local canattack = (_G.SDK and _G.SDK.Orbwalker:CanAttack()) or (not _G.SDK and _G.GOS and _G.GOS:CanAttack())
		local canmove = (_G.SDK and _G.SDK.Orbwalker:CanMove()) or (not _G.SDK and _G.GOS and _G.GOS:CanMove())
		if _G.SDK then
			minionlist = _G.SDK.ObjectManager:GetEnemyMinions(Q.Range)
		elseif _G.GOS then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < Q.Range then
					table.insert(minionlist, minion)
				end
			end
		end
		
		for i, minion in pairs(minionlist) do
			local distancetominion = myHero.pos:DistanceTo(minion.pos)
			if (distancetominion > myHero.range or (not canattack and canmove)) and not _G.SDK.Orbwalker:ShouldWait() then
				local QDamage = getdmg("Q",minion,myHero)
				local timetohit = distancetominion/Q.Speed
				if _G.SDK.HealthPrediction:GetPrediction(minion, timetohit + 0.3)<0 and _G.SDK.HealthPrediction:GetPrediction(minion, timetohit)< QDamage and _G.SDK.HealthPrediction:GetPrediction(minion, timetohit)>0 then
					if minion and self:CanCast(_Q) and minion:GetCollision(Q.Radius,Q.Speed,Q.Delay) == 1 then
						local castPos = minion:GetPrediction(Q.Speed,Q.Delay)
						local newpos = myHero.pos:Extended(castPos,math.random(100,300))
						self:CastSpell(HK_Q, newpos)
					end
				end
			end
		end
	end
	
	function Ezreal:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Ezreal:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Ezreal:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	
	function OnLoad()
		Ezreal()
	end
end

if myHero.charName == "Twitch" then
	local Scriptname,Version,Author,LVersion = "TRUSt in my Twitch","v1.4","TRUS","7.11"
	class "Twitch"
	require "DamageLib"
	local qtarget
	local barHeight = 8
	local barWidth = 103
	local barXOffset = 0
	local barYOffset = 0
	function Twitch:__init()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		Callback.Add("Draw", function() self:Draw() end)
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"		
			_G.SDK.Orbwalker:OnPostAttack(function(arg) 		
				DelayAction(recheckparticle,0.2)
			end)
		elseif _G.EOW then
			orbwalkername = "EOW"	
			_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
				DelayAction(recheckparticle,0.2)
			end)
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			_G.GOS:OnAttackComplete(function() 
				DelayAction(recheckparticle,0.2)
			end)
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	
	function Twitch:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyTwitch", name = Scriptname})
		self.Menu:MenuElement({id = "UseEKS", name = "Use E on killable", value = true})
		self.Menu:MenuElement({id = "UseERange", name = "Use E on running enemy", value = true})
		self.Menu:MenuElement({id = "MinStacks", name = "Minimal E stacks", value = 2, min = 0, max = 6, step = 5, identifier = ""})
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", value = true})
		self.Menu:MenuElement({id = "DrawE", name = "Draw Killable with E", value = true})
		self.Menu:MenuElement({id = "DrawEDamage", name = "Draw E damage on HPBar", value = true})
		self.Menu:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	local lastcasttime = 0
	function Twitch:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		
		if myHero.activeSpell and myHero.activeSpell.valid and myHero.activeSpell.name:lower() == "twitchvenomcask" and myHero.activeSpell.startTime ~= lastcasttime then
			lastcasttime = myHero.activeSpell.startTime
			DelayAction(recheckparticle,0.3)
		end
		
		
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		
		if combomodeactive then 
			if self.Menu.UseBOTRK:Value() then
				UseBotrk()
			end	
		end
		
		if self:CanCast(_E) and self.Menu.UseEKS:Value() then
			self:UseEKS()
		end
		
		if (harassactive or combomodeactive) and self.Menu.UseERange:Value() and self:CanCast(_E) then
			self:UseERange()
		end
	end
	
	function Twitch:UseERange()
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
		local target = (_G.SDK and _G.SDK.TargetSelector.SelectedTarget) or (_G.GOS and _G.GOS:GetTarget())
		if target then return end 
		for i, hero in pairs(heroeslist) do
			if stacks[hero.charName] and self:GetStacks(stacks[hero.charName].name) >= self.Menu.MinStacks:Value() then
				if myHero.pos:DistanceTo(hero.pos)<1000 and myHero.pos:DistanceTo(hero:GetPrediction(math.huge,0.25)) > 1000 then
					Control.CastSpell(HK_E)
				end
			end
		end
	end
	
	function Twitch:GetStacks(str)
		if str:lower():find("twitch_base_p_stack_01.troy") then return 1
		elseif str:lower():find("twitch_base_p_stack_02.troy") then return 2
		elseif str:lower():find("twitch_base_p_stack_03.troy") then return 3
		elseif str:lower():find("twitch_base_p_stack_04.troy") then return 4
		elseif str:lower():find("twitch_base_p_stack_05.troy") then return 5
		elseif str:lower():find("twitch_base_p_stack_06.troy") then return 6
		end
		return 0
	end
	stacks = {}
	function recheckparticle()
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
		for i = 1, Game.ObjectCount() do
			local object = Game.Object(i)		
			if object then
				for i, hero in pairs(heroeslist) do
					if object.pos:DistanceTo(hero.pos)<200 and object ~= hero then 
						local stacksamount = Twitch:GetStacks(object.name)
						if stacksamount > 0 then
							stacks[hero.charName] = object
						end
					end
				end
			end
		end
		return false
	end
	
	function Twitch:GetETarget()
		self.KillableHeroes = {}
		self.DamageHeroes = {}
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1200)) or (_G.GOS and _G.GOS:GetEnemyHeroes())
		local level = myHero:GetSpellData(_E).level
		if level == 0 then return end
		for i, hero in pairs(heroeslist) do
			if stacks[hero.charName] and self:GetStacks(stacks[hero.charName].name) > 0 then 
				local EDamage = (self:GetStacks(stacks[hero.charName].name) * (({15, 20, 25, 30, 35})[level] + 0.2 * myHero.ap + 0.25 * myHero.bonusDamage)) + ({20, 35, 50, 65, 80})[level]
				local tmpdmg = CalcPhysicalDamage(myHero, hero, EDamage)
				if hero.health and tmpdmg and tmpdmg > hero.health and myHero.pos:DistanceTo(hero.pos)<1200 then
					table.insert(self.KillableHeroes, hero)
				else
					table.insert(self.DamageHeroes, {hero = hero, damage = EDamage})
				end
			end
		end
		return self.KillableHeroes, self.DamageHeroes
	end
	
	function Twitch:UseEKS()
		local ETarget, damaged = self:GetETarget()
		if #ETarget > 0 then
			Control.KeyDown(HK_E)
			Control.KeyUp(HK_E)
		end
	end
	
	function Twitch:Draw()
		if self.Menu.DrawE:Value() or self.Menu.DrawEDamage:Value() then
			local ETarget, damaged = self:GetETarget()
			if self.Menu.DrawE:Value() then
				if not ETarget then return end
				for i, hero in pairs(ETarget) do
					Draw.Circle(hero.pos, 60, 3, self.Menu.DrawColor:Value())
				end
			end
			if self.Menu.DrawEDamage:Value() then 
				if not damaged then return end
				for i, hero in pairs(damaged) do
					local barPos = hero.hero.hpBar
					if barPos.onScreen then
						local damage = hero.damage
						local percentHealthAfterDamage = math.max(0, hero.hero.health - damage) / hero.hero.maxHealth
						local xPosEnd = barPos.x + barXOffset + barWidth * hero.hero.health/hero.hero.maxHealth
						local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
						Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, self.Menu.DrawColor:Value())
					end
				end
			end
		end
	end
	
	
	function Twitch:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Twitch:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Twitch:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	function OnLoad()
		Twitch()
	end
end

if myHero.charName == "KogMaw" then
	class "KogMaw"
	local Scriptname,Version,Author,LVersion = "TRUSt in my KogMaw","v1.1","TRUS","7.11"
	function KogMaw:__init()
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"
			_G.SDK.Orbwalker:OnPostAttack(function() 
				local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
				local harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
				if (combomodeactive or harassactive) then
					self:CastQ(_G.SDK.Orbwalker:GetTarget(),combomodeactive)
				end
			end)
		elseif _G.EOW then
			orbwalkername = "EOW"	
			_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
				local combomodeactive = _G.EOW:Mode() == 1
				local harassactive = _G.EOW:Mode() == 2
				if (combomodeactive or harassactive) then
					self:CastQ(_G.EOW:GetTarget(),combomodeactive)
				end
			end)
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			_G.GOS:OnAttackComplete(function() 
				local combomodeactive = _G.GOS:GetMode() == "Combo"
				local harassactive = _G.GOS:GetMode() == "Harass"
				if (combomodeactive or harassactive) then
					self:CastQ(_G.GOS:GetTarget(),combomodeactive)
				end
			end)
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	
	--[[Spells]]
	function KogMaw:LoadSpells()
		Q = {Range = 1175, width = 70, Delay = 0.25, Speed = 1650}
		E = {Range = 1280, width = 120, Delay = 0.5, Speed = 1350}
		R = {Range = 1200, Delay = 1.2, Radius = 120, Speed = math.huge}
	end
	
	function KogMaw:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyKogMaw", name = Scriptname})
		--[[Combo]]
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
		self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
		self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
		self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R", value = true})
		self.Menu.Combo:MenuElement({id = "MaxStacks", name = "Max R stacks: ", value = 3, min = 0, max = 10})
		self.Menu.Combo:MenuElement({id = "ManaW", name = "Save mana for W", value = true})
		
		--[[Harass]]
		self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
		self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
		self.Menu.Harass:MenuElement({id = "harassUseE", name = "Use E", value = true})
		self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
		self.Menu.Harass:MenuElement({id = "harassUseR", name = "Use R", value = true})
		self.Menu.Harass:MenuElement({id = "HarassMaxStacks", name = "Max R stacks: ", value = 3, min = 0, max = 10})
		
		
		
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function KogMaw:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		local HarassMinMana = self.Menu.Harass.harassMana:Value()
		
		
		if combomodeactive and self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end
		
		if ((combomodeactive) or (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana)) and (canmove or not currenttarget) then
			self:CastQ(currenttarget,combomodeactive or false)
			self:CastE(currenttarget,combomodeactive or false)
			self:CastR(currenttarget,combomodeactive or false)
		end
		
		
		if myHero.activeSpell and myHero.activeSpell.valid and (myHero.activeSpell.name == "KogMawQ" or myHero.activeSpell.name == "KogMawVoidOozeMissile" or myHero.activeSpell.name == "KogMawLivingArtillery") then
			EnableMovement()
		end
	end
	
	function EnableMovement()
		SetMovement(true)
	end
	
	function ReturnCursor(pos)
		Control.SetCursorPos(pos)
		DelayAction(EnableMovement,0.1)
	end
	
	function LeftClick(pos)
		Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
		Control.mouse_event(MOUSEEVENTF_LEFTUP)
		DelayAction(ReturnCursor,0.05,{pos})
	end
	
	function KogMaw:CastSpell(spell,pos)
		local customcast = self.Menu.CustomSpellCast:Value()
		if not customcast then
			Control.CastSpell(spell, pos)
			return
		else
			local delay = self.Menu.delay:Value()
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker > castSpell.casting then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
				if ticker - castSpell.tick < Game.Latency() then
					--block movement
					SetMovement(false)
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	function KogMaw:GetRRange()
		return (myHero:GetSpellData(_R).level > 0 and ({1200,1500,1800})[myHero:GetSpellData(_R).level]) or 0
	end
	
	function KogMaw:GetBuffs()
		self.T = {}
		for i = 0, myHero.buffCount do
			local Buff = myHero:GetBuff(i)
			if Buff.count > 0 then
				table.insert(self.T, Buff)
			end
		end
		return self.T
	end
	
	function KogMaw:UltStacks()
		for K, Buff in pairs(self:GetBuffs()) do
			if Buff.name:lower() == "kogmawlivingartillerycost" then
				return Buff.count
			end
		end
		return 0
	end
	
	
	--[[CastQ]]
	function KogMaw:CastQ(target, combo)
		if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
		if target and target.type == "AIHeroClient" and self:CanCast(_Q) and ((combo and self.Menu.Combo.comboUseQ:Value()) or (combo == false and self.Menu.Harass.harassUseQ:Value())) and target:GetCollision(Q.Width,Q.Speed,Q.Delay) == 0 then
			local castPos = target:GetPrediction(Q.Speed,Q.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_Q, newpos)
		end
	end
	
	
	--[[CastE]]
	function KogMaw:CastE(target,combo)
		if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
		if target and target.type == "AIHeroClient" and self:CanCast(_E) and ((combo and self.Menu.Combo.comboUseE:Value()) or (combo == false and self.Menu.Harass.harassUseE:Value())) then
			local castPos = target:GetPrediction(E.Speed,E.Delay)
			local newpos = myHero.pos:Extended(castPos,math.random(100,300))
			self:CastSpell(HK_E, newpos)
		end
	end
	
	--[[CastR]]
	function KogMaw:CastR(target,combo)
		if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
		local RRange = self:GetRRange()
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(RRange, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(RRange,"AP"))
		local currentultstacks = self:UltStacks()
		if target and target.type == "AIHeroClient" and self:CanCast(_R) 
		and ((combo and self.Menu.Combo.comboUseR:Value()) or (combo == false and self.Menu.Harass.harassUseR:Value())) 
		and ((combo == false and currentultstacks < self.Menu.Harass.HarassMaxStacks:Value()) or (currentultstacks < self.Menu.Combo.MaxStacks:Value()))
		then
			local castPos = target:GetPrediction(R.Speed,R.Delay)
			self:CastSpell(HK_R, castPos)
		end
	end
	
	function KogMaw:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function KogMaw:CheckMana(spellSlot)
		local savemana = self.Menu.Combo.ManaW:Value()
		return myHero:GetSpellData(spellSlot).mana < (myHero.mana - ((savemana and 40) or 0))
	end
	
	function KogMaw:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	
	function OnLoad()
		KogMaw()
	end
end

if myHero.charName == "Kalista" then 
	local Scriptname,Version,Author,LVersion = "TRUSt in my Kalista","v1.10","TRUS","7.11"
	class "Kalista"
	require "DamageLib"
	
	local barHeight = 8
	local barWidth = 103
	local barXOffset = 0
	local barYOffset = 0
	
	JungleHpBarOffset = {
		["SRU_Dragon_Water"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
		["SRU_Dragon_Fire"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
		["SRU_Dragon_Earth"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
		["SRU_Dragon_Air"] = {Width = 140, Height = 4, XOffset = -9, YOffset = -60},
		["SRU_Dragon_Elder"] = {Width = 140, Height = 4, XOffset = 11, YOffset = -142},
		["SRU_Baron"] = {Width = 190, Height = 10, XOffset = 16, YOffset = 24},
		["SRU_RiftHerald"] = {Width = 139, Height = 6, XOffset = 12, YOffset = 22},
		["SRU_Red"] = {Width = 139, Height = 4, XOffset = -7, YOffset = -19},
		["SRU_Blue"] = {Width = 139, Height = 4, XOffset = -14, YOffset = -38},
		["SRU_Gromp"] = {Width = 86, Height = 2, XOffset = 16, YOffset = -28},
		["Sru_Crab"] = {Width = 61, Height = 2, XOffset = 37, YOffset = -8},
		["SRU_Krug"] = {Width = 79, Height = 2, XOffset = 22, YOffset = -30},
		["SRU_Razorbeak"] = {Width = 74, Height = 2, XOffset = 15, YOffset = -23},
		["SRU_Murkwolf"] = {Width = 74, Height = 2, XOffset = 24, YOffset = -30}
	}
	
	
	function Kalista:__init()
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		Callback.Add("Draw", function() self:Draw() end)
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"	
			_G.SDK.Orbwalker:OnPostAttack(function() 
				local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
				local harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
				local QMinMana = self.Menu.Combo.qMinMana:Value()
				if (combomodeactive or harassactive) then	
					if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) then
						self:CastQ(_G.SDK.Orbwalker:GetTarget(),combomodeactive or false)
					end
				end
			end)
		elseif _G.EOW then
			orbwalkername = "EOW"	
			_G.EOW:AddCallback(_G.EOW.AfterAttack, function() self:DelayedQ() end)
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			_G.GOS:OnAttackComplete(function() 
				local combomodeactive = _G.GOS:GetMode() == "Combo"
				local harassactive = _G.GOS:GetMode() == "Harass"
				local QMinMana = self.Menu.Combo.qMinMana:Value()
				if (combomodeactive or harassactive) then
					if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) then
						self:CastQ(_G.GOS:GetTarget(),combomodeactive or false)
					end
				end
			end)
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	function Kalista:DelayedQ()
		DelayAction(function() 
			local combomodeactive = _G.EOW:Mode() == 1
			local harassactive = _G.EOW:Mode() == 2
			local QMinMana = self.Menu.Combo.qMinMana:Value()
			if (combomodeactive or harassactive) then
				if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) then
					self:CastQ(_G.EOW:GetTarget(),combomodeactive or false)
				end
			end
		end, 0.05)
	end
	--[[Spells]]
	function Kalista:LoadSpells()
		Q = {Range = 1150, width = 40, Delay = 0.25, Speed = 2100}
		E = {Range = 1000}
	end
	
	function Kalista:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyKalista", name = Scriptname})
		
		--[[Combo]]
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		self.Menu:MenuElement({id = "AlwaysKS", name = "Always KS with E", value = true})
		
		self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
		self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
		self.Menu.Combo:MenuElement({id = "qMinMana", name = "Minimal mana for Q:", value = 30, min = 0, max = 101, identifier = "%"})
		self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
		
		--[[Draw]]
		self.Menu:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
		self.Menu.Draw:MenuElement({id = "DrawEDamage", name = "Draw number health after E", value = true})
		self.Menu.Draw:MenuElement({id = "DrawEBarDamage", name = "On hpbar after E", value = true})
		--self.Menu.Draw:MenuElement({id = "HPBarOffset", name = "Z offset for HPBar ", value = 0, min = -100, max = 100, tooltip = "change this if damage showed in wrong position"})
		self.Menu.Draw:MenuElement({id = "DrawInPrecent", name = "Draw numbers in percent", value = true})
		self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw Killable with E", value = true})
		self.Menu.Draw:MenuElement({id = "TextOffset", name = "Z offset for text ", value = 0, min = -100, max = 100})
		self.Menu.Draw:MenuElement({id = "TextSize", name = "Font size ", value = 30, min = 2, max = 64})
		self.Menu.Draw:MenuElement({id = "DrawColor", name = "Color for drawing", color = Draw.Color(0xBF3F3FFF)})
		
		--[[Harass]]
		self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
		self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
		self.Menu.Harass:MenuElement({id = "harassUseELasthit", name = "Use E Harass when lasthit", value = true})
		self.Menu.Harass:MenuElement({id = "HarassMinEStacksLH", name = "Min E stacks (LastHit): ", value = 3, min = 0, max = 10})
		self.Menu.Harass:MenuElement({id = "harassUseERange", name = "Use E when out of range", value = true})
		self.Menu.Harass:MenuElement({id = "HarassMinEStacks", name = "Min E stacks (Range): ", value = 3, min = 0, max = 10})
		self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
		
		self.Menu:MenuElement({type = MENU, id = "SmiteMarker", name = "AutoE Jungle"})
		self.Menu.SmiteMarker:MenuElement({id = "Enabled", name = "Enabled", key = string.byte("K"), toggle = true})
		self.Menu.SmiteMarker:MenuElement({id = "MarkBaron", name = "Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkHerald", name = "Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkDragon", name = "Dragon", value = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkBlue", name = "Blue Buff", value = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkRed", name = "Red Buff", value = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkGromp", name = "Gromp", value = true, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkWolves", name = "Wolves", value = true, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkRazorbeaks", name = "Razorbeaks", value = true, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkKrugs", name = "Krugs", value = true, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
		self.Menu.SmiteMarker:MenuElement({id = "MarkCrab", name = "Crab", value = true, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
		
		
		self.Menu:MenuElement({type = MENU, id = "SmiteDamage", name = "Draw damage in Jungle"})
		self.Menu.SmiteDamage:MenuElement({id = "Enabled", name = "Display text", value = true})
		self.Menu.SmiteDamage:MenuElement({id = "EnabledHPBar", name = "Display on HPBar", value = true})
		self.Menu.SmiteDamage:MenuElement({id = "MarkBaron", name = "Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkHerald", name = "Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkDragon", name = "Dragon", value = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkBlue", name = "Blue Buff", value = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkRed", name = "Red Buff", value = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkGromp", name = "Gromp", value = true, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkWolves", name = "Wolves", value = true, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkRazorbeaks", name = "Razorbeaks", value = true, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkKrugs", name = "Krugs", value = true, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
		self.Menu.SmiteDamage:MenuElement({id = "MarkCrab", name = "Crab", value = true, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
		
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Kalista:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		local HarassMinMana = self.Menu.Harass.harassMana:Value()
		local QMinMana = self.Menu.Combo.qMinMana:Value()
		
		if combomodeactive and self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end
		if ((combomodeactive) or (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana)) then
			if (harassactive or (myHero.maxMana * QMinMana * 0.01 < myHero.mana)) and not currenttarget then
				self:CastQ(currenttarget,combomodeactive or false)
			end
			if (not canattack or not currenttarget) and self.Menu.Combo.comboUseE:Value() then
				self:CastE(currenttarget,combomodeactive or false)
			end
		end
		
		if self.Menu.AlwaysKS:Value() then
			self:CastE(false,combomodeactive or false)
		end
		
		if self.Menu.Harass.harassUseELasthit:Value() then
			self:UseEOnLasthit()
		end
		if (harassactive or combomodeactive) and self:CanCast(_E) and not canattack then
			if self.Menu.Harass.harassUseERange:Value() then 
				self:UseERange()
			end
		end
		
	end
	
	function EnableMovement()
		--unblock movement
		SetMovement(true)
	end
	
	function ReturnCursor(pos)
		Control.SetCursorPos(pos)
		Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
		Control.mouse_event(MOUSEEVENTF_RIGHTUP)
		DelayAction(EnableMovement,0.1)
	end
	
	function LeftClick(pos)
		Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
		Control.mouse_event(MOUSEEVENTF_LEFTUP)
		DelayAction(ReturnCursor,0.05,{pos})
	end
	
	function Kalista:CastSpell(spell,pos)
		local customcast = self.Menu.CustomSpellCast:Value()
		if not customcast then
			Control.CastSpell(spell, pos)
			return
		else
			local delay = self.Menu.delay:Value()
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker > castSpell.casting then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
				if ticker - castSpell.tick < Game.Latency() then
					--block movement
					SetMovement(false)
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	local SmiteTable = {
		SRU_Baron = "MarkBaron",
		SRU_RiftHerald = "MarkHerald",
		SRU_Dragon_Water = "MarkDragon",
		SRU_Dragon_Fire = "MarkDragon",
		SRU_Dragon_Earth = "MarkDragon",
		SRU_Dragon_Air = "MarkDragon",
		SRU_Dragon_Elder = "MarkDragon",
		SRU_Blue = "MarkBlue",
		SRU_Red = "MarkRed",
		SRU_Gromp = "MarkGromp",
		SRU_Murkwolf = "MarkWolves",
		SRU_Razorbeak = "MarkRazorbeaks",
		SRU_Krug = "MarkKrugs",
		Sru_Crab = "MarkCrab",
	}
	
	
	function Kalista:DrawDamageMinion(type, minion, damage)
		if not type or not self.Menu.SmiteDamage[type] then
			return
		end
		
		
		if self.Menu.SmiteDamage[type]:Value() then
			
			if self.Menu.SmiteDamage.Enabled:Value() then
				local offset = self.Menu.Draw.TextOffset:Value()
				local fontsize = self.Menu.Draw.TextSize:Value()
				local InPercents = self.Menu.Draw.DrawInPrecent:Value()
				local healthremaining = InPercents and math.floor((minion.health - damage)/minion.maxHealth*100).."%" or math.floor(minion.health - damage,1)
				Draw.Text(healthremaining, fontsize, minion.pos2D.x, minion.pos2D.y+offset,self.Menu.Draw.DrawColor:Value())
			end
			
			if self.Menu.SmiteDamage.EnabledHPBar:Value() then 
				local barPos = minion.hpBar
				if barPos.onScreen then
					local damage = damage
					local percentHealthAfterDamage = math.max(0, minion.health - damage) / minion.maxHealth
					local BarWidth = JungleHpBarOffset[minion.charName]["Width"]
					local BarHeight = JungleHpBarOffset[minion.charName]["Height"]
					local YOffset = JungleHpBarOffset[minion.charName]["YOffset"]
					local XOffset = JungleHpBarOffset[minion.charName]["XOffset"]
					local XPosStart = barPos.x + XOffset + BarWidth * 0
					local xPosEnd = barPos.x + XOffset + BarWidth * percentHealthAfterDamage
					
					Draw.Line(XPosStart, barPos.y + YOffset,xPosEnd, barPos.y + YOffset, BarHeight, self.Menu.Draw.DrawColor:Value())
				end
			end
			
		end
		
	end
	
	function Kalista:DrawSmiteableMinion(type,minion)
		if not type or not self.Menu.SmiteMarker[type] then
			return
		end
		if self.Menu.SmiteMarker[type]:Value() then
			if minion.pos2D.onScreen then
				Draw.Circle(minion.pos,minion.boundingRadius,6,Draw.Color(0xFF00FF00));
			end
			if self:CanCast(_E) then
				Control.CastSpell(HK_E)
			end
		end
	end
	function Kalista:HasBuff(unit, buffname)
		for K, Buff in pairs(self:GetBuffs(unit)) do
			if Buff.name:lower() == buffname:lower() then
				return Buff.expireTime
			end
		end
		return false
	end
	
	
	function Kalista:CheckKillableMinion()
		local minionlist = {}
		if _G.SDK then
			minionlist = _G.SDK.ObjectManager:GetMonsters(E.Range)
		elseif _G.GOS then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < E.Range then
					table.insert(minionlist, minion)
				end
			end
		end
		for i, minion in pairs(minionlist) do
			if self:GetSpears(minion) > 0 then 
				local EDamage = getdmg("E",minion,myHero)
				local minionName = minion.charName
				if EDamage*((minion.charName == "SRU_RiftHerald" and 0.65) or (self:HasBuff(myHero,"barontarget") and 0.5) or 0.79) > minion.health then
					local minionName = minion.charName
					self:DrawSmiteableMinion(SmiteTable[minionName], minion)
				else
					self:DrawDamageMinion(SmiteTable[minionName], minion, EDamage)
				end
			end
		end
	end
	function Kalista:GetBuffs(unit)
		self.T = {}
		for i = 0, unit.buffCount do
			local Buff = unit:GetBuff(i)
			if Buff.count > 0 then
				table.insert(self.T, Buff)
			end
		end
		return self.T
	end
	
	function Kalista:GetSpears(unit, buffname)
		for K, Buff in pairs(self:GetBuffs(unit)) do
			if Buff.name:lower() == "kalistaexpungemarker" then
				return Buff.count
			end
		end
		return 0
	end
	
	function Kalista:UseERange()
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or self:GetEnemyHeroes()
		local target = (_G.SDK and _G.SDK.TargetSelector.SelectedTarget) or (_G.EOW and _G.EOW:GetTarget()) or (_G.GOS and _G.GOS:GetTarget())
		if target then return end 
		for i, hero in pairs(heroeslist) do
			if self:GetSpears(hero) >= self.Menu.Harass.HarassMinEStacks:Value() then
				if myHero.pos:DistanceTo(hero.pos)<1000 and myHero.pos:DistanceTo(hero:GetPrediction(math.huge,0.25)) > 900 then
					Control.CastSpell(HK_E)
				end
			end
		end
	end
	
	function Kalista:UseEOnLasthit()
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1100)) or self:GetEnemyHeroes()
		local useE = false
		local minionlist = {}
		
		for i, hero in pairs(heroeslist) do
			if self:GetSpears(hero) >= self.Menu.Harass.HarassMinEStacksLH:Value() then
				if _G.SDK then
					minionlist = _G.SDK.ObjectManager:GetEnemyMinions(E.Range)
				elseif _G.GOS then
					for i = 1, Game.MinionCount() do
						local minion = Game.Minion(i)
						if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < E.Range then
							table.insert(minionlist, minion)
						end
					end
				end
				
				for i, minion in pairs(minionlist) do
					local spearsamount = self:GetSpears(minion)
					if spearsamount > 0 then 
						local EDamage = getdmg("E",minion,myHero)
						-- local basedmg = ({20, 30, 40, 50, 60})[level] + 0.6* (myHero.totalDamage)
						-- local perspear = ({10, 14, 19, 25, 32})[level] + ({0.2, 0.225, 0.25, 0.275, 0.3})[level]* (myHero.totalDamage)
						-- local tempdamage = basedmg + perspear*spearsamount
						if EDamage*0.8 > minion.health then
							Control.CastSpell(HK_E)
						end
					end
				end
			end
		end
	end
	function Kalista:GetEnemyHeroes()
		self.EnemyHeroes = {}
		for i = 1, Game.HeroCount() do
			local Hero = Game.Hero(i)
			if Hero.isEnemy and Hero.isTargetable then
				table.insert(self.EnemyHeroes, Hero)
			end
		end
		return self.EnemyHeroes
	end
	
	function Kalista:GetETarget()
		self.KillableHeroes = {}
		self.DamageHeroes = {}
		local heroeslist = (_G.SDK and _G.SDK.ObjectManager:GetEnemyHeroes(1200)) or self:GetEnemyHeroes()
		local level = myHero:GetSpellData(_E).level
		for i, hero in pairs(heroeslist) do
			if self:GetSpears(hero) > 0 and myHero.pos:DistanceTo(hero.pos)<E.Range then 
				local EDamage = getdmg("E",hero,myHero)*0.9
				if hero.health and EDamage and EDamage > hero.health then
					table.insert(self.KillableHeroes, hero)
				else
					table.insert(self.DamageHeroes, {hero = hero, damage = EDamage})
				end
			end
		end
		return self.KillableHeroes, self.DamageHeroes
	end
	
	--[[CastQ]]
	function Kalista:CastQ(target, combo)
		if (not _G.SDK and not _G.GOS) then return end
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AD"))
		if target and target.type == "AIHeroClient" and self:CanCast(_Q) and ((combo and self.Menu.Combo.comboUseQ:Value()) or (combo == false and self.Menu.Harass.harassUseQ:Value())) and target:GetCollision(Q.Width,Q.Speed,Q.Delay) == 0 then
			local castPos = target:GetPrediction(Q.Speed,Q.Delay)
			self:CastSpell(HK_Q, castPos)
		end
	end
	
	
	--[[CastE]]
	function Kalista:CastE(target,combo)
		local killable, damaged = self:GetETarget()
		if self:CanCast(_E) and #killable > 0 then
			Control.CastSpell(HK_E)
		end
	end
	
	
	
	function Kalista:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Kalista:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Kalista:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	function Kalista:Draw()
		if self.Menu.SmiteMarker.Enabled:Value() then
			self:CheckKillableMinion()
		end
		local killable, damaged = self:GetETarget()
		local offset = self.Menu.Draw.TextOffset:Value()
		local fontsize = self.Menu.Draw.TextSize:Value()
		local InPercents = self.Menu.Draw.DrawInPrecent:Value()
		if self.Menu.Draw.DrawE:Value() then
			for i, hero in pairs(killable) do
				Draw.Circle(hero.pos, 80, 6, self.Menu.Draw.DrawColor:Value())
				Draw.Text("killable", fontsize, hero.pos2D.x, hero.pos2D.y+offset,self.Menu.Draw.DrawColor:Value())
			end	
		end
		if self.Menu.Draw.DrawEDamage:Value() or self.Menu.Draw.DrawEBarDamage:Value()then
			for i, hero in pairs(damaged) do
				if self.Menu.Draw.DrawEBarDamage:Value() then 
					local barPos = hero.hero.hpBar
					if barPos.onScreen then
						--local barYOffset = self.Menu.Draw.HPBarOffset:Value()
						local damage = hero.damage
						local percentHealthAfterDamage = math.max(0, hero.hero.health - damage) / hero.hero.maxHealth
						local xPosEnd = barPos.x + barXOffset + barWidth * hero.hero.health/hero.hero.maxHealth
						local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
						Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, self.Menu.Draw.DrawColor:Value())
					end
				end
				if self.Menu.Draw.DrawEDamage:Value() then 
					local healthremaining = InPercents and math.floor((hero.hero.health - hero.damage)/hero.hero.maxHealth*100).."%" or math.floor(hero.hero.health - hero.damage,1)
					Draw.Text(healthremaining, fontsize, hero.hero.pos2D.x, hero.hero.pos2D.y+offset,self.Menu.Draw.DrawColor:Value())
				end
			end
		end
	end
	
	function OnLoad()
		Kalista()
	end
end


if myHero.charName == "Sivir" then 
	local Scriptname,Version,Author,LVersion = "TRUSt in my Sivir","v1.0","TRUS","7.10"
	class "Sivir"
	
	function Sivir:__init()
		self:LoadMenu()
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"	
			_G.SDK.Orbwalker:OnPostAttack(function() 
				local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
				local harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
				if (combomodeactive or harassactive) and self:CanCast(_W) and self.Menu.UseW:Value()then
					Control.CastSpell(HK_W)
				end
			end)
		elseif _G.EOW then
			orbwalkername = "EOW"	
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			_G.GOS:OnAttackComplete(function() 
				local combomodeactive = _G.GOS:GetMode() == "Combo"
				local harassactive = _G.GOS:GetMode() == "Harass"
				local QMinMana = self.Menu.Combo.qMinMana:Value()	
				if (combomodeactive or harassactive) and self:CanCast(_W) and self.Menu.UseW:Value() then
					Control.CastSpell(HK_W)
				end
			end)
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	
	
	function Sivir:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymySivir", name = Scriptname})
		
		--[[Combo]]
		self.Menu:MenuElement({id = "UseW", name = "Use W", value = true})
		
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Sivir:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Sivir:CheckMana(spellSlot)
		return myHero:GetSpellData(spellSlot).mana < myHero.mana
	end
	
	function Sivir:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	function OnLoad()
		Sivir()
	end
end

if myHero.charName == "Corki" then
	class "Corki"
	local Scriptname,Version,Author,LVersion = "TRUSt in my Corki","v1.0","TRUS","7.12"
	
	if FileExist(COMMON_PATH .. "Eternal Prediction.lua") then
		require 'Eternal Prediction'
		PrintChat("Eternal Prediction library loaded")
	end
	local EPrediction = {}
	
	function Corki:__init()
		self:LoadSpells()
		self:LoadMenu()
		Callback.Add("Tick", function() self:Tick() end)
		
		local orbwalkername = ""
		if _G.SDK then
			orbwalkername = "IC'S orbwalker"
			_G.SDK.Orbwalker:OnPostAttack(function() 
				local combomodeactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO]
				local harassactive = _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]
				if (combomodeactive or harassactive) then
					self:CastQ(_G.SDK.TargetSelector.SelectedTarget or _G.SDK.Orbwalker:GetTarget(825,_G.SDK.DAMAGE_TYPE_MAGICAL),combomodeactive)
				end
			end)
		elseif _G.EOW then
			orbwalkername = "EOW"	
			_G.EOW:AddCallback(_G.EOW.AfterAttack, function() 
				local combomodeactive = _G.EOW:Mode() == 1
				local harassactive = _G.EOW:Mode() == 2
				if (combomodeactive or harassactive) then
					self:CastQ(_G.EOW:GetTarget(),combomodeactive)
				end
			end)
		elseif _G.GOS then
			orbwalkername = "Noddy orbwalker"
			_G.GOS:OnAttackComplete(function() 
				local combomodeactive = _G.GOS:GetMode() == "Combo"
				local harassactive = _G.GOS:GetMode() == "Harass"
				if (combomodeactive or harassactive) then
					self:CastQ(_G.GOS:GetTarget(),combomodeactive)
				end
			end)
		else
			orbwalkername = "Orbwalker not found"
			
		end
		PrintChat(Scriptname.." "..Version.." - Loaded...."..orbwalkername)
	end
	
	--[[Spells]]
	function Corki:LoadSpells()
		Q = {Range = 825, Width = 250, Delay = 0.3, Speed = 1000}
		R = {Range = 1300, Delay = 0.2, Width = 120, Speed = 2000}
		R2 = {Range = 1500, Delay = 0.2, Width = 120, Speed = 2000}
		E = {Range = 400}
		
		if TYPE_GENERIC then
			local QSpell = Prediction:SetSpell({range = Q.Range, speed = Q.Speed, delay = Q.Delay, width = Q.Width}, TYPE_CIRCULAR, true)
			EPrediction["Q"] = QSpell
			local RSpell = Prediction:SetSpell({range = R.Range, speed = R.Speed, delay = R.Delay, width = R.Width}, TYPE_LINE, true)
			EPrediction["R"] = RSpell
			local R2Spell = Prediction:SetSpell({range = R.Range, speed = R2.Speed, delay = R2.Delay, width = R2.Width}, TYPE_LINE, true)
			EPrediction["R2"] = R2Spell
			
		end
	end
	
	function Corki:LoadMenu()
		self.Menu = MenuElement({type = MENU, id = "TRUStinymyCorki", name = Scriptname})
		--[[Combo]]
		self.Menu:MenuElement({id = "UseBOTRK", name = "Use botrk", value = true})
		self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
		self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
		self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
		self.Menu.Combo:MenuElement({id = "comboUseR", name = "Use R", value = true})
		self.Menu.Combo:MenuElement({id = "MaxStacks", name = "Min R stacks: ", value = 0, min = 0, max = 7})
		self.Menu.Combo:MenuElement({id = "ManaW", name = "Save mana for W", value = true})
		
		--[[Harass]]
		self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
		self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
		self.Menu.Harass:MenuElement({id = "harassUseR", name = "Use R", value = true})
		self.Menu.Harass:MenuElement({id = "HarassMaxStacks", name = "Min R stacks: ", value = 3, min = 0, max = 7})
		self.Menu.Harass:MenuElement({id = "harassMana", name = "Minimal mana percent:", value = 30, min = 0, max = 101, identifier = "%"})
		
		if TYPE_GENERIC then
			self.Menu:MenuElement({id = "minchance", name = "Minimal hitchance", value = 0.25, min = 0, max = 1, step = 0.05, identifier = ""})
		end
		self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so (thx Noddy for this one)", value = true})
		self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
		
		self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
		self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
	end
	
	function Corki:Tick()
		if myHero.dead or (not _G.SDK and not _G.GOS) then return end
		local combomodeactive, harassactive, canmove, canattack, currenttarget = CurrentModes()
		local HarassMinMana = self.Menu.Harass.harassMana:Value()
		
		
		if combomodeactive and self.Menu.UseBOTRK:Value() then
			UseBotrk()
		end
		
		if ((combomodeactive) or (harassactive and myHero.maxMana * HarassMinMana * 0.01 < myHero.mana)) and (canmove or not currenttarget) then
			self:CastQ(currenttarget,combomodeactive or false)
			if combomodeactive then
				self:CastE(currenttarget,true)
			end
			self:CastR(currenttarget,combomodeactive or false)
		end
	end
	
	function EnableMovement()
		SetMovement(true)
	end
	
	function ReturnCursor(pos)
		Control.SetCursorPos(pos)
		DelayAction(EnableMovement,0.1)
	end
	
	function LeftClick(pos)
		Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
		Control.mouse_event(MOUSEEVENTF_LEFTUP)
		DelayAction(ReturnCursor,0.05,{pos})
	end
	
	function Corki:CastSpell(spell,pos)
		local customcast = self.Menu.CustomSpellCast:Value()
		if not customcast then
			Control.CastSpell(spell, pos)
			return
		else
			local delay = self.Menu.delay:Value()
			local ticker = GetTickCount()
			if castSpell.state == 0 and ticker > castSpell.casting then
				castSpell.state = 1
				castSpell.mouse = mousePos
				castSpell.tick = ticker
				if ticker - castSpell.tick < Game.Latency() then
					--block movement
					SetMovement(false)
					Control.SetCursorPos(pos)
					Control.KeyDown(spell)
					Control.KeyUp(spell)
					DelayAction(LeftClick,delay/1000,{castSpell.mouse})
					castSpell.casting = ticker + 500
				end
			end
		end
	end
	
	function Corki:GetRRange()
		return (self:HasBig() and R2.Range or R.Range)
	end
	
	function Corki:GetBuffs()
		self.T = {}
		for i = 0, myHero.buffCount do
			local Buff = myHero:GetBuff(i)
			if Buff.count > 0 then
				table.insert(self.T, Buff)
			end
		end
		return self.T
	end
	
	function Corki:HasBig()
		for K, Buff in pairs(self:GetBuffs()) do
			if Buff.name:lower() == "corkimissilebarragecounterbig" then
				return true
			end
		end
		return false
	end
	
	function Corki:StacksR()
		return myHero:GetSpellData(_R).ammo
	end
	--[[CastQ]]
	function Corki:CastQ(target, combo)
		if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
		if target and target.type == "AIHeroClient" and self:CanCast(_Q) and ((combo and self.Menu.Combo.comboUseQ:Value()) or (combo == false and self.Menu.Harass.harassUseQ:Value())) then
			local castpos
			if TYPE_GENERIC then
				castPos = EPrediction["Q"]:GetPrediction(target, myHero.pos)
				if castPos.hitChance >= self.Menu.minchance:Value() then
					self:CastSpell(HK_Q, castPos.castPos)
				end
			else
				castPos = target:GetPrediction(Q.Speed,Q.Delay)
				self:CastSpell(HK_Q, castPos)
			end
		end
	end
	
	
	--[[CastE]]
	function Corki:CastE(target,combo)
		if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
		if target and target.type == "AIHeroClient" and self:CanCast(_E) and self.Menu.Combo.comboUseE:Value() then
			self:CastSpell(HK_E, target.pos)
		end
	end
	
	--[[CastR]]
	function Corki:CastR(target,combo)
		if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
		local RRange = self:GetRRange()
		local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(RRange, _G.SDK.DAMAGE_TYPE_PHYSICAL)) or (_G.GOS and _G.GOS:GetTarget(RRange,"AP"))
		local currentultstacks = self:StacksR()
		if target and target.type == "AIHeroClient" and self:CanCast(_R) 
		and ((combo and self.Menu.Combo.comboUseR:Value()) or (combo == false and self.Menu.Harass.harassUseR:Value())) 
		and ((combo == false and currentultstacks > self.Menu.Harass.HarassMaxStacks:Value()) or (combo and currentultstacks > self.Menu.Combo.MaxStacks:Value()))
		then
			local ulttype = self:HasBig() and "R2" or "R"
			if TYPE_GENERIC then
				castPos = EPrediction[ulttype]:GetPrediction(target, myHero.pos)
				if castPos.hitChance >= self.Menu.minchance:Value() and EPrediction[ulttype]:mCollision() == 0 then
					local newpos = myHero.pos:Extended(castPos.castPos,math.random(100,300))
					self:CastSpell(HK_R, newpos)
				end
			elseif ulttype == "R2" and target:GetCollision(R2.Radius,R2.Speed,R2.Delay) == 0 then
				castPos = target:GetPrediction(R2.Speed,R2.Delay)
				local newpos = myHero.pos:Extended(castPos,math.random(100,300))
				self:CastSpell(HK_R, newpos)
			elseif ulttype == "R" and target:GetCollision(R.Radius,R.Speed,R.Delay) == 0 then
				castPos = target:GetPrediction(R.Speed,R.Delay)
				local newpos = myHero.pos:Extended(castPos,math.random(100,300))
				self:CastSpell(HK_R, newpos)
			end
		end
	end
	
	function Corki:IsReady(spellSlot)
		return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
	end
	
	function Corki:CheckMana(spellSlot)
		local savemana = self.Menu.Combo.ManaW:Value()
		return myHero:GetSpellData(spellSlot).mana < (myHero.mana - ((savemana and 40) or 0))
	end
	
	function Corki:CanCast(spellSlot)
		return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
	end
	
	
	function OnLoad()
		Corki()
	end
end
