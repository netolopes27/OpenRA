
RunInitialActivities = function()
	Harvester.FindResources()
	IdlingUnits()
	Trigger.AfterDelay(10, function()
		BringPatrol1()
		BringPatrol2()
		BuildBase()
	end)

	Utils.Do(Map.NamedActors, function(actor)
		if actor.Owner == Greece and actor.HasProperty("StartBuildingRepairs") then
			Trigger.OnDamaged(actor, function(building)
				if building.Owner == Greece and building.Health < 3/4 * building.MaxHealth then
					building.StartBuildingRepairs()
				end
			end)
		end
	end)

	Reinforcements.Reinforce(player, SovietMCV, SovietStartToBasePath, 0, function(mcv)
		mcv.Move(StartCamPoint.Location)
	end)
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")

	Trigger.OnKilled(Barr, function(building)
		BaseBuildings[2][4] = false
	end)

	Trigger.OnKilled(Proc, function(building)
		BaseBuildings[3][4] = false
	end)

	Trigger.OnKilled(Weap, function(building)
		BaseBuildings[4][4] = false
	end)

	Trigger.OnEnteredFootprint(VillageCamArea, function(actor, id)
		if actor.Owner == player then
			local camera = Actor.Create("camera", true, { Owner = player, Location = VillagePoint.Location })
			Trigger.RemoveFootprintTrigger(id)
			Trigger.OnAllKilled(Village, function()
				camera.Destroy()
			end)
		end
	end)

	Trigger.OnAnyKilled(Civs, function()
		Trigger.ClearAll(civ1)
		Trigger.ClearAll(civ2)
		Trigger.ClearAll(civ3)
		local units = Reinforcements.Reinforce(Greece, Avengers, { SWRoadPoint.Location }, 0)
		Utils.Do(units, function(unit)
			unit.Hunt()
		end)
	end)

	Runner1.Move(CrossroadsEastPoint.Location)
	Runner2.Move(InVillagePoint.Location)
	Tank5.Move(V2MovePoint.Location)
	Trigger.AfterDelay(DateTime.Seconds(2), function()
		Tank1.Stop()
		Tank2.Stop()
		Tank3.Stop()
		Tank4.Stop()
		Tank5.Stop()
		Trigger.AfterDelay(1, function()
			Tank1.Move(SovietBaseEntryPointNE.Location)
			Tank2.Move(SovietBaseEntryPointW.Location)
			Tank3.Move(SovietBaseEntryPointNE.Location)
			Tank4.Move(SovietBaseEntryPointW.Location)
			Tank5.Move(V2MovePoint.Location)
		end)
	end)

	Trigger.AfterDelay(DateTime.Minutes(1), ProduceInfantry)
	Trigger.AfterDelay(DateTime.Minutes(2), ProduceArmor)

	if Map.Difficulty == "Hard" or Map.Difficulty == "Medium" then
		Trigger.AfterDelay(DateTime.Seconds(15), ReinfInf)
	end
	Trigger.AfterDelay(DateTime.Minutes(1), ReinfInf)
	Trigger.AfterDelay(DateTime.Minutes(3), ReinfInf)
	Trigger.AfterDelay(DateTime.Minutes(2), ReinfArmor)
end

Tick = function()
	if Greece.HasNoRequiredUnits() then
		player.MarkCompletedObjective(KillAll)
		player.MarkCompletedObjective(KillRadar)
	end

	if player.HasNoRequiredUnits() then
		Greece.MarkCompletedObjective(BeatUSSR)
	end

	if Greece.Resources >= Greece.ResourceCapacity * 0.75 then
		Greece.Cash = Greece.Cash + Greece.Resources - Greece.ResourceCapacity * 0.25
		Greece.Resources = Greece.ResourceCapacity * 0.25
	end

	if RCheck then
		RCheck = false
		if Map.Difficulty == "Hard" then
			Trigger.AfterDelay(DateTime.Seconds(150), ReinfArmor)
		elseif Map.Difficulty == "Medium" then
			Trigger.AfterDelay(DateTime.Minutes(5), ReinfArmor)
		else
			Trigger.AfterDelay(DateTime.Minutes(8), ReinfArmor)
		end
	end
end

WorldLoaded = function()
	player = Player.GetPlayer("USSR")
	Greece = Player.GetPlayer("Greece")

	RunInitialActivities()

	Trigger.OnObjectiveAdded(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)
	Trigger.OnObjectiveCompleted(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	KillAll = player.AddPrimaryObjective("Defeat the Allied forces.")
	BeatUSSR = Greece.AddPrimaryObjective("Defeat the Soviet forces.")
	KillRadar = player.AddSecondaryObjective("Destroy Allied Radar Dome to stop enemy\nreinforcements.")

	Trigger.OnPlayerLost(player, function()
		Media.PlaySpeechNotification(player, "Lose")
	end)

	Trigger.OnPlayerWon(player, function()
		Media.PlaySpeechNotification(player, "Win")
	end)

	Trigger.OnKilled(Radar, function()
		player.MarkCompletedObjective(KillRadar)
		Media.PlaySpeechNotification(player, "ObjectiveMet")
	end)

	Camera.Position = StartCamPoint.CenterPosition
end