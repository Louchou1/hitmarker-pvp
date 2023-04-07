local pInfo = {
    health = 0,
    armour = 0
}

CreateThread(function()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        pInfo.health = GetEntityHealth(player)
        pInfo.armour = GetPedArmour(player)
    end
end)

AddEventHandler('gameEventTriggered', function(name, data)
    if name == "CEventNetworkEntityDamage" then
        victim = tonumber(data[1])
        attacker = tonumber(data[2])
        victimDied = tonumber(data[6]) == 1 and true or false 
        weaponHash = tonumber(data[7])
        isMeleeDamage = tonumber(data[10]) ~= 0 and true or false 
        vehicleDamageTypeFlag = tonumber(data[11]) 
        local FoundLastDamagedBone, LastDamagedBone = GetPedLastDamageBone(victim)
        local bonehash = -1 
        if FoundLastDamagedBone then
            bonehash = tonumber(LastDamagedBone)
        end
        local PPed = PlayerPedId()
        local distance = IsEntityAPed(attacker) and #(GetEntityCoords(attacker) - GetEntityCoords(victim)) or -1
        local isplayer = IsPedAPlayer(attacker)
        local attackerid = isplayer and GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)) or tostring(attacker==-1 and " " or attacker)
        local deadid = isplayer and GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)) or tostring(victim==-1 and " " or victim)
        local victimName = GetPlayerName(PlayerId())

        if victim == attacker or victim ~= PPed or not IsPedAPlayer(victim) or not IsPedAPlayer(attacker) then return end

        local hit = {
            health = 0,
            armour = 0,
        }

        if pInfo.armour > GetPedArmour(PPed) then
            hit.armour = pInfo.armour - GetPedArmour(PPed)
        else
            hit["armour"] = nil
        end

        if pInfo.health > GetEntityHealth(PPed) then
            hit.health = pInfo.health - GetEntityHealth(PPed)
        else
            hit["health"] = nil
        end
        
        print(GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)))
        TriggerServerEvent('wais:s:writehit', attackerid, GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)), hit, victimDied, bonehash)
    end

end)

RegisterNetEvent('wais:c:writehit', function(victim, victimInfo, victimDied, Bone)
    exports['interact-sound']:PlayOnOne("hit", 0.5)
    if victimInfo.armour then
        OnEntityHealthChange(victim, victimInfo.armour, Bone, {r = 48, g = 152, b = 196}, victimDied)
    end
    if victimInfo.health then
        OnEntityHealthChange(victim, victimInfo.health, Bone,  {r = 212, g = 84, b = 84}, victimDied)
    end
end)

local DrawText2D = function(text, scale, x, y, a, color)
	SetTextScale(0.7, 0.5)
	SetTextFont(6)
	SetTextColour(color and tonumber(color.r or 0) or 0, color and tonumber(color.g or 0) or 0, color and tonumber(color.b or 0) or 0, 255)
	SetTextCentre(true)
    SetTextDropShadow()
    SetTextOutline(1)
    SetTextProportional(1)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
	ClearDrawOrigin()
end

function DrawText3D(text, x, y, z, color)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
	if onScreen then
		DrawText2D(text, 11, _x, _y, nil, color)
	end
end

local DrawText2DTweenUp = function(text, scale, x, y, moveheight, speed, color)
    Citizen.CreateThread(function()
        local height = y
        local total_ = height - (y - moveheight) 
        local total = height - (y - moveheight)
        while height > (y - moveheight) do 
            DrawText2D(text, scale, x, height, math.floor(255* (total/total_)), color)
            height = height - 0.003 * speed
            total = total - 0.003 * speed
            Citizen.Wait(1)
        end
    end)
end

local lastHit =  vector3(0, 0, 0)
local DrawText3DTweenUp = function(text, scale, x, y, z, moveheight, speed, color)
    if #(lastHit - vector3(x, y, z)) < 0.3 then 
        z = z + 0.2
    end
    --print(x,y,z)
    Citizen.CreateThread(function()
        local height = z
        local total_ = height - (z - moveheight) 
        local total = height - (z - moveheight)
        while height < (z + moveheight) do 
            DrawText3D(text, x, y, height, color)
            height = height + 0.003 * speed
            total = total + 0.003 * speed
            Citizen.Wait(1)
        end
    end)
end

OnEntityHealthChange = function(victim, value, bonehash, color, dead)
    local pcord = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(victim)))
    local coords =  bonehash and GetPedBoneCoords(victim, bonehash, 0.0, 0.0, 0.0) or pcord
    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if scale < 0.2 then scale = 0.2 end 
    DrawText3DTweenUp(tostring(value), 11, pcord.x + math.random(-500, 500)/1000, pcord.y, pcord.z + 0.650, 0.3, 0.35, color)
    Citizen.Wait(100)
end