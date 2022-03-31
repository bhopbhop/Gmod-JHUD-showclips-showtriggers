-- Credits for this go to Gaztoof

JHUD = { 
    Data = 
    { 
        Gains = {},
        Gain = 0, 
        JSSTable = {},
        JSS = 0, 
        LastTickVel = 0, 
        AngleFraction = 1, 
        LastUpdate = 0,
        Jumps = {}, 
        HoldingSpace = false,
    },
    DisplayData = table.Copy(Data),
    Trainer = 
    { 
        -- Basically those are scaleable, meaning their size will change depending on your screen resolution
        Enabled = false,
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
        Enabled = false,
    },
    WaitingForUpd = false,
}

local function JHUD_Notify( len, ply )
    JHUD.WaitingForUpd = true
    JHUD.DisplayData = table.Copy(JHUD.Data)
    JHUD.Data.Gain = net.ReadFloat()
end
net.Receive( "JHUD_Notify", JHUD_Notify )

surface.CreateFont( "JHUDMain", { size = 38, weight = 4000, font = "Trebuchet24" } )
surface.CreateFont( "JHUDTrainer", { size = 30, weight = 800, font = "DermaDefaultBold" } )

local function TableAverage(tab)
    local final = 0
    for k, v in pairs(tab) do
        final = final + v
    end
    return final / #tab
end
local function ResetData()
    table.Empty(JHUD.Data.Jumps)
    table.Empty(JHUD.Data.Gains)
    table.Empty(JHUD.Data.JSSTable)
    JHUD.Data.LastTickVel = 0
    JHUD.DisplayData = table.Copy(JHUD.Data)
end
local function LocalVelocity()
    local velocity = LocalPlayer():GetVelocity()
    velocity.z = 0
    return velocity:Length()
end

