local TOGGLE_COMMANDS = { "showclips", "clips", "hideclips", "toggleclips", "sc" }
local MENU_COMMANDS = { "clipsmenu", "clipsconfig" }

local function ToggleClips(ply)
    ply:ConCommand("showclips " .. (ply:GetInfoNum("showclips", 0) == 1 and "0" or "1"))
end

local function OpenMenu(ply)
    ply:ConCommand("showclips_menu")
end

-- Add chat commands after gamemode initialization
hook.Add("Initialize", "bhop_showclips", function()
    if istable(Command) and isfunction(Command.Register) then 
        -- FLOW v7
        Command:Register(TOGGLE_COMMANDS, ToggleClips)
        Command:Register(MENU_COMMANDS, OpenMenu)
    elseif istable(Core) and isfunction(Core.AddCmd) then
        -- FLOW v8
        Core.AddCmd(TOGGLE_COMMANDS, ToggleClips)
        Core.AddCmd(MENU_COMMANDS, OpenMenu)
    else
        -- Default
        hook.Add("PlayerSay", "bhop_showclips", function(ply, str)
            local prefix = str[1]
            if prefix == "!" or prefix == "/" then
                local cmd = string.Explode(" ", string.lower(string.sub(str, 2)))[1]
            
                if table.HasValue(TOGGLE_COMMANDS, cmd) then 
                    ToggleClips(ply) 
                    return ""
                end
        
                if table.HasValue(MENU_COMMANDS, cmd) then 
                    OpenMenu(ply)
                    return "" 
                end
            end
        end)
    end
end)
