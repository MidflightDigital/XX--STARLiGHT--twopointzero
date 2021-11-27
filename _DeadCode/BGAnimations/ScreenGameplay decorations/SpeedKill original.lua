
local readBPM = nil;

return Def.Actor{
    DoneLoadingNextSongMessageCommand=function()
        readBPM = CalculateReadBPM(GAMESTATE:GetCurrentSong())
    end,
    CodeMessageCommand=function(s,p)
      local pn = p.PlayerNumber
      local ps = GAMESTATE:GetPlayerState(pn)
      local po = ps:GetPlayerOptions("ModsLevel_Preferred");

      local cmod = po:CMod()
      local xmod = po:XMod()
      local mmod = po:MMod()


    end,
  };