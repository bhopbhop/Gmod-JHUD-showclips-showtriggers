-- Made by Gaztoof
-- Based on Meeno's code, he made a part of this and I recoded it entirely.

-- List of keywords
local Commands = { 
	["triggers"] = 
	{
		"trigger",
		"triggers",
		"showtrigger",
		"showtriggers",
		"st",
	}, 
	["triggersmenu"] = 
	{
		"triggermenu",
		"triggersmenu",
	}
}

local TriggerTable = { ["trigger_teleport"] = {}, ["trigger_push"] = {}, ["trigger_multiple"] = {}}

local ValidClass = {["trigger_teleport"] = true, ["trigger_push"] = true, ["trigger_multiple"] = true}

local IWishDadLovedMe = {false}

util.AddNetworkString( "showtriggers_state" )
net.Receive("showtriggers_state", function( len, ply )
	local newState = net.ReadBool()
	SetTriggersState(ply, newState)
end)

hook.Add("PlayerSay","ShowTriggers:ToggleCommand",function(ply,txt)
	local Prefix = string.sub(txt,0,1)
	if Prefix == "!" or Prefix == "/" then
		local PlayerCmd = string.lower(string.sub(txt,2))
		for k,_v in pairs(Commands) do
			for _k, v in pairs(_v) do
				if PlayerCmd == v then
					if k == "triggers" then
						local newState = (ply:GetInfoNum("showtriggers_enabled", 0) == 1 and 0 or 1)
						ply:ConCommand("showtriggers_enabled " .. tostring(newState))
						SetTriggersState(ply, newState)
						return ""
					elseif k == "triggersmenu" then
						ply:ConCommand("showtriggers_menu")
						return ""
					end
				end
			end
		end
	end
end)

local function InitializeTriggerTable()	
	for k,p in pairs(ValidClass) do
		for _,ent in pairs(ents.FindByClass(k)) do
			table.insert(TriggerTable[k],ent)
		end
	end
end
hook.Add("InitPostEntity","ShowTriggers:InitializeTriggerTable",InitializeTriggerTable)
InitializeTriggerTable()

local function InitSpawnPreventTransmit(ply)
	if ply:IsBot() then return end 

	IWishDadLovedMe[ply] = false

	-- This was more consistently faster compared to for i = 1,#t do but both had slower/faster calls
	for _,t in pairs(TriggerTable) do
		for k,p in pairs(t) do
			if p and p:IsValid() then
				p:RemoveEffects(EF_NODRAW)
				p:SetPreventTransmit(ply, !IWishDadLovedMe[pl])
			end
		end
	end

end
hook.Add("PlayerInitialSpawn","ShowTriggers:PlayerInitialSpawn",InitSpawnPreventTransmit)

function SetTriggersState(ply, state)
	IWishDadLovedMe[ply] = state

	for _,t in pairs(TriggerTable) do
		for k,p in pairs(t) do
			p:SetPreventTransmit(ply, !state)
		end
	end
end

function RemoveEntFromTable(ent)
    local class = ent:GetClass()
    if ValidClass[class] then
		table.remove(TriggerTable[class],table.KeyFromValue(TriggerTable[class],ent))
    end
end
hook.Add("EntityRemoved","ShowTriggers:RemoveEntFromTable",RemoveEntFromTable)