require( "constants" )
require( "gameplay_shared" )
require( "map_room" )
require( "reward_tables" )
require( "utility_functions" )
require( "ai/shared" )
require( "aghanim_ability_upgrade_interface" )


function GetMinMaxGoldChoiceReward( nRoomDepth, bElite )
	local nFixedGoldAwardOfDepth = ENCOUNTER_DEPTH_GOLD_REWARD[ nRoomDepth ]
	if bElite then
		--print( "Elite Room, increasing expected value of item reward " .. nFixedGoldAwardOfDepth .. " to " .. nFixedGoldAwardOfDepth * ELITE_VALUE_MODIFIER )
		nFixedGoldAwardOfDepth = nFixedGoldAwardOfDepth * ELITE_VALUE_MODIFIER
	end
	local nMaxValue = math.ceil( nFixedGoldAwardOfDepth * GOLD_REWARD_CHOICE_MAX_PCT )
	local nMinValue = math.floor( nFixedGoldAwardOfDepth * GOLD_REWARD_CHOICE_MIN_PCT ) 
	return nMinValue, nMaxValue
end

function GetPricedNeutralItems( nRoomDepth, bElite )
	local vecItemRewards = PRICED_ITEM_REWARD_LIST
	local nFixedGoldAwardOfDepth = ENCOUNTER_DEPTH_GOLD_REWARD[ nRoomDepth ]
	if bElite then
		--print( "Elite Room, increasing expected value of item reward " .. nFixedGoldAwardOfDepth .. " to " .. nFixedGoldAwardOfDepth * ELITE_NEUTRAL_ITEM_VALUE_MODIFIER )
		nFixedGoldAwardOfDepth = nFixedGoldAwardOfDepth * ELITE_NEUTRAL_ITEM_VALUE_MODIFIER
	end
	local flBonusPct = PRICED_ITEM_BONUS_DEPTH_PCT * nRoomDepth
	local nMaxValue = math.ceil( nFixedGoldAwardOfDepth * ( PRICED_ITEM_GOLD_MAX_PCT + flBonusPct ) )
	local nMinValue = math.floor( nFixedGoldAwardOfDepth * ( PRICED_ITEM_GOLD_MIN_PCT + flBonusPct ) ) 
	local vecPossibleItems = {}

	for szItemName, nValue in pairs( vecItemRewards ) do
		if nValue >= nMinValue and nValue <= nMaxValue then
			table.insert( vecPossibleItems, szItemName )
		end
	end

	return vecPossibleItems
end

function GetRoomRewards( nRoomDepth, nRoomType, bElite, nPlayerID, vecExternalExcludeList )

	local vecRewardStruct = nil	

	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )

	if hPlayerHero == nil then
		printf("GetRoomRewards; Aborting, no hero entity for Player %d", nPlayerID )
		return nil
	end

	if( vecExternalExcludeList == nil ) then
		vecExternalExcludeList = {}
	end

	local bLimitUltimateUpgrades = tonumber(nRoomDepth) == 1

	local szHeroName = hPlayerHero:GetName()
	local bHardRoom = bElite --or nRoomType == ROOM_TYPE_TRAPS

	-- Rarity:
	-- Common = 0 
	-- Rare = 1
	-- Epic = 2
	local iRewardRarity = 0

	if bHardRoom == true then
		iRewardRarity = 1		
	end

	vecRewardStruct = ROOM_REWARDS[ "depth_" .. nRoomDepth].normal

