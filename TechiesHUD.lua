local TechiesHUD = {}

TechiesHUD.optionTotal = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD" }, "TechiesHUD", "Activating the script")

TechiesHUD.optionDetonate = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Action" }, "Auto mines", "Auto detonate remote mines")

TechiesHUD.optionDelay = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Action" }, "Delay detonate ms", "wait some time after detonate in ms", 0, 3000, 50)

TechiesHUD.optionStack = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Action" }, "Stack mines", "Automatically puts mines as close as possible to each other")

TechiesHUD.optionStackRange = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Action" }, "Range Stack mines", "The radius at which nearby mines will be placed on the nearest mine", 0, 500, 10)

TechiesHUD.optionForce = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Action" }, "Auto force stuff", "Automatically use force stuff")

TechiesHUD.optionLR = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display" }, "Land mines range", "Draw the radius of land mines")

TechiesHUD.optionSR = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display" }, "Stasis mines range", "Draw the radius of stasis mines")

TechiesHUD.optionRR = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display" }, "Remote mines range", "Remote the radius of land mines")

TechiesHUD.optionPanelInfo = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display" }, "Panel", "Panel showing the number of mines for killing")

TechiesHUD.optionPanelInfoXL = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display", "Panel calibration" }, "x left", "horizontal offset", -100, 100, 1)

TechiesHUD.optionPanelInfoXR = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display", "Panel calibration" }, "x right", "horizontal offset", -100, 100, 1)

TechiesHUD.optionPanelInfoY = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display", "Panel calibration" }, "y", "vertical offset", -20, 100, 1)

TechiesHUD.optionPanelInfoDistLeft = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display", "Panel calibration" }, "distance left", "Distance between blocks radiant", -20, 1000, 1)

TechiesHUD.optionPanelInfoDistRight = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display", "Panel calibration" }, "distance right", "Distance between blocks dire", -20, 1000, 1)

TechiesHUD.optionBlastInfo = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display" }, "Blast info", "Displays the damage needed to kill")

TechiesHUD.optionFont = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display" }, "Font1", "Num mines, need blast damage, timers and etc", 10, 100, 1)

TechiesHUD.optionFontTopBar = Menu.AddOption({ "Hero Specific", "Techies", "TechiesHUD", "Display" }, "Font2", "Top bar", 10, 100, 1)

TechiesHUD.font = Renderer.LoadFont("Tahoma", Config.ReadInt("TechiesHUD", "font", 10), Enum.FontWeight.EXTRABOLD)

TechiesHUD.HUDfont = Renderer.LoadFont("Tahoma",  Config.ReadInt("TechiesHUD", "Bar_font", 15), Enum.FontWeight.BOLD)

mines_time = {} 
mines_damage = {}
hero_time = {}
hero_rotate_time = {}
check_detonate = {}
forc_time = 0
forced_time = 0
force_direction = {}
castPosit = {}
for i = 0, 10000 do
	mines_time[i] = 0
	hero_time[i] = 0
	force_direction[i] = 0
	hero_rotate_time[i] = 0
end

-- function TechiesHUD.OnUnitAnimation(animation)
	
	-- local myHero = Heroes.GetLocal()

	-- if not myHero then 
		-- return 
	-- end
	
	-- if NPC.GetUnitName(myHero) ~= "npc_dota_hero_techies" then 
		-- return 
	-- end
	
	-- if NPC.GetUnitName(animation.unit) ~= "npc_dota_hero_techies" then
		-- return
	-- end
	-- Log.Write("da")
	-- castBlast = 1
	-- castPosit = animation.castpoint
-- end

-- function TechiesHUD.OnUnitAnimationEnd(animation)

	-- -- if "npc_dota_hero_techies" ~= NPC.GetUnitName(animation.unit) then
		-- -- return
	-- -- end
	-- Log.Write("end")
	-- -- if castBlast == 1 then
		-- -- castBlast = 0
	-- -- end
-- end


