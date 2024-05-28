Config = {}

Config.Command = 'kidnap'

Config.Locale = 'en'

Config.Translation = {
    ['en'] = {
        ['kidnapping_started'] = 'You kidnapped a Player',
        ['player_not_found'] = 'Player is not online',
        ['player_not_given'] = 'You have to enter a Player Id',
        ['default_ban_reason'] = 'You got permanently banned',
    },
    ['de'] = {
        ['kidnapping_started'] = 'Du hast einen Spieler entführt',
        ['player_not_found'] = 'Spieler ist nicht online',
        ['player_not_given'] = 'Du musst eine Spieler-ID eingeben',
        ['default_ban_reason'] = 'Du wurdest permanent gebannt',
    }
}


function banPlayer(src, reason)
    --ban trigger or export 
    --use this if you got fuckBans (https://github.com/Red-Killer/fuckBans) (not public right now) else you neeed a other bansystem
    --exports["fuckBans"]:ban(src, reason, nil, nil)
    DropPlayer(src, reason)
end
