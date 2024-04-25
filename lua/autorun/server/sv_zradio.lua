util.AddNetworkString("radio_switched_channel")
util.AddNetworkString("radio_off")
util.AddNetworkString("radio_on")
resource.AddWorkshop(635535045)

-- Definiere die Kanäle und ihre Indizes
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

-- Initialisiere das Dictionary für das Zuhören
local lradioHear = {}

-- Funktion zum Aktualisieren der Zuhörer
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

-- Initialisierungspost-Entitätshook
hook.Add("InitPostEntity", "zradio_init", function()
    timer.Create("zradio_main", DarkRP.voiceCheckTimeDelay, 0, UpdateListeners)
end)

-- Spieler kann die Stimme anderer Spieler hören Hook
hook.Add("PlayerCanHearPlayersVoice", "zradio", function(listener, talker)
    return lradioHear[listener] and lradioHear[listener][talker], false
end)

-- Spielerinitialspawn-Hook
hook.Add("PlayerInitialSpawn", "zradio_spawnset", function(ply)
    ply.lradioOn = false
    ply.lradioCooldown = CurTime() + 0.5
end)

-- Zurücksetzen des Funkgeräts nach dem Tod
local function ResetRadio(ply)
    ply.lradioOn = false
end

hook.Add("PostPlayerDeath", "zradio_reset", ResetRadio)
hook.Add("PlayerSpawn", "zradio_reset", ResetRadio)

net.Receive("radio_on", function( len, ply )

    local channelIndex = net.ReadInt(8)
    local channelName = radioChannels[channelIndex] --entfernen
    ply.lradioOn = true
    ply.lradioChannel = channelIndex

    DarkRP.notify(ply, 0, 5, "Du hast dich in: '" .. channelName .. "' eingelogt (" .. channelIndex .. ")") --entfernen

end)

net.Receive("radio_off", function( len, ply )

    ply.lradioOn = false
    ply.lradioChannel = nil
    DarkRP.notify(ply, 0, 5, "Du hast dich ausgelogt") --entfernen

end)

-- Netzwerknachricht zum Wechseln des Kanals empfangen
net.Receive("radio_switched_channel", function(len, ply)
    local channelIndex = net.ReadInt(8) -- Annahme: Es gibt 9 Kanäle, also braucht man 4 Bits, um sie zu kodieren
    local channelName = radioChannels[channelIndex]
    if not channelName then
        DarkRP.notify(ply, 1, 5, "Ungültiger Kanal!")
        return
    end
    ply.lradioChannel = channelIndex
    DarkRP.notify(ply, 0, 5, "Kanal geändert zu: '" .. channelName .. "' (" .. channelIndex .. ")")
end)

print("[zradio] SV geladen!")