--[[	if nRoomType ~= ROOM_TYPE_TRAPS then
		if bElite then 
			vecRewardStruct = ROOM_REWARDS[ "depth_" .. nRoomDepth].elite
		else
			vecRewardStruct = ROOM_REWARDS[ "depth_" .. nRoomDepth].normal
		end
	else
		vecRewardStruct = ROOM_REWARDS[ "traps" ].normal
	end
--]]
	--printf("room substr = %s, bElite = %s, reward struct = %s", szRoomSubstr, bElite, vecRewardStruct )

	-- first, choose the appropriate reward tier for each option
	local vecGeneratedRewardTiers = {}

	for _,aRewardDef in pairs( vecRewardStruct ) do

		local flRoll = RandomFloat(0, 100.0)
		local flThreshold = 0.0

		for eRewardTier,flPct in pairs( aRewardDef ) do
			flThreshold = flThreshold + flPct
			if flRoll <= flThreshold then
				table.insert( vecGeneratedRewardTiers, eRewardTier )
				break
			end
		end
	end

	if TableLength(vecGeneratedRewardTiers) < 1 then
		return nil
	end

	-- shuffle the chosen reward tiers so that progressive probabilities are randomized
	ShuffleListInPlace( vecGeneratedRewardTiers )

	-- exclude any item or ability they've learned, chosen, have in inventory or are externally marked for exclusion
	local vecAbilitiesToExclude = GetPlayerAbilitiesAndItems( nPlayerID )
	for ii=1,nRoomDepth-1 do
		local RewardChoices = CustomNetTables:GetTableValue( "reward_choices", tostring(ii) )
		local RewardChoice = RewardChoices and RewardChoices[ tostring(nPlayerID) ] or nil
		if RewardChoice and RewardChoice["ability_name"] and RewardChoice["reward_type"] ~= "REWARD_TYPE_MINOR_ABILITY_UPGRADE" and RewardChoice["reward_type"] ~= "REWARD_TYPE_MINOR_STATS_UPGRADE" then
			table.insert( vecAbilitiesToExclude, RewardChoice["ability_name"] )
		end

		-- also exclude neutral items i was offered but did not choose.
		local RewardOptions = CustomNetTables:GetTableValue( "reward_options", tostring(ii) )
		local RewardOption = RewardOptions and RewardOptions[ tostring( nPlayerID ) ] or nil
		if RewardOption then
			for _,Reward in pairs ( RewardOption ) do
				if Reward[ "reward_type" ] == "REWARD_TYPE_ITEM" and Reward[ "ability_name" ] then
					--print( "excluding choice of " .. Reward[ "ability_name" ] )
					table.insert( vecAbilitiesToExclude, RewardOption["ability_name"] )
				end
			end
		end
	end
	for _,ExcludeAbility in pairs(vecExternalExcludeList) do
		table.insert( vecAbilitiesToExclude, ExcludeAbility )
	end

	local MinorUpgrades = deepcopy( MINOR_ABILITY_UPGRADES[ szHeroName ] )
	local MinorStatsUpgrades = deepcopy( MINOR_ABILITY_UPGRADES ["base_stats_upgrades"])

	-- then for each option, roll a reward type, and don't repeat types
	local vecGeneratedRewards = {}
	local vecMinorAbilityIDsToExclude = {}
	for _,eRewardTier in pairs(vecGeneratedRewardTiers) do

		local eGeneratedRewardType = nil 
	
		local aRewardTierDef = RebalanceRewards( REWARD_TIER_TABLE[eRewardTier], vecGeneratedRewards )

		local flRoll = RandomFloat(0, 100.0)
		local flThreshold = 0.0
		local MinorAbilityUpgrade = nil
		local MinorStatsUpgrade = nil

		for eRewardType,flPct in pairs( aRewardTierDef ) do

			flThreshold = flThreshold + flPct
			if flRoll <= flThreshold then

				local szAbilityName = nil
				local nQuantity = nil

				if eRewardType == "REWARD_TYPE_GOLD" then
					if USE_PRICED_REWARDS == true then
						local nMinValue, nMaxValue = GetMinMaxGoldChoiceReward( nRoomDepth, bElite )
						nQuantity = math.random( nMinValue, nMaxValue )
					else
						local aRewardResultDef = GOLD_REWARD_LIST[ eRewardTier ]
						nQuantity = RandomInt( aRewardResultDef[1], aRewardResultDef[2] )
					end
				elseif  eRewardType == "REWARD_TYPE_EXTRA_LIVES" then
					nQuantity = 1
				elseif eRewardType == "REWARD_TYPE_ITEM" then
					if USE_PRICED_REWARDS == true then
						local vecPossibleItems = GetPricedNeutralItems( nRoomDepth, bHardRoom )
						local vecFilteredItems = GameRules.Aghanim:FilterPreviouslyDroppedItems( vecPossibleItems )
						szAbilityName = GetRandomUnique( vecFilteredItems, vecAbilitiesToExclude )
					else
						local vecItemRewards = ITEM_REWARD_LIST[ eRewardTier ]
						szAbilityName = GetRandomUnique( vecItemRewards, vecAbilitiesToExclude )						
					end
				elseif eRewardType == "REWARD_TYPE_ABILITY_UPGRADE" then
					szAbilityName = GetRandomUnique( SPECIAL_ABILITY_UPGRADES[szHeroName], vecAbilitiesToExclude )
					iRewardRarity = 2
				elseif eRewardType == "REWARD_TYPE_MINOR_ABILITY_UPGRADE" then
					local k = math.random( 1, #MinorUpgrades )
					local Upgrade = MinorUpgrades[ k ]
					table.remove( MinorUpgrades, k )
					MinorAbilityUpgrade = deepcopy( Upgrade )
					if bHardRoom then
						print( "Elite Room, increasing expected value of ability upgrade from " .. MinorAbilityUpgrade[ "value" ] .. " to " .. MinorAbilityUpgrade[ "value" ] * ELITE_VALUE_MODIFIER )
						MinorAbilityUpgrade[ "value" ] = MinorAbilityUpgrade[ "value" ] * ELITE_VALUE_MODIFIER
					end
					--table.insert( vecMinorAbilityIDsToExclude, MinorAbilityUpgrade[ "id" ] ) 
				elseif eRewardType == "REWARD_TYPE_MINOR_STATS_UPGRADE" then
					local k = math.random( 1, #MinorStatsUpgrades )
					local StatsUpgrade = MinorStatsUpgrades[ k ]
					table.remove( MinorStatsUpgrades, k )
					MinorStatsUpgrade = deepcopy( StatsUpgrade )
					if bHardRoom then
						print( "Elite Room, increasing expected value of stats upgrade from " .. MinorStatsUpgrade[ "value" ] .. " to " .. MinorStatsUpgrade[ "value" ] * ELITE_VALUE_MODIFIER )
						MinorStatsUpgrade[ "value" ] = MinorStatsUpgrade[ "value" ] * ELITE_VALUE_MODIFIER
					end
				elseif eRewardType == "REWARD_TYPE_AURA" then
					szAbilityName = GetRandomUnique( AURA_REWARD_LIST, vecAbilitiesToExclude )	
					-- don't let multiple team members roll the same aura
					table.insert( vecExternalExcludeList, szAbilityName )
				elseif eRewardType == "REWARD_TYPE_TEMP_BUFF" then
					szAbilityName = GetRandomUnique( TEMP_BUFF_REWARD_LIST, vecAbilitiesToExclude )	
					-- don't let multiple team members roll the same temp buff
					table.insert( vecExternalExcludeList, szAbilityName )
				end

				if szAbilityName ~= nil then

					if bLimitUltimateUpgrades and szAbilityName and string.match(szAbilityName, ULTIMATE_ABILITY_NAMES[szHeroName] ) then
						for _key,szAbilityUpgrade in pairs(SPECIAL_ABILITY_UPGRADES[szHeroName]) do
							if string.match(szAbilityUpgrade, ULTIMATE_ABILITY_NAMES[szHeroName] ) then
								table.insert( vecAbilitiesToExclude, szAbilityUpgrade )
							end
						end
					end

					table.insert( vecAbilitiesToExclude, szAbilityName )
				end

				local GeneratedReward = 
				{
					reward_type  = eRewardType,
					reward_tier  = eRewardTier,
					ability_name = szAbilityName,
					quantity = nQuantity,
					rarity = iRewardRarity,
				}

				if bHardRoom then
					GeneratedReward[ "elite" ] = 1
				else
					GeneratedReward[ "elite" ] = 0
				end

				if MinorAbilityUpgrade ~= nil then
					GeneratedReward[ "ability_name" ] = MinorAbilityUpgrade[ "ability_name" ]
					GeneratedReward[ "description" ] = MinorAbilityUpgrade[ "description" ]
					GeneratedReward[ "value" ] = MinorAbilityUpgrade[ "value" ]
					GeneratedReward[ "id" ] = MinorAbilityUpgrade[ "id" ]
				end

				if MinorStatsUpgrade ~= nil then
					GeneratedReward[ "ability_name" ] = MinorStatsUpgrade[ "ability_name" ]
					GeneratedReward[ "description" ] = MinorStatsUpgrade[ "description" ]
					GeneratedReward[ "value" ] = MinorStatsUpgrade[ "value" ]
					GeneratedReward[ "id" ] = MinorStatsUpgrade[ "id" ]
				end

				table.insert( vecGeneratedRewards, GeneratedReward )
				break
			end
		end
		
		table.insert( vecGeneratedRewards, GeneratedReward )
	end

	return vecGeneratedRewards

end

function TestRoomRewardConsoleCommand( cmdName, szRoomDepth, szIsElite, szIsTrapRoom )

	--CustomNetTables:SetTableValue( "reward_options", "current_depth", { szRoomDepth } );

	local bIsElite = (szIsElite == "true")
	local bIsTrapRoom = (szIsTrapRoom == "true")
	local szRoomDepth = tostring( tonumber( szRoomDepth ) )
	local nPlayerID = Entities:GetLocalPlayer():GetPlayerID()
	local nRoomType = ROOM_TYPE_ENEMY
	if bIsTrapRoom == true then
		nRoomType = ROOM_TYPE_TRAPS
	end

	--printf( "Running %s %d %s %s %s...", cmdName, nPlayerID, szRoomDepth, szIsElite, szIsTrapRoom )

	CustomNetTables:SetTableValue( "reward_options", "current_depth", { szRoomDepth } )

	CustomNetTables:SetTableValue( "reward_choices", szRoomDepth, {} )

	local RewardOptions = {}
	local vecPlayerRewards = GetRoomRewards( tonumber(szRoomDepth), nRoomType, bIsElite, nPlayerID ) 
	RewardOptions[ tostring(nPlayerID) ] = vecPlayerRewards;

	--DeepPrintTable( vecPlayerRewards )

	CustomNetTables:SetTableValue( "reward_options", szRoomDepth, RewardOptions )

end

-- right now we just blacklist gold or lives rewards if they've already been chosen
-- but we could reduce relative probabilities of duplicates too
function RebalanceRewards( aRewardDef, vecPreviouslyGeneratedRewards )

	local aRebalancedRewardDef = deepcopy( aRewardDef )

	--printf("rebalancing rewards")
	--DeepPrintTable(aRewardDef)
	
	for _,aPreviouslyGeneratedReward in pairs(vecPreviouslyGeneratedRewards) do

		local ePrevRewardType = aPreviouslyGeneratedReward["reward_type"]

		if ePrevRewardType == "REWARD_TYPE_GOLD" or ePrevRewardType == "REWARD_TYPE_EXTRA_LIVES" or ePrevRewardType == "REWARD_TYPE_ITEM" then
			aRebalancedRewardDef[ePrevRewardType] = nil
		end

	end

	NormalizeFloatArrayInPlace( aRebalancedRewardDef, 100.0 )

	--DeepPrintTable(aRebalancedRewardDef)
	--printf("done rebalancing rewards")

	return aRebalancedRewardDef

end

function NormalizeFloatArrayInPlace( aFloatValues, flDesiredSum )

	if flDesiredSum == nil then
		flDesiredSum = 1.0
	end

	local flSum = 0
	for _,flFloatValue in pairs( aFloatValues ) do
		flSum = flSum + flFloatValue
	end

	for key,flFloatValue in pairs( aFloatValues ) do
		aFloatValues[key] = ( aFloatValues[key] / flSum ) * flDesiredSum
	end

end

function GrantRewards( nPlayerID, szRoomDepth, aReward )

	local hPlayerHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	if hPlayerHero == nil then
		printf("Aborting grant reward, no hero entity for Player %d", nPlayerID )
		return
	end

	local RewardChoices = CustomNetTables:GetTableValue( "reward_choices", szRoomDepth )
	if RewardChoices == nil then
		RewardChoices = {}
	end

	local aExistingReward = RewardChoices[ tostring(nPlayerID) ]
	if aExistingReward ~= nil then
		printf("GrantRewards: Player %d, Depth %s, aborting granting Reward %s to to existing Reward: %s", nPlayerID, szRoomDepth, DeepToString(aReward), DeepToString(aExistingReward) )
		return
	end

	printf("granting reward to %s: %s", hPlayerHero:GetName(), DeepToString(aReward) )

	local eRewardType = aReward["reward_type"]
	local nQuantity = aReward["quantity"]
	local szAbilityName = aReward["ability_name"]
	local bEliteReward = aReward["elite"] == 1


	--local eRewardTier = aReward["reward_tier"]

	if eRewardType == "REWARD_TYPE_ITEM" then
		GrantItemDropToHero( hPlayerHero, szAbilityName )
		GameRules.Aghanim:MarkNeutralItemAsDropped( szAbilityName )
	elseif eRewardType == "REWARD_TYPE_GOLD" then
		PlayerResource:ModifyGold( nPlayerID, nQuantity, true, DOTA_ModifyGold_Unspecified )
	elseif eRewardType == "REWARD_TYPE_EXTRA_LIVES" then
		hPlayerHero.nRespawnsRemaining = math.min( AGHANIM_MAX_LIVES, hPlayerHero.nRespawnsRemaining + nQuantity )
		hPlayerHero:SetRespawnsDisabled( hPlayerHero.nRespawnsRemaining == 0 )

		CustomGameEventManager:Send_ServerToPlayer( hPlayerHero:GetPlayerOwner(), "gained_life", {} )
		CustomNetTables:SetTableValue( "respawns_remaining", string.format( "%d", hPlayerHero:entindex() ),  { respawns = hPlayerHero.nRespawnsRemaining } )
	elseif eRewardType == "REWARD_TYPE_ABILITY_UPGRADE" then
		local data = {}
		data["PlayerID"] = nPlayerID
        data["AbilityName"] = szAbilityName
        data["LevelReward"] = true
		CAghanim:OnAbilityUpgradeButtonClicked(1, data)
		GameRules.Aghanim:GetAnnouncer():OnRewardSelected( hPlayerHero, tonumber( szRoomDepth ), eRewardType, szAbilityName )
	elseif eRewardType == "REWARD_TYPE_AURA" then
		local hNewAbility = hPlayerHero:AddAbility( szAbilityName )
		if ( hNewAbility ) then
			-- Grants and upgrades the ability
			printf("upgrading ability %s %s", szAbilityName, hNewAbility)
			hNewAbility:UpgradeAbility( false )
		end
	elseif eRewardType == "REWARD_TYPE_TEMP_BUFF" then
		local hNewAbility = hPlayerHero:AddAbility( szAbilityName )
		if ( hNewAbility ) then
			-- Grants and upgrades the ability
			printf("upgrading ability %s %s", szAbilityName, hNewAbility)
			hNewAbility:UpgradeAbility( false )
		end
	elseif eRewardType == "REWARD_TYPE_MINOR_ABILITY_UPGRADE" then
		local Upgrade = deepcopy( MINOR_ABILITY_UPGRADES[ hPlayerHero:GetUnitName() ][ aReward[ "id" ] ] )
		if bEliteReward then
			Upgrade[ "value" ] = Upgrade[ "value" ] * ELITE_VALUE_MODIFIER
		end
		CAghanim:AddMinorAbilityUpgrade( hPlayerHero, Upgrade )
		GameRules.Aghanim:GetAnnouncer():OnRewardSelected( hPlayerHero, tonumber( szRoomDepth ), eRewardType, Upgrade.description )
	elseif eRewardType == "REWARD_TYPE_MINOR_STATS_UPGRADE" then
		--Hook up via the same path as the minor ability upgrades
		local StatsUpgrade = deepcopy( MINOR_ABILITY_UPGRADES[ "base_stats_upgrades" ][aReward[ "id" ] ] )
		if bEliteReward then
			StatsUpgrade[ "value" ] = StatsUpgrade[ "value" ] * ELITE_VALUE_MODIFIER
		end
		--Make sure to grant and level up the stats ability if we haven't taken this reward yet
		CAghanim:AddMinorAbilityUpgrade( hPlayerHero, StatsUpgrade )
		CAghanim:VerifyStatsAbility(hPlayerHero, StatsUpgrade[ "ability_name" ])
		GameRules.Aghanim:GetAnnouncer():OnRewardSelected( hPlayerHero, tonumber( szRoomDepth ), eRewardType, StatsUpgrade.description )
	end

	RewardChoices[ tostring(nPlayerID) ] = aReward
	CustomNetTables:SetTableValue( "reward_choices", szRoomDepth, RewardChoices )
	CustomNetTables:SetTableValue( "reward_choices", "current_depth", { szRoomDepth } )


	local gameEvent = {}
	if aReward["quantity"] then
		gameEvent["int_value"] = tonumber(aReward["quantity"])
	end
	if aReward["ability_name"] then
		if eRewardType == "REWARD_TYPE_MINOR_ABILITY_UPGRADE" or eRewardType == "REWARD_TYPE_MINOR_STATS_UPGRADE" then
			--PrintTable( aReward, " reward choice: " )
			gameEvent["string_replace_token"] = aReward [ "description" ]
			gameEvent["ability_name"] = aReward[ "ability_name" ]	
			gameEvent["value"] = tonumber(aReward[ "value" ])
		else
			gameEvent["locstring_value"] ="#DOTA_Tooltip_Ability_" .. aReward["ability_name"]	
		end
	end
	gameEvent["player_id"] = nPlayerID
	gameEvent["teamnumber"] = -1
	gameEvent["message"] = "#DOTA_HUD_" .. aReward["reward_type"] .. "_Toast"

	--DeepPrintTable( RewardChoices )
	FireGameEvent( "dota_combat_event_message", gameEvent )
end

--------------------------------------------------------------------------------

function GenerateRewardStatsForPlayer( hPlayerHero, reward )

	local szAbilityName = nil
	local szAbilityTexture = nil

	if reward.reward_type == "REWARD_TYPE_ABILITY_UPGRADE" then
		szAbilityName = reward.ability_name
		szAbilityTexture = GetAbilityTextureNameForAbility( szAbilityName ) 
	elseif reward.reward_type == "REWARD_TYPE_MINOR_ABILITY_UPGRADE" then
		szAbilityName = MINOR_ABILITY_UPGRADES[ hPlayerHero:GetUnitName() ][ reward.id ].description
		szAbilityTexture = GetAbilityTextureNameForAbility( reward.ability_name ) 
	elseif reward.reward_type == "REWARD_TYPE_MINOR_STATS_UPGRADE" then
		szAbilityName = MINOR_ABILITY_UPGRADES[ "base_stats_upgrades" ][ reward.id ].description
		szAbilityTexture = "attribute_bonus"
	end

	if szAbilityName == nil then
		return nil
	end

	local rewardStats =
	{
		ability_name = szAbilityName,
		rarity = reward.rarity,	-- 0 - normal, 1 - elite, 2 - boss
	}

	if reward.value ~= nil then
		rewardStats.value = reward.value
	end

	if szAbilityTexture ~= nil then
		rewardStats.ability_texture = szAbilityTexture
	end

	return rewardStats
	
end

--------------------------------------------------------------------------------

function GenerateRewardStats( nPlayerID, szRoomDepth, roomOptions, szRewardIndex )
	
	local hHero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	local rewardStats =
	{
		selected_reward = GenerateRewardStatsForPlayer( hHero, roomOptions[ szRewardIndex ] ),
		unselected_rewards = {}
	}

	for key,reward in pairs ( roomOptions ) do
		if key ~= szRewardIndex then
			table.insert( rewardStats.unselected_rewards, GenerateRewardStatsForPlayer( hHero, reward ) )
		end
	end

	GameRules.Aghanim:RegisterRewardStats( nPlayerID, szRoomDepth, rewardStats )

end

--------------------------------------------------------------------------------

function OnRewardChoice( eventSourceIndex, data )

	local nPlayerID = data["PlayerID"]
	local szRoomDepth = tostring(data["room_depth"])
	local szRewardIndex = tostring(data["reward_index"])

	--printf("Processing reward choice for Player %d, %s", nPlayerID, DeepToString(data))

	local rewardOptions = CustomNetTables:GetTableValue( "reward_options", szRoomDepth )
	if rewardOptions == nil then
		return
	end

	local roomOptions = rewardOptions[ tostring( nPlayerID ) ]

	--printf("reward options data %d %s %s %s", nPlayerID, szRewardIndex, DeepToString(roomOptions.keys), DeepToString(roomOptions));

	local aReward = roomOptions[szRewardIndex]

	GrantRewards( nPlayerID, szRoomDepth, aReward )

	GenerateRewardStats( nPlayerID, szRoomDepth, roomOptions, szRewardIndex )
end