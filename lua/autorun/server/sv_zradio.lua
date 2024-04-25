util.AddNetworkString("radio_switched_channel")
util.AddNetworkString("radio_off")
util.AddNetworkString("radio_on")
resource.AddWorkshop(635535045)

local radioChannels = {
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

local lradioHear = {}

local function UpdateListeners()
    for _, listener in ipairs(player.GetHumans()) do
        lradioHear[listener] = {}
        for _, talker in pairs(player.GetAll()) do
            if not listener.lradioOn or not talker.lradioOn or listener.lradioChannel ~= talker.lradioChannel then continue end
            if IsValid(talker:GetActiveWeapon()) and talker:GetActiveWeapon():GetClass() == "zradio" then
                lradioHear[listener][talker] = true
            end
        end
    end
end

hook.Add("InitPostEntity", "zradio_init", function()
    timer.Create("zradio_main", DarkRP.voiceCheckTimeDelay, 0, UpdateListeners)
end)

hook.Add("PlayerCanHearPlayersVoice", "zradio", function(listener, talker)
    return lradioHear[listener] and lradioHear[listener][talker], false
end)

hook.Add("PlayerInitialSpawn", "zradio_spawnset", function(ply)
    ply.lradioOn = false
    ply.lradioCooldown = CurTime() + 0.5
end)

local function ResetRadio(ply)
    ply.lradioOn = false
end

hook.Add("PostPlayerDeath", "zradio_reset", ResetRadio)
hook.Add("PlayerSpawn", "zradio_reset", ResetRadio)

net.Receive("radio_on", function( len, ply )

    local channelIndex = net.ReadInt(8)
    ply.lradioOn = true
    ply.lradioChannel = channelIndex

end)

net.Receive("radio_off", function( len, ply )

    ply.lradioOn = false
    ply.lradioChannel = nil

end)

-- Netzwerknachricht zum Wechseln des Kanals empfangen
net.Receive("radio_switched_channel", function(len, ply)
    local channelIndex = net.ReadInt(8)
    ply.lradioChannel = channelIndex
end)

print("[zradio] SV geladen!")
