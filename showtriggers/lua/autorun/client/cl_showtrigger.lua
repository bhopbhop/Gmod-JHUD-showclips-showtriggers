-- Made by Gaztoof
-- Half the credits go to Claz, he made a good majority of this! I "ported" his showclips to work with showtriggers (showclips works with map's data, showtriggers works with entities networked from server, so yep totally different)
-- I(gaztoof) made the serverside stuff too

local COLOR_ACCENT = Color(255, 0, 123, 200)
local MAT_WIRE = CreateMaterial("showtriggers_wire", "Wireframe", { 
    ["$vertexalpha"] = 1,
})
local MAT_SOLID = CreateMaterial("showtriggers_solid", "UnlitGeneric", { 
    ["$basetexture"] = "color/white",
    ["$vertexalpha"] = 1,
})

local TriggerTable = { ["trigger_teleport"] = {}, ["trigger_push"] = {}, ["trigger_multiple"] = {}}
local ValidClass = {["trigger_teleport"] = true, ["trigger_push"] = true, ["trigger_multiple"] = true}

local g_clipBrushes = nil
local g_visible = false
local g_material = MAT_SOLID

-- Convars
local cv_enabled = CreateClientConVar("showtriggers_enabled", "0", false, true, "Enable or disable player triggers brushes", 0, 1)
local cv_overridedepth = CreateClientConVar("showtriggers_override", "0", true, false, "Override depth", 0, 1)
local cv_default = CreateClientConVar("showtriggers_default", "0", true, false, "Draw default triggers or solid triggers", 0, 1)
local cv_wireframe = CreateClientConVar("showtriggers_wireframe", "0", true, false, "Draw wireframe triggers", 0, 1)
local cv_color = CreateClientConVar("showtriggers_color", "255 0 123 64", true, false, "Triggers brush draw color \"R G B A\"")

local function ChatMessage(phrase) 
    chat.AddText(color_white, "[", COLOR_ACCENT, "ShowTriggers", color_white, "] ", language.GetPhrase(phrase))
end

local function UpdateMaterial(cv, old, new)
    if cv and new == old then return end
    local col = string.ToColor(cv_color:GetString())

    g_material = cv_wireframe:GetBool() and MAT_WIRE or MAT_SOLID
    g_material:SetFloat("$alpha", col.a / 255)
    g_material:SetVector("$color", col:ToVector())
end
UpdateMaterial()

local function LoadTriggersBrushes()
    local ok, err = pcall(function()
        g_triggersBrushes = {}
        for k,p in pairs(ValidClass) do
            for _,ent in pairs(ents.FindByClass(k)) do
                if !table.KeyFromValue(g_triggersBrushes,ent) then
                    table.insert(g_triggersBrushes,ent)
                end
            end
        end            
    end)
    if not ok then
        ChatMessage("showtriggers.msg.error")
        print("[ShowTriggers]", err)
    end
end

local function DrawTriggersBrushes()
    LoadTriggersBrushes()

    render.SetMaterial(g_material)
    if not g_triggersBrushes or #g_triggersBrushes < 1 then
        g_triggersBrushes = {}
        LoadTriggersBrushes(function(ok)end)
    end
    local wireframeST = cv_wireframe:GetBool()
    local defaultST = cv_default:GetBool()
    if cv_overridedepth:GetBool() then
        render.OverrideDepthEnable(true, true)
    end

    for _, mesh in ipairs(g_triggersBrushes) do
        if defaultST then
            mesh:RemoveEffects(EF_NODRAW)
        else 
            mesh:AddEffects(EF_NODRAW)
        end
        if not defaultST then
            render.DrawBox(mesh:GetPos(), mesh:GetAngles(), mesh:OBBMins(), mesh:OBBMaxs(), g_material:GetVector("$color"))
        end
    end

    render.OverrideDepthEnable(false)
end

local function ToggleTriggersBrushes()
    local newState = cv_enabled:GetBool()
    
    net.Start("showtriggers_state")
    net.WriteBool(newState)
    net.SendToServer()

    if newState then
        hook.Add("PostDrawOpaqueRenderables", "ShowTriggers:DrawTriggersBrushes", DrawTriggersBrushes)
        ChatMessage("showtriggers.msg.enabled")
        UpdateMaterial()
    else
        hook.Remove("PostDrawOpaqueRenderables", "ShowTriggers:DrawTriggersBrushes")
        ChatMessage("showtriggers.msg.disabled")
    end
end

function RemoveEntFromTable(ent)
    local class = ent:GetClass()
    if ValidClass[class] then
		table.remove(g_triggersBrushes,table.KeyFromValue(g_triggersBrushes,ent))
    end
end
hook.Add("EntityRemoved","ShowTriggers:RemoveEntFromTable",RemoveEntFromTable)


local function OpenConfigMenu()
    local w = vgui.Create("DFrame")
	w:SetSize(250, 300)
    w:SetTitle("#showtriggers.gui.title")
    w:SetDeleteOnClose(true)
    w:SetDraggable(true)
    w:SetSizable(true)

	local enab = w:Add("DCheckBoxLabel")
	enab:SetText("#showtriggers.gui.enabled")
    enab:SetChecked(cv_enabled:GetBool())
	enab:SetConVar(cv_enabled:GetName())
	enab:SizeToContents()
    enab:DockMargin(0, 0, 0, 4)
    enab:Dock(TOP)

    local wire = w:Add("DCheckBoxLabel")
	wire:SetText("#showtriggers.gui.wireframe")
    wire:SetChecked(cv_wireframe:GetBool())
	wire:SetConVar(cv_wireframe:GetName())
	wire:SizeToContents()
    wire:DockMargin(0, 0, 0, 4)
    wire:Dock(TOP)
    
    local override = w:Add("DCheckBoxLabel")
	override:SetText("#showtriggers.gui.override")
    override:SetChecked(cv_overridedepth:GetBool())
	override:SetConVar(cv_overridedepth:GetName())
	override:SizeToContents()
    override:DockMargin(0, 0, 0, 4)
    override:Dock(TOP)

	local solid = w:Add("DCheckBoxLabel")
	solid:SetText("#showtriggers.gui.default")
    solid:SetChecked(cv_default:GetBool())
	solid:SetConVar(cv_default:GetName())
	solid:SizeToContents()
    solid:Dock(TOP)

    local mixer = vgui.Create("DColorMixer", w)
    mixer:Dock(FILL)
    mixer:SetPalette(true)
    mixer:SetAlphaBar(true)
    mixer:SetWangs(true)
    mixer:SetColor(string.ToColor(cv_color:GetString()))
    mixer:DockMargin(0, 4, 0, 4)
    mixer.ValueChanged = function(self, col)
        cv_color:SetString(string.FromColor(col))
    end
    
	local close = w:Add("DButton")
    close:SetText("#close")
    close:Dock(BOTTOM)
    close.DoClick = function() w:Close() end

	w:Center()
    local x, y = w:GetPos()
    w:SetPos(4, y)
	w:MakePopup()
    return w
end
concommand.Add("showtriggers_menu", OpenConfigMenu, nil, "Open showtriggers config menu")


cvars.AddChangeCallback(cv_enabled:GetName(), ToggleTriggersBrushes, "showtriggers_enabled")
cvars.AddChangeCallback(cv_default:GetName(), UpdateMaterial, "showtriggers_default")
cvars.AddChangeCallback(cv_wireframe:GetName(), UpdateMaterial, "showtriggers_wireframe")
cvars.AddChangeCallback(cv_color:GetName(), UpdateMaterial, "showtriggers_color")

language.Add("showtriggers.msg.enabled", "Player triggers are enabled. Use !triggersmenu to configure")
language.Add("showtriggers.msg.disabled", "Player triggers are now disabled!")
language.Add("showtriggers.msg.error", "Can't load player triggers (see error message in console ~)")
language.Add("showtriggers.gui.title", "ShowTriggers menu")
language.Add("showtriggers.gui.enabled", "Draw player triggers")
language.Add("showtriggers.gui.wireframe", "Draw wireframe triggers")
language.Add("showtriggers.gui.default", "Draw default triggers")
language.Add("showtriggers.gui.override", "Override depth")