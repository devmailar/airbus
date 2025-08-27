local buckets = {}
for i = 1,50 do
    table.insert(buckets, 1000 + i)
end

local playerBuckets = {}

RegisterNetEvent("airbus:enter")
AddEventHandler("airbus:enter", function()
    local source = source
    if playerBuckets[source] then
        return
    end

    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - Config.CallMarker)

    if distance <= Config.CallMaxDistance then
        if #buckets > 0 then
            local bucket = table.remove(buckets, 1)
            playerBuckets[source] = bucket
            SetPlayerRoutingBucket(source, bucket)
            TriggerClientEvent("airbus:enterDone", source)
        else
            print("All buses are busy")
        end
    else
        print("Player too far away from the callbus marker")
    end
end)

RegisterNetEvent("airbus:exit")
AddEventHandler("airbus:exit", function()
    local source = source
    local bucket = playerBuckets[source]

    if bucket then
        table.insert(buckets, bucket)
        playerBuckets[source] = nil
    end

    SetPlayerRoutingBucket(source, 0)
end)