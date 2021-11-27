-- To add a section to the credits, use the following:
-- local theme_credits= {
-- 	name= "Theme Credits", -- the name of your section
-- 	"Me", -- The people you want to list in your section.
-- 	"Myself",
-- 	"My other self",
--  {logo= "pro_dude", name= "Pro self"}, -- Someone who has a logo image.
--     -- This logo image would be "Graphics/CreditsLogo pro_dude.png".
-- }
-- StepManiaCredits.AddSection(theme_credits)
--
-- If you want to add your section after an existing section, use the following:
-- StepManiaCredits.AddSection(theme_credits, 7)
--
-- Or position can be the name of a section to insert after:
-- StepManiaCredits.AddSection(theme_credits, "Special Thanks")
--
-- Or if you want to add your section before a section:
-- StepManiaCredits.AddSection(theme_credits, "Special Thanks", true)

-- StepManiaCredits is defined in _fallback/Scripts/04 CreditsHelpers.lua.

local line_on=function(s) s:zoom(1):strokecolor(Color.Black) end
local section_on=function(s) s:zoom(2):strokecolor(Color.Black) end
local subsection_on = function(s) s:zoom(1):strokecolor(Color.Black) end
local item_padding_start = 4;
local line_height= 60
-- Tell the credits table the line height so it can use it for logo sizing.
XXCredits.SetLineHeight(line_height)

local creditScroller = Def.ActorScroller {
	SecondsPerItem = 0.5;
	NumItemsToDraw = 40;
	TransformFunction = function( self, offset, itemIndex, numItems)
		self:y(line_height*offset)
	end;
	OnCommand = function(s) s:scrollwithpadding(item_padding_start,15) end,
}

-- Add sections with padding.
for section in ivalues(XXCredits.Get()) do
	StepManiaCredits.AddLineToScroller(creditScroller, section.name, section_on)
	for name in ivalues(section) do
		if name.type == "subsection" then
			XXCredits.AddLineToScroller(creditScroller, name, subsection_on)
		else
			XXCredits.AddLineToScroller(creditScroller, name, line_on)
		end
	end
	XXCredits.AddLineToScroller(creditScroller)
	XXCredits.AddLineToScroller(creditScroller)
end

creditScroller.BeginCommand=function(self)
	SCREENMAN:GetTopScreen():PostScreenMessage( 'SM_MenuTimer', (creditScroller.SecondsPerItem * (#creditScroller + item_padding_start) + 10) );
end;

return Def.ActorFrame{
  LoadActor("movie.mp4")..{
    InitCommand=function(s) s:FullScreen() end,
  };
  creditScroller..{
		InitCommand=function(s) s:CenterX():y(SCREEN_BOTTOM-128) end,
	}
}
