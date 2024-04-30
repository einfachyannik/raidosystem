util.AddNetworkString("radio_switched_channel")
util.AddNetworkString("radio_off")
util.AddNetworkString("radio_on")
resource.AddWorkshop(635535045)

local channels = {
    [1] = "Foundation",
    [2] = "Notfall",
    [3] = "MTF",
    [4] = "TRT",
    [5] = "MTF & TRT",
    [6] = "Medic",
    [7] = "Managment",
    [8] = "Service",
    [9] = "CI",
    [10] = "Obergrund"
}

local radioHear = {}

local function UpdateListeners()
    for _, listener in ipairs(player.GetHumans()) do
        radioHear[listener] = {}
        for _, talker in pairs(player.GetAll()) do
            if not listener.radioOn or not talker.radioOn or listener.radioChannel ~= talker.radioChannel then continue end
            if IsValid(talker:GetActiveWeapon()) and talker:GetActiveWeapon():GetClass() == "zradio" then
                radioHear[listener][talker] = true
            end
        end
    end
end

hook.Add("InitPostEntity", "init", function()
    timer.Create("main", DarkRP.voiceCheckTimeDelay, 0, UpdateListeners)
end)

hook.Add("PlayerCanHearPlayersVoice", "radio", function(listener, talker)
    return radioHear[listener] and radioHear[listener][talker], false
end)

hook.Add("PlayerInitialSpawn", "spawnset", function(ply)
    ply.radioOn = false
    ply.radioCooldown = CurTime() + 0.5
end)

local function ResetRadio(ply)
    ply.radioOn = false
end

hook.Add("PostPlayerDeath", "reset", ResetRadio)
hook.Add("PlayerSpawn", "reset", ResetRadio)

net.Receive("radio_on", function( len, ply )

    local channelIndex = net.ReadInt(8)
    ply.radioOn = true
    ply.radioChannel = channelIndex

end)

net.Receive("radio_off", function( len, ply )

    ply.radioOn = false
    ply.radioChannel = nil

end)

-- Netzwerknachricht zum Wechseln des Kanals empfangen
net.Receive("radio_switched_channel", function(len, ply)
    local channelIndex = net.ReadInt(8)
    ply.radioChannel = channelIndex
end)
