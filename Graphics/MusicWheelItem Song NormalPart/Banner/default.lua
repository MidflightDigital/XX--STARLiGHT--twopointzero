local t = Def.ActorFrame{};
local jk = ...
local SongAttributes = LoadModule "SongAttributes.lua"

t[#t+1] = Def.ActorFrame{
	SetMessageCommand=function(s)
		s:rotationz(-45):zoom(0.95)
	end,
	Def.Sprite{
		Texture=THEME:GetPathG("","_shared/_banner back"),
		InitCommand=function(s) s:zoom(0.7) end,
	},
	Def.Sprite{
		Name="SongCD";
		SetMessageCommand=function(self,params)
			local song = params.Song;
			if song then
				self:Load(jk.GetSongGraphicPath(song,"Banner")):scaletofit(-180,-60,180,60)
			end;
		end;
	};
	Def.ActorFrame{
		InitCommand=function(s) s:y(48) end,
		Def.Sprite{
			Texture="box.png",
			InitCommand=function(s) s:zoom(0.51) end,
		},
		Def.BitmapText{
			Font="_avenir next demi bold/20px";
			SetMessageCommand=function(s,p)
				local song = p.Song
				if song then
					s:settext(song:GetDisplayMainTitle()):diffuse(SongAttributes.GetMenuColor(song)):strokecolor(ColorDarkTone(SongAttributes.GetMenuColor(song)))
				end
				s:maxwidth(300)
			end,
		}
	},
	
};

local factorsx = {-518, 0, 518};
local indexes = {7, 8, 9};
for i = 1,3 do
	t[#t+1] = Def.ActorFrame{
		SetMessageCommand=function(self,params)
			local song = params.Song
			local index = params.DrawIndex
			
			if song then
				if index then
					if index == indexes[i] then
						self:visible(true)
					else
						self:visible(false)
					end;
				end;
			end;
		end;
		Def.Sprite{
			InitCommand=function(s) s:xy(factorsx[i],-416) end,
			SetMessageCommand=function(self,params)
				local song = params.Song
				local index = params.DrawIndex
				
				if song then
					if index then
						if index == indexes[i] then
							self:LoadFromCached("Jacket",jk.GetSongGraphicPath(song,"Jacket"))
							self:setsize(716,716)
							self:cropbottom(0.35):croptop(0.26)
						end;
					end;
				end;
			end;
		};
		loadfile(THEME:GetPathG("MusicWheelItem","Song NormalPart/Banner/diff.lua"))()..{
			InitCommand=function(s) s:xy((factorsx[i]),-330) end,
		};
		Def.Sprite{
			Name="SongLength",
			Texture=THEME:GetPathG("","_shared/SongIcon 2x1"),
			InitCommand=function(s) s:animate(0):zoom(0.75):xy(factorsx[i]-310,-540) end,
			SetMessageCommand=function(s,p)
				local index = p.DrawIndex
				local song = p.Song
				if song then
					if index then
						if index == indexes[i] then
							if song:IsLong() then
								s:setstate(0)
								s:visible(true)
							elseif song:IsMarathon() then
								s:setstate(1)
								s:visible(true)
							else
								s:visible(false)
							end
						else
							s:visible(false)
						end
					end
				else
					s:visible(false)
				end
			end,
		};
	};
end;

return t;
