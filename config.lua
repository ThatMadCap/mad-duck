Config = {}

-- Enable/disable '/quack' command 
Config.EnableCommand = true -- (true/false | default: true)

-- Enable/disable duck footsteps on resource start/player loaded events 
Config.AlwaysStart = true -- (true/false | default: true)

-- Set how far away players can hear other player's duck footsteps
Config.SoundDistance = 15.0 -- (number | default: 15.0)

-- Enable/disable duck footsteps event mode (different approach, faster)
Config.EventMode = true -- (true/false | default: true)

-- Mute original footsteps when duck footsteps are enabled (only works with EventMode = false)
Config.MuteOriginalFootsteps = false -- (true/false | default: false)