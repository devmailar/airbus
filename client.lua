local callMarker = vector3(-1038.834, -2733.346, 19.169627)
local called = false;
local arrivedCity = false;
local driverHash = 1885233650
local vehicleHash = 1283517198
local realtimeDistanceToCallMarker = 15.0
local availableBucketsRange = { 0, 50 }

-- As we mes with routing buckets, we need to default the player to bucket 0 to overwrite the old bucket
TriggerServerEvent("airbus:sv:setBucket", 0)

-- Make sure the player blip is visible
SetBlipDisplay(GetMainPlayerBlipId(), 8);

-- Get player distance to marker
CreateThread(function(threadId)
	while not arrivedCity do
		Wait(500)

		local playerCoords = GetEntityCoords(PlayerPedId())
		realtimeDistanceToCallMarker = #(playerCoords - callMarker)
	end
end)

-- As long as airbus is not called and distance < 15.0, draw the marker and display the help text
CreateThread(function(threadId)
	while (not called) do
		Wait(0)

		if (realtimeDistanceToCallMarker < 15.0 and not called) then
			DrawMarker(2, callMarker.x, callMarker.y, callMarker.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 128, 0, 50, false, true, 2, false, nil, nil, false)
		end

		if (realtimeDistanceToCallMarker < 1.3 and not called) then
			BeginTextCommandDisplayHelp("STRING")
			AddTextComponentString("Press ~INPUT_CONTEXT~ to call AIR-BUS.")
			EndTextCommandDisplayHelp(0, false, true, -1)

			if (IsControlJustPressed(0, 38)) then
				called = true;
				TriggerServerEvent("airbus:sv:setBucket", math.random(availableBucketsRange[1], availableBucketsRange[2]));
				Wait(1000)
				CallAirbus()
			end
		end
	end
end)