function TechiesHUD.OnMenuOptionChange(option, oldValue, newValue)
	--Log.Write(option)
	if option == 18 then
		TechiesHUD.font = Renderer.LoadFont("Tahoma", newValue, Enum.FontWeight.EXTRABOLD)
		Config.WriteInt("TechiesHUD", "font", newValue)
	end
	if option == 19 then
		TechiesHUD.HUDfont = Renderer.LoadFont("Tahoma", newValue, Enum.FontWeight.EXTRABOLD)
		Config.WriteInt("TechiesHUD", "Bar_font", newValue)
	end
end

function TechiesHUD.OnEntityCreate(ent)
	if not Menu.IsEnabled(TechiesHUD.optionTotal) then return end
	if not Menu.IsEnabled(TechiesHUD.optionStack) then return end
	
	if (ent ~= nil) 
	and Entity.IsNPC(ent)
	and not NPC.IsCreep(ent)
	then
		mines_damage[Entity.GetIndex(ent)] = -1
	end
end

function DrawCircle(UnitPos, radius)
	local x1,y1,visible1 = Renderer.WorldToScreen(UnitPos)
	local x4, y4, x3, y3, visible3
	local dergee = 15
	for angle = 0, 360 / dergee do
		x4 = 0 * math.cos(angle * dergee / 57.3) - radius * math.sin(angle * dergee / 57.3) 
		y4 = radius * math.cos(angle * dergee / 57.3) + 0 * math.sin(angle * dergee / 57.3)
		x3,y3,visible3 = Renderer.WorldToScreen(UnitPos + Vector(x4,y4,0))
		Renderer.DrawLine(x1,y1,x3,y3)
		x1,y1,visible1 = Renderer.WorldToScreen(UnitPos + Vector(x4,y4,0))
	end
end

