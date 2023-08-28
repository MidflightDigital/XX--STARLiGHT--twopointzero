return function (MenuList, QuadSize, MarginArea, ButtonAreaY, DropdownMT)
    -- Set an initial position to the menu list
    local CurrentChoice = {1, 1}

    -- The amount of menu buttons we need
    local MaxSize = #MenuList

    local InputSystem
    local allowedToMove = true

    -- Useful function for determine a range and limiting it without overflowing
    local function LimitRange(Val, Start, Endv, Min, Max)
        -- Unfortunately, the scale function available does not properly limit the value
        local EndVal = scale(Val, Start, Endv, Min, Max)
        return clamp( EndVal, Min, Max )
    end

    -- Adapted from above, this will allow us to properly scale items horizontally on the screen
    local function WidthScale(Min, Max)
        local EndValue = scale(SCREEN_WIDTH, 960, 1280, Min, Max)
        if EndValue > Max then return Max end
        if EndValue < Min then return Min end
        return EndValue
    end

    -- We can still operate with only left/right/start, so save the preference to remind us of it later
    local ThreeButtonComp = PREFSMAN:GetPreference("ThreeKeyNavigation")

    -- The actor frame responsible for controlling input and logic
    local t = Def.ActorFrame{
        OnCommand=function(self)
            -- We will be using an input callback to detect key presses
            InputSystem = LoadModule("Lua.InputSystem.lua")(self)
            SCREENMAN:GetTopScreen():AddInputCallback(InputSystem)
            GAMESTATE:Reset()

            -- Iterate through all items from the menu list and apply the focus on the current one
            for k,v in pairs(MenuList) do
                for a,w in pairs(v) do
                    self:GetChild("Button"..k..a):playcommand( "LoseFocus" )
                    if (k == CurrentChoice[2] and a == CurrentChoice[1]) then
                        self:GetChild("Button"..k..a):playcommand("GainFocus")
                    end
                end
            end
        end,

        DropdownMenuStateChangedMessageCommand=function(self,params)
            allowedToMove = not params.IsOpen
        end,

        -- Detach our input callback to avoid locking the game out from input in general
        OffCommand=function(self) SCREENMAN:GetTopScreen():RemoveInputCallback(InputSystem) end,

        -- Input time!

        -- A table will be sent with the Move command, which will be added to
        -- the current choice coordinate in order to update the selected item
        MenuLeftCommand=function(self)  self:playcommand("Move", {-1, 0}) end,
        MenuRightCommand=function(self) self:playcommand("Move", {1, 0}) end,
        MenuUpCommand=function(self)    self:playcommand("Move", {0, -1}) end,
        MenuDownCommand=function(self)  self:playcommand("Move", {0, 1}) end,

        BackCommand=function(self)
            if not allowedToMove then
                DropdownMT:CloseMenu()
            end
        end,

        -- When entering, always join a player and grab the name of the next screen to avoid crashes/hangs
        StartCommand=function(self)
            if not allowedToMove then
                -- Dropdown menu has control now.
                DropdownMT:ConfirmChoice()
                return
            end

            SCREENMAN:PlayStartSound()
            GAMESTATE:JoinPlayer( self.pn or PLAYER_1 )
            -- Only apply this when the user selects the Play option.
            if CurrentChoice[2] == 1 and CurrentChoice[1] == 1 then
                GAMESTATE:SetCurrentStyle("single")
                GAMESTATE:SetCurrentPlayMode("regular")
                -- local theSong = SONGMAN:GetRandomSong()
                -- if theSong then
                --     GAMESTATE:SetCurrentSong( theSong )
                --     GAMESTATE:SetCurrentSteps( self.pn or PLAYER_1, theSong:GetStepsByStepsType( "StepsType_Dance_Single" )[1] )
                -- end
            end
            -- Each item on the menu list contains a name and a screen, the latter being used here by [2]
            SCREENMAN:GetTopScreen():SetNextScreenName(MenuList[CurrentChoice[2]][CurrentChoice[1]][2])
            :StartTransitioningScreen("SM_GoToNextScreen")
        end,

        -- The fun part - moving around the items
        MoveCommand=function(self, param)
            if not allowedToMove then
                -- Dropdown menu has control now.
                DropdownMT:MoveOption( param[ ThreeButtonComp and 1 or 2  ] )
                return
            end
            -- lua.ReportScriptError("Move performed")
            local NewChoice = CurrentChoice
            local OldChoice = CurrentChoice

            -- If we only have left and right, moving directly up or down should never happen
            if ThreeButtonComp then
                if param[2] ~= 0 then
                    return
                end
            end

            -- Add the table sent from the message command so that we move the new choice
            NewChoice[1] = NewChoice[1] + param[1]
            NewChoice[2] = NewChoice[2] + param[2]

            -- Limit and loop the list from its vertical limits
            if NewChoice[2] < 1 then NewChoice[2] = #MenuList end
            if NewChoice[2] > #MenuList then NewChoice[2] = 1 end

            -- The same happens here but horizontally
            if NewChoice[1] < 1 then
                -- Compatibility with three-button input
                if ThreeButtonComp then
                    -- We need to loop to the previous/last item on the list, which could be at a different column
                    NewChoice[2] = NewChoice[2] - 1
                    -- If already at the top, then move to the bottom of the list
                    if NewChoice[2] < 1 then
                        NewChoice[2] = #MenuList
                    end
                end

                NewChoice[1] = #MenuList[NewChoice[2]]
            end
            if NewChoice[1] > #MenuList[NewChoice[2]] then
                -- Same compatibility with three-button input
                if ThreeButtonComp then
                    -- The same loop process occurs here but with the next/first item, so we add instead of subtract
                    NewChoice[2] = NewChoice[2] + 1
                    if NewChoice[2] > #MenuList then
                        NewChoice[2] = 1
                    end
                end

                NewChoice[1] = 1
            end

            -- After all is done, finally define the new current choice for all other functions to access.
            CurrentChoice = NewChoice

            -- If an additional value is sent via the message command, sound will not play
            if not param[3] then
                self:GetChild("SoundChange"):play()
            end

            -- With the updated position, iterate through and apply the focus on the current item
            for k,v in pairs(MenuList) do
                for a,w in pairs(v) do
                    self:GetChild("Button"..k..a):playcommand( "LoseFocus" )
                    if (k == CurrentChoice[2] and a == CurrentChoice[1]) then
                        self:GetChild("Button"..k..a):playcommand("GainFocus")
                    end
                end
            end

        end
    }

    -- Sound for moving around
    t[#t+1] = Def.Sound{Name="SoundChange", File=THEME:GetPathS("Common", "Value")}

    -- Dark background for the menu buttons
    t[#t+1] = Def.Quad{
        OnCommand=function(self)
            self:zoomto(SCREEN_WIDTH, QuadSize[2] * #MenuList ):y(ButtonAreaY + (QuadSize[2] / 2) * (#MenuList - 1)):halign(0):diffuse(Alpha(Color.Black, 0.4))
            :cropleft(1):decelerate(0.2):cropleft(0)
        end,
        OffCommand=function(self)
            self:easeinexpo(0.25):zoomy(0):diffusealpha(0):sleep(0.1)
        end
    }

    -- This portion of code is responsible for generating the actors for each button in the list
    for k,v in pairs( MenuList ) do
        local NumItems = #v
        for a,w in pairs( v ) do
            local ButtonActorFrame = Def.ActorFrame{
                Name = "Button"..k..a,
                InitCommand=function(self)
                    self:addx(200):diffusealpha(0):sleep(0.05*k):easeoutexpo(0.5):addx(-200):diffusealpha(1)
                end,
                OffCommand=function(self)
                    self:hurrytweening(0.2)
                    if k == CurrentChoice[2] and a == CurrentChoice[1] then
                        self:sleep(0.2):easeoutquart(0.25):diffusealpha(0)
                    else
                        self:sleep(0.02*a):easeoutquart(0.2):diffusealpha(0)
                    end
                end,
                GainFocusCommand=function(self)
                    self:GetChild("ObjectBox"):stoptweening():easeoutquint(0.5):diffuse(Alpha(Color.White, 1))
                end,
                LoseFocusCommand=function(self)
                    self:GetChild("ObjectBox"):stoptweening():easeoutquint(0.5):diffuse(Alpha(Color.White, 0.5))
                end,
            }

            local IsLowEnough = true
            local ButtonPosFunc = {
                x = function()
                    if IsLowEnough then
                        return LimitRange((a-1) % 3, 0, 2, MarginArea[1], MarginArea[2])
                    end
                    return LimitRange(k, 1, MaxSize, MarginArea[1], MarginArea[2])
                end,
                y = function()
                    if IsLowEnough then
                        return LimitRange(k - 1, 0, k, ButtonAreaY, ButtonAreaY + QuadSize[2] * k)
                    end
                    return ButtonYArea
                end
            }

            local whatKindOfButton = function()
                if w[3] then
                    if k == #MenuList then
                        -- We're at the bottom, the corners should be Bottom.
                        return "BottomButton"
                    end
                    return "CornerButton"
                end
                return "MiddleButton"
            end

            ButtonActorFrame[#ButtonActorFrame+1] = LoadModule("UI/UI.GenerateUIWithButtonAction.lua"){
                UseImage=Def.Sprite{
                    Texture=THEME:GetPathG("Shapes/Title", whatKindOfButton()),
                    InitCommand=function(self)
                        self:zoom(1.4)
                        if w[3] then
                            self:rotationy( 180 * w[3] )
                        end
                        self:diffuse(GameColor.Custom["MenuButtonBorder"])
                        self.size = {self:GetZoomedWidth(), self:GetZoomedHeight()}
                    end
                },
                Width=tonumber(QuadSize[1] - 10),
                Height=tonumber(QuadSize[2] - 6),
                Pos={ButtonPosFunc.x(), ButtonPosFunc.y()},
                Cache = true,
                Action=function(self)
                    if not allowedToMove then
                        allowedToMove = true
                        DropdownMT:CloseMenu()
                        return false
                    end
                    CurrentChoice[1] = a
                    CurrentChoice[2] = k
                    local sc = self:GetParent():GetParent():GetParent()
                    sc:playcommand("Move",{0, 0, 1})
                    sc:playcommand("Start")
                    return true
                end,
                AddActors=Def.ActorFrame{
                    Def.Text{
                        Font=THEME:GetPathF("","IBMPlexSans-Bold.ttf"),
                        Text=ToUpper(THEME:GetString("ScreenTitleMenu", w[1])),
                        Size=40,
                        -- StrokeSize=2,
                        InitCommand=function(self)
                            self:valign(1):y(self:GetParent():GetParent():GetChild("BG"):GetZoomedHeight() * .5 - 24 ):zoom(0.8)
                        end
                    },

                    -- Icons
                    Def.Sprite{
                        Texture=THEME:GetPathG("","TitleMenuIcon/"..w[1]),
                        OnCommand=function(self)
                            self:y( -24 ):zoom(0.25)
                        end
                    }
                }
            }..{ Name="ObjectBox" }

            t[#t+1] = ButtonActorFrame
        end
    end

    return t
end