local counter = 0
local lastCounterVal = "0"
local fading = 255
local BackupData = JHUD.Data
hook.Add( "HUDPaint", "JHud:HUDPaint", function()
    local oColor = surface.GetDrawColor()
    if not LocalPlayer() or LocalPlayer():GetObserverMode() > 0 then return true  end
    if not JHUD.DisplayData then JHUD.DisplayData = table.Copy(JHUD.Data) end
    
    --local percentage = math.Clamp(math.abs(math.sin( CurTime() ) * 2), 0, 2)
    local percentage = math.Clamp(JHUD.Data.AngleFraction, 0, 2)
    
    counter = counter + 1

    local rectColor = JHUD.Trainer.RectangleColor
    if JHUD.Trainer.DynamicRectangleColor == true then
        rectColor = Color((1 - percentage)*255, (percentage - 1) * 255, 0, JHUD.Trainer.RectangleColor.a)
    end

    -- Strafe Trainer
    if /*LocalVelocity() > 100 and */JHUD.Trainer.Enabled == true then
        -- The Rectangle
        surface.SetDrawColor( rectColor )
        surface.DrawOutlinedRect( ScrW()/2 - JHUD.Trainer.Width/2, ScrH()/2 - JHUD.Trainer.Height/2 + JHUD.Trainer.HeightOffset, JHUD.Trainer.Width, JHUD.Trainer.Height, JHUD.Trainer.CornerSize )

        -- The static bar (middle)
        surface.SetDrawColor( JHUD.Trainer.StaticBarColor )
        surface.DrawRect(ScrW() / 2 - JHUD.Trainer.StaticBarWidth/2, ScrH() / 2 - JHUD.Trainer.Height/2 + JHUD.Trainer.HeightOffset - 10, JHUD.Trainer.StaticBarWidth, JHUD.Trainer.Height + 10*2)

        -- The dynamic bar (moving one)
        surface.SetDrawColor( JHUD.Trainer.DynamicBarColor )
        local maxBarOffset = (JHUD.Trainer.Width/2 - JHUD.Trainer.CornerSize)
        local barOffset = maxBarOffset * percentage - JHUD.Trainer.DynamicBarWidth*(percentage/2)
        
        -- Very unoptimal!!!
        if counter % 10 == 0 then -- do it once every x frames
            lastCounterVal = tostring(math.Round(percentage * 100, 0))
        elseif counter > 100000 then
            counter = 0
        end

        draw.SimpleText(lastCounterVal.."%", "JHUDTrainer", ScrW() / 2, (ScrH() / 2) + JHUD.Trainer.HeightOffset - JHUD.Trainer.Height, JHUD.Trainer.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.DrawRect(ScrW()/2 - (JHUD.Trainer.Width/2 - JHUD.Trainer.CornerSize) + barOffset, ScrH()/2 - JHUD.Trainer.Height/2 + JHUD.Trainer.HeightOffset + JHUD.Trainer.CornerSize, JHUD.Trainer.DynamicBarWidth, JHUD.Trainer.Height - JHUD.Trainer.CornerSize*2)
        draw.SimpleText("100%", "JHUDTrainer", ScrW() / 2, (ScrH() / 2) + JHUD.Trainer.HeightOffset + JHUD.Trainer.Height, JHUD.Trainer.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local Data = JHUD.DisplayData
    if #JHUD.DisplayData.Jumps <= 0 then
        Data = BackupData
    else
        Data = JHUD.DisplayData
    end
    local currVel = Data.Jumps[#Data.Jumps] or 0

    -- JHud
    if JHUD.HUD.Enabled == true then
        local color = Color(200, 0, 0, 130)
        local color2 = Color(235, 49, 46, 100)
        
        if currVel > 0 then
            if currVel >= 276 then
                color2 = Color(74, 252, 248, 120)
            elseif currVel > 274 then
                color2 = Color(39, 255, 37, 110)
            elseif currVel > 270 then
                color2 = Color(252, 208, 141, 100)
            end
        end

        
        if Data.Gain > 0 then 
            if Data.Gain >= 0.8 then 
                color = Color(0, 160, 200, 130)
            elseif Data.Gain > 0.7 and Data.Gain < 0.8 then 
                color = Color(0, 200, 0, 130)
            elseif Data.Gain > 0.6 and Data.Gain < 0.7 then 
                color = Color(220, 150, 0, 130)
            end
	    end

        if (JHUD.Data.LastUpdate + 2) < CurTime() then 
            fading = fading + 0.5
            color.a = math.Clamp(color.a - fading, 0, 255)
            color2.a = color.a
        else 
            fading = 0
        end
        
        local function GetJSS()
            local jss = math.Round(Data.JSS * 100, 0)
            return " (" .. tostring(math.Clamp(jss, 0, 99)) .. " ".. (jss >= 101 and "▲" or (jss <= 99 and "▼" or "✓")) .. ")"
        end

        if (#Data.Jumps >= 1 and #Data.Jumps <= 6) or #Data.Jumps % 6 == 0 then
            draw.SimpleText(string.format("%d: %.f%s", #Data.Jumps, currVel, ((#Data.Jumps > 1 and #Data.Jumps <= 6 or #Data.Jumps % 6 == 0) and GetJSS() or "") ), "JHUDMain", ScrW() / 2, (ScrH() / 2) - 40, color2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
        else
            draw.SimpleText(tostring(math.Round(Data.Gain*100, 2)) .. "% " .. GetJSS(), "JHUDMain", ScrW() / 2, (ScrH() / 2) - 40, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
        end
    end

    BackupData = table.Copy(Data)
    surface.SetDrawColor(oColor)
end )


local function GetSpeedCap(st)
	-- Legit, Easy Scroll, Jump pack or Stamina
	if st == 6 or st == 7 or st == 16 then return 32.4 end
	-- Swift, Unreal, Crazy or Extreme
	if st == 21 or st == 10 or st == 12 or st == 43 then return 50 end
	if st == 24 then return 420 end -- MLG
	if st == 30 then return 1000 end -- Cancer
	return 32.8 -- Other styles
end

hook.Add( "SetupMove", "JHud:SetupMove", function( ply, data, cmd )
    if !ply:IsValid() then return end
	if ply:IsBot() then return end 
	if ply:GetObserverMode() > 0 then return end

    if LocalVelocity() < 100 then return end

    local aim = data:GetMoveAngles()
	local fm, sm = data:GetForwardSpeed(), data:GetSideSpeed()

    local maxvel = GetSpeedCap(ply.Style)
    local fmove = data:GetForwardSpeed()
    local smove = data:GetSideSpeed()
	local aim = data:GetMoveAngles()
	local wishvel = aim:Forward() * fmove + aim:Right() * smove
	
	local wishspd = math.Clamp(wishvel:Length(), 0, maxvel)
	
	local wishdir = wishvel:GetNormal()
	local current = data:GetVelocity():Dot(wishdir)

    /*if current <= 30 then
		local gain = ((wishspd - math.abs(current)) / wishspd)
        if gain > 0 then
		    table.insert(JHUD.Data.Gains, gain)
        end
	end*/

    /*if JHUD.Data.LastTickVel > 0 then
        local maxVel = math.sqrt(math.pow(maxvel,2) + math.pow(LocalVelocity(), 2)) - LocalVelocity()
        local gain = (LocalVelocity() - JHUD.Data.LastTickVel) / maxVel
        table.insert(JHUD.Data.Gains, gain)
    end*/
    JHUD.Data.LastTickVel = LocalVelocity()

    JHUD.Data.AngleFraction = (wishspd - current) / wishspd
    if fm == 0 and sm == 0 then
        JHUD.Data.AngleFraction = 0    
    end
    table.insert(JHUD.Data.JSSTable, JHUD.Data.AngleFraction)
end )

local function PlayerGround( ply, bWater )
    if JHUD.Data.LastUpdate + 0.2 < CurTime() then
        if not JHUD.Data.HoldingSpace then
            ResetData()
        else
            
            table.insert(JHUD.Data.Jumps, LocalVelocity())
            --JHUD.Data.Gain = math.Clamp(TableAverage(JHUD.Data.Gains), 0, 1)
            --table.Empty(JHUD.Data.Gains)

            JHUD.Data.JSS = math.Clamp(TableAverage(JHUD.Data.JSSTable), 0, 2)
            table.Empty(JHUD.Data.JSSTable)

            JHUD.Data.LastUpdate = CurTime()

            if JHUD.WaitingForUpd then
                JHUD.WaitingForUpd = false
                JHUD.DisplayData = table.Copy(JHUD.Data)
            end
        end
    end
end
hook.Add( "OnPlayerHitGround", "JHUD:HitGround", PlayerGround )


local function PlayerKeyPress(ply, key)
    if ply:IsBot() or ply:GetObserverMode() > 0 then return end

	if key == IN_JUMP then
		JHUD.Data.HoldingSpace = true

        -- Initial jump
        if ply:OnGround() then
            ResetData()
            table.insert(JHUD.Data.Jumps, LocalVelocity())
            JHUD.Data.LastUpdate = CurTime()
            if JHUD.WaitingForUpd then
                JHUD.WaitingForUpd = false
                JHUD.DisplayData = table.Copy(JHUD.Data)
            end
        end
	end
end
hook.Add("KeyPress", "JHUD:KeyPress", PlayerKeyPress)

local function PlayerKeyRelease(ply, key)
    if ply:IsBot() or ply:GetObserverMode() > 0 then return end

	if key == IN_JUMP then
		JHUD.Data.HoldingSpace = false
    end
end
hook.Add("KeyRelease", "JHUD:KeyRelease", PlayerKeyRelease)
