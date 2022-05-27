local t = Def.ActorFrame{}

for _,pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
    t[#t+1] = Def.ActorProxy{
        OnCommand=function(s)
            if s:GetParent():GetParent():GetParent():GetName() == "LuaNoteSkins" then
                if SCREENMAN:GetTopScreen() then
                    local CurNoteSkin = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin()
					s:SetTarget( SCREENMAN:GetTopScreen():GetChild("NS"..string.lower(CurNoteSkin)) )
					:zoom(0.6):x( pn == PLAYER_1 and 240 or 380 ):zoomx(pn == PLAYER_1 and 0.6 or -0.6)
                end
            end
        end,
        LuaNoteSkinsChangeMessageCommand=function(self,param)
			if self:GetParent():GetParent():GetParent() and self:GetParent():GetParent():GetParent():GetName() == "LuaNoteSkins" then
				if param.pn == pn then
					local name = NOTESKIN:GetNoteSkinNames()[param.choice]
					self:SetTarget( SCREENMAN:GetTopScreen():GetChild("NS"..string.lower(param.choicename)) )
				end
			end
		end,
    }
end

return t