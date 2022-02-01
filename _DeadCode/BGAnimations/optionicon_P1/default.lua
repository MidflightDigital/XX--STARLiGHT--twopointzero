return Def.ActorFrame {
	-- Speed
	Def.ActorFrame{
		OnCommand=function(self)
			self:x(-85)
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'1x') then self:visible(false)
			else self:visible(true)
			end
		end,
		CodeMessageCommand=function(self, params)
			if params.PlayerNumber == PLAYER_1 then
				self:playcommand("Init");
				if params.Name == "SpeedUp" or params.Name == "SpeedDown" then
					self:queuecommand("On")
				end
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("On");
			end;
		end;
		Def.Sprite{
			Texture="non",
		};
		Def.BitmapText{
			Font="_avenirnext lt pro bold/10px",
			OnCommand=function(s,p)
				local speed = nil
				local mode = nil
				local poptions= GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions("ModsLevel_Preferred")
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
	
	--[[Def.Sprite {
		OnCommand=function(self)
			self:x(-85);
			
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'1.5x') and SCREENMAN:GetTopScreen():GetScreenType() == "ScreenType_Gameplay" then
				self:Load(THEME:GetPathB("","optionicon_P1/speed_x1_5_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'2x') then
				self:Load(THEME:GetPathB("","optionicon_P1/speed_x2_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'3x') then
				self:Load(THEME:GetPathB("","optionicon_P1/speed_x3_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'5x') then
				self:Load(THEME:GetPathB("","optionicon_P1/speed_x5_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'8x') then
				self:Load(THEME:GetPathB("","optionicon_P1/speed_x8_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'0.5x') then
				self:Load(THEME:GetPathB("","optionicon_P1/speed_x0_5_P1"));
			end;
		end;
	};]]
	-- Boost
	Def.Sprite {
		InitCommand=function(self)
			self:x(-68);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'boost') then
				self:Load(THEME:GetPathB("","optionicon_P1/boost_on_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'brake') then
				self:Load(THEME:GetPathB("","optionicon_P1/boost_brake_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'wave') then
				self:Load(THEME:GetPathB("","optionicon_P1/boost_wave_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Appearance
	Def.Sprite {
		InitCommand=function(self)
			self:x(-51);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'hidden') then
				self:Load(THEME:GetPathB("","optionicon_P1/appearance_hidden_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'sudden') then
				self:Load(THEME:GetPathB("","optionicon_P1/appearance_sudden_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'stealth') then
				self:Load(THEME:GetPathB("","optionicon_P1/appearance_stealth_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Turn
	Def.Sprite {
		InitCommand=function(self)
			self:x(-34);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'mirror') then
				self:Load(THEME:GetPathB("","optionicon_P1/turn_mirror_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'left') then
				self:Load(THEME:GetPathB("","optionicon_P1/turn_left_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'right') then
				self:Load(THEME:GetPathB("","optionicon_P1/turn_right_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'shuffle') then
				self:Load(THEME:GetPathB("","optionicon_P1/turn_shuffle_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Dark
	Def.Sprite {
		InitCommand=function(self)
			self:x(-17);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'dark') then
				self:Load(THEME:GetPathB("","optionicon_P1/dark_on_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Scroll
	Def.Sprite {
		InitCommand=function(self)
			self:x(0);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'reverse') then
				self:Load(THEME:GetPathB("","optionicon_P1/scroll_reverse_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Arrow
	Def.Sprite {
		InitCommand=function(self)
			self:x(17);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'NORMAL-FLAT')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'CLASSIC-FLAT')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'SOLO-FLAT')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'PS3-FLAT') then
				self:Load(THEME:GetPathB("","optionicon_P1/arrow_flat_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'NORMAL-NOTE')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'CLASSIC-NOTE')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'SOLO-NOTE')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'PS3-NOTE') then
				self:Load(THEME:GetPathB("","optionicon_P1/arrow_note_P1"));
			elseif GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'NORMAL-RAINBOW')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'CLASSIC-RAINBOW')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'SOLO-RAINBOW')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'DDRX-VIVID')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'DDRX-RAINBOW')
			or GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'PS3-RAINBOW') then
				self:Load(THEME:GetPathB("","optionicon_P1/arrow_rainbow_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Cut
	Def.Sprite {
		InitCommand=function(self)
			self:x(34);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'little') then
				self:Load(THEME:GetPathB("","optionicon_P1/cut_on_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Freeze arrow
	Def.Sprite {
		InitCommand=function(self)
			self:x(51);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'noholds') then
				self:Load(THEME:GetPathB("","optionicon_P1/freeze_arrow_off_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Jump
	Def.Sprite {
		InitCommand=function(self)
			self:x(68);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'nojumps') then
				self:Load(THEME:GetPathB("","optionicon_P1/jump_off_P1"));
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
	-- Risky
	Def.Sprite {
		InitCommand=function(self)
			self:x(85);
			if GAMESTATE:PlayerIsUsingModifier(PLAYER_1,'battery') 
				and GAMESTATE:GetPlayMode() ~= 'PlayMode_Oni' then			
				self:Load(THEME:GetPathB("","optionicon_P1/Risky"));			
			end;
		end;
		PlayerJoinedMessageCommand=function(self, params)
			if params.Player == PLAYER_1 then
				self:playcommand("Init");
			end;
		end;
	};
};
