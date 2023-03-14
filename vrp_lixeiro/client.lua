Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP() 

local trabalhando = false
local carregandoBag = false
local carryBag = nil
local selfTruck = nil
local descarregarBlip =  nil

local uniformes = {
    ["male"] = {
        ["drawable:1"] = {0,0},
        ["drawable:8"] = {59,0},
        ["drawable:3"] = {63,0},
        ["drawable:4"] = {36,0},
        ["drawable:6"] = {27,0},
        ["drawable:5"] = {0,0},
        ["drawable:11"] = {56,0},
        ["prop:0"] = {8,0},
    },
    ["female"] = {
        ["drawable:1"] = {0,0},
        ["drawable:8"] = {36,0},
        ["drawable:3"] = {72,0},
        ["drawable:4"] = {35,0}, 
        ["drawable:6"] = {26,0}, 
        ["drawable:5"] = {0,0},
        ["drawable:11"] = {49,0},
        ["prop:0"] = {120,0},
    },
}




local bagProps = {
    1627301588,
    -819563011,
    628215202,
    -935625561,
    -1998455445,
    -375613925,
    600967813,
    1388415578,
    1627301588
}

local dumpsterProp = {
    1748268526,
    -58485588,
    1511880420,
    682791951,
    666561306
}


local vrp_lixeiro = class("vrp_lixeiro",vRP.Extension)


Citizen.CreateThread(function()
    local model = "s_m_y_garbage"
    local pos = vector3(-354.10931396484,-1546.1169433594,27.720872879028)
    local heading = 267.80
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(10)
	end
	local garbagePed = CreatePed(26, GetHashKey(model), pos.x, pos.y, pos.z-1, heading, false, false)
    SetEntityAsMissionEntity(garbagePed,true,true)
	FreezeEntityPosition(garbagePed, true)
	SetModelAsNoLongerNeeded(model)     
	SetEntityCanBeDamaged(garbagePed, 0)
	SetPedAsEnemy(garbagePed, 0)   
	SetBlockingOfNonTemporaryEvents(garbagePed, 1)
	SetPedResetFlag(garbagePed, 249, 1)
	SetPedConfigFlag(garbagePed, 185, true)
	SetPedConfigFlag(garbagePed, 108, true)
	SetPedCanEvasiveDive(garbagePed, 0)
	SetPedCanRagdollFromPlayerImpact(garbagePed, 0)
	SetPedConfigFlag(garbagePed, 208, true)       
	SetEntityHeading(garbagePed, heading)

	exports['qtarget']:AddEntityZone("garbageped", garbagePed, {
		name = "garbageped",
		heading=GetEntityHeading(garbagePed),
		debugPoly=false,
	}, {
		options = {
			{
				event = "vrp_lixeiro:trabalhar",
				icon = "fas fa-file-signature",
				label = "Trabalhar",
                trabalho = true,
                canInteract = function(entity)
                    if not trabalhando then
                        return true
                    else
                        return false
                    end
                end,
			},
            {
				event = "vrp_lixeiro:spawntruck",
				icon = "fas fa-truck",
				label = "Retirar Caminhão",
                trabalho = false,
                canInteract = function(entity)
                    if trabalhando and not selfTruck then
                        return true
                    else
                        return false
                    end
                end,
			},
            {
				event = "vrp_lixeiro:trabalhar",
				icon = "fas fa-file-signature",
				label = "Demitir-se",
                trabalho = false,
                canInteract = function(entity)
                    if trabalhando then
                        return true
                    else
                        return false
                    end
                end,
			},
		},
		distance = 3.5
	})

    while true do
        Citizen.Wait(200)
        FreezeDumpsters()
    end

end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local ped = PlayerPedId()	


            if carregandoBag then
                -- check anim
                if not IsEntityPlayingAnim(ped, 'anim@heists@narcotics@trash', 'walk', 3) then
                    if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
                        RequestAnimDict("anim@heists@narcotics@trash")
                    end
                    while not HasAnimDictLoaded("anim@heists@narcotics@trash") do
                        Citizen.Wait(0)
                    end
                    TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,50,0,0, 0,0)
                end
                -- put trash into truck
                    local pos = GetEntityCoords(GetPlayerPed(-1))
                    local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, 0.0)
                
                    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
                    local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)

                    if vehicleHandle ~= nil and IsVehicleModel(vehicleHandle,GetHashKey("trash2")) then
                            local trunkcoord = GetOffsetFromEntityInWorldCoords(vehicleHandle, 0.0, -5.25, 0.0)
                            local tdistance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),trunkcoord)
                                
                                if tdistance < 3 then
                                    SetVehicleDoorOpen(vehicleHandle,5,0,false)
                                    DisplayHelpText("Pressione ~INPUT_PICKUP~ Para Colocar Lixo")
                                    if IsControlJustPressed(1,38) then
                                        carregandoBag = false
                                        ClearPedTasksImmediately(GetPlayerPed(-1))
                                        TaskPlayAnim(GetPlayerPed(-1), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0,-1,2,0,0, 0,0)
                                        Citizen.Wait(800)
                                        TriggerServerEvent("trydeleteobj", carryBag)
                                        TriggerEvent("cancelando", false)
                                        SetVehicleDoorShut(vehicleHandle,5)
                                        ClearPedTasks(ped)
                                        TriggerServerEvent("vrp_lixeiro:ColocarLixo",1,NetworkGetNetworkIdFromEntity(vehicleHandle))
                                    end
                                end
                    end

            end

            if selfTruck then
                if GetVehiclePedIsIn(ped,false) == selfTruck then
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-333.8020324707,-1565.4508056641,24.943592071533)
                    if distance <= 3 then
                        DisplayHelpText("Pressione ~INPUT_PICKUP~ para guardar caminhão")
                        if IsControlJustPressed(1,38) then
                            SetVehicleHasBeenOwnedByPlayer(selfTruck,false)
                            SetEntityAsMissionEntity(selfTruck, false, true)
                            SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(selfTruck))
                            DeleteVehicle(selfTruck)
                            selfTruck = nil
                        end
                    end
                end

            end

            if trabalhando then
                if IsVehicleModel(GetVehiclePedIsIn(ped,false),GetHashKey("trash2"))then
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)),-328.60488891602,-1522.8067626953,27.53413772583)
                    if distance <= 10 then
                        DisplayHelpText("Pressione ~INPUT_PICKUP~ para descarregar lixo")
                        if IsControlJustPressed(1,38) then
                            local car = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                            TriggerServerEvent("vrp_lixeiro:EntregarLixo",NetworkGetNetworkIdFromEntity(car))
                        end
                    end
                end
            end

    end 
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0,0,1,-1)
end

