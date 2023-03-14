fx_version 'cerulean'
games { 'rdr3', 'gta5' }

dependencies {
	"qtarget",
    "vrp"
}

client_scripts {
	"@vrp/lib/utils.lua",
	"client.lua"
}

server_scripts{
	"@vrp/lib/utils.lua",
	"vrp.lua"
}