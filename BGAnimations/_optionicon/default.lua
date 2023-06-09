local pn = ...
local short = ToEnumShortString(pn)
local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")

return Def.ActorFrame {
	-- Speed
	Def.ActorFrame{
		OnCommand=function(self)
			self:x(-85)
			if poptions:ScrollSpeed() == 1 and poptions:XMod() ~= nil then
				self:visible(false)
			else 
				self:visible(true)
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
				if poptions:MMod() ~= nil then
					speed=math.round(poptions:MMod())
					mode="M"
				elseif poptions:CMod() ~= nil then
					speed=math.round(poptions:CMod())
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
			if poptions:Boost() ~= 0 then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/boost_on"));
			elseif poptions:Brake() ~= 0 then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/boost_brake"));
			elseif poptions:Wave() ~= 0 then
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
			local PlayerUID = PROFILEMAN:GetProfile(pn):GetGUID()  
			local MyValue = ReadOrCreateAppearancePlusValueForPlayer(PlayerUID,MyValue);
			self:x(-51);
			if MyValue == "Hidden" then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_hidden (doubleres).png"));
			elseif MyValue == "Hidden+" then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_hiddenplus (doubleres).png"));
			elseif MyValue == "Sudden" then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_sudden (doubleres).png"));
			elseif MyValue == "Sudden+" then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_hiddenplus (doubleres).png"));
			elseif MyValue == "Stealth" then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_stealth"));
			elseif MyValue == "Hidden+&Sudden+" then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/appearance_hiddensuddenplus (doubleres).png"));
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
			if poptions:Mirror() then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/turn_mirror"));
			elseif poptions:Left() then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/turn_left"));
			elseif poptions:Right() then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/turn_right"));
			elseif poptions:Shuffle() then
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
			if poptions:Dark() ~= 0 then
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
			if poptions:Reverse() == 1 then
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
			if string.find(poptions:NoteSkin(),"flat") then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/arrow_flat"));
			elseif string.find(poptions:NoteSkin(),"note") then
				self:Load(THEME:GetPathB("","_optionicon/"..short.."/arrow_note"));
			elseif string.find(poptions:NoteSkin(),"rainbow") then
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
			if poptions:Little() then
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
			if poptions:NoHolds() then
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
			if poptions:NoJumps() then
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
		Texture=THEME:GetPathB("","_optionicon/"..short.."/Risky"),
		InitCommand=function(self)
			self:x(85):visible(false);
			if poptions:LifeSetting(1)
				and GAMESTATE:GetPlayMode() ~= 'PlayMode_Oni' then			
				self:visible(true)		
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == pn then
				self:playcommand("Init");
			end;
		end;
	};
};
