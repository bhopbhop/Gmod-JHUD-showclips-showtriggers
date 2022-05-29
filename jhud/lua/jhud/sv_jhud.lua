local Commands = {
	["jhud"] =
	{
		"jhud",
		"jhudmenu",
        "trainer",
        "strafetrainer",
	},
}

local function InitTables( ply )
	ply.JHUD = {
		LastTickVel = 0,
		Gains = {},
		LastUpdate = CurTime(),
	}
end

local function TableAverage(tab)
    local final = 0
    for k, v in pairs(tab) do
        final = final + v
    end
    return final / #tab
end

local function GetSpeedCap(st)
	-- Legit, Easy Scroll, Jump pack or Stamina
	if st == 6 or st == 7 or st == 16 then return 32.4 end
	-- Swift, Unreal, Crazy or Extreme
	if st == 21 or st == 10 or st == 12 or st == 43 then return 50 end
	if st == 24 then return 420 end -- MLG
	if st == 30 then return 1000 end -- Cancer
	return 32.8 -- Other styles
end

hook.Add( "SetupMove", "JHud:SetupMoveSV", function( ply, data, cmd )
	if !ply:IsValid() then return end
	if not ply.JHUD then InitTables(ply) end

	if ply:IsBot() then return end
	if ply:GetObserverMode() > 0 then return end

	if not ply:OnGround() and ply:WaterLevel() < 2 and ply:GetMoveType() == MOVETYPE_WALK then
		local mv, vel, absVel, ang = 32.8, Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0), ply:GetAbsVelocity(), cmd:GetViewAngles()

		local fore, side = ang:Forward(), ang:Right()
		fore.z = 0
		side.z = 0
		fore:Normalize()
		side:Normalize()

		local wishvel = Vector()
		wishvel.x = fore.x * vel.x + side.x * vel.y
		wishvel.y = fore.y * vel.x + side.y * vel.y

		local wishdir = wishvel:GetNormal()

		local wishspeed = wishvel:Length()
		local maxSpeed = ply:GetMaxSpeed()
		wishvel:Normalize()

		if wishspeed > maxSpeed and maxSpeed ~= 0 then
			wishspeed = maxSpeed
		end

		-- if some speed is gained
		if wishspeed ~= 0 then
			local wishspd = (wishspeed > mv) and mv or wishspeed
			local currentgain = absVel:Dot(wishdir)
			local gaincoeff = 0.0

			-- if speed isnt clamped
			if currentgain < mv then
				gaincoeff = (wishspd - math.abs(currentgain)) / wishspd
			end

			table.insert(ply.JHUD.Gains, gaincoeff)
		end
	end
	--[[local aim = data:GetMoveAngles()

	local fm, sm = data:GetForwardSpeed(), data:GetSideSpeed()

	local currvel = data:GetVelocity()
	currvel.z = 0
	currvel = currvel:Length()

    local maxvel = GetSpeedCap(ply.Style)
    local fmove = data:GetForwardSpeed()
    local smove = data:GetSideSpeed()
	local aim = data:GetMoveAngles()
	local wishvel = aim:Forward() * fmove + aim:Right() * smove

	local wishspd = math.Clamp(wishvel:Length(), 0, maxvel)

	local wishdir = wishvel:GetNormal()
	local current = data:GetVelocity():Dot(wishdir)

	if ply.JHUD.LastTickVel > 0 then
        local maxVel = math.sqrt(math.pow(maxvel,2) + math.pow(currvel, 2)) - currvel
        local gain = (currvel - ply.JHUD.LastTickVel) / maxVel
        table.insert(ply.JHUD.Gains, gain)
    end

    ply.JHUD.LastTickVel = currvel--]]

end )

util.AddNetworkString("JHUD_Notify")
local function PlayerGround( ply, bWater )
	if not ply.JHUD then InitTables(ply) end

    if ply.JHUD.LastUpdate + 0.2 < CurTime() then
		ply.JHUD.Gain = math.Clamp(TableAverage(ply.JHUD.Gains), 0, 1)
        table.Empty(ply.JHUD.Gains)

		net.Start("JHUD_Notify")
		net.WriteFloat(ply.JHUD.Gain)
		net.Send(ply)
    end
	ply.JHUD.LastUpdate = CurTime()
end
hook.Add( "OnPlayerHitGround", "JHUD:HitGroundSV", PlayerGround )

local function PlayerKeyPress(ply, key)
    if ply:IsBot() or ply:GetObserverMode() > 0 then return end

	if key == IN_JUMP then
		net.Start("JHUD_Notify")
		net.Send(ply)
	end
end
hook.Add("KeyPress", "JHUD:KeyPressSV", PlayerKeyPress)


util.AddNetworkString("JHUD_UpdateSettings")
local function JHUD_UpdateSettings( len, ply )
	ply:SetPData( "jhudh_enabled", net.ReadBool() )
	ply:SetPData( "jhudt_enabled", net.ReadBool() )
	ply:SetPData( "jhudt_dynrectcol", net.ReadBool() )
	ply:SetPData( "jhudt_width", net.ReadUInt(10) )
	ply:SetPData( "jhudt_height", net.ReadUInt(7) )
	ply:SetPData( "jhudt_heightoffset", net.ReadInt(10) )
	ply:SetPData( "jhudt_rectcol", string.ToColor( net.ReadString() ) ) -- weirdly enough, if i don't send string i'll get an error saying "got table instead of color!"
	ply:SetPData( "jhudt_textcol", string.ToColor( net.ReadString() ) )
end
net.Receive("JHUD_UpdateSettings", JHUD_UpdateSettings)

util.AddNetworkString("JHUD_RetrieveSettings")
local function JHUD_RetrieveSettings( ply, openMenu )
	net.Start("JHUD_RetrieveSettings")
	net.WriteBool( openMenu )
	net.WriteBool( tobool( ply:GetPData( "jhudh_enabled" ) ) )
	net.WriteBool( tobool( ply:GetPData( "jhudt_enabled" ) ) )
	net.WriteBool( tobool( ply:GetPData( "jhudt_dynrectcol" ) ) )
	net.WriteUInt( ply:GetPData( "jhudt_width" ) or 600, 10 ) -- Or = default values
	net.WriteUInt( ply:GetPData( "jhudt_height" ) or 70, 7 )
	net.WriteInt( ply:GetPData( "jhudt_heightoffset" ) or 150, 10 )
	net.WriteColor( string.ToColor( ply:GetPData( "jhudt_rectcol" ) or "220 220 220 126" ) )
	net.WriteColor( string.ToColor( ply:GetPData( "jhudt_textcol" ) or "255 255 255 255" ) )
	net.Send( ply )
end

concommand.Add("jhud_menu", function(ply, cmd, args, argStr)
	JHUD_RetrieveSettings( ply, true )
end, nil, "Open JHUD menu")

hook.Add("PlayerSay","JHUD:ToggleCommand",function(ply,txt)
	local Prefix = string.sub(txt,0,1)
	if Prefix == "!" or Prefix == "/" then
		local PlayerCmd = string.lower(string.sub(txt,2))
		for k,_v in pairs(Commands) do
			for _k, v in pairs(_v) do
				if PlayerCmd == v then
					if k == "jhud" then
						ply:ConCommand("jhud_menu")
						return ""
                    end
				end
			end
		end
	end
end)

local function JHUD_PlayerInit( ply )
	JHUD_RetrieveSettings( ply, false )
end

hook.Add("PlayerInitialSpawn", "JHUD:PlayerInit", JHUD_PlayerInit)
