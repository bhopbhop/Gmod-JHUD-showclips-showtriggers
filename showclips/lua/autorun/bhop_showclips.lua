-- Garry's mod Bunnyhop ShowClips addon
-- By CLazStudio: steamcommunity.com/id/CLazStudio
-- luabsp.lua by h3xcat: github.com/h3xcat

if SERVER then
    AddCSLuaFile("showclips/luabsp.lua")
    AddCSLuaFile("showclips/cl_init.lua")

    include("showclips/sv_init.lua")
else
    include("showclips/cl_init.lua")
end
