return Def.Actor{
    OnCommand=function(s)
        if GAMESTATE:IsAnExtraStage() then
            s:sleep(2)
        end
    end
}