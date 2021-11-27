-- xxx: needs editing for flashing
local player = Var "Player"
local curLives = nil
local lastLives = nil
local stream = "hot"

local t = Def.ActorFrame {};

t[#t+1] = Def.ActorFrame{
-- Battery full line
	Def.Sprite{
		Texture=THEME:GetPathB("","ScreenGameplay decorations/lifeframe/stream/" .. stream ),
		InitCommand=function(self)
			self:texcoordvelocity(-0.8,0)
			self:setsize(644,48)
			self:xy(-6,2)
		end;
		BeginCommand=function(s,p)
			local screen = SCREENMAN:GetTopScreen();
			local glifemeter = screen:GetLifeMeter(player);
			if glifemeter:GetTotalLives() == 1 then
				s:Load(THEME:GetPathB("","ScreenGameplay decorations/lifeframe/stream/danger"));
				s:setsize(644,48);
			end
		end,
		LifeChangedMessageCommand=function(self,params)
			if (not params.LostLife) or (not params.Player == player) then
				return;
			end;

			if params.LivesLeft == 1 then
				self:Load(THEME:GetPathB("","ScreenGameplay decorations/lifeframe/stream/danger"));
				self:setsize(644,48);
			else
				self:Load(THEME:GetPathB("","ScreenGameplay decorations/lifeframe/stream/normal"));
				self:setsize(644,48);
			end;
		end;
	};
	-- 4 Battery empty red
	Def.Quad{
		InitCommand=function(self)
			self:diffusetopedge(color("#707171"));
			self:diffusebottomedge(color("#404040"));
			self:halign(1);
			if IsUsingWideScreen() then
				self:x(SCREEN_WIDTH/6);
			else
				self:x(SCREEN_WIDTH/4.5)
			end
			self:y(2)
		end;
		BeginCommand=function(self,params)
			local screen = SCREENMAN:GetTopScreen();
			local glifemeter = screen:GetLifeMeter(player);
			self:setsize((165)*(4-math.min(4,glifemeter:GetTotalLives())), 48);
		end;
		LifeChangedMessageCommand=function(self,params)
			if params.Player ~= player then return end;
			if not params.LostLife then return end;
			self:finishtweening();
			self:linear(0);
			self:diffusetopedge(color("#5d1115"));
			self:diffusebottomedge(color("#f50d0d"));
			self:setsize((165)*(4-math.min(4,params.LivesLeft)), 48);
			self:linear(0.33);
			self:diffusetopedge(color("#707171"));
			self:diffusebottomedge(color("#404040"));
		end;
	};
};
return t;
