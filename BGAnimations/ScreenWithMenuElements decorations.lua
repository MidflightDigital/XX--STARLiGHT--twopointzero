local screen = Var("LoadingScreen")

local t = Def.ActorFrame{}

t[#t+1] = StandardDecorationFromFileOptional("Header","Header");
t[#t+1] = StandardDecorationFromFileOptional("Footer","Footer");
t[#t+1] = StandardDecorationFromFileOptional("Help","Help");

return t
