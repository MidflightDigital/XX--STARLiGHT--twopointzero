local main = "project_main.png"

if MonthOfYear() == 3 and DayOfMonth() == 1 then
  main = "project_mainowo.png"
end

return Def.ActorFrame{
  Def.Sprite{
      Texture="XX.png",
      InitCommand=function(s)
        s:xy(280,16)
      end,
  },
  Def.Sprite{
      Texture="starlight.png",
      InitCommand=function(s)
        s:xy(22,60)
      end,
  };
  --[[Def.Sprite{
      Texture="twopointzero.png",
      InitCommand=function(s)
        if Branding() == "ddr_" then
          s:y(126)
        else
          s:y(100)
        end
        s:x(112)
      end,
  };]]
  Def.Sprite{
    Texture=main,
    InitCommand=function(s)
      s:xy(-64,-32)
    end,
  };
}