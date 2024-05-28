local waitingForbans = {} -- src list of players waiting for ban

RegisterCommand(Config.Command, function(source, args, rawCommand)
    local src = source
    local target = args[1]
    local reason = args[2] or Config.Translation[Config.Locale]['default_ban_reason']
    if not target then
        TriggerClientEvent("chat:addMessage", src,
            { args = { "^1SYSTEM", Config.Translation[Config.Locale]['player_not_given'] } })
        return
    end

    if not GetPlayerName(target) then
        TriggerClientEvent("chat:addMessage", src,
            { args = { "^1SYSTEM", Config.Translation[Config.Locale]['player_not_found'] } })
        return
    end

    TriggerClientEvent("kidnap:startAbschiebung", target, src)
    waitingForbans[target] = reason

    TriggerClientEvent("chat:addMessage", src,
        { args = { "^1SYSTEM", Config.Translation[Config.Locale]['kidnapping_started'] } })
end, "admin")

AddEventHandler("playerDropped", function()
    local src = tostring(source)
    if not waitingForbans[src] then return end
    banPlayer(src, waitingForbans[src])
    waitingForbans[src] = nil
end)

RegisterNetEvent("kidnap:endedAbschiebung", function()

    local src = tostring(source)
    if not waitingForbans[src] then return end

    banPlayer(src, waitingForbans[src])
    waitingForbans[src] = nil
end)
