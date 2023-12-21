-- Variables
local spawnedPeds = {}

-- Functions
local function nearPed(model, coords, gender, animDict, animName, scenario)
	lib.requestModel(model)

	local spawnedPed = nil
	if Config.MinusOne then
		spawnedPed = CreatePed(Config.GenderNumbers[gender], model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
	else
		spawnedPed = CreatePed(Config.GenderNumbers[gender], model, coords.x, coords.y, coords.z, coords.w, false, true)
	end

	SetEntityAlpha(spawnedPed, 0, false)

	if Config.Frozen then
		FreezeEntityPosition(spawnedPed, true)
	end

	if Config.Invincible then
		SetEntityInvincible(spawnedPed, true)
	end

	if Config.Stoic then
		SetBlockingOfNonTemporaryEvents(spawnedPed, true)
	end

	if animDict and animName then
		lib.requestAnimDict(animDict)

		TaskPlayAnim(spawnedPed, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end

    if scenario then
        TaskStartScenarioInPlace(spawnedPed, scenario, 0, true)
    end

	if Config.FadeIn then
		for i = 0, 255, 51 do
			Wait(50)
			SetEntityAlpha(spawnedPed, i, false)
		end
	end

	return spawnedPed
end

local function addPed(tableData)
	Config.PedList[#Config.PedList+1] = tableData
end
exports('AddPed', addPed)

-- Threads
CreateThread(function()
	while true do
		Wait(500)
		for i = 1, #Config.PedList, 1 do
			local pedData = Config.PedList[i]
			if pedData then
				local playerCoords = GetEntityCoords(cache.ped)
				local distance = #(playerCoords - pedData[i].coords.xyz)
	
				if distance < Config.DistanceSpawn and not spawnedPeds[i] then
					local spawnedPed = nearPed(pedData[i].model, pedData[i].coords, pedData[i].gender, pedData[i].animDict, pedData[i].animName, pedData[i].scenario)
					spawnedPeds[i] = { spawnedPed = spawnedPed }
				end
	
				if distance >= Config.DistanceSpawn and spawnedPeds[i] then
					if Config.FadeIn then
						for i = 255, 0, -51 do
							Wait(50)
							SetEntityAlpha(spawnedPeds[i].spawnedPed, i, false)
						end
					end
					DeletePed(spawnedPeds[i].spawnedPed)
					spawnedPeds[i] = nil
				end
			end
		end
	end
end)