function TechiesHUD.OnDraw()
	if not Menu.IsEnabled(TechiesHUD.optionTotal) then return end
	
	local myHero = Heroes.GetLocal()

	if not myHero then 
		return 
	end
	
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_techies" then 
		return 
	end
	
	local land_m = NPC.GetAbilityByIndex(myHero, 0)
	local trap_m = NPC.GetAbilityByIndex(myHero, 1)
	local blast = NPC.GetAbilityByIndex(myHero, 2)
	local remote = NPC.GetAbilityByIndex(myHero, 5)
	
	local force = NPC.GetItem(myHero, "item_force_staff", 1)
	
	local land_m_damage = Ability.GetLevelSpecialValueFor(land_m, "damage")
	local blast_damage = Ability.GetLevelSpecialValueFor(blast, "damage") + Ability.GetLevel(NPC.GetAbilityByIndex(myHero, 11)) * 400
	
	local magicalDamageMul = 1 + Hero.GetIntellectTotal(myHero)/ 16 / 100
	--if (NPC.HasItem(myHero, "item_ultimate_scepter", 1)) then
	local remote_damage = Ability.GetLevelSpecialValueFor(remote, "damage")
	--else
	--	remote_damage = Ability.GetLevelSpecialValueFor(remote, "damage")
	--end
	
	if Ability.IsInAbilityPhase(blast) then
		Renderer.SetDrawColor(255, 255, 255, 255)
		DrawCircle(castPosit, 400)
	end
	
	for i = 0, NPCs.Count() do
		local Unit = NPCs.Get(i)
		local UnitPos = Entity.GetAbsOrigin(Unit)	
		
		if Menu.IsEnabled(TechiesHUD.optionLR) then 
			if (NPC.GetUnitName(Unit) == "npc_dota_techies_land_mine") and Entity.IsAlive(Unit) then -- activate range land mines
				
				Renderer.SetDrawColor(255, 20, 0, 255)
				DrawCircle(UnitPos, 400)
				if (GameRules.GetGameTime() - Modifier.GetCreationTime(NPC.GetModifier(Unit, "modifier_techies_land_mine")) < 1.75) then
					local x, y, visible = Renderer.WorldToScreen(UnitPos)
					Renderer.DrawText(TechiesHUD.font, x, y, math.floor((1.75 - (GameRules.GetGameTime() - Modifier.GetCreationTime(NPC.GetModifier(Unit, "modifier_techies_land_mine")))) * 100) / 100, 0)
				else
					local check_loop = 0
					for j = 0, NPCs.Count() do
						local Unit2 = NPCs.Get(j)
						if  Entity.IsNPC(Unit2)
						and Entity.GetTeamNum(Unit2) ~= Entity.GetTeamNum(myHero)
						--and Entity.IsHero(Unit2)
						and Entity.GetHealth(Unit2) > 0 
						then
							if (NPC.IsPositionInRange(Unit2, Entity.GetAbsOrigin(Unit), 400, 0)) then
								--if (proximity_threshold)
								check_loop = 1
								local x, y, visible = Renderer.WorldToScreen(UnitPos)
								if (mines_time[Entity.GetIndex(Unit)] <= 0) then
									mines_time[Entity.GetIndex(Unit)] = GameRules.GetGameTime()
								end
								if (1.6 - (GameRules.GetGameTime() - mines_time[Entity.GetIndex(Unit)]) > 0) then
									Renderer.SetDrawColor(255, 255, 255, 255)
									Renderer.DrawText(TechiesHUD.font, x, y, math.floor((1.61 - (GameRules.GetGameTime() - mines_time[Entity.GetIndex(Unit)])) * 100) / 100, 0)
								end
							end
						end
					end
					if (check_loop == 0) then
						mines_time[Entity.GetIndex(Unit)] = 0
					end
				end
			end -- activate range land mines
		end
		
		if Menu.IsEnabled(TechiesHUD.optionSR) then 
			if (NPC.GetUnitName(Unit) == "npc_dota_techies_stasis_trap") and Entity.IsAlive(Unit)then --activate range stasis
				
				Renderer.SetDrawColor(0, 0, 255, 255)
				DrawCircle(UnitPos, 400)
				if (NPC.GetModifier(Unit, "modifier_techies_stasis_trap") ~= nil) then
					if (GameRules.GetGameTime() - Modifier.GetCreationTime(NPC.GetModifier(Unit, "modifier_techies_stasis_trap")) < 2) then
						local x, y, visible = Renderer.WorldToScreen(UnitPos)
						Renderer.DrawText(TechiesHUD.font, x, y, math.floor((2 - (GameRules.GetGameTime() - Modifier.GetCreationTime(NPC.GetModifier(Unit, "modifier_techies_stasis_trap")))) * 100)/100, 0)
					end
				end
			end --activate range stasis
		
			if (NPC.GetUnitName(Unit) == "npc_dota_techies_stasis_trap") and Entity.IsAlive(Unit)then --stun range stasis
				Renderer.SetDrawColor(0, 255, 255, 255)
				DrawCircle(UnitPos, 600)
			end --stun range stasis
		end
		
		
		if (NPC.GetUnitName(Unit) == "npc_dota_techies_remote_mine") and Entity.IsAlive(Unit)then --remote range
			
			if (mines_damage[Entity.GetIndex(Unit)] == nil or mines_damage[Entity.GetIndex(Unit)] == -1) then
				mines_damage[Entity.GetIndex(Unit)] = remote_damage
			end
			
			if Menu.IsEnabled(TechiesHUD.optionRR) then 
				Renderer.SetDrawColor(0, 255, 0, 255)
				DrawCircle(UnitPos, 425)
				
				Renderer.SetDrawColor(255, 255, 255, 255)
				local x, y, visible = Renderer.WorldToScreen(UnitPos)
				--Renderer.DrawText(TechiesHUD.font, x, y, mines_damage[Entity.GetIndex(Unit)], 0)
				
				local num_mines = 1;
				for j = 0, NPCs.Count() do
					local Unit2 = NPCs.Get(j)
					local UnitPos2 = Entity.GetAbsOrigin(Unit2)	
					if ((NPC.GetUnitName(Unit2) == "npc_dota_techies_remote_mine") 
					and Entity.IsAlive(Unit2) 
					and NPC.IsPositionInRange(Unit2, UnitPos, 425, 0)) 
					and NPC.GetModifier(Unit2, "modifier_techies_remote_mine") ~= nil
					and i ~= j
					then
						num_mines = num_mines + 1
					end
				end
				
				Renderer.DrawText(TechiesHUD.font, x, y, num_mines, 0)
			end
			
			
		end --remote range
		
		
		
		if  Entity.IsNPC(Unit) --blast damage display
		and Entity.GetTeamNum(Unit) ~= Entity.GetTeamNum(myHero)
		and Entity.IsHero(Unit)
		and Entity.GetHealth(Unit) > 0 
		then
			if Menu.IsEnabled(TechiesHUD.optionBlastInfo) then
				if Ability.GetLevel(blast) ~= 0 then
					local Hp = (Entity.GetHealth(Unit) + NPC.GetHealthRegen(Unit) * 2.5) - blast_damage * NPC.GetMagicalArmorDamageMultiplier(Unit) * magicalDamageMul
					
					if Hp > 0 then 
						Renderer.SetDrawColor(255, 0, 0, 255)
					else
						Renderer.SetDrawColor(0, 255, 0, 255)
					end
					local x, y, visible = Renderer.WorldToScreen(UnitPos)
					if visible then 
						Renderer.DrawText(TechiesHUD.font, x, y, math.ceil(Hp), 0)
						if ((Menu.GetValue(TechiesHUD.optionDelay) / 1000) + 0.25 - (GameRules.GetGameTime() - hero_time[i]) > 0) then
							Renderer.SetDrawColor(255, 255, 255, 255)
							Renderer.DrawText(TechiesHUD.font, x, y - 15, math.floor(((Menu.GetValue(TechiesHUD.optionDelay) / 1000) + 0.25 - (GameRules.GetGameTime() - hero_time[i])) * 100) / 100, 0)
						end
					end
				end
			end
			
			if Menu.IsEnabled(TechiesHUD.optionForce) then
				if (force ~= nil) then
					
					if (hero_time[i] == 1 and forced_time ~= 0 and GameRules.GetGameTime() - forced_time > 1) then
						hero_time[i] = 0
						forced_time = 0
					end
					
					Renderer.SetDrawColor(255, 255, 255, 255)
					
					local rotate = Entity.GetAbsRotation(Unit):GetYaw()
					
					x4 = 600 * math.cos(rotate / 57.3) - 0 * math.sin(rotate / 57.3)
					y4 = 0 * math.cos(rotate / 57.3) + 600 * math.sin(rotate / 57.3)
					x3,y3,visible3 = Renderer.WorldToScreen(UnitPos + Vector(x4,y4,0))
					
					local remote_sum_damage = 0
					for j = 0, NPCs.Count() do
						local Unit2 = NPCs.Get(j)
						local UnitPos2 = Entity.GetAbsOrigin(Unit2)	
						if ((NPC.GetUnitName(Unit2) == "npc_dota_techies_remote_mine") 
						and Entity.IsAlive(Unit2) 
						and NPC.IsPositionInRange(Unit2, UnitPos + Vector(x4,y4,0), 425 - NPC.GetMoveSpeed(Unit) * 0.1, 0)) 
						and NPC.GetModifier(Unit2, "modifier_techies_remote_mine") ~= nil
						then
							if (mines_damage[Entity.GetIndex(Unit)] == nil or mines_damage[Entity.GetIndex(Unit)] == -1) then
								mines_damage[Entity.GetIndex(Unit)] = remote_damage
							end
							remote_sum_damage = remote_sum_damage + mines_damage[Entity.GetIndex(Unit2)] + 150 * (NPC.HasItem(myHero, "item_ultimate_scepter", 1) and 1 or 0)
						end
					end
					if (NPC.IsPositionInRange(myHero, UnitPos, 1000, 0))
					and (remote_sum_damage * NPC.GetMagicalArmorDamageMultiplier(Unit) > Entity.GetHealth(Unit) and GameRules.GetGameTime() - forc_time > 0.5) then
						if (force_direction[i] == 0) then
							force_direction[i] = GameRules.GetGameTime()
						end
						if (force_direction[i] ~= 0 and GameRules.GetGameTime() - force_direction[i] > 0.5) then
							Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, Unit, Vector(0, 0, 0), force, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero, 0, 0)
							forc_time = GameRules.GetGameTime()
							hero_time[i] =  1
							forced_time = GameRules.GetGameTime()
							force_direction[i] = 0
						end
					else
						force_direction[i] = 0
					end
					local x, y, visible = Renderer.WorldToScreen(UnitPos)
					if visible then 
						Renderer.DrawLine(x, y, x3, y3)
					end
				end
			end
		end --blast damage display
			
		
		if Menu.IsEnabled(TechiesHUD.optionPanelInfo) then
			if Ability.GetLevel(remote) ~= 0 then -- remote num display
				if  Entity.IsNPC(Unit)
				and Entity.GetTeamNum(Unit) ~= Entity.GetTeamNum(myHero)
				and Entity.IsHero(Unit)
				then
					
					local Hp = Entity.GetHealth(Unit) / ((remote_damage + 150 * (NPC.HasItem(myHero, "item_ultimate_scepter", 1) and 1 or 0)) * NPC.GetMagicalArmorDamageMultiplier(Unit))
					local Hp_all = Entity.GetMaxHealth(Unit) / ((remote_damage + 150 * (NPC.HasItem(myHero, "item_ultimate_scepter", 1) and 1 or 0)) * NPC.GetMagicalArmorDamageMultiplier(Unit))
					
					Renderer.SetDrawColor(0, 255, 0, 255)
					local size_x, size_y = Renderer.GetScreenSize()
					if (Entity.GetTeamNum(myHero) == 2) then
						Renderer.DrawText(TechiesHUD.HUDfont, size_x / 2 + 30 + (53 + Menu.GetValue(TechiesHUD.optionPanelInfoDistRight)) * (Hero.GetPlayerID(Unit) - 4) + Menu.GetValue(TechiesHUD.optionPanelInfoXR), 32 + Menu.GetValue(TechiesHUD.optionPanelInfoY), (math.ceil(Hp * 10) / 10).. "|" .. (math.ceil(Hp_all * 10) / 10), 0)
					end
					if (Entity.GetTeamNum(myHero) == 3) then
						Renderer.DrawText(TechiesHUD.HUDfont, size_x / 2 - 400 + (53 + Menu.GetValue(TechiesHUD.optionPanelInfoDistLeft)) * Hero.GetPlayerID(Unit) + Menu.GetValue(TechiesHUD.optionPanelInfoXL), 32 + Menu.GetValue(TechiesHUD.optionPanelInfoY), (math.ceil(Hp * 10) / 10) .. "|" .. (math.ceil(Hp_all * 10) / 10), 0)
					end
				end
			end -- remote num display
		end
	end -- for all entity list
