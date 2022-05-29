if SERVER then
	AddCSLuaFile("jhud/cl_jhud.lua")
	AddCSLuaFile("jhud/cl_menu.lua")
	include("jhud/sv_jhud.lua")
else
	include("jhud/cl_jhud.lua")
	include("jhud/cl_menu.lua")
end