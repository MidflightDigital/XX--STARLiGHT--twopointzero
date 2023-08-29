return function( args )
	local player = args.Player

    local t = Def.ActorFrame{
        Name="DiffTab",
        PlayerSwitchedStepMessageCommand=function(self,params)
            if params.Player ~= args.Player then return end
            if not GAMESTATE:IsPlayerEnabled(args.Player) then return end
            if type(params.Song) == "string" then
                -- lua.ReportScriptError("not song")
                self:stoptweening():linear(0.1):diffusealpha(0)
                return
            end

            self:stoptweening():linear(0.1):diffusealpha(1)

            local curSteps = params.Song[params.Index]

            self:playcommand("UpdateDiffs",{Data=params.Song,Index = params.Index})
        end,
        UpdateDiffsCommand=function(self,params,Diff)
            local newdata = params.Data[params.Index]
    
            self:stoptweening()
            if newdata then
                self:GetChild("Block"):diffuse( GameColor.Difficulty[ args.Song:GetOneSteps(Style,newdata) ] ):visible(true)
                self:GetChild("Meter"):settext(newdata:GetMeter()):visible(true)
            else
                self:GetChild("Block"):visible(false)
                self:GetChild("Meter"):visible(false)
            end
    
        end,
        Def.Sprite{
            Name="Block",
            Texture=THEME:GetPathG("","_SelectMusic/Default/Diff.png"),
            InitCommand=function(s) s:rotationz(player==PLAYER_2 and 180 or 0):y(player==PLAYER_1 and -100 or 100)  end,
        };
        Def.BitmapText{
            Name="Meter",
            Font="_avenirnext lt pro bold/25px";
            InitCommand=function(s) s:xy(player==PLAYER_1 and -90 or 90,player==PLAYER_1 and -102 or 102)
            end,
        };
    }
    return t
end