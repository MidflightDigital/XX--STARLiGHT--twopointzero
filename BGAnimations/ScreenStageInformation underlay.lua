local t = Def.ActorFrame{};

if not GAMESTATE:IsCourseMode() then
local Handle = RageFileUtil.CreateRageFile();
local pass = Handle:Open(THEME:GetCurrentThemeDirectory().."NowPlaying.txt", 2);
local song = GAMESTATE:GetCurrentSong():GetDisplayMainTitle();
local art = GAMESTATE:GetCurrentSong():GetDisplayArtist();
local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
local diffname = diff:GetDifficulty()
local meter = diff:GetMeter()
if pass then
	Handle:Write(art.." - "..song.." - "..THEME:GetString("CustomDifficulty",ToEnumShortString(diffname)).." "..meter);
	Handle:Flush();
end;
Handle:Close();

end;
return t;
