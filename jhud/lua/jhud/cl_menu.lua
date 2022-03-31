include("cl_jhud.lua")

/*JHUD = { 
    Data = 
    { 
        Gain = {}, 
        AngleFraction = 1, 
        Jumps = {}, 
        HoldingSpace = false 
    },
    Trainer = 
    { 
        Enabled = true,
        Width = ScrW()/6, 
        Height = ScrH()/20, 
        HeightOffset = ScrH()/4.8, 
        CornerSize = 5, 
        DynamicBarWidth = ScrW()/860, 
        StaticBarWidth = ScrW()/860,
        DynamicBarColor = Color(220, 220, 220, 220),
        StaticBarColor = Color(220, 220, 220, 220),
        RectangleColor = Color(220, 220, 220, 126),
        DynamicRectangleColor = true,
        TextColor = color_white,
    },
    HUD = 
    {

    }
}*/

local function JHUD_UpdateSettings()
    net.Start("JHUD_UpdateSettings")
        net.WriteBool(JHUD.HUD.Enabled)
        net.WriteBool(JHUD.Trainer.Enabled)
        net.WriteBool(JHUD.Trainer.DynamicRectangleColor)
        net.WriteUInt(JHUD.Trainer.Width, 10)
        net.WriteUInt(JHUD.Trainer.Height, 7)
        net.WriteInt(JHUD.Trainer.HeightOffset, 10)
        net.WriteString( string.FromColor( JHUD.Trainer.RectangleColor ) )
        net.WriteString( string.FromColor( JHUD.Trainer.TextColor ) )
    net.SendToServer()
end

local function OpenMenu()
    local window = vgui.Create("DFrame")
	window:SetSize(250, 430)
    window:SetTitle("#jhud.gui.title")
    window:SetDeleteOnClose(true)
    window.OnClose = function() JHUD_UpdateSettings() end
    window:SetDraggable(true)
    window:SetSizable(true)

    local jhudEnabled = window:Add("DCheckBoxLabel")
	jhudEnabled:SetText("#jhud.gui.jhud.enabled")
	jhudEnabled:SizeToContents()
    jhudEnabled:DockMargin(0, 0, 0, 4)
    jhudEnabled:Dock(TOP)
    jhudEnabled:SetChecked(JHUD.HUD.Enabled)
    jhudEnabled.OnChange = function(v) JHUD.HUD.Enabled = v:GetChecked() end

    local trainerEnabled = window:Add("DCheckBoxLabel")
	trainerEnabled:SetText("#jhud.gui.trainer.enabled")
	trainerEnabled:SizeToContents()
    trainerEnabled:DockMargin(0, 0, 0, 4)
    trainerEnabled:Dock(TOP)
    trainerEnabled:SetChecked(JHUD.Trainer.Enabled)
    trainerEnabled.OnChange = function(v) JHUD.Trainer.Enabled = v:GetChecked() end

    local dynamicCol = window:Add("DCheckBoxLabel")
	dynamicCol:SetText("#jhud.gui.trainer.dynamiccolor")
	dynamicCol:SizeToContents()
    dynamicCol:DockMargin(0, 0, 0, 4)
    dynamicCol:Dock(TOP)
    dynamicCol:SetChecked(JHUD.Trainer.DynamicRectangleColor)
    dynamicCol.OnChange = function(v) JHUD.Trainer.DynamicRectangleColor = v:GetChecked() end

    local wslider = window:Add("DNumSlider")
    wslider:SetSize(0, 20)
    wslider:SetMin( 200 )
    wslider:SetMax( 800 )
    wslider:SetDecimals( 0 )
    wslider:SetText("#jhud.gui.trainer.width")
    wslider:Dock(TOP)
    wslider:SetValue(JHUD.Trainer.Width)
    wslider.OnValueChanged = function(_, v) JHUD.Trainer.Width = v end

    local hslider = window:Add("DNumSlider")
    hslider:SetSize(0, 20)
    hslider:SetMin( 20 )
    hslider:SetMax( 100 )
    hslider:SetDecimals( 0 )
    hslider:SetText("#jhud.gui.trainer.height")
    hslider:Dock(TOP)
    hslider:SetValue(JHUD.Trainer.Height)
    hslider.OnValueChanged = function(_, v) JHUD.Trainer.Height = v end

    local hoffset = window:Add("DNumSlider")
    hoffset:SetSize(0, 20)
    hoffset:SetMin( -500 )
    hoffset:SetMax( 500 )
    hoffset:SetDecimals( 0 )
    hoffset:SetText("#jhud.gui.trainer.offset")
    hoffset:DockMargin(0, 0, 0, 4)
    hoffset:Dock(TOP)
    hoffset:SetValue(JHUD.Trainer.HeightOffset)
    hoffset.OnValueChanged = function(_, v) JHUD.Trainer.HeightOffset = v end

    local rectCol = window:Add("DColorMixer")
    rectCol:SetSize(0, 120)
    rectCol:SetPalette(false)
    rectCol:SetAlphaBar(true)
    rectCol:DockMargin(0, 0, 0, 4)
    rectCol:Dock(TOP)
    rectCol:SetColor(JHUD.Trainer.RectangleColor)
    rectCol.ValueChanged = function(_, v) JHUD.Trainer.RectangleColor = v end

    local textCol = window:Add("DColorMixer")
    textCol:SetSize(0, 120)
    textCol:SetPalette(false)
    textCol:SetAlphaBar(true)    
    textCol:DockMargin(0, 0, 0, 4)
    textCol:Dock(TOP)
    textCol:SetColor(JHUD.Trainer.TextColor)
    textCol.ValueChanged = function(_, v) JHUD.Trainer.TextColor = v end

    
	local close = window:Add("DButton")
    close:SetText("#close")
    close:Dock(BOTTOM)
    close.DoClick = function() window:Close() end

	window:Center()
    local x, y = window:GetPos()
    window:SetPos(4, y)
	window:MakePopup()
    return window
end

local function JHUD_RetrieveSettings()
    local openMenu = net.ReadBool()

    JHUD.HUD.Enabled = net.ReadBool()
	JHUD.Trainer.Enabled = net.ReadBool()
	JHUD.Trainer.DynamicRectangleColor = net.ReadBool()
	JHUD.Trainer.Width = net.ReadUInt(10)
	JHUD.Trainer.Height = net.ReadUInt(7)
	JHUD.Trainer.HeightOffset = net.ReadInt(10)
	JHUD.Trainer.RectangleColor = net.ReadColor()
	JHUD.Trainer.TextColor = net.ReadColor()

    if openMenu then
        OpenMenu()
    end
end
net.Receive( "JHUD_RetrieveSettings", JHUD_RetrieveSettings )


language.Add("jhud.gui.title", "JHUD Menu")
language.Add("jhud.gui.jhud.enabled", "Enable JHUD")
language.Add("jhud.gui.trainer.enabled", "Enable Strafe Trainer")
language.Add("jhud.gui.trainer.width", "Width")
language.Add("jhud.gui.trainer.height", "Height")
language.Add("jhud.gui.trainer.offset", "Height Offset")
language.Add("jhud.gui.trainer.dynamiccolor", "Dynamic trainer color")