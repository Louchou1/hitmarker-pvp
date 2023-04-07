RegisterNetEvent('wais:s:writehit', function(attackerid, victim, hit, victimDied, bonehash, vCoords)
    TriggerClientEvent('wais:c:writehit', attackerid, victim, hit, victimDied, bonehash, vCoords)
end)