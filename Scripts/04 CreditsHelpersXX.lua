local function Fooled()
	local phrases = {
		"hornswoggled",
		"bamboozled",
		"hoodwinked",
		"swindled",
		"duped",
		"hoaxed",
		"fleeced",
		"shafted",
		"caboodled",
		"beguiled",
		"finagled",
		"two-timed",
		"suckered",
		"flimflammed",
		"tricked",
		"conned",
		"scammed",
		"grifted",
		"diddled",
		"cheated",
		"engineered",
		"decieved",
		"defrauded",
		"managed",
		"had"
	}
	return phrases[math.random(#phrases)]
end

local line_height= 30 -- so that actor logos can use it.

local XXcredits= {
	{
		name= "PROJECT MANAGERS",
		"HypnoticMarten77",
		"NewbStepper/hnkul702",
	},
	{
		name= "STARLiGHT CONCEPT + DESIGN",
		"silverdragon754",
	},
	{
		name= "GRAPHICS + DESIGN",
		"silverdragon754",
		"Inorizushi",
		"black4ever",
		"KowalskiPenguin10897",
		"DDRDAIKENKAI",
		"riskofsoundingnerdy/leeium",
		"HypnoticMarten77",
		"Haley Halcyon",
	},
	{
		name= "CODING + PROGRAMMING",
		"Inorizushi",
		"tertu",
		"",
		{type= "subsection", name= "along with..."},
		"kenP",
		"razorblade",
		"leadbman",
		"Kyzentun",
		"ZTS",
		"Jousway",
		"Lirodon",
		"quietly-turning",
	},
	{
		name= "STEP ARTISTS",
		"HypnoticMarten77",
		"NewbStepper/hnkul702",
		"DDRDAIKENKAI",
		"RIME",
		"KexMiX",
		"PandemoniumX",
		"Talkion",
	},
	{
		name= "SOUND DESIGN",
		"funkyzukin/MiDO",
		"riskofsoundingnerdy/leeium",
		"aidan9030/saiiko2",
		"InklingBear/tykoneko",
		"Dynamite Grizzly",
		"xRGTMx/Drisello",
		"Quickman",
		"Sigrev2",
		"djVERTICAI",
	},
	{
		name="Ending Theme",
		"Red Dolphin",
		"from DDR SuperNOVA Master Mode",
	},
	{
		name= "SPECIAL THANKS",
		"Midflight Digital",
		"silverdragon designs",
		"KONAMI Digital Entertainment",
		"KONAMI Amusement Co Ltd.",
		"Zenius -I- vanisher.com",
		"(#1 Ad-Free Gaming Music Site)",
	},
	{
		name= "THANK YOU FOR PLAYING!",
		"",
	},
}

local kyzentuns_fancy_value= 16

local special_logos= {
	kyzentun= Def.ActorMultiVertex{
		Name= "logo",
		Texture= THEME:GetPathG("CreditsLogo", "kyzentun"),
		OnCommand= function(self)
			self:SetDrawState{Mode= "DrawMode_Quads"}
			kyzentuns_fancy_value= math.random(2, 32)
			self:playcommand("fancy", {state= 0})
			self:queuecommand("normal_state")
		end,
		fancyCommand= function(self, params)
			local verts= {}
			local rlh= line_height - 2
			local sx= rlh * -1
			local sy= rlh * -.5
			local sp= rlh / kyzentuns_fancy_value
			local spt= 1 / kyzentuns_fancy_value
			local c= color("#ffffff")
			for x= 1, kyzentuns_fancy_value do
				local lx= sx + (sp * (x-1))
				local rx= sx + (sp * x)
				local ltx= spt * (x-1)
				local rtx= spt * x
				for y= 1, kyzentuns_fancy_value do
					local ty= sy + (sp * (y-1))
					local by= sy + (sp * y)
					local tty= spt * (y-1)
					local bty= spt * y
					if params.state == 1 then
						ltx= 0
						rtx= 1
						tty= 0
						bty= 1
					end
					verts[#verts+1]= {{lx, ty, 0}, {ltx, tty}, c}
					verts[#verts+1]= {{rx, ty, 0}, {rtx, tty}, c}
					verts[#verts+1]= {{rx, by, 0}, {rtx, bty}, c}
					verts[#verts+1]= {{lx, by, 0}, {ltx, bty}, c}
				end
			end
			self:SetVertices(verts)
		end,
		normal_stateCommand= function(self)
			self:linear(1)
			self:playcommand("fancy", {state= 0})
			self:queuecommand("split_state")
		end,
		split_stateCommand= function(self)
			self:linear(1)
			self:playcommand("fancy", {state= 1})
			self:queuecommand("normal_state")
		end,
	},
	mojang= Def.Actor{
		Name= "logo",
		OnCommand= function(self)
			self:GetParent():GetChild("name"):distort(.25) -- minecraft is broken, -kyz
		end
	},
}

-- Go through the credits and swap in the special logos.
for section in ivalues(XXcredits) do
	for entry in ivalues(section) do
		if type(entry) == "table" and special_logos[entry.logo] then
			entry.logo= special_logos[entry.logo]
		end
	end
end

local function position_logo(self)
	local name= self:GetParent():GetChild("name")
	local name_width= name:GetZoomedWidth()
	local logo_width= self:GetZoomedWidth()
	self:x(0 - (name_width / 2) - 4 - (logo_width / 2))
end

XXCredits= {
	AddSection= function(section, pos, insert_before)
		if not section.name then
			lua.ReportScriptError("A section being added to the credits must have a name field.")
			return
		end
		if #section < 1 then
			lua.ReportScriptError("Adding a blank section to the credits doesn't make sense.")
			return
		end
		if type(pos) == "string" then
			for i, section in ipairs(XXcredits) do
				if section.name == pos then
					pos= i -- insert_after is default behavior
				end
			end
		end
		if pos and type(pos) ~= "number" then
			lua.ReportScriptError("Credits section '" .. tostring(pos) .. " not found, cannot use position to add new section.")
			return
		end
		pos= pos or #XXcredits
		if insert_before then
			pos= pos - 1
		end
		-- table.insert does funny things if you pass an index <= 0
		if pos < 1 then
			lua.ReportScriptError("Cannot add credits section at position " .. tostring(pos) .. ".")
			return
		end
		table.insert(XXcredits, pos, section)
	end,
	AddLineToScroller= function(scroller, text, command)
		if type(scroller) ~= "table" then
			lua.ReportScriptError("scroller passed to AddLineToScroller must be an actor table.")
			return
		end
		local actor_to_insert
		if type(text) == "string" or not text then
			actor_to_insert= Def.ActorFrame{
				Def.BitmapText{
					Font= "_avenirnext lt pro bold/46px",
					Text = text or "";
					OnCommand = command or lineOn;
				}
			}
		elseif type(text) == "table" then
			actor_to_insert= Def.ActorFrame{
				Def.BitmapText{
					Name= "name", Font= "_avenirnext lt pro bold/46px",
					Text = text.name or "",
					InitCommand = command or lineOn,
				},
			}
			if text.logo then
				if type(text.logo) == "string" then
					actor_to_insert[#actor_to_insert+1]= Def.Sprite{
						Name= "logo",
						InitCommand= function(self)
							-- Use LoadBanner to disable the odd dimension warning.
							self:LoadBanner(THEME:GetPathG("CreditsLogo", text.logo))
							-- Scale to slightly less than the line height for padding.
							local yscale= (line_height-2) / self:GetHeight()
							self:zoom(yscale)
							-- Position logo to the left of the name.
							position_logo(self)
						end
					}
				else -- assume logo is an actor
					-- Insert positioning InitCommand.
					text.logo.InitCommand= position_logo
					actor_to_insert[#actor_to_insert+1]= text.logo
				end
			end
		end
		table.insert(scroller, actor_to_insert)
	end,
	Get= function()
		-- Copy the base credits and add the copyright message at the end.
		local ret= DeepCopy(XXcredits)
		ret[#ret+1]= XXCredits.RandomCopyrightMessage()
		return ret
	end,
	RandomCopyrightMessage= function()
		return {
			name= "NOTICE",
			"XX -STARLiGHT- is a fan project and is not for commercial use.",
			"If you paid for it or to play it, you've been " .. Fooled() .. ".",
		}
	end,
	SetLineHeight= function(height)
		if type(height) ~= "number" then
			lua.ReportScriptError("height passed to XXCredits.SetLineHeight must be a number.")
			return
		end
		line_height= height
	end
}
