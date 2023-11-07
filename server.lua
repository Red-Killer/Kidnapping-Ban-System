local waitingForbans = {} -- src list of players waiting for ban

RegisterCommand(Config.Command, function(source, args, rawCommand)
    local src = source
    local target = args[1]
    local reason = args[2] or Config.Translation[Config.Locale]['default_ban_reason']
    if not target then
        TriggerClientEvent("chat:addMessage", src, {args = {"^1SYSTEM", Config.Translation[Config.Locale]['player_not_given']}})
        return
    end

    if not GetPlayerName(target) then
        TriggerClientEvent("chat:addMessage", src, {args = {"^1SYSTEM", Config.Translation[Config.Locale]['player_not_found']}})
        return
    end
    
    TriggerClientEvent("kidnap:startAbschiebung", target, src)
    waitingForbans[src] = {reason = reason}

    TriggerClientEvent("chat:addMessage", src, {args = {"^1SYSTEM", Config.Translation[Config.Locale]['kidnapping_started']}})
end, "admin")

AddEventHandler("playerDropped", function()
    local src = source
    if waitingForbans[src] then
        banPlayer(src, waitingForbans[src].reason)
        waitingForbans[src] = nil
    end
end)

RegisterNetEvent("kidnap:endedAbschiebung", function()
    banPlayer(source, waitingForbans[source].reason)
    waitingForbans[source] = nil
end)