-- Function to call the airbus
function CallAirbus()
	RequestModel(driverHash)
	while not HasModelLoaded(driverHash) do
		Wait(100)
	end

	if (HasModelLoaded(driverHash)) then
		local driver = CreatePed(0, driverHash, -1067.831, -2559.146, 21.0, 237.912, true, true)

		if DoesEntityExist(driver) then
			SetPedComponentVariation(driver, 2, 4, 4, 0) -- Hair
			SetPedComponentVariation(driver, 7, 38, 0, 0); -- Accessory
			SetPedComponentVariation(driver, 11, 242, 1, 0); -- Torso
			SetPedComponentVariation(driver, 8, 15, 0, 0); -- T-Shirt
			SetPedComponentVariation(driver, 4, 35, 0, 0); -- Pants
			SetPedComponentVariation(driver, 6, 21, 0, 0); -- Shoes

			RequestModel(vehicleHash)
			while not HasModelLoaded(vehicleHash) do
				Wait(100)
			end

			if (HasModelLoaded(vehicleHash)) then
				local airbus = CreateVehicle(1283517198, -1062.101, -2555.909, 20.07566, 150.1505, true, false)

				if DoesEntityExist(airbus) then
					local airbusBlip = AddBlipForEntity(airbus)
					SetBlipSprite(airbusBlip, 513)
					SetBlipColour(airbusBlip, 0)
					SetBlipScale(airbusBlip, 0.8)
					SetBlipFlashes(airbusBlip, true)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString("AIR-BUS")
					EndTextCommandSetBlipName(airbusBlip)

					TaskWarpPedIntoVehicle(driver, airbus, -1)

					-- Set the vehicle properties
					SetVehicleOnGroundProperly(airbus)
					SetVehicleNumberPlateText(airbus, "AIRBUS")
					SetVehicleEngineOn(airbus, true, true, false)
					SetVehicleLivery(airbus, 1)

					TaskVehicleDriveToCoord(
						driver,
						airbus,
						-1050.137,
						-2720.53,
						20.08276,
						10.0,
						nil,
						vehicleHash,
						786599,
						5.0, nil
					)

					BeginTextCommandDisplayHelp("STRING")
					AddTextComponentString("AIR-BUS ~BLIP_BUS~ is on its way to the bus station ~BLIP_LEVEL~")
					EndTextCommandDisplayHelp(0, false, true, 8000)

					local stationBlip = AddBlipForCoord(-1045.806, -2722.468, 20.10379)
					SetBlipColour(stationBlip, 0)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString("AIR-BUS Station")
					EndTextCommandSetBlipName(stationBlip)

					Wait(4000)
					SetBlipFlashes(airbusBlip, false)
					Wait(10000)

					-- Wait for bus to arrive at the station
					while (#(GetEntityCoords(airbus) - vector3(-1050.137, -2720.53, 20.08276)) > 15.0) do
						Wait(1000)
					end

					-- Bus has arrived at the station
					RemoveBlip(stationBlip)
					SetEntityCoords(airbus, -1050.137, -2720.53, 20.08276, false, false, false, true)
					SetEntityHeading(airbus, 238.8681)
					FlashMinimapDisplay()

					BeginTextCommandDisplayHelp("STRING")
					AddTextComponentString("AIR-BUS ~BLIP_BUS~ has arrived at the bus station ~BLIP_LEVEL~")
					EndTextCommandDisplayHelp(0, false, true, 4000)

					-- Wait for player to enter the bus
					while (#(GetEntityCoords(PlayerPedId()) - vector3(-1041.774, -2726.878, 20.01925)) > 10.0) do
						Wait(0)
					end

					while (not IsControlJustPressed(0, 23)) do
						Wait(0)
					end

					TaskEnterVehicle(
						PlayerPedId(),
						airbus,
						-1,
						0,
						1.0,
						1,
						0
					)

					Wait(500)
					SetFollowPedCamViewMode(4)
					Wait(6000)
					SetFollowVehicleCamViewMode(4)

					BeginTextCommandDisplayHelp("STRING")
					AddTextComponentString("AIR-BUS ~BLIP_BUS~ is departuring.")
					EndTextCommandDisplayHelp(0, false, true, 4000)

					SetBlipDisplay(GetMainPlayerBlipId(), 0);
					SetNewWaypoint(298.8799, -1202.714);

					TaskVehicleDriveToCoord(
						driver,
						airbus,
						259.2122,
						-1179.586,
						29.44427,
						20.0,
						nil,
						vehicleHash,
						786599,
						5.0, nil
					)

					-- Wait for bus to arrive at the destination
					while (#(GetEntityCoords(airbus) - vector3(259.2122, -1179.586, 29.44427)) > 10.0) do
						-- If player gets out early
						if (not IsPedInVehicle(PlayerPedId(), airbus, false)) then
							SetBlipDisplay(GetMainPlayerBlipId(), 8);
							Wait(2000)
							DeleteEntity(driver)
							DeleteEntity(airbus)
							arrivedCity = true;

							TriggerServerEvent("airbus:sv:setBucket", 0)
						end

						Wait(1000)
					end

					BeginTextCommandDisplayHelp("STRING")
					AddTextComponentString("AIR-BUS ~BLIP_BUS~ has arrived at the destination.")
					EndTextCommandDisplayHelp(0, false, true, 4000)

					Wait(1000)
					TaskLeaveVehicle(PlayerPedId(), airbus, 0)

					-- Wait for player to exit the bus
					while (IsPedInVehicle(PlayerPedId(), airbus, false)) do
						Wait(1000)
					end

					SetBlipDisplay(GetMainPlayerBlipId(), 8);
					Wait(2000)
					DeleteEntity(driver)
					DeleteEntity(airbus)
					arrivedCity = true;

					TriggerServerEvent("airbus:sv:setBucket", 0)
				else
					print("[ERROR] Entity airbus does not exist.")
				end
			end
		else
			print("[ERROR] Entity driver does not exist.")
		end
	end
end
