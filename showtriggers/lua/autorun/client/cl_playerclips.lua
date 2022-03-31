-- Dusabled! Replaced by new showclips, in separate addon.

--[[luabsp = include( 'autorun/client/luabsp.lua' )
Clips = Clips or {}
Clips.Enabled = false

do
    local clips_tool_font = "clips_tool_font_"..os.time()
    surface.CreateFont( clips_tool_font, {
        font = "Consolas",
        size = 40,
        weight = 800,
    } )

    local tool_mats_queue = {}
    local function MaterialGenerator()
        for k, data in pairs(tool_mats_queue) do
            local mat = data.mat
            local mat_name = data.mat_name
            local color = data.color
            local text = data.text
            local rt_tex = GetRenderTarget( mat_name, 256, 256, true )
            mat:SetTexture( "$basetexture", rt_tex )

            render.PushRenderTarget( rt_tex )

            render.SetViewPort(0, 0, 256, 256)
            render.OverrideAlphaWriteEnable( true, true )
            cam.Start2D()
                render.Clear( color.r, color.g, color.b, color.a )
                surface.SetFont( clips_tool_font )
                surface.SetTextColor( 255, 255, 255, 255 )
                local txt_w, txt_h = surface.GetTextSize( text )
                surface.SetTextPos( 128-txt_w/2, 128-txt_h/2 )
                surface.DrawText( text )
                
                surface.SetDrawColor( 255,255,255 )
                surface.DrawOutlinedRect( 10, 10, 256-10, 256-10 )
            cam.End2D()

            render.OverrideAlphaWriteEnable( false )
            render.PopRenderTarget()
        end
        tool_mats_queue = {}

        hook.Remove("DrawMonitors", "Clips_MaterialGenerator")
    end



    function Clips.GenerateToolMaterial( mat_name, color, text )
        local mat = CreateMaterial( mat_name, "UnlitGeneric", {["$vertexalpha"] = 1} )
        tool_mats_queue[#tool_mats_queue + 1] = { mat_name=mat_name, color=color, text=text, mat=mat }

        hook.Add("DrawMonitors", "Clips_MaterialGenerator", MaterialGenerator)

        return mat
    end
end
Clips.Material = Clips.GenerateToolMaterial( "clips_playerclip", Color(126, 126, 126,98), "Player Clip" )

function Clips.Renderer()
    render.SetMaterial( Clips.Material )
    Clips.RenderMesh:Draw()
end

function Clips.Enable()
    if not Clips.RenderMesh then 
        local bsp = luabsp.LoadMap( game.GetMap() )
        if bsp then
            Clips.RenderMesh = bsp:GetClipBrushes( true )
        end
    end

    if Clips.RenderMesh then 
        hook.Add("PostDrawOpaqueRenderables", "Clips_Renderer", Clips.Renderer)
    end
end

function Clips.Disable()
    hook.Remove("PostDrawOpaqueRenderables", "Clips_Renderer")
end

concommand.Add("TogglePlayerClips", function()
    -- DISABLED!! Simply replaced by a newer showclips

    if false then
        if( Clips.Enabled ) then
            Clips.Disable()
            Clips.Enabled = false
            LocalPlayer():ChatPrint 'Player Clips Disabled!'
        else
            Clips.Enable()
            Clips.Enabled = true
            LocalPlayer():ChatPrint 'Player Clips Enabled!'
        end
    end
end)]]--