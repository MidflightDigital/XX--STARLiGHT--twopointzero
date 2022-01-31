function ShowTwoPart(self)
	--[[if ThemePrefs.Get("WheelType") == "A" or ThemePrefs.Get("WheelType") == "Default" or ThemePrefs.Get("WheelType") == "Banner" then
		return true
	else
		return false
	end;]]
	return true
end;

function PrevSteps2(self)
	if ThemePrefs.Get("WheelType") ~= "A" then
		return "MenuUp"
	else
		return
	end
end

function NextSteps2(self)
	if ThemePrefs.Get("WheelType") ~= "A" then
		return "MenuDown"
	else
		return
	end
end

function CourseItem(self)
	if getenv("FixStage") == 1 then
		return ""
	else
		if GAMESTATE:GetCurrentStage() == "Stage_1st" or GAMESTATE:GetCurrentStage() == "Stage_Event" or PREFSMAN:GetPreference("SongsPerPlay") == 1 then
			return "Crs"
		else return ""
		end
	end
end

function ListOrPO(self)
	if _VERSION == "Lua 5.3" then
		return true
	else
		return false
	end
end

function SelectMenu(self)
	if _VERSION == "Lua 5.3" then
		return false
	else
		return true
	end
end

--[[
	Since it apparently helps to consolidate the Scripts folder, Wheel.lua has been moved into here.
	-Inori
]]

function curved_wheel_transform(self,offsetFromCenter,_fake1,_fake2)

	local numItems = THEME:GetMetric("MusicWheelWheel","NumWheelItems")
	local curve3D = THEME:GetMetric("MusicWheelWheel", "CirclePercent")*4*math.pi
	local fRotX = scale(offsetFromCenter, -numItems/2,numItems/2, -curve3D/2,curve3D/2)
	local radius = THEME:GetMetric("MusicWheelWheel","Wheel3DRadius")
	local curveX = THEME:GetMetric("MusicWheelWheel","ItemCurveX")
	local spacingY = THEME:GetMetric("MusicWheelWheel","ItemSpacingY")
	self:x( (1-math.cos(offsetFromCenter/math.pi))*72 )
	--self:y( (offsetFromCenter*scale(math.abs(offsetFromCenter), 0,numItems/2, spacingY,spacingY*math.sin(1.151))) )
	self:z( -10*math.abs(offsetFromCenter*2.5) )
	self:rotationx((offsetFromCenter*14) * math.sin(180/math.pi))
	self:y( (offsetFromCenter*scale(math.abs(offsetFromCenter), 0,numItems/2, spacingY,spacingY*math.sin(0.8))) )
	if offsetFromCenter < -0.5 then
		self:addy( -20 );
		self:addx(0)
	elseif offsetFromCenter > 0.5 then
		self:addy( 20 );
		self:addx(0)
	elseif offsetFromCenter >= -0.5 and offsetFromCenter <= 0.5 then
		self:addy( offsetFromCenter*20 );
		self:addx( 40 )
	end
end

function ScrollBarH()
	if ThemePrefs.Get("WheelType") == "A" then
		return SCREEN_HEIGHT/4
	elseif ThemePrefs.Get("WheelType") == "Wheel" then
		return SCREEN_HEIGHT/3
	else
		return 1
	end
end

function ScrollBarOn(s)
	if not GAMESTATE:IsCourseMode() then
		if ThemePrefs.Get("WheelType") == "A" then
			s:diffusealpha(1):xy(450,-140):skewx(0.25):zoomx(1.5)
		elseif ThemePrefs.Get("WheelType") == "Wheel" then
			s:diffusealpha(1):xy(600,-140):zoomx(-1.5):zoomy(1.5):draworder(500)
		else
			s:diffusealpha(0)
		end
	else
		s:diffusealpha(0)
	end
end

function PreviewWheel(self,offsetFromCenter,itemIndex,numItems)
    local spacing = 210*2.25;
	local edgeSpacing = 135*2.25;
    if math.abs(offsetFromCenter) < .5 then
        self:x(offsetFromCenter*(spacing+edgeSpacing*2));
    else
        if offsetFromCenter >= .5 then
            self:x(offsetFromCenter*spacing+edgeSpacing);
        elseif offsetFromCenter <= -.5 then
            self:x(offsetFromCenter*spacing-edgeSpacing);
        end;
            --self:zoom(1);
    end;
end;
