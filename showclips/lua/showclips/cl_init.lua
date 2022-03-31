local luabsp = include("luabsp.lua")

local COLOR_ACCENT = Color(255, 0, 123, 200)
local MAT_WIRE = CreateMaterial("showclips_wire", "Wireframe", { 
    ["$vertexalpha"] = 1,
})
local MAT_SOLID = CreateMaterial("showclips_solid", "UnlitGeneric", { 
    ["$basetexture"] = "color/white",
    ["$vertexalpha"] = 1,
})

local g_clipBrushes = nil
local g_visible = false
local g_material = MAT_SOLID

-- Convars
local cv_enabled = CreateClientConVar("showclips", "0", false, true, "Enable or disable player clip brushes", 0, 1)
local cv_solid = CreateClientConVar("showclips_solid", "1", true, false, "Draw solid clips or wireframe", 0, 1)
local cv_color = CreateClientConVar("showclips_color", "255 0 123 64", true, false, "Clips brush draw color \"R G B A\"")

local function ChatMessage(phrase) 
    chat.AddText(color_white, "[", COLOR_ACCENT, "ShowClips", color_white, "] ", language.GetPhrase(phrase))
end

local function UpdateMaterial(cv, old, new)
    if cv and new == old then return end
    local col = string.ToColor(cv_color:GetString())

    g_material = cv_solid:GetBool() and MAT_SOLID or MAT_WIRE
    g_material:SetFloat("$alpha", col.a / 255)
    g_material:SetVector("$color", col:ToVector())
end

local function LoadClipBrushes(cb)
    if g_clipBrushes then return cb(true) end
    ChatMessage("showclips.msg.lags")

    timer.Simple(0.1, function()
        -- Handle errors
        local ok, err = pcall(function()
            local bsp = luabsp.LoadMap(game.GetMap())
            if bsp then
                g_clipBrushes = bsp:GetClipBrushes(false)
            end
            print("[ShowClips]", "Found " .. #g_clipBrushes .. " brushes")
        end)
        if not ok then
            ChatMessage("showclips.msg.error")
            print("[ShowClips]", err)
        end
        cb(ok)
    end)
end

local function DrawClipBrushes()
    render.OverrideDepthEnable(true, true)
    render.SetMaterial(g_material)
    for _, mesh in ipairs(g_clipBrushes) do
        mesh:Draw()
    end
    render.OverrideDepthEnable(false)
end

local function ToggleClipBrushes()
    if cv_enabled:GetBool() then
        LoadClipBrushes(function(ok)
            if not ok then return cv_enabled:SetBool(false) end
            hook.Add("PostDrawOpaqueRenderables", "bhop_showclips", DrawClipBrushes)
            ChatMessage("showclips.msg.enabled")
            UpdateMaterial()
        end)
    else
        hook.Remove("PostDrawOpaqueRenderables", "bhop_showclips")
        ChatMessage("showclips.msg.disabled")
    end
end

local function OpenConfigMenu()
    local w = vgui.Create("DFrame")
	w:SetSize(250, 300)
    w:SetTitle("#showclips.gui.title")
    w:SetDeleteOnClose(true)
    w:SetDraggable(true)
    w:SetSizable(true)

	local enab = w:Add("DCheckBoxLabel")
	enab:SetText("#showclips.gui.enabled")
    enab:SetChecked(cv_enabled:GetBool())
	enab:SetConVar(cv_enabled:GetName())
	enab:SizeToContents()
    enab:DockMargin(0, 0, 0, 4)
    enab:Dock(TOP)

	local solid = w:Add("DCheckBoxLabel")
	solid:SetText("#showclips.gui.solid")
    solid:SetChecked(cv_solid:GetBool())
	solid:SetConVar(cv_solid:GetName())
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

concommand.Add("showclips_menu", OpenConfigMenu, nil, "Open playerclips config menu")

-- Convar callbacks
cvars.AddChangeCallback(cv_enabled:GetName(), ToggleClipBrushes, "showclips_enabled")
cvars.AddChangeCallback(cv_solid:GetName(), UpdateMaterial, "showclips_solid")
cvars.AddChangeCallback(cv_color:GetName(), UpdateMaterial, "showclips_color")
UpdateMaterial()

-- i18n
language.Add("showclips.msg.lags", "Reading player clips information from map. There may be some lags...")
language.Add("showclips.msg.enabled", "Player clips are enabled. Use !clipsmenu to configure")
language.Add("showclips.msg.disabled", "Player clips are now disabled!")
language.Add("showclips.msg.error", "Cant load player clips (see error message in console ~)")
language.Add("showclips.gui.title", "ShowClips menu")
language.Add("showclips.gui.enabled", "Draw player clips")
language.Add("showclips.gui.solid", "Draw solid brushes (not wireframe)")
