local Rows = Def.ActorFrame{}

-- left/right padding from screen edges
local padding = WideScale(12, 28)

-- OptionRow height and width
local row_height = 68
local row_width  = WideScale(582, 784) - (padding * 2)

-- width of OptionRow area to the left that contains the row title
local title_bg_width = 244

-- a row
Rows[#Rows+1] = Def.Quad {
	Name="RowBackgroundQuad",
	InitCommand=function(self)
		self:horizalign(left):x(padding)
		self:setsize(row_width , row_height):diffuse(Alpha(Color.Black,0.5))
	end
}

-- black quad behind the title
Rows[#Rows+1] = Def.Quad {
	Name="TitleBackgroundQuad",
	OnCommand=function(self)
		self:horizalign(left):x(padding)
		self:setsize(title_bg_width, row_height):diffuse(Color.Black)
		self:diffusealpha(0.8)
	end
}

for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
    Rows[#Rows+1] = Def.ActorProxy{
        OnCommand=function(self)
            if self:GetParent():GetParent():GetParent():GetName() == "LuaNoteSkins" then
                if SCREENMAN:GetTopScreen() and GAMESTATE:IsHumanPlayer(pn) then
                    local CurNoteSkin = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin()
                    self:SetTarget(SCREENMAN:GetTopScreen():GetChild("NS"..string.lower(CurNoteSkin)))
                    :x(pn==PLAYER_1 and _screen.cx-30 or _screen.cx+500):zoom(0.9)
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

return Rows