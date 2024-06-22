
local vrp_lixeiro = class("vrp_lixeiro",vRP.Extension)

function vrp_lixeiro:__construct()
	vRP.Extension.__construct(self)
end

vrp_lixeiro.tunnel = {}

function table.empty(self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

local garbagetrucks = {}
local dumpsters = {}
local trashPrice = 20

-- list of waste materials that can be found when collecting a bag of garbage and chance of obtaining them
local waste = {
    {name = "reciclagem",chance=7},
    {name = "fvq",chance=4},
    {name = "benzedrina",chance=2},
}

math.randomseed(os.time())

function randomTrashChance(percent) 
    assert(percent >= 0 and percent <= 100) 
    return percent >= math.random(1, 100)   
                                            
end

function vrp_lixeiro.tunnel:IsDumpsterEmpty(pos)
    for k,v in pairs(dumpsters) do
        if v.pos == pos then
            if v.timer > 0 then
                return true
            else
                return false
            end
        end
    end
    return false
end

function vrp_lixeiro.tunnel:setDumpster(pos,timer)
    table.insert(dumpsters,{pos=pos,timer=timer})
end

RegisterServerEvent("vrp_lixeiro:PutTrashInTruck")
AddEventHandler("vrp_lixeiro:PutTrashInTruck",function(val,nvehid)
    local source = source
    local user = vRP.users_by_source[source]
    local garbageIndex = nil
 
    if not garbagetrucks[nvehid] then
        garbagetrucks[nvehid] = {}
    end

    for i,v in pairs(garbagetrucks[nvehid]) do
        if v.char == user.cid then
            garbageIndex = i
        end
    end

    if garbageIndex then
        garbagetrucks[nvehid][garbageIndex].lixos = garbagetrucks[nvehid][garbageIndex].lixos + val
    else
        table.insert(garbagetrucks[nvehid],{char=user.cid,lixos=val})
    end

    for i,v in pairs(waste) do
        if randomTrashChance(v.chance)  then
            user:tryGiveItem(v.name, math.random(1,5))
            TriggerClientEvent("Notify",user.source,"importante","Você encontrou algo no saco de lixo")
            break
        end
     end
end)

RegisterServerEvent("vrp_lixeiro:DumpTrash")
AddEventHandler("vrp_lixeiro:DumpTrash",function(nvehid)
    local source = source
    local user = vRP.users_by_source[source]
    
    if garbagetrucks[nvehid] and not table.empty(garbagetrucks[nvehid]) then 

        for i,v in pairs(garbagetrucks[nvehid]) do
            local player = vRP.users_by_cid[v.char]
            if player then
                local reward = v.lixos*trashPrice
                player:giveWallet(reward)
                TriggerClientEvent("Notify",player.source,"importante","Você recebeu <b>$"..reward.."</b> pela coleta de lixo")
            end
        end


        garbagetrucks[nvehid] = {}
    else
        TriggerClientEvent("Notify",user.source,"aviso","Este caminhão não possui sacos de lixo")
    end
end)

RegisterServerEvent("vrp_lixeiro:Uniform")
AddEventHandler("vrp_lixeiro:Uniform",function(value,sex)
    local source = source
    local user = vRP.users_by_source[source]
    if not sex or not value then
        user:removeCloak()
    else
        user:setCloak(sex)  
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(dumpsters) do
			if v.timer > 0 then
                v.timer = v.timer - 1
			end
		end
	end
end)


vRP:registerExtension(vrp_lixeiro)
