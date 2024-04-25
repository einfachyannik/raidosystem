SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "Funkgerät"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.UseHands = true

SWEP.Author = "einfachyannik"
SWEP.Instructions = "LMB um das Funkgerät ein/aus zu schalten. RMB um den Funkkanal zu ändern"

SWEP.Category = "Radiosystem"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- model
SWEP.ViewModel = "models/radio/c_radio.mdl"
SWEP.WorldModel = "models/radio/w_radio.mdl"
-- /model

SWEP.Primary.ClipSize = -1
 
SWEP.Primary.DefaultClip = -1
 
SWEP.Primary.Automatic = false
 
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1

SWEP.Secondary.DefaultClip = -1

SWEP.Secondary.Automatic = false

SWEP.Secondary.Ammo = "none"

SWEP.channel = nil
SWEP.isOn = false

SWEP.channels = {
    "Foundation",
    "Notfall",
    "MTF",
    "TRT",
    "MTF & TRT",
    "Medic",
    "Managment",
    "Service",
    "CI",
    "Obergrund"
}

SWEP.channelPermissions = {
--  ["Channel"]    = { "Job", "Job", ...},
    ["Foundation"] = { "MTF", "Mediziner", "TRT", "Site Director", },
    ["Notfall"] = { "MTF", "Mediziner", "TRT", "Site Director"},
    ["MTF"] = { "MTF", "Site Director", },
    ["TRT"] = { "TRT", "Site Director", },
    ["MTF & TRT"] = { "MTF", "TRT", "Site Director", },
    ["Medic"] = { "Mediziner", "Site Director", },
    ["Managment"] = { "O5", "Site Director", },
    ["Service"] = { "Koch", "Site Director", },
    ["CI"] = { "Chaos Insurgency", },
    ["Obergrund"] = { "Chaos Insurgency", "Citizen", }
}

SWEP.defaultChannels = {
--  ["Job"] = "Channel",    
    ["MTF"] = "MTF", -- MTF
    ["Mediziner"] = "Medic", -- Mediziner
    ["TRT"] = "TRT", -- TRT
    ["O5"] = "Managment", -- O5 / Site Director etc
    ["Koch"] = "Service", -- Service Kräfte : Koch, Putzkraft, (Techniker)
    ["Chaos Insurgency"] = "CI", -- Chaos Insurgency
    ["Citizen"] = "Obergrund", -- Obergrund / D-Klassen
    ["Site Director"] = "Managment"
}

