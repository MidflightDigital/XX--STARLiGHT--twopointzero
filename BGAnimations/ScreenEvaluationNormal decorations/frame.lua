--[[
pn = Which player's stats to display.
controller = which controller controls the panel
showInstructionsTab = If the fifth tab should also be shown. (It's too much work to replicate DDR 2014 exactly, so it's the fifth tab)
If showInstructionsTab is true, it will start on the instructions tab.

In DDR2014, two panels are loaded and P2 controller
moves the right panel, while P1 controller moves
the left panel.
]]
local pn  = ({...})[1]
local controller = ({...})[2]
local paneState = ({...})[3]
local tabCount = 3

local profileID = GetProfileIDForPlayer(pn)
local pPrefs = ProfilePrefs.Read(profileID)

local t = Def.ActorFrame{
    OnCommand=function(s) s:addy(800):sleep(0.3):linear(0.2):addy(-800) end,
	OffCommand=function(s)
		s:linear(0.2):addy(800)
		ProfilePrefs.Save(profileID)
		ProfilePrefs.SaveAll()
	end,
    --Input handler
    CodeMessageCommand=function(s,p)
        if p.PlayerNumber==controller then
			if p.Name=="Left" then
				if paneState > 0 then
					SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change" ));
					paneState = paneState - 1;
				end;
			elseif p.Name=="Right" then
				if paneState < (tabCount-1) then
					SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change" ));
					paneState = paneState + 1;
				end;
			else
				SCREENMAN:SystemMessage("Unknown button: "..p.Name);
			end;
			if controller == PLAYER_1 then
				pPrefs.evalpane1 = paneState
			else
				pPrefs.evalpane2 = paneState
			end
        end;
    end, 
    Def.Sprite{
        Texture="_box",
    };
	Def.ActorFrame{
		Def.Sprite{
			Name="Left",
			Texture="header arrows 1x3.png",
			InitCommand=function(s)
				s:pause():rotationz(180):xy(-212,-144):setstate(paneState)
				if paneState == 0 then
					s:visible(false)
				else
					s:visible(true)
				end
			end,
			CodeMessageCommand=function(self,params)
				if params.PlayerNumber==controller then
					self:setstate(paneState)
					if paneState == 0 then
						self:visible(false)
					else
						self:visible(true)
					end
				end;
			end;
		};
		Def.Sprite{
			Name="Right",
			Texture="header arrows 1x3.png",
			InitCommand=function(s)
				s:pause():xy(212,-144):setstate(paneState)
				if paneState == 2 then
					s:visible(false)
				else
					s:visible(true)
				end
			end,
			CodeMessageCommand=function(self,params)
				if params.PlayerNumber==controller then
					self:setstate(paneState)
					if paneState == 2 then
						self:visible(false)
					else
						self:visible(true)
					end
				end;
			end;
		};
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/glow/24 eval header",
		InitCommand=function(s) s:y(-150)
			:settext(THEME:GetString("ScreenEvaluation","Box Header"..paneState))
			if paneState == 0 then
				s:DiffuseAndStroke(color("#dff0ff"),color("#00baff"))
			elseif paneState == 1 then
				s:DiffuseAndStroke(color("#dfffe4"),color("#00ff60"))
			elseif paneState == 2 then
				s:DiffuseAndStroke(color("#ffdffc"),color("#ff00d2"))
			end
		end,
		CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				self:settext(THEME:GetString("ScreenEvaluation","Box Header"..paneState))
				if paneState == 0 then
					self:DiffuseAndStroke(color("#dff0ff"),color("#00baff"))
				elseif paneState == 1 then
					self:DiffuseAndStroke(color("#dfffe4"),color("#00ff60"))
				elseif paneState == 2 then
					self:DiffuseAndStroke(color("#ffdffc"),color("#ff00d2"))
				end
			end;
		end;
	};
	Def.ActorFrame{
		--Welcome to ActorFrame hell featuring Sunny.
		InitCommand=function(s) s:y(188) end,
		Def.ActorFrame{
			Name="Results",
			InitCommand=function(s) s:x(-253) end,
			Def.BitmapText{
				Font="_avenirnext lt pro bold/16px",
				Text=THEME:GetString("ScreenEvaluation","Bottom0"),
				InitCommand=function(s) s:strokecolor(Color.Black):maxwidth(300) end,
			},
		};
		Def.ActorFrame{
			Name="Rival",
			Def.BitmapText{
				Font="_avenirnext lt pro bold/16px",
				Text=THEME:GetString("ScreenEvaluation","Bottom1"),
				InitCommand=function(s) s:strokecolor(Color.Black):maxwidth(300) end,
			},
		};
		Def.ActorFrame{
			Name="Calories",
			InitCommand=function(s) s:x(253) end,
			Def.BitmapText{
				Font="_avenirnext lt pro bold/16px",
				Text=THEME:GetString("ScreenEvaluation","Bottom2"),
				InitCommand=function(s) s:strokecolor(Color.Black):maxwidth(300) end,
			},
		};
		Def.ActorFrame{
			InitCommand=function(s)
				s:y(20)
				if paneState == 0 then
					s:x(-253):zoomx(1)
				elseif paneState == 1 then
					s:x(0):zoomx(1.6)
				elseif paneState == 2 then
					s:x(253):zoomx(1.2)
				else
					s:x(0):zoomx(1.6)
				end
			end,
			CodeMessageCommand=function(s,params)
				if params.PlayerNumber==controller then
					if paneState == 0 then
						s:x(-253):zoomx(1)
					elseif paneState == 1 then
						s:x(0):zoomx(1.6)
					elseif paneState == 2 then
						s:x(253):zoomx(1.2)
					else
						s:x(0):zoomx(1.6)
					end
				end;
			end;
			Def.Sprite{
				Texture="bottom bar glow.png",
				InitCommand=function(s)
					if paneState == 0 then
						s:diffuse(color("#00baff"))
					elseif paneState == 1 then
						s:diffuse(color("#00ff60"))
					elseif paneState == 2 then
						s:diffuse(color("#ff00d2"))
					else
						s:diffuse(Color.White)
					end
				end,
				CodeMessageCommand=function(s,params)
					if params.PlayerNumber==controller then
						if paneState == 0 then
							s:diffuse(color("#00baff"))
						elseif paneState == 1 then
							s:diffuse(color("#00ff60"))
						elseif paneState == 2 then
							s:diffuse(color("#ff00d2"))
						else
							s:diffuse(Color.White)
						end
					end;
				end;
			},
			Def.Sprite{
				Texture="bottom bar.png",
				InitCommand=function(s)
					if paneState == 0 then
						s:diffuse(color("#dff0ff"))
					elseif paneState == 1 then
						s:diffuse(color("#dfffe4"))
					elseif paneState == 2 then
						s:diffuse(color("#ffdffc"))
					else
						s:diffuse(Color.White)
					end
				end,
				CodeMessageCommand=function(s,params)
					if params.PlayerNumber==controller then
						if paneState == 0 then
							s:diffuse(color("#dff0ff"))
						elseif paneState == 1 then
							s:diffuse(color("#dfffe4"))
						elseif paneState == 2 then
							s:diffuse(color("#ffdffc"))
						else
							s:diffuse(Color.White)
						end
					end;
				end;
			},
		}
	};
	Def.BitmapText{
		Font="_avenirnext lt pro bold/16px",
		Text=THEME:GetString("ScreenEvaluation","BottomInstruct"),
		InitCommand=function(s) s:y(210) end,
	},
    Def.ActorFrame{
		InitCommand=function(s)
			if paneState == 0 then
				s:diffusealpha(1);
			else
				s:diffusealpha(0);
			end;
		end,
        CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				if paneState == 0 then
					self:diffusealpha(1);
				else
					self:diffusealpha(0);
				end;
			end;
        end;
        loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/stats"))(pn);
    };
    --3rd pane, rankings
	loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/scoresUnified"))(pn)..{
		InitCommand=function(s) 
			s:diffusealpha(0):draworder(3):y(18)
			if paneState == 1 then
				s:diffusealpha(1);
			else
				s:diffusealpha(0);
			end;
		end,
		CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				if paneState == 1 then
					self:diffusealpha(1);
				else
					self:diffusealpha(0);
				end;
			end;
		end;
    };
    --4th pane, calories
	loadfile(THEME:GetPathB("ScreenEvaluationNormal","decorations/kcalP1"))(pn)..{
		InitCommand=function(s)
			s:diffusealpha(0)
			if paneState == 2 then
				s:diffusealpha(1);
			else
				s:diffusealpha(0);
			end;
		end,
		CodeMessageCommand=function(self,params)
			if params.PlayerNumber==controller then
				if paneState == 2 then
					self:diffusealpha(1);
				else
					self:diffusealpha(0);
				end;
			end;
		end;
	};
}

return t;