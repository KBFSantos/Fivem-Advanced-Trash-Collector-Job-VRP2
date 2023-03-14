local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

async(function()
    vRP.loadScript("vrp_lixeiro", "server") -- load "my_resource/vrp.lua"
end)