end

check_detonate = 0
function TechiesHUD.OnUpdate()
	if not Menu.IsEnabled(TechiesHUD.optionTotal) then return end
	
	local myHero = Heroes.GetLocal()

	if not myHero then 
		return 
	end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_techies" then 
		return 
	end
	local remote = NPC.GetAbilityByIndex(myHero, 5)
	local magicalDamageMul = 1 + Hero.GetIntellectTotal(myHero)/ 16 / 100
	
	local remote_damage = Ability.GetLevelSpecialValueFor(remote, "damage")
	
	for i = 0, NPCs.Count() do
		local Unit = NPCs.Get(i)
		local UnitPos = Entity.GetAbsOrigin(Unit)	
		if Ability.GetLevel(remote) ~= 0 then -- remote auto detonate
			if  Entity.IsNPC(Unit)
			and Entity.GetTeamNum(Unit) ~= Entity.GetTeamNum(myHero)
			and Entity.IsHero(Unit)
			and NPC.IsKillable(Unit)
			and not NPC.IsIllusion(Unit)
			and Entity.GetHealth(Unit) > 0 
			then
					local remote_sum_damage = 0
					for j = 0, NPCs.Count() do
						local Unit2 = NPCs.Get(j)
						local UnitPos2 = Entity.GetAbsOrigin(Unit2)	
						if ((NPC.GetUnitName(Unit2) == "npc_dota_techies_remote_mine") 
						and Entity.IsAlive(Unit2) 
						and NPC.IsPositionInRange(Unit2, UnitPos, 425 - NPC.GetMoveSpeed(Unit) * 0.1, 0)) 
						and NPC.GetModifier(Unit2, "modifier_techies_remote_mine") ~= nil
						then
							if (hero_time[i] == 0) then
								hero_time[i] = GameRules.GetGameTime()
							end
							if (mines_damage[Entity.GetIndex(Unit2)] ~= nil) then
								remote_sum_damage = remote_sum_damage + mines_damage[Entity.GetIndex(Unit2)] + 150 * (NPC.HasItem(myHero, "item_ultimate_scepter", 1) and 1 or 0)
							end
						end
					end
				if Menu.IsEnabled(TechiesHUD.optionDetonate) then
					if (remote_sum_damage * NPC.GetMagicalArmorDamageMultiplier(Unit) > Entity.GetHealth(Unit)) then
						--Log.Write(remote_sum_damage * NPC.GetMagicalArmorDamageMultiplier(Unit))
						local remote_need_damage = Entity.GetHealth(Unit) + NPC.GetHealthRegen(npc) * 0.25
						if (GameRules.GetGameTime() - check_detonate > 0.5) and (hero_time[i] ~= 0) and (GameRules.GetGameTime() - hero_time[i] > Menu.GetValue(TechiesHUD.optionDelay) / 1000) then
							--hero_time[i] = 0
							--Log.Write(GameRules.GetGameTime() - hero_time[i])
							for j = 0, NPCs.Count() do
								local Unit2 = NPCs.Get(j)
								local UnitPos2 = Entity.GetAbsOrigin(Unit2)	
								if ((NPC.GetUnitName(Unit2) == "npc_dota_techies_remote_mine") 
								and Entity.IsAlive(Unit2) 
								and NPC.IsPositionInRange(Unit2, UnitPos, 415, 0)) 
								and NPC.GetModifier(Unit2, "modifier_techies_remote_mine") ~= nil
								then
								--Log.Write(remote_need_damage)
									if (remote_need_damage > 0) then
										Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, 0, Vector(0, 0, 0), NPC.GetAbilityByIndex(Unit2, 0), Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, Unit2, 0, 0)
										check_detonate = GameRules.GetGameTime()
										remote_need_damage = remote_need_damage - (mines_damage[Entity.GetIndex(Unit2)] + 150 * (NPC.HasItem(myHero, "item_ultimate_scepter", 1) and 1 or 0)) * NPC.GetMagicalArmorDamageMultiplier(Unit)
									end
								end
							end
						end
					else
						if (hero_time[i] ~= 1) then
						--Log.Write(i)
							hero_time[i] = 0
						end
					end
				end 
			
			end
		end
	end
