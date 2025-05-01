RegisterNetEvent("airbus:sv:setBucket")
AddEventHandler("airbus:sv:setBucket", function(bucket)
    SetPlayerRoutingBucket(source, bucket)
end)
