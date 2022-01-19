--[[
StarlightCache
This is a weak table. What that means is that this table isn't counted when
the garbage collector decides whether a given object is still in use or not.
So you can put things in this table without worrying that they won't be freed
when Lua needs more memory, as long as they aren't being used anywhere else.
Note that under certain circumstances (ScreenSelectMusic especially) Lua does
garbage collections pretty frequently, so you shouldn't rely on objects
staying in here very long. The Env table is also a pretty good place to
put objects that you want to live for an entire game, as StepMania will delete
the Env table itself when the GameState is reset. (tertu has verified this.)
WARNING: Don't put a table that contains itself in here under Lua 5.1. Lua 5.2
and later allow it, but this theme has to run on 5.1 still.
--]]
StarlightCache = setmetatable({}, {__mode="v"})

local videoRenderers = split(",",PREFSMAN:GetPreference("VideoRenderers"))
if videoRenderers[1] == "d3d" then
	Warn("Direct3D mode detected. XX -STARLiGHT- does not support Direct3D mode. Use at your own risk.")
end

function GetProfileIDForPlayer(pn)
    if GAMESTATE:IsHumanPlayer(pn) then
        local profile = PROFILEMAN:GetProfile(pn)
        if not PROFILEMAN:IsPersistentProfile(pn) then
            return "!MACHINE"
        end
        if PROFILEMAN:ProfileWasLoadedFromMemoryCard(pn) then
            return (pn=='PlayerNumber_P1') and "!MC0" or "!MC1"
        end
        if GAMESTATE:Env() then
            local pidCache = GetOrCreateChild(GAMESTATE:Env(),"PlayerLocalIDs")
            if pidCache[pn] then
                return pidCache[pn]
            end
            --worst case scenario: we have to search all the local profiles to find it.
            for _, id in pairs(PROFILEMAN:GetLocalProfileIDs()) do
                if PROFILEMAN:GetLocalProfile(id) == profile then
                    pidCache[pn] = id
                    return id
                end
            end
            --apparently this just means we're using the machine profile if this all fails.
            pidCache[pn] = "!MACHINE"
            return "!MACHINE"
        end
    end
    return "!MACHINE"
end