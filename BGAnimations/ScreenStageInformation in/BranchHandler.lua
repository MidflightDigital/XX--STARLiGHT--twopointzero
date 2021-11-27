local t = Def.ActorFrame{};
local song = GetCurrentSong();

for _, pn in pairs(GAMESTATE:GetEnabledPlayers()) do
t[#t+1] = Def.Actor{
  BeginCommand=function(self)
    local song = GAMESTATE:GetCurrentSong()
    if song then
      local stype = GAMESTATE:GetCurrentStyle()
      local steps = GAMESTATE:GetCurrentSteps(pn)
      if song:GetDisplayMainTitle() == "Tohoku EVOLVED" then
        local sel = math.random(1,4)
        local mod = SONGMAN:FindSong("Tohoku EVOLVED (TYPE"..sel..")");
        GAMESTATE:SetCurrentSong(mod)
        GAMESTATE:SetCurrentStyle(stype)
        GAMESTATE:SetCurrentSteps(pn,steps)
     end;
   end;
 end;
};
end;

return t;
