local pn = ({...})[1] --only argument to file
local short_pn = ToEnumShortString(pn)
local env = GAMESTATE:Env()
local charName = ResolveCharacterName(pn)
local style = GAMESTATE:GetCurrentStyle():GetStyleType();

local t = Def.ActorFrame{};

local maskfile =
{
	P1 = THEME:GetPathB("ScreenGameplay", "underlay/Cutin/_Mask_down"),
	P2 = THEME:GetPathB("ScreenGameplay", "underlay/Cutin/_Mask_up")
}
maskfile = maskfile[short_pn]

local versus_y = {
	P1 = -260,
	P2 = 400
}
versus_y = versus_y[short_pn]

if (charName ~= "") then
  	local charComboA = Characters.GetAssetPath(charName, "comboA.png")
  	local charComboB = Characters.GetAssetPath(charName, "comboB.png")
  	local charCombo100 = Characters.GetAssetPath(charName, "combo100.png")
  	local charColor = (Characters.GetConfig(charName)).color
  	local charVer = (Characters.GetConfig(charName)).version

	t[#t+1] = Def.ActorFrame{
		ComboChangedMessageCommand=function(self, params)
			if params.Player ~= pn then return end
			local tapsAndHolds = GAMESTATE:GetCurrentSteps(params.Player):GetRadarValues(params.Player):GetValue('RadarCategory_TapsAndHolds')
			local CurCombo = params.PlayerStageStats:GetCurrentCombo()
			if CurCombo == 0 or CurCombo == params.OldCombo then
    			return
    		elseif CurCombo == math.floor(tapsAndHolds/2) or CurCombo == math.floor(tapsAndHolds*0.9) then
    	  		self:playcommand("Popup", {type='B'})
    		elseif CurCombo % 100 == 0 then
    	  		self:playcommand("Popup", {type='C'})
    		elseif CurCombo == 20 or (CurCombo % 50 == 0) then
    	  		self:playcommand("Popup", {type='A'})
    		end;
  		end;
		Def.Sprite{
		  	Name="Mask",
			InitCommand=function(self)
    	  		self:clearzbuffer(true):zwrite(true):blend('BlendMode_NoEffect');
    	  		if style == "StyleType_TwoPlayersTwoSides" or GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
					self:Load(maskfile);
					if pn == PLAYER_2 then
						self:croptop(0.1)
				  	end
			  	else
				  	self:visible(false);
			  	end
		   	end;
   		};
		loadfile(THEME:GetPathB("ScreenGameplay","underlay/Back.lua"))()..{
			Name="Background",
  			InitCommand=function(self)
    			self:setsize(450,1080):setstate(0):diffusealpha(0):MaskDest();
				if style == "StyleType_TwoPlayersTwoSides" or GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
					if pn == PLAYER_2 then
						self:croptop(0.3)
					else
						self:croptop(0)
					end
				end
  			end;
			PopupCommand=function(self)
				self:finishtweening():setstate(0):linear(0.2):diffusealpha(1)
				:diffuse(unpack(charColor)):sleep(1):linear(0.2):diffusealpha(0);
			end;
		};
		Def.Sprite {
			Name="100 char",
  			InitCommand=function(self)
    			self:MaskDest():diffusealpha(0)
    			if style == "StyleType_TwoPlayersTwoSides" or GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
    				self:y(versus_y)
   				end
    			--this forces StepMania to have these all in memory so gameplay doesn't freeze up
    			self:Load(charComboA)
    			self:Load(charComboB)
    			self:Load(charCombo100)
  			end;
  			PopupCommand=function(self, params)
  				if params.type == 'A' then
  					self:Load(charComboA)
					if charVer <= 2 then
		      			self:setsize(450,1080)
	    			else
	    	 			self:scaletoclipped(450,1080)
	    			end;
  				elseif params.type == 'B' then
  					self:Load(charComboB)
					if charVer <= 2 then
	    	  			self:setsize(450,1080)
	    			else
	    	  			self:scaletoclipped(450,1080)
	    			end;
  				elseif params.type == 'C' then
  					self:Load(charCombo100)
					if charVer <= 2 then
	    	  			self:setsize(450,1080)
	    			else
	   		   			self:scaletoclipped(450,1080)
	    			end;
  				else
  					error("Cutin: unknown Popup type "..tostring(type))
  				end
    			self:finishtweening();

    			if charVer ~= 3 then
    				self:y(44);
				else
  					self:addy(13);
  				end
  				self:sleep(0.1):linear(0.1):diffusealpha(1):linear(1);

  				if charVer ~=3 then
  					self:y(26)
  				else
  					self:addy(-13);
  				end
  				self:linear(0.1):diffusealpha(0);
			end;
		};
		Def.Quad{
			Name="Light",
			InitCommand=function(self) self:MaskDest():diffusetopedge(color("#000000")):diffusebottomedge(unpack(charColor)):diffusealpha(0)
				:blend('BlendMode_Add'):setsize(450,1080)
				if style == "StyleType_TwoPlayersTwoSides" or GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
					self:y(versus_y)
				end
			end;
			PopupCommand=function(self)
				self:finishtweening():sleep(0):linear(0.2):diffusealpha(0.5):sleep(0.8):linear(0.2):diffusealpha(0)
			end;
		};
		Def.ActorFrame {
			InitCommand=function(self)
				self:MaskDest()
				--self:diffuse(CutInColor())
				if style == "StyleType_TwoPlayersTwoSides" or GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
					self:y(versus_y)
    			end;
			end;
			Def.Sprite{
				Texture="_Circles",
				Name="Left 1",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.17):diffusealpha(1):xy(-191.25,202.5)
					:zoomx(1.6):zoomy(4.95):linear(0.4):y(-337.5):diffusealpha(0)
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Right 1",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.17):diffusealpha(1):xy(60*2.25,155*2.25)
					:zoomx(0.95*2.25):zoomy(1.6*2.25):linear(0.4*2.25):y(-10*2.25):diffusealpha(0);
				end;
			};
			Def.Sprite{
				Name="Center2 Right",
				Texture="_Circles",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.33):diffusealpha(1):xy(10*2.25,150*2.25)
					:zoomx(0.8*2.25):zoomy(1.75*2.25):linear(0.4*2.25):y(-30*2.25):diffusealpha(0)
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Center 2 Left",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.33):diffusealpha(1):xy(-40*2.25,210*2.25)
					:zoomx(0.8*2.25):zoomy(1*2.25):linear(0.4*2.25):y(110*2.25):diffusealpha(0)
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Right 3",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.53):diffusealpha(1):xy(70*2.25,120*2.25)
					:zoomx(0.6*2.25):zoomy(2.07*2.25):linear(0.4):y(-120*2.25):diffusealpha(0)
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Left 3 big",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.5):diffusealpha(1):x(-75*2.25,-90*2.25)
					:zoomx(1*2.25):zoomy(4.45*2.25):linear(0.4):y(-320*2.25):diffusealpha(0);
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Left 4",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.63):diffusealpha(1):xy(-75*2.25,85*2.25)
					:zoomx(1.2*2.25):zoomy(2.2*2.25):linear(0.4):y(-150*2.25):diffusealpha(0)
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Right 4 small",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.63):diffusealpha(1):x(40*2.25,185*2.25)
					:zoomx(0.6*2.25):zoomy(1.1*2.25):linear(0.4):y(85*2.25):diffusealpha(0);
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Right 5 big",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.86):diffusealpha(1):xy(70*2.25,20*2.25)
					:zoomx(0.9*2.25):zoomy(3*2.25):linear(0.4):y(-190*2.25):diffusealpha(0)
				end;
			};
			Def.Sprite{
				Texture="_Circles",
				Name="Left 5",
				InitCommand=function(s) s:diffusealpha(0):blend('BlendMode_Add'):valign(0) end,
				PopupCommand=function(self)
					self:finishtweening():sleep(0.86):diffusealpha(1):xy(-30*2.25,150*2.25)
					:zoomx(0.6*2.25):zoomy(1.7*2.25):linear(0.4):y(-25*2.25):diffusealpha(0)
				end;
			};
		};
	};
end;

return t;