RegisterNetEvent("vrp_lixeiro:PegarLixo")
AddEventHandler("vrp_lixeiro:PegarLixo",function(data)
    if not carregandoBag then
        NetworkRegisterEntityAsNetworked(data.entity)
        local netid = NetworkGetNetworkIdFromEntity(data.entity)
        if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
            RequestAnimDict("anim@heists@narcotics@trash")
        end
        while not HasAnimDictLoaded("anim@heists@narcotics@trash") do
            Citizen.Wait(0)
        end
        TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'pickup', 1.0, -1.0,-1,50,0,0, 0,0)
        Citizen.Wait(600)
        TriggerServerEvent("trydeleteobj", netid)
        local lixo = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(lixo, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true)
        
        TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,50,0,0, 0,0)
        TriggerEvent("cancelando", true)
        carryBag = NetworkGetNetworkIdFromEntity(lixo)
        carregandoBag = true
    end
end)

RegisterNetEvent('vrp_lixeiro:spawntruck')
AddEventHandler('vrp_lixeiro:spawntruck',function()
	local mhash = GetHashKey("trash2")
	while not HasModelLoaded(mhash) do
		RequestModel(mhash)
		Citizen.Wait(10)
	end

    if not IsAnyVehicleNearPoint(-333.8020324707,-1565.4508056641,24.943592071533,3.0) then

        if HasModelLoaded(mhash) then
            local ped = PlayerPedId()
            selfTruck = CreateVehicle(mhash,-333.8020324707,-1565.4508056641,24.943592071533,237.94,true,false)
            SetVehicleIsStolen(selfTruck,false)
            SetVehicleOnGroundProperly(selfTruck)
            SetEntityInvincible(selfTruck,false)
            Citizen.InvokeNative(0xAD738C3085FE7E11,selfTruck,true,true)
            SetVehicleHasBeenOwnedByPlayer(selfTruck,true)
            SetVehicleDirtLevel(selfTruck,0.0)
            SetVehRadioStation(selfTruck,"OFF")
            SetVehicleDoorsLocked(selfTruck,1)
            SetVehicleDoorsLockedForAllPlayers(selfTruck,false)
            SetVehicleDoorsLockedForPlayer(selfTruck,PlayerId(),false)
            SetVehicleEngineOn(GetVehiclePedIsIn(ped,false),true)
            SetModelAsNoLongerNeeded(mhash)
            TriggerEvent("Notify","sucesso","Seu Caminhão foi retirado")
        end
    else
        TriggerEvent("Notify","negado","Vaga esta ocupada")
    end
end)