end

function TechiesHUD.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(TechiesHUD.optionTotal) then return true end
	if not Menu.IsEnabled(TechiesHUD.optionStack) then return true end
	
	if orders.order ~= Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION then return true end
    if not orders.ability then return true end
    if not orders.npc then return true end
	
	if Ability.GetName(orders.ability) == "techies_suicide" then
		castPosit = orders.position
		return true
	end
	
	if Ability.GetName(orders.ability) ~= "techies_remote_mines"
	and Ability.GetName(orders.ability) ~= "techies_land_mines"
	and Ability.GetName(orders.ability) ~= "techies_stasis_trap"
	then return true end
	
	for i = 0, NPCs.Count() do
		local Unit = NPCs.Get(i)
		local UnitPos = Entity.GetAbsOrigin(Unit)
		if ((NPC.GetModifier(Unit, "modifier_techies_remote_mine") ~= nil
		or NPC.GetModifier(Unit, "modifier_techies_land_mine") ~= nil
		or NPC.GetModifier(Unit, "modifier_techies_stasis_trap") ~= nil)
		and Entity.IsAlive(Unit)
		and NPC.IsPositionInRange(Unit, orders.position, Menu.GetValue(TechiesHUD.optionStackRange), 0))
		--	and NPC.GetModifier(Unit, "modifier_techies_remote_mine") ~= nil
		then
			Player.PrepareUnitOrders(orders.player, orders.order, orders.target, UnitPos, orders.ability, orders.orderIssuer, orders.npc, orders.queue, orders.showEffects)
			
			return false
		end
	end
    
    return true
end

return TechiesHUD