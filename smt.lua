Google Tradutor
Texto original
SmiteMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})
Sugerir uma tradução melhor
Local mapID = Game.mapID;
If mapID ~ = SUMMONERS_RIFT então
	Retorna
fim

Local SmiteMenu = MenuElement ({type = MENU, id = "SmiteMenu", name = "Auto Smite & Marcadores", leftIcon = "http://puu.sh/rPsnZ/a05d0f19a8.png"})
SmiteMenu: MenuElement ({id = "Enabled", name = "Enabled", value = true})
SmiteMenu: MenuElement ({type = MENU, id = "SmiteMarker", name = "Smite Marcador Minions"})
SmiteMenu.SmiteMarker: MenuElement ({id = "Enabled", name = "Enabled", value = true})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkBaron", name = "Mark Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkHerald", name = "Mark Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkDragon", name = "Mark Dragon", valor = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkBlue", name = "Mark Blue Buff", value = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkRed", name = "Mark Red Buff", value = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkGromp", name = "Mark Gromp", value = true, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkWolves", name = "Mark Wolves", value = true, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkRazorbeaks", name = "Mark Razorbeaks", value = true, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkKrugs", name = "Mark Krugs", value = true, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
SmiteMenu.SmiteMarker: MenuElement ({id = "MarkCrab", name = "Mark Crab", value = true, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
SmiteMenu: MenuElement ({type = MENU, id = "AutoSmiter", nome = "Auto Smite Minions"})
SmiteMenu.AutoSmiter: MenuElement ({id = "Enabled", name = "Enabled", value = true})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteBaron", name = "Smite Baron", value = true, leftIcon = "http://puu.sh/rPuVv/933a78e350.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteHerald", name = "Smite Herald", value = true, leftIcon = "http://puu.sh/rQs4A/47c27fa9ea.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteDragon", name = "Dragão Smite", value = true, leftIcon = "http://puu.sh/rPvdF/a00d754b30.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteBlue", name = "Smite Blue Buff", valor = true, leftIcon = "http://puu.sh/rPvNd/f5c6cfb97c.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteRed", name = "Smite Red Buff", valor = true, leftIcon = "http://puu.sh/rPvQs/fbfc120d17.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteGromp", name = "Smite Gromp", valor = falso, leftIcon = "http://puu.sh/rPvSY/2cf9ff7a8e.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteWolves", name = "Smite Wolves", value = false, leftIcon = "http://puu.sh/rPvWu/d9ae64a105.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteRazorbeaks", name = "Smite Razorbeaks", value = false, leftIcon = "http://puu.sh/rPvZ5/acf0e03cc7.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteKrugs", name = "Smite Krugs", valor = false, leftIcon = "http://puu.sh/rPw6a/3096646ec4.png"})
SmiteMenu.AutoSmiter: MenuElement ({id = "SmiteCrab", name = "Smite Crab", value = false, leftIcon = "http://puu.sh/rPwaw/10f0766f4d.png"})
SmiteMenu: MenuElement ({type = MENU, id = "AutoSmiterH", nome = "Auto Smite Heroes"})
SmiteMenu.AutoSmiterH: MenuElement ({id = "Enabled", name = "Enabled", value = true, leftIcon = "http://puu.sh/rTVac/7ed9f87157.png"})


Local MarkTable = {
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

Local SmiteTable = {
	SRU_Baron = "SmiteBaron",
	SRU_RiftHerald = "SmiteHerald",
	SRU_Dragon_Water = "SmiteDragon",
	SRU_Dragon_Fire = "SmiteDragon",
	SRU_Dragon_Earth = "SmiteDragon",
	SRU_Dragon_Air = "SmiteDragon",
	SRU_Dragon_Elder = "SmiteDragon",
	SRU_Blue = "SmiteBlue",
	SRU_Red = "SmiteRed"
	SRU_Gromp = "SmiteGromp",
	SRU_Murkwolf = "SmiteWolves",
	SRU_Razorbeak = "SmiteRazorbeaks",
	SRU_Krug = "SmiteKrugs",
	Sru_Crab = "SmiteCrab",
}

Local SmiteNames = {'SummonerSmite', 'S5_SummonerSmiteDuel', 'S5_SummonerSmitePlayerGanker', 'S5_SummonerSmiteQuick', 'ItemSmiteAoE'};
Local SmiteDamage = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000};
Local mySmiteSlot = 0;
--20 + 8 * GetLevel (myHero) 


Função local GetSmite (smiteSlot)
	Local returnVal = 0;
	Local spellName = myHero: GetSpellData (smiteSlot) .name;
	Para i = 1, 5
		If spellName == SmiteNames [i] então
			ReturnVal = smiteSlot
		fim
	fim
	Return returnVal;
fim

Função OnLoad ()
	MySmiteSlot = GetSmite (SUMMONER_1);
	Se mySmiteSlot == 0 então
		MySmiteSlot = GetSmite (SUMMONER_2);
	fim
fim

Função local DrawSmiteableMinion (tipo, minion)
	Se não tipo ou não SmiteMenu.SmiteMarker [tipo] então
		Retorna
	fim
	Se SmiteMenu.SmiteMarker [type]: Value () então
		Se minion.pos2D.onScreen então
			Draw.Circle (minion.pos, minion.boundingRadius, 6, Draw.Color (0xFF00FF00));
		fim
	fim
fim

Função local AutoSmiteMinion (tipo, minion)
	Se não tipo ou não SmiteMenu.AutoSmiter [tipo] então
		Retorna
	fim
	Se SmiteMenu.AutoSmiter [type]: Value () então
		Se minion.pos2D.onScreen então
			Se mySmiteSlot == SUMMONER_1 então
				Control.CastSpell (HK_SUMMONER_1, minion)
			outro
				Control.CastSpell (HK_SUMMONER_2, minion)
			fim
		fim
	fim
fim


Função OnDraw ()
Se myHero.alive == false então return end
	Se SmiteMenu.Enabled: Value () e (mySmiteSlot> 0) então
		Se SmiteMenu.SmiteMarker.Enabled: Value () ou SmiteMenu.AutoSmiter.Enabled: Valor () então
			Local SData = myHero: GetSpellData (mySmiteSlot);
			Para i = 1, Game.MinionCount () fazer
				Minion = Game.Minion (i);
				Se minion e minion.valid e (minion.team == 300) e minion.visible então
					Se minion.health <= SmiteDamage [myHero.levelData.lvl] então
						Local minionName = minion.charName;
						Se SmiteMenu.SmiteMarker.Enabled: Value () então
							DrawSmiteableMinion (MarkTable [minionName], minion);
						fim
						Se SmiteMenu.SmiteMarker.Enabled: Value () então
							Se mySmiteSlot> 0 então
								Se SData.level> 0 então
									If (SData.ammo> 0) then
										Se minion.distance <= (500 + myHero.boundingRadius + minion.boundingRadius) então
											AutoSmiteMinion (SmiteTable [minionName], minion);
										fim
									fim
								fim
							fim
						fim
					fim
				fim
			fim
		fim
		Se SmiteMenu.AutoSmiterH.Enabled: Valor () então
			Local smiteDmg = 20 + 8 * myHero.levelData.lvl;
			Local SData = myHero: GetSpellData (mySmiteSlot);
			Se SData.name == SmiteNames [3] então
				Se SData.level> 0 então
					If (SData.ammo> 0) then
						Para i = 1, Game.HeroCount () fazer
							Herói = Game.Hero (i);
							Se herói e hero.valid e hero.visible e hero.isEnemy e (hero.distance <= (500 + myHero.boundingRadius + hero.boundingRadius)) e (hero.health <= smiteDmg) então
								Se mySmiteSlot == SUMMONER_1 então
									Control.CastSpell (HK_SUMMONER_1, herói)
								outro
									Control.CastSpell (HK_SUMMONER_2, herói)
								fim
							fim
						fim
					fim
				fim
			fim
		fim
	fim
fim


--PrintChat ("Smite gerenciador por Feretorix carregado.")