RegisterNetEvent("vrp_lixeiro:trabalhar")
AddEventHandler("vrp_lixeiro:trabalhar",function(data)
    if data.trabalho and not trabalhando then
        trabalhando = true

        -- blip
        descarregarBlip = AddBlipForCoord(-328.60488891602,-1522.8067626953,27.53413772583)
        SetBlipSprite(descarregarBlip,642)
        SetBlipColour(descarregarBlip,4)
        SetBlipScale(descarregarBlip,0.7)
        SetBlipAsShortRange(descarregarBlip,false)
        SetBlipRoute(descarregarBlip,false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Descarregar Caminhão")
        EndTextCommandSetBlipName(descarregarBlip)
        
        -- pegar sacos de lixo
        exports['qtarget']:AddTargetModel(bagProps, {
            options = {
                {
                    event = "vrp_lixeiro:PegarLixo",
                    icon = "fas fa-trash",
                    label = "Pegar Lixo",
                },
            },
            distance = 2.0
        })

        -- pegar lixos da lixeira
        exports['qtarget']:AddTargetModel(dumpsterProp, {
            options = {
                {
                    event = "vrp_lixeiro:PegarDumpsterLixo",
                    icon = "fas fa-trash",
                    label = "Pegar Lixo",
                },
            },
            distance = 2.0
        })

        -- setar uniforme
        DoScreenFadeOut(250)
        while not IsScreenFadedOut() do
        Citizen.Wait(10)
        end
        if IsMale(PlayerPedId()) then
            TriggerServerEvent("vrp_lixeiro:Uniforme",true,uniformes["male"])
        else
            TriggerServerEvent("vrp_lixeiro:Uniforme",true,uniformes["female"])
        end
        Citizen.Wait(150)
        DoScreenFadeIn(250)
        TriggerEvent("Notify","importante","Você foi contratado para trabalhar como <b>lixeiro</b>")
    elseif not data.trabalho and trabalhando then
        trabalhando = false
        exports['qtarget']:RemoveTargetModel(bagProps,{"Pegar Lixo"})
        exports['qtarget']:RemoveTargetModel(dumpsterProp,{"Pegar Lixo"})
        RemoveBlip(descarregarBlip)

        -- retira uniforme
        DoScreenFadeOut(250)
        while not IsScreenFadedOut() do
        Citizen.Wait(10)
        end
        TriggerServerEvent("vrp_lixeiro:Uniforme",false)
        Citizen.Wait(150)
        DoScreenFadeIn(250)
        TriggerEvent("Notify","importante","Você se demitiu do serviço")
    end
end)

function IsMale(ped)
	if IsPedModel(ped, 'mp_m_freemode_01') then
		return true
	else
		return false
	end
end


function vrp_lixeiro:__construct()
	vRP.Extension.__construct(self)

RegisterNetEvent("vrp_lixeiro:PegarDumpsterLixo")
AddEventHandler("vrp_lixeiro:PegarDumpsterLixo",function(data)
    if not carregandoBag then
            if self.remote.IsDumpsterEmpty(GetEntityCoords(data.entity)) then 
                TriggerEvent("Notify","aviso","Esta lixeira esta vazia")
                return
            else
                self.remote.setDumpster(GetEntityCoords(data.entity), 2100)
            end
        if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
            RequestAnimDict("anim@heists@narcotics@trash")
        end
        while not HasAnimDictLoaded("anim@heists@narcotics@trash") do
            Citizen.Wait(0)
        end
        TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'pickup', 1.0, -1.0,-1,50,0,0, 0,0)
        Citizen.Wait(600)
        local lixo = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(lixo, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true)
        
        TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,50,0,0, 0,0)
        TriggerEvent("cancelando", true)
        carryBag = NetworkGetNetworkIdFromEntity(lixo)
        carregandoBag = true
    end
end)


end

function FreezeDumpsters()
    local playerped = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerped)
    local handle, ped = FindFirstObject()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(ped)
        local distance = GetDistanceBetweenCoords(playerCoords, pos, true)
        if distance < 10.0 then
            distanceFrom = distance
            rped = ped

            for k,v in pairs(dumpsterProp) do
                if GetEntityModel(ped) == v then
                    FreezeEntityPosition(ped, true)
                end
            end


        end

        success, ped = FindNextObject(handle)
    until not success
    EndFindObject(handle)
end


vRP:registerExtension(vrp_lixeiro)