function SWEP:SwitchChannel()
    local currentIndex = table.KeyFromValue(self.channels, self.channel) or 1
    
    local nextIndex = currentIndex % #self.channels + 1
    while nextIndex ~= currentIndex do
        local nextChannel = self.channels[nextIndex]

        if self:HasAccessToChannel(nextChannel) then
            if not (currentIndex > #self.channels) then

                if not IsFirstTimePredicted() then return end

                self.channel = nextChannel
                self.Owner:ChatPrint("Kanal gewechselt zu: " .. self.channel)
                return
            else

                if not IsFirstTimePredicted() then return end

                self.channel = self.defaultChannels[team.GetName(self.Owner:Team())] or "Foundation"
            end    
        end

        nextIndex = nextIndex % #self.channels + 1
    end

    self.Owner:ChatPrint("Du hast keine Berechtigung für die verfügbaren Kanäle!")
end

function SWEP:HasAccessToChannel(channel)
    local job = team.GetName(self.Owner:Team())
    local allowedJobs = self.channelPermissions[channel]
    if allowedJobs and table.HasValue(allowedJobs, job) then
        return true
    else
        return false
    end
end

hook.Add("OnPlayerChangedJob", "PlayerChangedJob", function(ply, oldJob, newJob)

    self.channel = nil
    
end)

if CLIENT then

    RADIO_EXISTS = true
    function SWEP:Initialize()
        deviceScreen = vgui.Create("DFrame")
        deviceScreen:SetSize( 157, 60 ) -- SetSize( 157, 60 )
        deviceScreen:SetDraggable( false )
        deviceScreen:ShowCloseButton( false )
        deviceScreen:SetTitle("")
        deviceScreen:SetPos( 0, 0 )
        deviceScreen:SetPaintedManually( true )

        surface.CreateFont( "ScreenFont", {
            font = "DS-Digital",
            size = 22,
            weight = 400,
            antialias = true
        })

        textScreen = vgui.Create("DLabel", deviceScreen)
        textScreen:SetText("")
        textScreen:SetFont("ScreenFont")
        textScreen:SizeToContents()
        textScreen:SetWidth(130)
        textScreen:SetWrap( true )
        textScreen:SetTextColor( Color( 255, 255, 255, 255 ) )
        textScreen:Center()

        funkImage = vgui.Create("DImage", deviceScreen)
        funkImage.SizeToContents()
        --funkImage:Dock(RIGHT)
        --funkImage.DockMargin(5, 5, 0, 0)
        funkImage:SetImage("radio/full-battery.png")

        return true

    end

end

function SWEP:Think()
    if not deviceScreen then return end
    deviceScreen.Paint = function()
        if self.isOn then --radio on
            draw.RoundedBox( 8, 0, 0, deviceScreen:GetWide(), deviceScreen:GetTall(), Color(0,255,19) )
        else
            draw.RoundedBox( 8, 0, 0, deviceScreen:GetWide(), deviceScreen:GetTall(), Color(20,20,20)  ) 
        end
    end
end

function SWEP:PostDrawViewModel(vm, wep, ply)
    if IsValid(vm) then
        local BoneIndx = vm:LookupBone("ValveBiped.Bip01_R_Hand")
        local BonePos, BoneAng = vm:GetBonePosition( BoneIndx )
        TextPos = BonePos + BoneAng:Forward( ) * 5.18 + BoneAng:Right( ) * 3.9 + BoneAng:Up( ) * -4.21
        TextAngle = BoneAng
        TextAngle:RotateAroundAxis(TextAngle:Right(), 185)
        TextAngle:RotateAroundAxis(TextAngle:Up(), -2)
        TextAngle:RotateAroundAxis(TextAngle:Forward( ), 95)
        if self.isOn then --radio on
            if self.channel ~= nil then
                textScreen:SetText(self.channel)
            else
                textScreen:SetText("ERROR")
            end    
        else --radio off
            textScreen:SetText(" ")
        end
        cam.Start3D2D(TextPos, TextAngle, 0.015)
            deviceScreen:PaintManual()
        cam.End3D2D()
    end
end

function SWEP:Deploy()
    self:SetHoldType("slam")
    return true
end

function SWEP:PrimaryAttack()

    local job = team.GetName(self.Owner:Team())
    local defaultChannel = self.defaultChannels[job]

    if self.isOn == true then

        self.isOn = false
        self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

        if (CLIENT) then

            if not IsFirstTimePredicted() then return end
            net.Start("radio_off")
            net.SendToServer()

        end
    else

        if defaultChannel then
            self.channel = defaultChannel
        else
            self.channel = "Foundation"
        end

        self.Owner:ChatPrint(defaultChannel)

        self.isOn = true
        self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

        if (CLIENT) then

            if not IsFirstTimePredicted() then return end
            local currentIndex = table.KeyFromValue(self.channels, self.channel) or 1

            net.Start("radio_on")
            net.WriteUInt(currentIndex, 8)
            net.SendToServer()

        end    

    end 

end

function SWEP:SecondaryAttack()
    if (CLIENT) then
        if self.isOn then
            if not IsFirstTimePredicted() then return end
            self:SwitchChannel()
            local currentIndex = table.KeyFromValue(self.channels, self.channel) or 1
            net.Start("radio_switched_channel")
            net.WriteUInt(currentIndex, 8)
            net.SendToServer()
            self:SendWeaponAnim( ACT_VM_IDLE )
        end
    end    
end