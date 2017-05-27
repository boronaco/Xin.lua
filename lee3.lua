if myHero.charName ~= "LeeSin" then return end
require "DamageLib"
require 'MapPositionGOS'
require "Collision"
-- SpellDatas
local P = {name = "blindmonkpassive_cosmetic", icon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/2/24/Flurry.png"}
local Q = {name="BlindMonkQOne",delay = 0.2,range = 1100,speed = 1800,width=60,icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/7/74/Sonic_Wave.png", icon2 = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/f/f2/Resonating_Strike.png"}
local QSpell = Collision:SetSpell(Q.range, Q.speed, Q.delay, Q.width, true)
local W = {name="BlindMonkWOne",range = 700,icon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/f/f1/Safeguard.png", icon2 = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/7/7f/Iron_Will.png"}
local E = {name="BlindMonkEOne",delay = 0.1,range = 350,speed = math.huge,icon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/b/bb/Tempest.png", icon2 = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/8/86/Cripple.png"}
local R = {name="BlindMonkRKick",delay = 0.3,range = 375,icon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/a/aa/Dragon%27s_Rage.png"}
local flashIcon="http://news.cdn.leagueoflegends.com/public/images/pages/2016/february/f-fla/flash-icon.jpg"
local smiteIcon="http://choualbox.com/Img/141692498458.png"
local wardIcon="https://s-media-cache-ak0.pinimg.com/236x/bf/3f/88/bf3f88c18d6385422c5bb23a595327d0.jpg"
local challengerIcon="http://4.bp.blogspot.com/-CsEIhRh74bE/VfRlhyvNjXI/AAAAAAAABPQ/FFLyO8VNguE/s1600/challenger.png"
-- Menu
local LeeSinMenu = MenuElement({type = MENU, id = "LeeSinMenu", name = "LeeSin", leftIcon = "http://vignette2.wikia.nocookie.net/leagueoflegends/images/2/28/Lee_Sin_Poro_Icon.png"})
--Combo
LeeSinMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Menu", leftIcon = "http://news.cdn.leagueoflegends.com/public/images/articles/2015/march_2015/upn/orbitallaser.jpg"})
LeeSinMenu.Combo:MenuElement({type = PARAM, id = "Q", name = "Use Q", value = true, leftIcon = Q.icon})
LeeSinMenu.Combo:MenuElement({type = PARAM, id = "W", name = "Use W", value = true, leftIcon = W.icon})
LeeSinMenu.Combo:MenuElement({type = PARAM, id = "E", name = "Use E", value = true, leftIcon = E.icon})
LeeSinMenu.Combo:MenuElement({type = PARAM, id = "P", name = "Use Passive", value = true, leftIcon = P.icon})
--LeeSinMenu.Combo:MenuElement({type = PARAM, id = "PS", name = "Passive Stacks To Use", value = 2,min=1,may=2, leftIcon = P.icon})
LeeSinMenu.Combo:MenuElement({type = PARAM, id = "WJ", name = " WardJump As Gapclose", value = true, leftIcon = wardIcon})
--JungleClear
LeeSinMenu:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear Menu", leftIcon = "http://3.bp.blogspot.com/-AIpsCUj6Fbo/VUkO1shYyjI/AAAAAAAApcA/YubY3joYf70/s1600/profileIcon847.png"})
LeeSinMenu.JungleClear:MenuElement({type = PARAM, id = "Q", name = "Use Q", value = true, leftIcon = Q.icon})
LeeSinMenu.JungleClear:MenuElement({type = PARAM, id = "W", name = "Use W", value = true, leftIcon = W.icon})
LeeSinMenu.JungleClear:MenuElement({type = PARAM, id = "E", name = "Use E", value = true, leftIcon = E.icon})
LeeSinMenu.JungleClear:MenuElement({type = PARAM, id = "P", name = "Use Passive", value = true, leftIcon = P.icon})
--InSec
LeeSinMenu:MenuElement({type = MENU, id = "InSec", name = "InSecS", leftIcon = "http://guides.gamepressure.com/lol/gfx/word/1057761971.png"})
--LeeSinMenu.InSec:MenuElement({type = PARAM, id = "SimpleKickS", name = "SimpleKick Key", key=string.byte("Y")})
LeeSinMenu.InSec:MenuElement({type = PARAM, id = "FlashKickS", name = "FlashKick Key", key=string.byte("X")})
LeeSinMenu.InSec:MenuElement({type = PARAM, id = "InSecS", name = "Typical-InSec Key", key=string.byte("C")})
LeeSinMenu.InSec:MenuElement({type = PARAM, id = "PosKey", name = "KickToPos Changer Key", key=string.byte("K")})
--WardJump
LeeSinMenu:MenuElement({type = MENU, id = "WardJump", name = "WardJump", leftIcon = W.icon})
LeeSinMenu.WardJump:MenuElement({type = PARAM, id = "Key", name = "Ward Jump Key", key=string.byte("+")})
LeeSinMenu.WardJump:MenuElement({type = PARAM, id = "AW", name = "Ward Jump AnyWay", value = false, leftIcon = W.icon})
LeeSinMenu.WardJump:MenuElement({type = PARAM, id = "AMR", name = "Ward Jump Only At Max Range", value = false, leftIcon = W.icon})
--SmiteQ
LeeSinMenu:MenuElement({type = PARAM, id = "SmiteQ", name = "Smite-Q", value = true, leftIcon = smiteIcon})
--KillSecure
LeeSinMenu:MenuElement({type = MENU, id = "KillSecure", name = " KillSecure Menu", leftIcon = "http://www.freeiconspng.com/uploads/troll-face-png-2.png"})
LeeSinMenu.KillSecure:MenuElement({type = PARAM, id = "Q", name = "Use Q", value = true, leftIcon = Q.icon})
LeeSinMenu.KillSecure:MenuElement({type = PARAM, id = "E", name = "Use E", value = true, leftIcon = E.icon})
LeeSinMenu.KillSecure:MenuElement({type = PARAM, id = "R", name = "Use R", value = true, leftIcon = R.icon})
--Drawings
LeeSinMenu:MenuElement({type = MENU, id = "Drawings", name = "Drawings", leftIcon = "http://photoservice.gamesao.vn/Resources/Upload/Images/Editor/33/Li%C3%AAn%20Minh%20Huy%E1%BB%81n%20Tho%E1%BA%A1i/C%E1%BA%ADp%20nh%E1%BA%ADt%20tin%20t%E1%BB%A9c%20ng%C3%A0y%2017%20th%C3%A1ng%206%20n%C4%83m%202015/15.1.png"})
LeeSinMenu.Drawings:MenuElement({type = PARAM, id = "KP", name = "Draw Kick Path", value = false, leftIcon = R.icon})
LeeSinMenu.Drawings:MenuElement({type = PARAM, id = "ISJP", name = "Draw InSec Jump Pos", value = false, leftIcon = W.icon})
LeeSinMenu.Drawings:MenuElement({type = PARAM, id = "WJR", name = "Draw Ward Jump Range", value = false, leftIcon = W.icon})
LeeSinMenu.Drawings:MenuElement({type = PARAM, id = "W", name = "Draw Wards", value = false, leftIcon = wardIcon})
--
---
local lastQ1=os.clock()
local lastQ2=os.clock()
local passive=false
local stacks=0
local kickToPos=mousePos
local target=nil
local ItemSlots={ITEM_1,ITEM_2,ITEM_3,ITEM_4,ITEM_5,ITEM_6,ITEM_7}
local ItemHotKeys={HK_ITEM_1,HK_ITEM_2,HK_ITEM_3,HK_ITEM_4,HK_ITEM_5,HK_ITEM_6,HK_ITEM_7}
local WardingItems={2055,2302,2301,2303,2049,2045,3711,1408,1409,1410,1418}
--------------------------------------------------------------------------------
--[[Rectangel]]--from fubman
--------------------------------------------------------------------------------
local function DrawLine3D(x,y,z,a,b,c,width,col)
  local p1 = Vector(x,y,z):To2D()
  local p2 = Vector(a,b,c):To2D()
  Draw.Line(p1.x, p1.y, p2.x, p2.y, width, col)
end

local function DrawRectangleOutline(a, b, width, col)--
  local startPos = a
  local endPos = b
  local c1 = startPos+Vector(Vector(endPos)-startPos):Perpendicular():Normalized()*width
  local c2 = startPos+Vector(Vector(endPos)-startPos):Perpendicular2():Normalized()*width
  local c3 = endPos+Vector(Vector(startPos)-endPos):Perpendicular():Normalized()*width
  local c4 = endPos+Vector(Vector(startPos)-endPos):Perpendicular2():Normalized()*width
  DrawLine3D(c1.x,c1.y,c1.z,c2.x,c2.y,c2.z,2,col)
  DrawLine3D(c2.x,c2.y,c2.z,c3.x,c3.y,c3.z,2,col)
  DrawLine3D(c3.x,c3.y,c3.z,c4.x,c4.y,c4.z,2,col)
  DrawLine3D(c1.x,c1.y,c1.z,c4.x,c4.y,c4.z,2,col)
end
---
---
---
local function GetSummonerSpellSlot(name)
	if myHero:GetSpellData(4).name==name then
		return SUMMONER_1
	elseif myHero:GetSpellData(5).name==name then
		return SUMMONER_2
	end
end

local function GetNumberOfTableElements(table)
	local kkk=0
	if table then
		if table[1] then
			for k,v in pairs(table) do
				kkk=kkk+1
			end
		end
	end
	return kkk
end

local function GetCD(x)
	return myHero:GetSpellData(x).currentCd
end

local function GetItemHotKey(item)
	for i=1,7 do
		if item==ItemSlots[i] then
			return ItemHotKeys[i]
		end
	end
end

local function GetSpellVersion(spell)
	if spell==_Q then
		if myHero:GetSpellData(spell).name==Q.name then
			return 1
		else
			return 2
		end
	elseif spell==_W then
		if myHero:GetSpellData(spell).name==W.name then
			return 1
		else
			return 2
		end
	elseif spell==_E then
		if myHero:GetSpellData(spell).name==E.name then
			return 1
		else
			return 2
		end
	end
end

local function GetWardingItemSlot()
	local itemm
	for i=1,7 do
		local slot=ItemSlots[i]
		local item=myHero:GetItemData(slot)
		local foundItem=false
		if myHero:GetSpellData(ITEM_7).ammo>0 and myHero:GetItemData(ITEM_7).itemID==3340 and GetCD(ITEM_7)==0 then
			foundItem=true
			itemm=ItemSlots[7]
		end
		if item.ammo~=0 and not foundItem and GetCD(ItemSlots[i])==0 then
			for k=1,GetNumberOfTableElements(WardingItems) do
				local ID=WardingItems[k]
				if item.itemID==ID then
					local
					foundItem=true
					itemm=ItemSlots[i]
				end
			end
		end
		if foundItem then
			break
		end
	end
	return itemm
end

local function Normalized2(what,x,to)
	local x=x or 1
	local asd=(what-to)
	asd=Vector(0,0,0)+asd
	asd=asd:Normalized()
	asd=asd*x
	asd=to+asd
	return asd
end

local function GetClosestAllyMinion(pos,range)
	local closest
	for i=1,Game.MinionCount() do
		local minion=Game.Minion(i)
		if minion.isAlly and not minion.dead and not minion.isImmortal then
			if pos:DistanceTo(Vector(minion.pos))<=range then
				if closest then
					if pos:DistanceTo(Vector(minion.pos))<pos:DistanceTo(Vector(closest.pos)) then
						closest=minion
					end
				else closest=minion end
			end
		end
	end
	return closest
end

local function GetClosestAllyWard(pos,range)
	local closest
	for i=1,Game.WardCount() do
		local ward=Game.Ward(i)
		if ward.isAlly and not ward.dead then
			if pos:DistanceTo(Vector(ward.pos))<=range then
				if closest then
					if pos:DistanceTo(Vector(ward.pos))<pos:DistanceTo(Vector(closest.pos)) then
						closest=ward
					end
				else closest=ward end
			end
		end
	end
	return closest
end

local function GetClosestAllyHero(pos,range)
	local closest
	for i=1,Game.HeroCount() do
		local hero=Game.Hero(i)
		if hero.isAlly and not hero.dead and not hero.isImmortal and not hero.isMe then
			if pos:DistanceTo(Vector(hero.pos))<=range then
				if closest then
					if pos:DistanceTo(Vector(hero.pos))<pos:DistanceTo(Vector(closest.pos)) then
						closest=hero
					end
				else closest=hero end
			end
		end
	end
	return closest
end

local function GetClosestAllyTurret(pos,range)
	local closest
	for i=1,Game.TurretCount() do
		local turret=Game.Turret(i)
		if turret.isAlly and not turret.dead and not turret.isImmortal and not turret.isMe then
			if pos:DistanceTo(Vector(turret.pos))<=range then
				if closest then
					if pos:DistanceTo(Vector(turret.pos))<pos:DistanceTo(Vector(closest.pos)) then
						closest=turret
					end
				else closest=turret end
			end
		end
	end
	return closest
end

local function GetBuffIndexByName(unit,name)
	for i=1,unit.buffCount do
		local buff=unit:GetBuff(i)
		if buff.name==name then
			return i
		end
	end
end

local function HasSonicMark(unit)
	if unit:GetBuff(GetBuffIndexByName(unit,"BlindMonkQOne")).duration>0.3 and unit.isEnemy then
		return true else return false
	end
end

local function CanBounceTo(pos,range)
	local hero=GetClosestAllyHero(pos,range)
	local ward=GetClosestAllyWard(pos,range)
	local minion=GetClosestAllyMinion(pos,range)
	local CanBounce=false
	if hero then
		CanBounce=true
	elseif ward then
		CanBounce=true
	elseif minion then
		CanBounce=true
	end
	return CanBounce
end

local function GetSonicMarkedUnit()
	local target
	for i=1,Game.HeroCount() do
		local a=Game.Hero(i)
		if a.isEnemy then
			if a.distance<=3000 then
				if not a.dead and not a.isImmortal then
					if HasSonicMark(a) then
						target=a
						break
					end
				end
			end
		end
	end
	if not target then
		for i=1,Game.MinionCount() do
			local a=Game.Minion(i)
			if a.isEnemy then
				if a.distance<=3000 then
					if not a.dead and not a.isImmortal then
						if HasSonicMark(a) then
							target=a
							break
						end
					end
				end
			end
		end
	end
	return target
end

local function isHero(unit)
	for i=1,Game.HeroCount() do
		local hero=Game.Hero(i)
		if hero.isEnemy then
			if hero==unit then
				return true
			else
				return false
			end
		end
	end
end

local function GetSmiteDamage()
	local damage={390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}
	return damage[myHero.levelData.lvl]
end

local function CastQ(who)
	if who then
		if not who.dead and not who.isImmortal then
			local smite=GetSummonerSpellSlot("SummonerSmite")
			local smiteK
			if smite==4 then smiteK=HK_SUMMONER_1 else smiteK=HK_SUMMONER_2 end
			local pred=who:GetPrediction(Q.speed,Q.delay)
			local block, list = QSpell:__GetCollision(myHero, pred, 5,who)
			if Game.CanUseSpell(_Q)==READY and GetSpellVersion(_Q)==1 and Vector(myHero.pos):DistanceTo(pred)<=Q.range then
				if GetNumberOfTableElements(list)==0 then
					Control.CastSpell(HK_Q,pred)
					lastQ1=os.clock()
				elseif smite and LeeSinMenu.SmiteQ:Value() then
					if Game.CanUseSpell(smite)==READY then
						if GetNumberOfTableElements(list)==1 then
							local dude=list[1]
							if not dude.dead and not dude.isImmortal and not isHero(dude) then
								if dude.health<=GetSmiteDamage() and dude.distance<=500 then
									Control.CastSpell(HK_Q,pred)
									lastQ1=os.clock()
									DelayAction(function()Control.CastSpell(smiteK,dude)end,0.1)
								end
							end
						end
					end
				end
			elseif Game.CanUseSpell(_Q)==READY and GetSonicMarkedUnit()==who and GetSpellVersion(_Q)==2 and who.distance<=1300 then
				Control.CastSpell(HK_Q)
				lastQ2=os.clock()
			end
		end
	end
end

local function GetClosestAllyTurret(pos,range)
	local closest
	for i=1,Game.TurretCount() do
		local turret=Game.Turret(i)
		if turret.isAlly and not turret.dead and not turret.isImmortal then
			if pos:DistanceTo(Vector(turret.pos))<=range then
				if closest then
					if pos:DistanceTo(Vector(turret.pos))<pos:DistanceTo(Vector(closest.pos)) then
						closest=turret
					end
				else closest=turret end
			end
		end
	end
	return closest
end

local function GetKickEndPos(targetx,from)
	local from=from or Vector(myHero.pos)
	local targetx=targetx or target
	return Normalized2(Vector(targetx.pos),from:DistanceTo(Vector(targetx.pos))+700,from)
end

local lastWarding=os.clock()-10
local lastWardingPos=mousePos
local function WardJump(pos,source,r)
	local source=source or false
	local r=r or 100
	if not source then
		if pos:DistanceTo(Vector(myHero.pos))<=640 then
			if LeeSinMenu.WardJump.AMR:Value() then
				pos=Normalized2(pos,640,myHero.pos)
			else
				pos=pos
			end
		elseif LeeSinMenu.WardJump.AW:Value() then
			pos=Normalized2(pos,640,myHero.pos)
		else
			pos=pos
		end
	else
		pos=pos
	end
	if pos:DistanceTo(Vector(myHero.pos))<=640 and pos:DistanceTo(Vector(myHero.pos))>100 then
		if GetCD(_W)==0 and GetSpellVersion(_W)==1 and not MapPosition:inWall(pos) then
			if os.clock()-lastWarding<0.3 then
				Control.CastSpell(HK_W,lastWardingPos)
			else
				local WardingItem=GetWardingItemSlot()
				local ward=GetClosestAllyWard(pos,r)
				local minion=GetClosestAllyMinion(pos,r)
				local hero=GetClosestAllyHero(pos,r)
				if hero then
					Control.CastSpell(HK_W,hero.pos)
					lastWarding=os.clock()
					lastWardingPos=pos
				elseif ward then
					Control.CastSpell(HK_W,ward.pos)
					lastWarding=os.clock()
					lastWardingPos=pos
				elseif minion then
					Control.CastSpell(HK_W,minion.pos)
					lastWarding=os.clock()
					lastWardingPos=pos
				elseif WardingItem then
					Control.CastSpell(GetItemHotKey(WardingItem),pos)
					lastWarding=os.clock()
					lastWardingPos=pos
				end
			end
		end
	end
end

local function InSec(posx)
	if target and Game.CanUseSpell(_R)==READY then
		local WardingItem=GetWardingItemSlot()
		local pos=Normalized2(Vector(target.pos),posx:DistanceTo(Vector(target.pos))+300,posx)
		local pos2=Normalized2(Vector(target.pos),posx:DistanceTo(Vector(target.pos))-700,posx)
		if Vector(myHero.pos):DistanceTo(pos)<=600 and not MapPosition:inWall(pos) then
			if GetKickEndPos(target):DistanceTo(pos2)>300 or Vector(myHero.pos):DistanceTo(pos)>=100 then
				WardJump(pos,true,150)
			end
			if GetKickEndPos(target):DistanceTo(pos2)<=300 then
				Control.CastSpell(HK_R,target)
			end
		elseif Game.CanUseSpell(_W) and GetSpellVersion(_W)==1 and WardingItem then
			CastQ(target)
		end
	end
end

--[[local function SimpleKick(posx)
	if target then
		local pos=Normalized2(Vector(target.pos),posx:DistanceTo(Vector(target.pos))+200,posx)
		local pos2=Normalized2(Vector(target.pos),posx:DistanceTo(Vector(target.pos))-700,posx)
		if GetKickEndPos():DistanceTo(pos2)<=150 then
			if Game.CanUseSpell(_R)==READY then
				Control.CastSpell(HK_R,target)
			end
		end
	end
end]]

local function FlashKick(posx)
	local flash=GetSummonerSpellSlot("SummonerFlash")
	if target and Game.CanUseSpell(_R)==READY then
		if flash then
			local flashk
			if flash==4 then flashk=HK_SUMMONER_1 else flashk=HK_SUMMONER_2 end
			local pos=Normalized2(Vector(target.pos),posx:DistanceTo(Vector(target.pos))+180,posx)
			local pos2=Normalized2(Vector(target.pos),posx:DistanceTo(Vector(target.pos))-700,posx)
			if Vector(myHero.pos):DistanceTo(pos)<=360 and Vector(myHero.pos):DistanceTo(Vector(target.pos))<=R.range then
				if GetKickEndPos(target):DistanceTo(pos2)<=300 then
					Control.CastSpell(HK_R,target)
				elseif Game.CanUseSpell(flash)==READY and not MapPosition:inWall(pos) then
					Control.CastSpell(HK_R,target)
					DelayAction(function()Control.CastSpell(flashk,pos)end,0.2)
				end
			elseif Game.CanUseSpell(flash)==READY and not MapPosition:inWall(pos) then
				CastQ(target)
			end
		end
	end
end

local function GetPassive()
	if myHero:GetBuff(GetBuffIndexByName(myHero,P.name)).duration>0.3 and myHero:GetBuff(GetBuffIndexByName(myHero,P.name)).count>0 then
		return true,myHero:GetBuff(GetBuffIndexByName(myHero,P.name)).count
	else 
		return false,0
	end
end

local function CanQ(who)
	if who then
		if not who.dead and not who.isImmortal then
			if who.distance<=Q.range then
				local pred=who:GetPrediction(Q.speed,Q.delay)
				if Game.CanUseSpell(_Q)==READY and GetSpellVersion(_Q)==1 and pred:DistanceTo(Vector(myHero.pos))<=Q.range then
					local block, list = QSpell:__GetCollision(myHero, pred, 5,who)
					if not block then
						return true
					elseif smite and LeeSinMenu.SmiteQ:Value() then
						if Game.CanUseSpell(smite)==READY then
							if GetNumberOfTableElements(list)==1 then
								local dude=list[1]
								if not dude.dead and not dude.isImmortal and not isHero(dude) then
									if dude.health<=GetSmiteDamage() and dude.distance<=500 then
										return true
									end
								end
							end
						end
					else return false end
				elseif Game.CanUseSpell(_Q)==READY and GetSonicMarkedUnit()==who and GetSpellVersion(_Q)==2 and who.distance<=1300 then
					return true
				end
			end
		end
	end
	return false
end

local function CanE(who)
	if who then
		if not who.dead and not who.isImmortal then
			if Game.CanUseSpell(_E)==READY and GetSpellVersion(_E)==1 and who.distance<=E.range then
				return true
			elseif Game.CanUseSpell(_E)==READY and GetSpellVersion(_E)==2 then
				return true
			end
		end
	end
	return false
end

local function CastW()
	if Game.CanUseSpell(_W)==READY and GetSpellVersion(_W)==1 then
		Control.CastSpell(HK_W,myHero)
	elseif Game.CanUseSpell(_W)==READY and GetSpellVersion(_W)==2 then
		Control.CastSpell(HK_W)
	end
end

local function CanW()
	if Game.CanUseSpell(_W)==READY and GetSpellVersion(_W)==1 then
		return true
	elseif Game.CanUseSpell(_W)==READY and GetSpellVersion(_W)==2 then
		return true
	end
	return false
end

local function DefaultCombo(who)
	if LeeSinMenu.Combo.Q:Value() and CanQ(who) then
		CastQ(who)
	elseif who.distance<=600 then
		if LeeSinMenu.Combo.P:Value() and passive then
		elseif LeeSinMenu.Combo.E:Value() and CanE(who) then
			Control.CastSpell(HK_E)
		elseif LeeSinMenu.Combo.W:Value() and CanW() and who.distance<=200 then
			CastW()
		end
	elseif LeeSinMenu.Combo.WJ:Value() and os.clock()-lastQ2>=1 and os.clock()-lastQ1>=1 then
		local pos=Normalized2(Vector(target.pos),target.distance-220,Vector(myHero.pos))
		WardJump(pos,true,300)
	end
end

local function GetClosestMonster()
	local monsters=_G.SDK.ObjectManager:GetMonsters(Q.range-200)
	if GetNumberOfTableElements(monsters)>=1 then
		local closest=monsters[1]
		for k,monster in pairs(monsters) do
			if monster.distance<closest.distance and not monster.dead and not monster.isImmortal then
				closest=monster
			end
		end
		return closest
	end
end

local function JungleClear(who)
	if LeeSinMenu.JungleClear.Q:Value() and CanQ(who) then
			CastQ(who)
	elseif who.distance<=600 then
		if LeeSinMenu.JungleClear.P:Value() and passive then
		elseif LeeSinMenu.JungleClear.E:Value() and CanE(who) then
			Control.CastSpell(HK_E)
		elseif LeeSinMenu.JungleClear.W:Value() and CanW() and who.distance<=200 then
			CastW()
		end
	end
end
--
local checktime=os.clock()-10
function OnTick()
	if os.clock()-checktime>=0.2 then
		passive,stacks=GetPassive()
		checktime=os.clock()
	end
	target=_G.SDK.TargetSelector:GetTarget(Q.range*1.5)
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and target then
		DefaultCombo(target)
	end
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
		local monster=GetClosestMonster()
		if monster then
			JungleClear(monster)
		end
	end
	--
	if LeeSinMenu.KillSecure.Q:Value() or LeeSinMenu.KillSecure.E:Value() or LeeSinMenu.KillSecure.R:Value() then
		for i=1,Game.HeroCount() do
			local hero=Game.Hero(i)
			if hero.distance<=2000 and hero.isEnemy then
				if not hero.dead and not hero.isImmortal and hero.visible then
					if LeeSinMenu.KillSecure.E:Value() and hero.distance<=E.range then
						local e=getdmg("E",hero)
						if hero.health<e then
							if CanE(hero) then
								Control.CastSpell(HK_E)
							end
						end
					end
					if LeeSinMenu.KillSecure.Q:Value() and hero.distance<=Q.range then
						local q1=getdmg("Q",hero,myHero,1)
						local q2=getdmg("Q",hero,myHero,2)
						if (hero.health<q1+q2) and GetSpellVersion(_Q)==1 then
							CastQ(hero)
						elseif hero.health<q2 and GetSpellVersion(_Q)==2 then
							CastQ(hero)
						end
					end
					if LeeSinMenu.KillSecure.R:Value() and hero.distance<=R.range then
						local r=getdmg("R",hero)
						if hero.health<r then
							Control.CastSpell(HK_R,hero)
						end
					end
				end
			end
		end
	end
	--
	if LeeSinMenu.InSec.PosKey:Value() then
		kickToPos=mousePos
	end
	if LeeSinMenu.WardJump.Key:Value(+) then
		WardJump(mousePos)
	end
	--if LeeSinMenu.InSec.SimpleKickS:Value() then
		--SimpleKick(kickToPos)
	--end
	if LeeSinMenu.InSec.FlashKickS:Value() then
		FlashKick(kickToPos)
	end
	if LeeSinMenu.InSec.InSecS:Value() then
		InSec(kickToPos)
	end
end
local screenX,screenY=Game.Resolution().x,Game.Resolution().y
function OnDraw()
	Draw.Circle(kickToPos,200,Draw.Color(255,255, 153, 0))
	Draw.Circle(kickToPos,100)--
	if not myHero.dead and not myHero.isImmortal then
		if LeeSinMenu.Drawings.W:Value() then
			for i=1,Game.WardCount() do
				local ward=Game.Ward(i)
				if not ward.dead and ward.distance<=1300 then
					Draw.Circle(ward.pos,100)
				end
			end
		end
		if LeeSinMenu.Drawings.WJR:Value() and Game.CanUseSpell(_W)==READY and GetSpellVersion(_W)==1 then
			Draw.Circle(myHero.pos,640)--wardjump range
		end
		if LeeSinMenu.Drawings.KP:Value() and Game.CanUseSpell(_R)==READY and target then
			--for i=1,Game.HeroCount() do
				local hero=target
				if hero.isEnemy and not hero.dead and not hero.isImmortal then
					DrawRectangleOutline(GetKickEndPos(hero),Vector(hero.pos),100)
					Draw.Circle(GetKickEndPos(hero),100)
				end
			--end
		end
		if LeeSinMenu.Drawings.ISJP:Value() and Game.CanUseSpell(_W)==READY and GetSpellVersion(_W)==1 and target then
			--for i=1,Game.HeroCount() do
				local hero=target
				if hero.isEnemy and not hero.dead and not hero.isImmortal then
					local pos=Normalized2(Vector(hero.pos),kickToPos:DistanceTo(Vector(hero.pos))+350,kickToPos)
					DrawRectangleOutline(pos,Vector(hero.pos),100)
				end
			--end
		end
	end
end
--
print(".")
