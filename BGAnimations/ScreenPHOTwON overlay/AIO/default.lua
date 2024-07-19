local curIndex=1
local oldIndex = curIndex

local BGM = {
    {"Default", "DEFAULT (fz)"},
    {"saiiko", "saiiko"},
    {"vortivask", "DJ Vortivask"},
    {"inori", "Inori"},
    {"RGTM", "RGTM"},
    {"fancy cake", "fancy cake!!"},
    {"leeium", "leeium"},
    {"SN3", "SuperNOVA3"},
    {"Off", "Off"},
};

local Backgrounds;
--SN2 - SN3's backgrounds are disabled outside of dev mode due to various issues.
if SN3Debug then
    Backgrounds = {
      {"Default","DEFAULT"},
      {"OG","STARLiGHT 1.0"},
      {"OLD","STARLiGHT 2011"},
      {"SN1","SuperNOVA"},
      {"SN2", "SuperNOVA2"},
      {"X1", "X"},
      {"X2", "X2"},
      {"SN3","SuperNOVA 3"},
      {"NG2","NG2"},
    };
else
    Backgrounds = {
      {"Default","DEFAULT"},
      {"OG","STARLiGHT 1.0"},
      {"OLD","STARLiGHT 2011"},
      {"SN1","SuperNOVA"},
    };
end

local Wheels

if SN3Debug then
    Wheels = {
      {"Default", "DEFAULT"},
      {"CoverFlow", "COVERFLOW"},
      {"A", "GRID"},
      {"Banner", "4thMIX"},
      {"Jukebox", "JUKEBOX"},
      {"Wheel","WHEEL"},
      {"Solo","SOLO"},
      {"Preview","PREVIEW"}
    };
else
    Wheels = {
      {"Default", "DEFAULT"},
      {"CoverFlow", "COVERFLOW"},
      {"A", "GRID"},
      {"Banner", "4thMIX"},
      {"Jukebox", "JUKEBOX"},
      {"Wheel","WHEEL"},
    };
end

local frames;
if getenv("photwonchoice") == "MenuState_MenuBG" then frames = Backgrounds
elseif getenv("photwonchoice") == "MenuState_Wheel" then frames = Wheels
elseif getenv("photwonchoice") == "MenuState_BGM" then frames = BGM end

local function GetFrame(frames, key)
    for i,v in ipairs(frames) do
      if key == "file" then
        return frames[1]
      elseif key == "name" then
        return frames[2]
      end
    end
end

local function MakeRow(frames, idx)
    return Def.ActorFrame{
        Name="Row"..idx,
        BeginCommand=function(s)
            s:playcommand(idx == curIndex and "GainFocus" or "LoseFocus")
        end,
        MoveScrollerAIOMessageCommand=function(self,param)
            if curIndex == idx then
                s:queuecommand("GainFocus")
            elseif oldIndex == idx then
                s:queuecommand("LoseFocus")
            end
        end,
        Def.Quad{
            InitCommand=function(s) s:setsize(400,260):diffuse(color("0,0,0,0")) end,
            GainFocusCommand=function(s) s:stoptweening():diffusealpha(0.5) end,
            LoseFocusCommand=function(s) s:stoptweening():diffusealpha(0) end,
        };
        Def.Sprite{
            OnCommand=function(s) s:y(20):queuecommand("Set") end,
            SetCommand=function(self)
              self:Load(THEME:GetPathB("","ScreenPHOTwON overlay/"..frames.."/CDs/"..GetFrame(frames, "file")..".png"));
            end;
        };
        Def.ActorFrame{
            InitCommand=function(s) s:y(-94) end,
            Def.Sprite{ Texture="../item.png"},
            Def.BitmapText{
                Font="_avenirnext lt pro bold/20px",
                OnCommand=function(s) s:zoom(0.8):queuecommand("Set") end,
                SetCommand=function(s)
                    local DisplayName = GetFrame(frames, "name")
                    local bgPref = ThemePrefs.Get("MenuMusic")
                    s:settext(DisplayName)
                    if bgPref == GetFrame(frames,"file") then
                        s:diffuse(Color.Green)
                    else
                        s:diffuse(Color.White)
                    end
                end
            }
        }
    }
end

local RowList = {}
for i=1,#frames do
    RowList[#RowList+1] = MakeRow(frames[i],i)
end

local t = Def.ActorFrame{
    Name="AIOMenu",
    InitCommand=function(s) s:xy(_screen.cx+2,_screen.cy+SCREEN_HEIGHT) end,
    MenuStateChangedMessageCommand=function(self,param)
		if param.NewState == "MenuState_AIO" then
			self:playcommand("ShowAIO")
		elseif param.NewState == "MenuState_Main" then
			self:playcommand("HideAIO")
		end;
	end;
    ShowAIOCommand=function(self)
        self:stoptweening():linear(0.2):y(_screen.cy)
    end;
    HideAIOCommand=function(self)
        self:stoptweening():linear(0.2):y(_screen.cy+SCREEN_HEIGHT)
    end;
    Def.Actor{
        Name="MenuBGController";
        PlayerMenuInputMessageCommand=function(self,param)
          oldIndex = curIndex
          if param.MenuState == "MenuState_AIO" then
            if param.Input == "Start" then
              ThemePrefs.Set("MenuMusic",frames[curIndex][1]);
              MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
            elseif param.Input == "Back" then
              MESSAGEMAN:Broadcast("MenuStateChanged",{NewState = "MenuState_Main"});
              SOUND:PlayOnce(THEME:GetPathS("","Codebox/o-close.ogg"))
            elseif param.Input == "Up" or param.Input == "Left" then
              if curIndex == 1 then
                          curIndex = 1
                      else
                          curIndex = curIndex - 1
                MESSAGEMAN:Broadcast("ChangeRow")
                      end
                  elseif param.Input == "Down" or param.Input == "Right" then
                      if curIndex < #RowList then
                          curIndex = curIndex + 1
                MESSAGEMAN:Broadcast("ChangeRow")
                      elseif curIndex <= 2 then
                          curIndex = 2
                      end
            end;
            MESSAGEMAN:Broadcast("MoveScrollerAIO",{ Player = param.PlayerNumber, Input = param.Input});
          end;
        end;
      };
}

return t
