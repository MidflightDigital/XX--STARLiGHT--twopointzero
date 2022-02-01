local pn = ...
local short = ToEnumShortString(pn)

local function CurrentNoteSkin()
	local poptions = GAMESTATE:GetPlayerState(pn):GetPlayerOptionsArray('ModsLevel_Preferred')
	local skins = NOTESKIN:GetNoteSkinNames()
	for i=1,#poptions do
		for j=1,#skins do
			if string.lower(poptions[i]) == string.lower(skins[j]) then
				return skins[j];
			else
				return ""
			end
		end
	end
end


return Def.ActorFrame {
	-- Speed
	Def.ActorFrame{
		OnCommand=function(self)
			self:x(-85)
			if GAMESTATE:PlayerIsUsingModifier(pn,'1x') then self:visible(false)
			else self:visible(true)
			end
		end,
		CodeMessageCommand=function(self, params)
			if params.PlayerNumber == pn then
				self:playcommand("Init");
				if params.Name == "SpeedUp" or params.Name == "SpeedDown" then
					self:queuecommand("On")
				end
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("On");
			end;
		end;
		Def.Sprite{
			Texture=short.."/non",
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/10px",
			OnCommand=function(s,p)
				local speed = nil
				local mode = nil
				local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
				if poptions:MaxScrollBPM() > 0 then
					speed=math.round(poptions:MaxScrollBPM())
					mode="M"
				elseif poptions:TimeSpacing() > 0 then
					speed=math.round(poptions:ScrollBPM())
					mode="C"
				else
					speed=poptions:ScrollSpeed()
					mode="x"
				end
				s:settext(mode..speed)
				s:maxwidth(16):zoom(0.9)
			end,
		}
	};
	-- Boost
	Def.Sprite {
		InitCommand=function(self)
			self:x(-68);
			if GAMESTATE:PlayerIsUsingModifier(pn,'boost') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/boost_on"));
			elseif GAMESTATE:PlayerIsUsingModifier(pn,'brake') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/boost_brake"));
			elseif GAMESTATE:PlayerIsUsingModifier(pn,'wave') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/boost_wave"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Appearance
	Def.Sprite {
		InitCommand=function(self)
			self:x(-51);
			if GAMESTATE:PlayerIsUsingModifier(pn,'hidden') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_hidden"));
			elseif GAMESTATE:PlayerIsUsingModifier(pn,'sudden') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_sudden"));
			elseif GAMESTATE:PlayerIsUsingModifier(pn,'stealth') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_stealth"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Turn
	Def.Sprite {
		InitCommand=function(self)
			self:x(-34);
			if GAMESTATE:PlayerIsUsingModifier(pn,'mirror') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/turn_mirror"));
			elseif GAMESTATE:PlayerIsUsingModifier(pn,'left') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/turn_left"));
			elseif GAMESTATE:PlayerIsUsingModifier(pn,'right') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/turn_right"));
			elseif GAMESTATE:PlayerIsUsingModifier(pn,'shuffle') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/turn_shuffle"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Dark
	Def.Sprite {
		InitCommand=function(self)
			self:x(-17);
			if GAMESTATE:PlayerIsUsingModifier(pn,'dark') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/dark_on"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Scroll
	Def.Sprite {
		InitCommand=function(self)
			self:x(0);
			if GAMESTATE:PlayerIsUsingModifier(pn,'reverse') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/scroll_reverse"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Arrow
	Def.Sprite {
		InitCommand=function(self)
			self:x(17);
			if string.find(CurrentNoteSkin(),"flat") then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/arrow_flat"));
			elseif string.find(CurrentNoteSkin(),"note") then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/arrow_note"));
			elseif string.find(CurrentNoteSkin(),"rainbow") then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/arrow_rainbow"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Cut
	Def.Sprite {
		InitCommand=function(self)
			self:x(34);
			if GAMESTATE:PlayerIsUsingModifier(pn,'little') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/cut_on"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Freeze arrow
	Def.Sprite {
		InitCommand=function(self)
			self:x(51);
			if GAMESTATE:PlayerIsUsingModifier(pn,'noholds') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/freeze_arrow_off"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Jump
	Def.Sprite {
		InitCommand=function(self)
			self:x(68);
			if GAMESTATE:PlayerIsUsingModifier(pn,'nojumps') then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/jump_off"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
	-- Risky
	Def.Sprite {
		InitCommand=function(self)
			self:x(85);
			if GAMESTATE:PlayerIsUsingModifier(pn,'battery') 
				and GAMESTATE:GetPlayMode() ~= 'PlayMode_Oni' then			
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/Risky"));			
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
};
