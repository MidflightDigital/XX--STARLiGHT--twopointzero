local yspacing = 32
local indexcur = 1
local tempcur = indexcur
local isOpen = false
local allowInput = false
local TEMPChosenOptionMouse = false

local mettable = {
    width = 0,
    height = 0,
    -- TOOD: Remove
    xpos = 0,
    ypos = 0,
    List = {},
    currentitem = 1,
    peritemaction = nil,
    player = nil,
    handler = nil,
    ListHandler = nil,
    __call = function(this, Attr)
        this.width = Attr.Width or 200
        this.height = Attr.Height or 32
        this.xpos = Attr.XPos or 0
        this.ypos = Attr.YPos or 0
        this.List = Attr.List or {}
        this.currentitem = Attr.currentItem or 1
        this.peritemaction = Attr.perItemAction or nil
        this.player = Attr.Player or nil
        return this
    end,
    AllowInput = function(this,state)
        allowInput = state
        MESSAGEMAN:Broadcast("DropdownMenuStateChanged",{IsOpen=state})
    end,
    MoveOption = function(this,offset)
        indexcur = indexcur + offset

        if indexcur > #this.List then indexcur = 1 end
        if indexcur < 1 then indexcur = #this.List end

        this.handler:GetChild("ChildrenList"):playcommand("ShowMenu")
    end,
    CloseMenu = function(this)
        this.ListHandler.pos = 0
        this.ListHandler:playcommand("MoveArea",{loc=0})
        
        isOpen = false
        this:AllowInput(false)
        this.handler:GetChild("ChildrenList"):playcommand("ShowMenu")
    end,
    ConfirmChoice = function(this)
        this.handler:playcommand("ConfirmSelection")
        -- We're done, reset positions!
        this.ListHandler.pos = 0
        this.ListHandler:playcommand("MoveArea",{loc=0})

        isOpen = false
        this:AllowInput(false)
        this.handler:GetChild("ChildrenList"):playcommand("ShowMenu")
    end,
    IsOpen = function(this)
        return isOpen
    end,
    Create = function(this)
        local t = Def.ActorFrame{
            InitCommand=function(self)
                -- If we do have a player being assigned, but does not exist yet, then block input from it,
                -- and wait externally for it to arrive.
                for k,v in pairs( self:GetChildren() ) do
                    v:xy( this.xpos, this.ypos )
                end
                -- self:GetChild("ChildrenList"):playcommand("ShowMenu")
                indexcur = this.currentitem(self, this.List, this.player)
                this.handler = self
            end,
            ConfirmSelectionCommand=function(self,param)
                if not this:IsOpen() then return end
                self:GetChild("ChildrenList"):playcommand("ShowMenu")
                self:GetChild("LabelText"):settext( self:GetChild("ChildrenList"):GetChild(indexcur).itemname )
                if self:GetChild("ChildrenList"):GetChild(indexcur):GetChild("") then
                    self:GetChild("ObjectHolder"):visible(true):SetTarget( self:GetChild("ChildrenList"):GetChild(indexcur):GetChild(""):GetChild("Icon") )
                    self:GetChild("LabelText"):x( this.xpos - this.width*.2 ):maxwidth( this.width*.6 )
                else
                    self:GetChild("ObjectHolder"):visible(false)
                    self:GetChild("LabelText"):x( this.xpos - this.width*.425 ):maxwidth( this.width*.6 )
                end
                if this.peritemaction then
                    this.peritemaction( self:GetChild("ChildrenList"):GetChild(indexcur):GetChild("Click") , this.List, indexcur, this.player)
                end
            end,
        }
        
        local maxypos = yspacing * #this.List
        
        local ListActorFrame = Def.ActorFrame{
            Name="ChildrenList",
            InitCommand=function(self)
                this.ListHandler = self
                self.pos = 0
                for k,v in pairs( this.List ) do
                    self:GetChild(k):y(this.height):diffusealpha( this:IsOpen() and 1 or 0 )
                end
            end,
            ShowMenuCommand=function(self)
                self.pos = #this.List > 20 and yspacing * (indexcur-1) or 0

                local openset = this:IsOpen()
                    
                self:GetParent():GetChild("BG"):stoptweening()
                for k,v in pairs( this.List ) do
                    self:GetChild(k):stoptweening():easeoutquint(0.25)
                    :y( openset and (8 + (yspacing * (k))) or this.height )
                    :diffusealpha( openset and 1 or 0 )
                end
                self:GetParent():GetChild("Click").eatinput = openset
                    
                -- Elements from the scroller itself.
                self:GetChild("BGPlane"):stoptweening():easeoutquint(0.25):zoomy( openset and (maxypos + yspacing) or 0 )
                self:GetChild("BGPlane2"):stoptweening():easeoutquint(0.25):zoomy( openset and (maxypos + yspacing - 8) or 0 )
                self:GetChild("Highlight"):stoptweening():easeoutquint(0.25):diffusealpha( openset and 0.5 or 0 )
                :y( -8 + (yspacing * (indexcur)) )
        
                -- Parent actors from the scroller.
                self:GetParent():GetChild("LabelText"):finishtweening():easeoutquint(0.125):y( this:IsOpen() and (this.ypos-self.pos) or this.ypos )
                self:GetParent():GetChild("ObjectHolder"):finishtweening():easeoutquint(0.125):y( this:IsOpen() and (this.ypos-self.pos) or this.ypos )
                self:GetParent():GetChild("BG"):finishtweening():easeoutquint(0.125):y( this:IsOpen() and (this.ypos-self.pos) or this.ypos )
                self:GetParent():GetChild("Overflow"):finishtweening():easeoutquint(0.125):diffusealpha( this:IsOpen() and 0 or 1 )
                self:playcommand("MoveArea",{ loc =  0 } )
            end,
            MoveAreaCommand=function(self,param)
                if not this:IsOpen() then return end
                if (#this.List < 18 or ((this.ypos + maxypos) < SCREEN_BOTTOM)) then return end
                self.pos = self.pos + param.loc
            
                if self.pos < 0 then
                    self.pos = 0
                end
            
                if self.pos > (maxypos - yspacing) then
                    self.pos = (maxypos - yspacing)
                end
            
                self:hurrytweening(0.75):decelerate(0.05):y( this.ypos-self.pos )
                self:GetParent():GetChild("LabelText"):hurrytweening(0.75):easeoutquint(0.05):y( this.ypos-self.pos )
                self:GetParent():GetChild("ObjectHolder"):hurrytweening(0.75):easeoutquint(0.05):y( this.ypos-self.pos )
            end,
            MouseWheelDownMessageCommand=function(self)
                self:playcommand("MoveArea",{ loc =  -20} )
            end,
            MouseWheelUpMessageCommand=function(self)
                self:playcommand("MoveArea",{ loc =  20} )
            end,
        
            Def.Quad{
                Name="BGPlane",
                OnCommand=function(self)
                    self:zoomto( this.width - 8, 0 ):valign(0):diffuse( GameColor.Custom["MenuButtonBorder"] )
                end
            },
        
            Def.Quad{
                Name="BGPlane2",
                OnCommand=function(self)
                    self:zoomto( this.width - 12, 0 ):y(4):valign(0)
                    :diffuse( ColorDarkTone( GameColor.Custom["MenuButtonGradient"] ) )
                end
            },
        
            Def.Quad{
                Name = "Highlight",
                OnCommand = function(self)
                    self:zoomto( this.width - 12, yspacing ):valign(0)
                    :y( yspacing * (indexcur-1) ):diffusealpha(0)
                end
            }
        }

        -- BEGIN ITEM CREATION
        for k,v in pairs( this.List ) do
            local itemname,itemicon
        
            -- Items can either be a table, or a string. Check those cases.
            local temp = Def.ActorFrame{
                Name = k,
                InitCommand=function(self) self:y( 8 + (yspacing * k) ) end
            }
        
            if type(v) == "table" then
                itemname = v.Name or ""
                itemicon = v.Icon or nil
        
                -- if we do have icon, sanitise it's contents.
                if itemicon then
                    -- If it's not an actortype, it might just be looking to apply a direct texture.
                    if type(itemicon) ~= "table" then
                        itemicon = Def.Sprite{ Texture = itemicon }
                    end
                end
        
                -- Add the main object
                temp[#temp+1] = Def.ActorFrame{
                    (itemicon..{
                        Name = "Icon",
                        OnCommand=function(self)
                            self:zoom(
                                LoadModule("Lua.Resize.lua")(
                                    self:GetZoomedWidth(),
                                    self:GetZoomedHeight(),
                                    this.width,
                                    this.height - (v.Margin or 6)
                                )
                            ):x( -(this.width/2) + 32 )
                        end
                    } or Def.Actor),
                    Def.BitmapText{
                        Name = "Text",
                        Font = "Common Normal",
                        Text = itemname,
                        InitCommand=function(self)
                            self:halign( 0 ):x( -(this.width/2) + 60 ):maxwidth( this.width - 72 )
                        end
                    },
                }
            else
                itemname = v
                -- Add the main object
                temp[#temp+1] = Def.BitmapText{
                    Name = "Text",
                    Font = "Common Normal",
                    Text = itemname,
                    InitCommand=function(self)
                        self:halign( 0 ):x( -(this.width/2) + 16 ):maxwidth( this.width - 30 )
                    end
                }
            end
        
            -- Only the click area needs to be generated here to perform the placement.
            temp[#temp+1] = LoadModule( "UI/UI.ClickArea.lua" ){
                Width = this.width,
                Height = yspacing - 2,
                Action = function(self)
                    if not this:IsOpen() then return end
                    TEMPChosenOptionMouse = true
                    indexcur = k
                    this:ConfirmChoice()
                end
            } .. { Name="Click" }
        
            temp.OnCommand=function(self) self.itemname = itemname end
        
            ListActorFrame[#ListActorFrame+1] = temp
        
        end
        t[#t+1] = ListActorFrame
        
        t[#t+1] = LoadModule( "UI/UI.ButtonBox.lua" )( this.width, this.height )..{ Name = "BG" }

        t[#t+1] = LoadModule( "UI/UI.ClickArea.lua" ){
            Width = this.width,
            Height = this.height,
            Action = function(self)
                if this:IsOpen() then return end
                if TEMPChosenOptionMouse then
                    TEMPChosenOptionMouse = false
                    return
                end
                isOpen = not isOpen
                this:AllowInput( not allowInput )
                self:GetParent():GetChild("ChildrenList"):playcommand("ShowMenu")
            end,
        } .. { Name="Click" }
        
        t[#t+1] = Def.BitmapText{
            Name = "LabelText",
            Font = "Common Normal",
            OnCommand = function(self)
                self:halign(0):x( this.xpos - this.width*.425 )
                :maxwidth( this.width - self:GetParent():GetChild("Overflow"):GetZoomedWidth() - 6 )
                self:settext(
                    type(this.List[indexcur]) == "table" and this.List[indexcur].Name or this.List[indexcur]
                )
                if self:GetParent():GetChild("ChildrenList"):GetChild(indexcur):GetChild("") then
                    self:x( this.xpos - this.width*.2 ):maxwidth( this.width*.4 )
                end
            end
        }
        
        t[#t+1] = Def.ActorProxy{
            Name = "ObjectHolder",
            OnCommand = function(self)  
                self:x( this.xpos )
                if self:GetParent():GetChild("ChildrenList"):GetChild(indexcur):GetChild("") then
                    self:SetTarget( self:GetParent():GetChild("ChildrenList"):GetChild(indexcur):GetChild(""):GetChild("Icon") )
                end
            end
        }
            
        t[#t+1] = Def.Sprite{
            Name = "Overflow",
            Texture = THEME:GetPathG("MenuIcon","dropdown"),
            OnCommand = function(self)
                self:halign(1):x( this.xpos + this.width*.45 ):zoom(0.25)
            end
        }
            
        return t
    end
}

return setmetatable(mettable,mettable)

--[[
	Copyright 2021-2022 Jose Varela, Project OutFox

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]]